From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH 3/3] [RFC] smc: introduce socket family AF_SMC
Date: Fri, 21 Nov 2014 21:08:04 +0100
Message-ID: <1416600484-55631-4-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1416600484-55631-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: linux-s390@vger.kernel.org, davem@davemloft.net,
	utz.bacher@de.ibm.com, ogerlitz@mellanox.com, monis@mellanox.com,
	fowlerja@us.ibm.com, heiko.carstens@de.ibm.com,
	frank.blaschka@de.ibm.com, ursula.braun@de.ibm.com,
	ubraun@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:60918 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752510AbaKUUIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 15:08:18 -0500
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 21 Nov 2014 20:08:16 -0000
In-Reply-To: <1416600484-55631-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

A connection using SMC-R starts out setting up a connection using the
TCP/IP protocol [2]. Thus an internal smc-managed TCP socket is established,
whose traffic flows across an interface belonging to the same Converged
Ethernet fabric, defined by a so-called "pnet table" [1].

As part of the connection setup, flags indicating the support
for SMC-R will be used to negotiate SMC-R usage. If any of the two parties
involved does not support SMC-R, the connection will fall back to plain TCP/IP
usage. If both parties support SMC-R, the TCP/IP connection will be used to
exchange the necessary connection data for setup of an Infiniband (IB)
connection in the so-called {\em rendezvous handshake}.

The code implements also the link management of the SMC-R protocol forming link
groups for each remote host and provide for
- dynamic addition of further RoCE Host Channel Adapters (HCAs) to form a
  so-called link group
- seamless failover, moving existing connections from a failed HCA
  to the remaining HCAs in a link group
- load balancing of connections across the links in a link group

SMC-R design defines memory areas for data transport through RDMA called
RDMA Memory Buffer (RMB) split up into several RMB Elements (RMBEs) assigned to
single connections. This initial Linux implementation requires real contiguous
storage for these RMBs and uses a separate RMB with just 1 RMBE for every
connection. Its size is derived from:
- a system wide default minimum SMC receive buffer size (tailorable by
  /proc/net/smc/rcvbuf
- if given, the socket specific SETSOCKOPT SO_RCVBUF configuration
- the size of the tcp socket receive buffer determined from the system wide tcp
  socket receive buffer configuration
- the amount of available contiguous storage
In the Linux implementation an equivalent concept exists for the socket send
buffers [1].

The patch provided does not yet cover:
- IPv6 support
- Tracing
- Statistic hooks
These items are on our list of things to do.

References:
[1] SMC-R Overview and Reference Materials:
    http://www-01.ibm.com/software/network/commserver/SMCR/
[2] SMC-R Informational RFC:
    http://datatracker.ietf.org/doc/draft-fox-tcpm-shared-memory-rdma-05/

Prerequiste for proper VLAN handling is this recent patch in
drivers/infiniband/core/verbs.c:
	https://patchwork.kernel.org/patch/5335641/

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/Kconfig        |    1 +
 net/smc/Kconfig    |    9 +
 net/smc/Makefile   |    3 +
 net/smc/af_smc.c   | 2905 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/smc/af_smc.h   |  669 +++++++++++
 net/smc/smc_core.c | 3112 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/smc/smc_llc.c  | 1472 +++++++++++++++++++++++++
 net/smc/smc_llc.h  |  192 ++++
 net/smc/smc_proc.c |  829 ++++++++++++++
 9 files changed, 9192 insertions(+)
 create mode 100644 net/smc/Kconfig
 create mode 100644 net/smc/Makefile
 create mode 100644 net/smc/af_smc.c
 create mode 100644 net/smc/af_smc.h
 create mode 100644 net/smc/smc_core.c
 create mode 100644 net/smc/smc_llc.c
 create mode 100644 net/smc/smc_llc.h
 create mode 100644 net/smc/smc_proc.c

diff --git a/net/Kconfig b/net/Kconfig
index 99815b5..5b42c40 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -51,6 +51,7 @@ source "net/packet/Kconfig"
 source "net/unix/Kconfig"
 source "net/xfrm/Kconfig"
 source "net/iucv/Kconfig"
+source "net/smc/Kconfig"
 
 config INET
 	bool "TCP/IP networking"
diff --git a/net/smc/Kconfig b/net/smc/Kconfig
new file mode 100644
index 0000000..4ae42d5
--- /dev/null
+++ b/net/smc/Kconfig
@@ -0,0 +1,9 @@
+config AFSMC
+	tristate "AF_SMC socket address family"
+	depends on INET && INFINIBAND
+	---help---
+	  SMC_R provides a "sockets over RDMA" solution making use of
+	  RDMA over Converged Ethernet (ROCE) technology.
+	  Socket family AF_SMC implements this solution for Linux.
+
+	  Select this option if you want to run AF_SMC socket applications
diff --git a/net/smc/Makefile b/net/smc/Makefile
new file mode 100644
index 0000000..76017f0
--- /dev/null
+++ b/net/smc/Makefile
@@ -0,0 +1,3 @@
+ccflags-y += -I$(src)
+smc-y := af_smc.o smc_core.o smc_proc.o smc_llc.o
+obj-$(CONFIG_AFSMC)	+= smc.o
diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
new file mode 100644
index 0000000..39bde93
--- /dev/null
+++ b/net/smc/af_smc.c
@@ -0,0 +1,2905 @@
+/*
+ *  Shared Memory Communications over RDMA (SMC-R) and ROCE
+ *
+ *  AF_SMC protocol family socket handler
+ *
+ *  Copyright IBM Corp. 2014
+ *
+ *  Author(s):  Ursula Braun <ursula.braun@de.ibm.com>
+ *              Frank Blaschka <blaschka@linux.vnet.ibm.com>
+ *              Stefan Raspl <raspl@linux.vnet.ibm.com>
+ */
+
+#define KMSG_COMPONENT "af_smc"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/interrupt.h>
+#include <linux/slab.h>
+#include <linux/skbuff.h>
+#include <linux/init.h>
+#include <linux/poll.h>
+#include <linux/socket.h>
+#include <linux/pci.h>
+#include <linux/seq_file.h>
+#include <linux/uaccess.h>
+#include <linux/workqueue.h>
+#include <linux/proc_fs.h>
+#include <linux/types.h>
+#include <net/sock.h>
+#include <net/inet_sock.h>
+#include <net/tcp.h>
+#include <asm/byteorder.h>
+#include <asm/ioctls.h>
+#include <rdma/ib_verbs.h>
+
+#include "af_smc.h"
+#include "smc_llc.h"
+
+#define VERSION "1.0"
+
+static struct proto smc_proto = {
+	.name		= "AF_SMC",
+	.owner		= THIS_MODULE,
+	.obj_size	= sizeof(struct smc_sock),
+};
+
+static struct sock *smc_sock_alloc(struct socket *, int, gfp_t);
+static void smc_tcp_listen_worker(struct work_struct *);
+static int smc_getsockopt_from_tcp(struct smc_sock *, int);
+static struct sock *smc_accept_dequeue(struct sock *, struct socket *);
+
+struct list_head smc_ib_devices;	/* list of smc_ib_devices */
+static spinlock_t smc_ib_dev_lock;	/* protect smc_ib_devices_list */
+struct smc_lgr_list_struct smc_lgr_list;	/* list of link_groups */
+static u8 local_peerid[8] = SMC_LOCAL_PEERID_RESET;	/* unique system
+							 * identifier
+							 */
+u32 smc_ctrl_buf_cnt = 16;		/* # of control buffers per link */
+u32 smc_max_conn_per_lgr = 255;		/* max. # of connections per lgr */
+atomic_t smc_lgr_num = ATOMIC_INIT(0);	/* unique link group number */
+unsigned int smc_def_rcvbuf_size = 65532;	/* def. receive buffer size */
+unsigned int smc_def_sndbuf_size = 65532;	/* def. send buffer size */
+
+atomic_t smc_reconfiguring = ATOMIC_INIT(0);	/* serialize port_add/port_err
+						 * and free_lgr
+						 */
+
+static void smc_link_up(struct smc_link_group *lgr,
+			struct smc_ib_device *smc_ibdev, u8 port_num)
+{
+	struct smc_link *link = NULL;
+	struct smc_roce_defs rocdefs;
+	int i;
+
+	if (list_empty(&lgr->list)) /* link group to be freed */
+		return;
+	/* determine working link */
+	mutex_lock(&lgr->conf_mutex);
+	for (i = 0; i <= SMC_MAX_SYM_LINKS; i++) {
+		if (atomic_read(&lgr->lnk[i].state) == SMC_LINK_UP) {
+			if ((lgr->lgr_type == ASYMMETRIC) &&
+			    (lgr->asymm_link == i))
+				continue;
+			link = &lgr->lnk[i];
+			break;
+		}
+	}
+	mutex_unlock(&lgr->conf_mutex);
+	if (!link || (lgr->lgr_type == SYMMETRIC))
+		return;
+	if (lgr->role == SMC_SERV) {
+		struct llc_add_link_fake_msg *add_llc;
+
+		add_llc = kzalloc(sizeof(*add_llc), GFP_KERNEL);
+		if (add_llc) {
+			add_llc->hd.length = sizeof(struct llc_msg);
+			add_llc->hd.type = LLC_ADD_LINK;
+			add_llc->ibdev = smc_ibdev;
+			add_llc->port_num = port_num;
+			add_llc->hd.flags |= LLC_FLAG_PORT_ADD;
+		}
+	} else {
+		/* invite server to start ADD LINK */
+		rocdefs.ibdev = smc_ibdev;
+		rocdefs.port = port_num;
+		rocdefs.vlan = lgr->vlan;
+		smc_gid_by_dev(&rocdefs);
+		if (lgr->llc_ctl[LLC_SERV].active != LLC_GRP_NONE)
+			wait_event_interruptible_timeout(lgr->llc_waiter,
+				(lgr->llc_ctl[LLC_SERV].active == LLC_GRP_NONE),
+				LLC_WAIT_TIMEO);
+		if (!list_empty(&lgr->list))
+			llc_send_add_link(link, &rocdefs, NULL, LLC_REQ,
+					  LLC_NO_NOTIFY);
+	}
+}
+
+static void smc_port_add_worker(struct work_struct *work)
+{
+	struct smc_ib_device *smc_ibdev =
+				container_of(work, struct smc_ib_device,
+					     port_add_work);
+	struct smc_link_group *lgr;
+	u8 port_num = 0;
+	int i;
+
+	atomic_inc(&smc_reconfiguring);
+	for (i = 0; i < 2; i++) {
+		char pnet[SMC_MAX_PNET_ID_LEN];
+		int rc;
+
+		if (!smc_ibdev->port_add[i])
+			continue;
+		smc_check_port_attr(smc_ibdev, i);
+		port_num = i + 1;
+		memset(pnet, 0, sizeof(pnet));
+		rc = smc_pnet_by_ibdev(port_num, pnet, smc_ibdev);
+		if (rc)
+			continue;
+		list_for_each_entry(lgr, &smc_lgr_list.list, list) {
+			if (strncmp(pnet, lgr->pnet_id, sizeof(pnet)) ||
+			    (lgr->lgr_type == SYMMETRIC))
+				continue;
+			smc_link_up(lgr, smc_ibdev, port_num);
+		}
+		smc_ibdev->port_add[i] = 0;
+	}
+	atomic_dec(&smc_reconfiguring);
+}
+
+void smc_link_down(struct smc_link_group *lgr, int lnk_idx)
+{
+	struct smc_link *link = &lgr->lnk[lnk_idx];
+	struct smc_ib_device *smc_ibdev = link->roce_defs.ibdev;
+	int to_lnk_idx;
+	u8 port_num = link->roce_defs.port;
+
+	to_lnk_idx = smc_switch_conns(lgr, lnk_idx, 1);
+	if (to_lnk_idx < 0) /* no backup link available */
+		return;
+	lgr->lgr_type = SINGLE;
+	if (lgr->role == SMC_SERV) {
+		struct llc_del_link_msg *del_llc;
+
+		del_llc = kzalloc(sizeof(*del_llc), GFP_KERNEL);
+		if (del_llc) {
+			del_llc->hd.length = sizeof(struct llc_msg);
+			del_llc->hd.type = LLC_DEL_LINK;
+			del_llc->link_num = link->link_id;
+			del_llc->reason = htonl(LLC_DEL_LOST_PATH);
+			del_llc->hd.flags |= LLC_FLAG_DEL_ORDERLY;
+			/* try to restart the link */
+			if (!list_empty(&lgr->list) &&
+			    !list_empty(&smc_ibdev->list) &&
+			    smc_port_active(smc_ibdev, port_num)) {
+				mutex_unlock(&lgr->conf_mutex);
+				smc_link_up(lgr, smc_ibdev, port_num);
+				mutex_lock(&lgr->conf_mutex);
+			}
+		}
+	} else {
+		if (lgr->llc_ctl[LLC_SERV].active != LLC_GRP_NONE) {
+			wait_event_interruptible_timeout(lgr->llc_waiter,
+				(lgr->llc_ctl[LLC_SERV].active ==
+							LLC_GRP_NONE),
+				LLC_WAIT_TIMEO);
+		}
+		llc_send_del_link(&lgr->lnk[to_lnk_idx], link,
+				  LLC_FLAG_DEL_ORDERLY,
+				  LLC_DEL_LOST_PATH, LLC_NO_NOTIFY);
+	}
+}
+
+static void smc_port_err_worker(struct work_struct *work)
+{
+	struct smc_ib_device *smc_ibdev =
+		container_of(work, struct smc_ib_device, port_err_work);
+	struct smc_link_group *lgr, *tmp;
+	int i, rc1, rc2;
+	u8 port_num;
+	char pnet1[SMC_MAX_PNET_ID_LEN], pnet2[SMC_MAX_PNET_ID_LEN];
+
+	atomic_inc(&smc_reconfiguring);
+	for (i = 0; i < 2; i++) {
+		if (!smc_ibdev->port_err[i])
+			continue;
+		smc_check_port_attr(smc_ibdev, i);
+		port_num = i + 1;
+		rc1 = smc_pnet_by_ibdev(1, pnet1, smc_ibdev);
+		rc2 = smc_pnet_by_ibdev(2, pnet2, smc_ibdev);
+		smc_ibdev->port_err[i] = 0;
+		if (rc1 && rc2)
+			continue;
+		/* smc_lgr_list lock ? */
+		list_for_each_entry_safe(lgr, tmp, &smc_lgr_list.list, list) {
+			int j;
+
+			if (strncmp(pnet1, lgr->pnet_id, sizeof(pnet1)) &&
+			    strncmp(pnet2, lgr->pnet_id, sizeof(pnet2)))
+				continue;
+			if (lgr->lgr_type == NONE)
+				continue;
+			mutex_lock(&lgr->conf_mutex);
+			for (j = 0; j <= SMC_MAX_SYM_LINKS; j++) {
+				struct smc_link *lnk = &lgr->lnk[j];
+
+				if ((lnk->roce_defs.ibdev == smc_ibdev) &&
+				    (lnk->roce_defs.port == port_num) &&
+				    smc_lnk_downing(&lnk->state))
+					smc_link_down(lgr, j);
+			}
+			mutex_unlock(&lgr->conf_mutex);
+		}
+	}
+	atomic_dec(&smc_reconfiguring);
+}
+
+static void smc_global_event_handler(struct ib_event_handler *handler,
+				     struct ib_event *event)
+{
+	struct smc_ib_device *dev;
+	u8 port_num = event->element.port_num - 1;
+
+	/* irq context! */
+	dev = container_of(handler, struct smc_ib_device, event_handler);
+	switch (event->event) {
+	case IB_EVENT_DEVICE_FATAL:
+		dev->port_err[0] = 1;
+		dev->port_err[1] = 1;
+		schedule_work(&dev->port_err_work);
+		break;
+	case IB_EVENT_PORT_ERR:
+		if (cmpxchg(&dev->port_err[port_num], 0, 1) == 0)
+			schedule_work(&dev->port_err_work);
+		break;
+	case IB_EVENT_PORT_ACTIVE:
+		if (cmpxchg(&dev->port_add[port_num], 0, 1) == 0)
+			schedule_work(&dev->port_add_work);
+	case IB_EVENT_GID_CHANGE:
+	default:
+		break;
+	}
+}
+
+static void smc_ib_add_dev(struct ib_device *dev)
+{
+	struct smc_ib_device *smc_ibdev;
+	struct smc_roce_defs rocdefs;
+
+	if (dev->node_type != RDMA_NODE_IB_CA)
+		return;
+	smc_ibdev = kzalloc(sizeof(*smc_ibdev), GFP_KERNEL);
+	if (!smc_ibdev)
+		return;
+	smc_ibdev->dev = dev;
+	smc_ibdev->roce_cq_send = ib_create_cq(dev, smc_cq_handler_send,
+		smc_cq_event_handler, smc_ibdev, SMC_MAX_CQE, 0);
+	if (IS_ERR(smc_ibdev->roce_cq_send))
+		goto err;
+	smc_ibdev->roce_cq_recv = ib_create_cq(dev, smc_cq_handler_recv,
+		smc_cq_event_handler, smc_ibdev, SMC_MAX_CQE, 0);
+	if (IS_ERR(smc_ibdev->roce_cq_recv))
+		goto err;
+	if (!strncmp(local_peerid, SMC_LOCAL_PEERID_RESET,
+		     sizeof(local_peerid))) {
+		rocdefs.ibdev = smc_ibdev;
+		rocdefs.port = 1;
+		smc_get_ib_mac(&rocdefs);
+		memcpy(&local_peerid[2], &rocdefs.mac, sizeof(rocdefs.mac));
+		get_random_bytes_arch(&local_peerid[0], 2);
+	}
+	spin_lock_bh(&smc_ib_dev_lock);
+	list_add_tail(&smc_ibdev->list, &smc_ib_devices);
+	spin_unlock_bh(&smc_ib_dev_lock);
+	ib_set_client_data(dev, &smc_ib_client, smc_ibdev);
+	smc_check_dev_attr(smc_ibdev);
+	INIT_WORK(&smc_ibdev->port_err_work, smc_port_err_worker);
+	INIT_WORK(&smc_ibdev->port_add_work, smc_port_add_worker);
+	INIT_IB_EVENT_HANDLER(&smc_ibdev->event_handler, dev,
+			      smc_global_event_handler);
+	ib_register_event_handler(&smc_ibdev->event_handler);
+	tasklet_init(&smc_ibdev->recv_tasklet, smc_recv_tasklet_fn,
+		     (unsigned long)smc_ibdev);
+	tasklet_init(&smc_ibdev->send_tasklet, smc_send_tasklet_fn,
+		     (unsigned long)smc_ibdev);
+	return;
+
+err:
+	kfree(smc_ibdev);
+}
+
+static void smc_wait_for_freed_links(struct smc_ib_device *sdev)
+{
+	struct smc_link_group *lgr, *tmp;
+	int i;
+
+	list_for_each_entry_safe(lgr, tmp, &smc_lgr_list.list, list) {
+		for (i = 0; i <= SMC_MAX_SYM_LINKS; i++) {
+			struct smc_link *lnk = &lgr->lnk[i];
+
+			if (lnk->roce_defs.ibdev == sdev)
+				msleep(LLC_WAIT_TIMEO);
+		}
+	}
+}
+
+static void smc_ib_remove_dev(struct ib_device *dev)
+{
+	struct smc_ib_device *smc_ibdev;
+
+	smc_ibdev = ib_get_client_data(dev, &smc_ib_client);
+	ib_unregister_event_handler(&smc_ibdev->event_handler);
+	smc_ibdev->port_add[0] = 0;
+	smc_ibdev->port_add[1] = 0;
+	smc_ibdev->port_err[0] = 1;
+	smc_ibdev->port_err[1] = 1;
+	schedule_work(&smc_ibdev->port_err_work);
+	flush_work(&smc_ibdev->port_err_work);
+	ib_set_client_data(dev, &smc_ib_client, NULL);
+	spin_lock_bh(&smc_ib_dev_lock);
+	list_del_init(&smc_ibdev->list);
+	spin_unlock_bh(&smc_ib_dev_lock);
+	smc_wait_for_freed_links(smc_ibdev);
+	tasklet_kill(&smc_ibdev->recv_tasklet);
+	tasklet_kill(&smc_ibdev->send_tasklet);
+	ib_destroy_cq(smc_ibdev->roce_cq_send);
+	ib_destroy_cq(smc_ibdev->roce_cq_recv);
+	kfree(smc_ibdev);
+}
+
+struct ib_client smc_ib_client = {
+	.name	= "smc_ib",
+	.add	= smc_ib_add_dev,
+	.remove = smc_ib_remove_dev
+};
+
+static void smc_sock_state_change(struct sock *sk)
+{
+	struct socket *sock = sk->sk_socket;
+	struct socket_wq *wq;
+
+/* equal to sock_def_wakeup */
+	if (!sock)
+		return;
+	rcu_read_lock();
+	wq = rcu_dereference(sk->sk_wq);
+	if (wq_has_sleeper(wq))
+		wake_up_interruptible_all(&wq->wait);
+	rcu_read_unlock();
+}
+
+void smc_sock_wake_rx(struct sock *sk)
+{
+	struct socket_wq *wq;
+
+	/* derived from sock_def_readable() */
+	/* Attention: sk_data_ready=smc_sock_wake_rx called in listen_worker */
+	rcu_read_lock();
+	wq = rcu_dereference(sk->sk_wq);
+	if (wq_has_sleeper(wq))
+		wake_up_interruptible_sync_poll(&wq->wait, POLLIN | POLLPRI |
+						POLLRDNORM | POLLRDBAND);
+	if ((sk->sk_shutdown == SHUTDOWN_MASK) ||
+	    (sk->sk_state == SMC_CLOSED))
+		sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_HUP);
+	else
+		sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
+	rcu_read_unlock();
+}
+
+void smc_sock_wake_tx(struct sock *sk)
+{
+	struct smc_sock *smc = smc_sk(sk);
+	struct socket *sock = sk->sk_socket;
+	struct socket_wq *wq;
+
+/* similar to sk_stream_write_space */
+	if (atomic_read(&smc->conn.tx_buf_space) && sock) {
+		clear_bit(SOCK_NOSPACE, &sock->flags);
+		rcu_read_lock();
+		wq = rcu_dereference(sk->sk_wq);
+		if (wq_has_sleeper(wq))
+			wake_up_interruptible_poll(&wq->wait,
+						   POLLOUT | POLLWRNORM |
+						   POLLWRBAND);
+		if (wq && wq->fasync_list && !(sk->sk_shutdown & SEND_SHUTDOWN))
+			sock_wake_async(sock, SOCK_WAKE_SPACE, POLL_OUT);
+		rcu_read_unlock();
+	}
+}
+
+static void smc_sk_release(struct smc_sock *, int);
+static void smc_sock_destruct(struct sock *sk);
+
+static void smc_destruct_non_accepted(struct sock *sk)
+{
+	struct smc_sock *smc = smc_sk(sk);
+	struct smc_connection *conn = &smc->conn;
+	int i;
+
+	sock_hold(sk);
+	lock_sock(sk);
+	smc_sk_release(smc, 0);
+	if (smc->tcpsocket) {
+		sock_release(smc->tcpsocket);
+		smc->tcpsocket = NULL;
+	}
+	release_sock(sk);
+	if (!smc->use_tcp) {
+		for (i = 0;
+		     ((i < 10) &&
+		      (smc_pending_sends(conn) ||
+		      !smc_close_received(smc)));
+		     i++)
+			msleep(SMC_WAIT_PENDING_SENDS_TIMEO);
+	}
+	if (cmpxchg(&smc->sock_put_done, 0, 1) == 0) {
+		sock_set_flag(sk, SOCK_ZAPPED);
+		sock_set_flag(sk, SOCK_DEAD);
+		schedule_work(&smc->release_work);
+	}
+	sock_put(sk);
+}
+
+static void smc_sock_cleanup_listen(struct sock *parent)
+{
+	struct sock *sk;
+
+	/* Close non-accepted connections */
+	while ((sk = smc_accept_dequeue(parent, NULL)))
+		smc_destruct_non_accepted(sk);
+}
+
+static void smc_wait_close(struct smc_sock *smc)
+{
+	struct sock *sk = &smc->sk;
+	DEFINE_WAIT(wait);
+	signed long timeout;
+
+	/* cancel CORK */
+	if (timer_pending(&smc->cork_timer)) {
+		del_timer_sync(&smc->cork_timer);
+		destroy_timer_on_stack(&smc->cork_timer);
+		if (!delayed_work_pending(&smc->write_work))
+			schedule_delayed_work(&smc->write_work, 0);
+	}
+	timeout = sk->sk_lingertime ? sk->sk_lingertime : MAX_SCHEDULE_TIMEOUT;
+	if (smc_prepared_sends(&smc->conn) && !sk->sk_err &&
+	    !(current->flags & PF_EXITING)) {
+		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+		do {
+			if (sk_wait_event(sk, &timeout,
+					  !smc_prepared_sends(&smc->conn)))
+				break;
+		} while (!signal_pending(current) && timeout);
+		clear_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+		finish_wait(sk_sleep(sk), &wait);
+	}
+	timeout = SMC_WAIT_FREE_CTRL_BUF_TIMEO;
+	if (smc_pending_sends(&smc->conn) &&
+	    !(current->flags & PF_EXITING)) {
+		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+		do {
+			if (sk_wait_event(sk, &timeout,
+					  !smc_pending_sends(&smc->conn)))
+				break;
+		} while (!signal_pending(current) && timeout);
+		clear_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+		finish_wait(sk_sleep(sk), &wait);
+	}
+}
+
+static int smc_wait_for_pending_sends(struct smc_sock *smc)
+{
+	struct smc_link *link;
+	u32 i, j;
+	int rc;
+
+	release_sock(&smc->sk);
+	rc = wait_event_interruptible_timeout(smc->destruct_waiter,
+					      !smc_pending_sends(&smc->conn),
+					      SMC_WAIT_PENDING_SENDS_TIMEO);
+	lock_sock(&smc->sk);
+	if ((rc == -ERESTARTSYS) || !rc) { /* interrupted or timeout reached */
+		for (j = 0; j <= SMC_MAX_SYM_LINKS; j++) {
+			link = &smc->conn.lgr->lnk[j];
+			if (!link->lnk_grp)
+				continue;
+			for (i = 0; i < link->send_wr_num; i++)
+				if (link->pending[i].conn == &smc->conn) {
+					link->pending[i].conn = NULL;
+					clear_bit(i, link->pending_bit_mask);
+				}
+		}
+	}
+	return rc;
+}
+
+static void smc_conn_term_abnormal(struct smc_sock *smc, int old_state)
+{
+	struct sock *sk = &smc->sk;
+	struct smc_connection *conn = &smc->conn;
+
+	if (sk->sk_state == SMC_PEERCLW2 ||
+	    sk->sk_state == SMC_PEERFINCLW ||
+	    sk->sk_state == SMC_CLOSED ||
+	    sk->sk_state == SMC_INIT ||
+	    sk->sk_state == SMC_PEERABORTW) {
+		sk->sk_state = SMC_CLOSED;
+	} else {
+		if (sk->sk_state == SMC_PEERCLW1) {
+			/* enable wait_close wakeup */
+			smc_clear_pending_sends(conn);
+		}
+		/* cancel close waiting */
+		atomic64_set(&conn->tx_curs_prep.s.acurs,
+			     conn->tx_curs_sent.s.lcurs);
+		atomic64_set(&conn->tx_curs_fin.s.acurs,
+			     conn->tx_curs_sent.s.lcurs);
+		sk->sk_state = SMC_PROCESSABORT;
+		/* purge all in-flight data, do abnormal term step */
+		conn->local_tx_ctrl.conn_state_flags.abnormal_close = 1;
+		if ((old_state != SMC_PROCESSABORT) && (conn->lgr) &&
+		    (conn->lgr->lgr_type != NONE))
+			smc_ctrl_send(conn, conn->lnk_idx);
+		if (sock_flag(sk, SOCK_DEAD))
+			mod_timer(&smc->fin_timer, jiffies + TCP_TIMEWAIT_LEN);
+	}
+	sk->sk_err = ECONNABORTED;
+}
+
+static void smc_accept_unlink(struct sock *);
+
+void smc_conn_term(struct smc_sock *smc)
+{
+	struct sock *tcpsk;
+	struct sock *sk = &smc->sk;
+	struct smc_connection *conn = &smc->conn;
+	int old_state;
+
+	old_state = sk->sk_state;
+	/* Handle abnormal termination */
+	if (conn->local_rx_ctrl.conn_state_flags.abnormal_close) {
+		smc_conn_term_abnormal(smc, old_state);
+		goto out;
+	}
+	switch (sk->sk_state) {
+	/* Normal termination - Passive close part */
+	case SMC_INIT:
+	case SMC_ACTIVE:
+		if (conn->local_rx_ctrl.conn_state_flags.sending_done ||
+		    conn->local_rx_ctrl.conn_state_flags.closed_conn) {
+			/* complete any outstanding recv with zero-length
+			 * if peerclosedconn and pending data to be written
+			 * then reset conn
+			 */
+			sk->sk_state = SMC_APPLCLW1;
+			if (sock_flag(sk, SOCK_DEAD))
+				mod_timer(&smc->fin_timer,
+					  jiffies + TCP_TIMEWAIT_LEN);
+		}
+		break;
+	case SMC_PEERFINCLW:
+		if (conn->local_rx_ctrl.conn_state_flags.closed_conn)
+			sk->sk_state = SMC_CLOSED;
+		break;
+		/* Normal termination - Active close part */
+	case SMC_PEERCLW1:
+		if (conn->local_rx_ctrl.conn_state_flags.sending_done) {
+			/* complete any outstanding recv with zero-length */
+			sk->sk_state = SMC_PEERCLW2;
+		} /* fall through */
+	case SMC_PEERCLW2:
+		if (conn->local_rx_ctrl.conn_state_flags.closed_conn) {
+			struct smc_e_ctrl *tx_ctrl = &conn->local_tx_ctrl;
+
+			/* complete any outstanding recv with zero-length */
+			if (sk->sk_shutdown == SHUTDOWN_MASK &&
+			    (tx_ctrl->conn_state_flags.closed_conn ||
+			     tx_ctrl->conn_state_flags.abnormal_close)) {
+				sk->sk_state = SMC_CLOSED;
+				if (timer_pending(&smc->fin_timer)) {
+					del_timer_sync(&smc->fin_timer);
+					destroy_timer_on_stack(&smc->fin_timer);
+				}
+			} else {
+				sk->sk_state = SMC_APPLFINCLW;
+			}
+		}
+		break;
+	default:
+		break;
+	}
+out:
+	if ((sk->sk_err == ECONNABORTED) &&
+	    !list_empty(&smc->accept_q))
+		smc_accept_unlink(sk);
+	if (smc_stop_received(conn)) {
+		sk->sk_shutdown = sk->sk_shutdown | RCV_SHUTDOWN;
+		if (smc->tcpsocket && smc->tcpsocket->sk) {
+			tcpsk = smc->tcpsocket->sk;
+			tcpsk->sk_shutdown = tcpsk->sk_shutdown | RCV_SHUTDOWN;
+		}
+	}
+	if (smc_close_received(smc) &&
+	    (sk->sk_state == SMC_CLOSED) &&
+	    (sk->sk_socket == NULL) &&
+	    !smc_pending_sends(conn))
+		sock_set_flag(sk, SOCK_DEAD);
+	if ((old_state != sk->sk_state) &&
+	    (old_state != SMC_INIT))
+		sk->sk_state_change(sk);
+}
+
+static void smc_sk_release(struct smc_sock *smc, int wait)
+{
+	struct sock *sk = &smc->sk;
+	struct smc_connection *conn = &smc->conn;
+	int rc = 0;
+
+	if (smc->use_tcp) {
+		sk->sk_state = SMC_CLOSED;
+		sk->sk_state_change(sk);
+		goto out;
+	}
+	sk->sk_shutdown = SHUTDOWN_MASK;
+	sk_stop_timer(sk, &sk->sk_timer);
+	switch (sk->sk_state) {
+	case SMC_INIT:
+	case SMC_CLOSED:
+		sk->sk_state = SMC_CLOSED;
+		sk->sk_state_change(sk);
+		break;
+	case SMC_LISTEN:
+		sk->sk_state = SMC_CLOSED;
+		sk->sk_state_change(sk);
+		if (smc->tcpsocket && smc->tcpsocket->sk) {
+			rc = kernel_sock_shutdown(smc->tcpsocket, SHUT_RDWR);
+			smc->tcpsocket->sk->sk_data_ready(smc->tcpsocket->sk);
+			/* to wake up kernel_accept of smc_tcp_listen_worker */
+		}
+		release_sock(sk);
+		smc_sock_cleanup_listen(sk);
+		while (work_busy(&smc->tcp_listen_work))
+			msleep(20);
+		lock_sock_nested(sk, SINGLE_DEPTH_NESTING);
+		break;
+	case SMC_ACTIVE:
+		/* active close */
+		if (conn->local_rx_ctrl.conn_state_flags.sending_done)
+			sk->sk_state = SMC_PEERCLW2;
+		else
+			sk->sk_state = SMC_PEERCLW1;
+		sk->sk_state_change(sk);
+		/* handle SOCK_LINGER */
+		/* fall through */
+	case SMC_PEERCLW1:
+		if (wait)
+			smc_wait_close(smc);
+		sk->sk_state = SMC_PEERCLW2;
+		smc_send_close(smc);
+		/* fall through */
+	case SMC_PEERCLW2:
+		rc = smc_wait_for_pending_sends(smc);
+		if ((rc <= 0) ||   /* timeout or interrupted */
+		    smc_close_received(smc)) {
+			sk->sk_state = SMC_CLOSED;
+			sk->sk_state_change(sk);
+		}
+		break;
+	case SMC_PROCESSABORT:
+	case SMC_APPLFINCLW:
+		/* socket already shutdown wr or both (active close) */
+		if (!conn->local_tx_ctrl.conn_state_flags.closed_conn) {
+			rc = smc_send_close(smc);
+			smc_wait_for_pending_sends(smc);
+		}
+		sk->sk_state = SMC_CLOSED;
+		sk->sk_state_change(sk);
+		break;
+	case SMC_APPLCLW1:
+		/* passive close */
+		if (wait)
+			smc_wait_close(smc);
+		/* fall through */
+	case SMC_APPLCLW2:
+		/* confirm close from peer */
+		smc_send_close(smc);
+		if (smc_close_received(smc)) {
+			smc_wait_for_pending_sends(smc);
+			sk->sk_state = SMC_CLOSED;
+			sk->sk_state_change(sk);
+		} else {
+			sk->sk_state = SMC_PEERFINCLW;
+			sk->sk_state_change(sk);
+		}
+		break;
+	case SMC_PEERFINCLW:
+		break;
+	default:
+		break;
+	}
+out:
+	return;
+}
+
+static int smc_check_peer_gone(struct smc_sock *smc)
+{
+	struct smc_link_group *lgr = smc->conn.lgr;
+	struct smc_link *link = &lgr->lnk[smc->conn.lnk_idx];
+	struct llc_qentry *qentry;
+	int rc = 0;
+
+	/* check peer with testlink */
+	if (!llc_initiate(lgr, LLC_GRP_TEST_LINK))
+		return -ETIMEDOUT;
+	rc = llc_send_test_link(link, "KEEPALIVE_CHECK");
+	if (rc)
+		goto out;
+	qentry = llc_wait(lgr, LLC_TESTLINK, LLC_WAIT_TIMER_TIMEO,
+			  LLC_TEST_LINK);
+	if (qentry) { /* peer is alive */
+		kfree(qentry);
+		goto out;
+	}
+	rc = -ETIMEDOUT;
+out:
+	llc_stop(lgr, LLC_GRP_TEST_LINK);
+	return rc;
+}
+
+	/* check if we can cleanup sock or keep it for peers responses */
+static int smc_sock_release(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc;
+	int rc = 0;
+
+	smc = smc_sk(sk);
+	if (!sk || (sk->sk_state == SMC_DESTRUCT))
+		return rc;
+
+	sock_hold(sk);
+	if (sk->sk_state == SMC_LISTEN)
+		lock_sock_nested(sk, SINGLE_DEPTH_NESTING);
+	else
+		lock_sock(sk);
+	smc_sk_release(smc, 1);
+	if (smc->tcpsocket) {
+		sock_release(smc->tcpsocket);
+		smc->tcpsocket = NULL;
+	}
+
+	/* detach socket */
+	sock->state = SS_UNCONNECTED;
+	sock_set_flag(sk, SOCK_ZAPPED);
+	sock_orphan(sk); /* incl. SOCK_DEAD */
+	if (timer_pending(&smc->cork_timer)) {
+		del_timer_sync(&smc->cork_timer);
+		destroy_timer_on_stack(&smc->cork_timer);
+	}
+	release_sock(sk);
+	if (!smc->use_tcp && (smc->write_work.work.func == smc_write_worker)) {
+		wake_up_interruptible(&smc->rx_waiter);
+		if (delayed_work_pending(&smc->write_work))
+			cancel_delayed_work_sync(&smc->write_work);
+	}
+	if (sk->sk_state == SMC_PEERCLW2) {
+		if (smc_check_peer_gone(smc)) /* guarantee socket cleanup */
+			mod_timer(&smc->fin_timer, jiffies + TCP_FIN_TIMEOUT);
+	}
+
+	/* check if we can cleanup sock or keep it for peers responses */
+	if ((sk->sk_state == SMC_CLOSED) &&
+	    (cmpxchg(&smc->sock_put_done, 0, 1) == 0))
+		sock_put(sk);
+	sock->sk = NULL;
+	sock_put(sk);
+
+	return rc;
+}
+
+static int smc_sock_bind(struct socket *sock, struct sockaddr *addr,
+			 int addr_len)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc = smc_sk(sk);
+	int rc;
+
+	smc->tcpsocket->sk->sk_reuse = sk->sk_reuse;
+	rc = kernel_bind(smc->tcpsocket, addr, addr_len);
+	return rc;
+}
+
+/* Wait for data on the tcp-socket and fallback to tcp in decline is received
+ * Returns 0 if success
+ *         tcpsocket error, -ETIME, -EPROTO or -ECONNABORTED otherwise
+ */
+int clc_wait_msg(struct smc_sock *smc, int noblock, char *buf, int buflen,
+		 u8 type, int *reason_code)
+{
+	struct sock *sk = smc->tcpsocket->sk;
+	long timeo;
+	int rc = 0;
+	int len;
+	int krflags = 0;
+	struct msghdr msg;
+	struct kvec vec;
+	struct smc_clc_msg_hdr *clcm = (struct smc_clc_msg_hdr *)buf;
+	DEFINE_WAIT(wait);
+
+	timeo = (noblock) ? 0 : 1*HZ;
+	if (noblock)
+		krflags = MSG_DONTWAIT;
+	lock_sock(sk);
+	rc = sk_wait_data(sk, &timeo);
+	release_sock(sk);
+	if (sk->sk_err)
+		rc = -sk->sk_err;
+	if (signal_pending(current)) {
+		rc = sock_intr_errno(timeo);
+		sk->sk_err = -rc;
+	}
+	if (rc < 0) {
+		smc->sk.sk_err = sk->sk_err;
+		goto out;
+	}
+	rc = 0;
+	vec.iov_base = buf;
+	vec.iov_len = buflen;
+	memset(&msg, 0, sizeof(struct msghdr));
+	len = kernel_recvmsg(smc->tcpsocket, &msg, &vec, 1,
+			     sizeof(struct smc_clc_msg_hdr), krflags);
+	if (!len) { /* no data */
+		smc->sk.sk_err = ETIME;
+		rc = -ETIME;
+		goto out;
+	}
+	if (len < 4) {
+		smc->sk.sk_err = EPROTO;
+		rc = -EPROTO;
+		goto out;
+	}
+	len = ntohs(clcm->length);
+	if (!len) {
+		smc->sk.sk_err = EPROTO;
+		rc = -EPROTO;
+		goto out;
+	}
+	vec.iov_base = buf + sizeof(struct smc_clc_msg_hdr);
+	vec.iov_len = buflen - sizeof(struct smc_clc_msg_hdr);
+	memset(&msg, 0, sizeof(struct msghdr));
+	len = kernel_recvmsg(smc->tcpsocket, &msg, &vec, 1,
+			     len - sizeof(struct smc_clc_msg_hdr), 0);
+	len = len + sizeof(struct smc_clc_msg_hdr);
+	if ((len < sizeof(struct smc_decline_clc_msg)) ||
+	    memcmp(clcm->ec_clce, SMC_EC, sizeof(SMC_EC))) {
+		if (!sk->sk_err)
+			sk->sk_err = EPROTO;
+		rc = -EPROTO;
+		goto out;
+	}
+	if (clcm->type == SMC_CLC_DECLINE) {
+		smc->use_tcp = 1;
+		if (clcm->flags & SMC_LINK_GROUP_OUT_OF_SYNCH) {
+			smc_terminate_conn(smc->conn.lgr);
+			sk->sk_err = ECONNABORTED;
+			rc = -ECONNABORTED;
+			return rc;
+		}
+		*reason_code = SMC_CLC_DEC_REPLY;
+		goto out;
+	}
+	if ((clcm->type != type) ||
+	    (memcmp(&clcm->ec_clce, SMC_EC, sizeof(SMC_EC)))) {
+		if (!smc->sk.sk_err)
+			smc->sk.sk_err = EPROTO;
+		rc = -EPROTO;
+		goto out;
+	}
+out:
+	return rc;
+}
+
+int clc_send_decline(struct smc_sock *smc, u32 reason_code, u8 flags)
+{
+	struct smc_decline_clc_msg dclc;
+	struct msghdr msg;
+	struct kvec vec;
+	int len;
+
+	memset(&dclc, 0, sizeof(struct smc_decline_clc_msg));
+	memcpy(dclc.hdr.ec_clce, SMC_EC, sizeof(SMC_EC));
+	memcpy(dclc.peer_id, local_peerid, sizeof(local_peerid));
+	dclc.hdr.type = SMC_CLC_DECLINE;
+	dclc.hdr.length = htons(sizeof(struct smc_decline_clc_msg));
+	dclc.hdr.flags = SMC_CLC_V1 | flags;
+	dclc.peer_diagnosis = htonl(reason_code);
+	memcpy(dclc.ec_dclcf, SMC_EC, sizeof(SMC_EC));
+
+	vec.iov_base = &dclc;
+	vec.iov_len = sizeof(struct smc_decline_clc_msg);
+	memset(&msg, 0, sizeof(struct msghdr));
+	len = kernel_sendmsg(smc->tcpsocket, &msg, &vec, 1,
+			     sizeof(struct smc_decline_clc_msg));
+	if (len < sizeof(struct smc_decline_clc_msg))
+		smc->sk.sk_err = EPROTO;
+	if (len < 0)
+		smc->sk.sk_err = -len;
+	return len;
+}
+
+/* Copy flags relevant for SO_* sockopts */
+static void smc_copy_sockopt_settings(struct sock *nsk, struct sock *osk)
+{
+	nsk->sk_type = osk->sk_type;
+	nsk->sk_sndbuf = osk->sk_sndbuf;
+	nsk->sk_rcvbuf = osk->sk_rcvbuf;
+	nsk->sk_sndtimeo = osk->sk_sndtimeo;
+	nsk->sk_rcvtimeo = osk->sk_rcvtimeo;
+	nsk->sk_mark = osk->sk_mark;
+	nsk->sk_priority = osk->sk_priority;
+	nsk->sk_rcvlowat = osk->sk_rcvlowat;
+	nsk->sk_bound_dev_if = osk->sk_bound_dev_if;
+	sock_copy_flags(nsk, osk);
+}
+
+static void smc_init_tmp_sockopts(struct smc_sock *smc)
+{
+	smc->tmp_sockopts.set = 0;
+	smc->tmp_sockopts.cork = 0;
+	smc->tmp_sockopts.defer_accept = 0;
+	smc->tmp_sockopts.nodelay = 0;
+}
+
+static int smc_sock_setsockopt(struct socket *, int, int, char __user *,
+			       unsigned int);
+
+/* Apply all user-set sockopts effective that were supressed as they
+ * might have a negative effect during the CLC handshake
+ */
+static int smc_apply_tmp_sockopts(struct socket *socket,
+				  const struct smc_tmp_sockopts *sopts)
+{
+	int rc = 0, brc;
+	mm_segment_t old_fs = get_fs();
+
+	set_fs(KERNEL_DS);
+	if (sopts->set & SMC_SOCKOPTS_CORK) {
+		brc = smc_sock_setsockopt(socket, SOL_TCP, TCP_CORK,
+					  (char __user *)&sopts->cork,
+					  sizeof(sopts->cork));
+		if (brc)
+			rc = -EFAULT;
+	}
+	if (sopts->set & SMC_SOCKOPTS_DEFER_ACCEPT) {
+		brc = smc_sock_setsockopt(socket, SOL_TCP, TCP_DEFER_ACCEPT,
+					  (char __user *)&sopts->defer_accept,
+					  sizeof(sopts->defer_accept));
+		if (brc)
+			rc = -EFAULT;
+	}
+	if (sopts->set & SMC_SOCKOPTS_NODELAY) {
+		brc = smc_sock_setsockopt(socket, SOL_TCP, TCP_NODELAY,
+					  (char __user *)&sopts->nodelay,
+					  sizeof(sopts->nodelay));
+		if (brc)
+			rc = -EFAULT;
+	} else {
+		struct smc_sock *smc = smc_sk(socket->sk);
+
+		tcp_sk(smc->tcpsocket->sk)->nonagle &= ~TCP_NAGLE_OFF;
+	}
+	set_fs(old_fs);
+
+	return rc;
+}
+
+static int smc_find_link_accept(struct smc_link_group *lgr,
+				struct smc_acc_conf_clc_msg *clc)
+{
+	int i;
+	u32 tmp_qpnum;
+
+	ntoh_three(&tmp_qpnum, clc->qp_num);
+	for (i = 0; i <= SMC_MAX_SYM_LINKS; i++) {
+		if (!memcmp(&lgr->lnk[i].gid_peer, &clc->hdr2.gid, 16) &&
+		    !memcmp(&lgr->lnk[i].mac_peer, &clc->hdr2.mac, 6) &&
+		    (lgr->lnk[i].qp_num_peer == tmp_qpnum))
+			return i;
+	}
+	return -ENOENT;
+}
+
+static int smc_rtoken_handling(struct smc_link_group *lgr, struct smc_sock *smc,
+			       struct smc_acc_conf_clc_msg *clc)
+{
+	struct smc_connection *conn = &smc->conn;
+	u64 vaddr = be64_to_cpu(clc->rmb_vaddr);
+	unsigned int rkey = ntohl(clc->rmb_rkey);
+	int lnk_idx;
+
+	lnk_idx = smc_find_link_accept(lgr, clc);
+	if (lnk_idx < 0)
+		return -ENOENT;
+	conn->rtok_idx =
+		smc_find_rtoken_by_link(lgr, lnk_idx, rkey);
+	if (conn->rtok_idx == -ENOENT) {
+		conn->rtok_idx = smc_get_rtoken(lgr);
+		lgr->rtok[conn->rtok_idx].rkey[lnk_idx] = rkey;
+		lgr->rtok[conn->rtok_idx].vaddr[lnk_idx] = vaddr;
+		lgr->rtok[conn->rtok_idx].link_id[lnk_idx] =
+			lgr->lnk[lnk_idx].link_id;
+	}
+	return 0;
+}
+
+static int smc_send_proposal(struct smc_sock *smc,
+			     struct smc_roce_defs *roce_sugg,
+			     struct smc_acc_conf_clc_msg *aclc,
+			     int *reason_code)
+{
+	int pclc_msgsize = sizeof(struct smc_proposal_clc_msg) +
+			   sizeof(struct smc_proposal_clc_msg2);
+	struct smc_proposal_clc_msg *pclc;
+	struct smc_proposal_clc_msg2 *pclc2;
+	struct kvec vec;
+	struct msghdr msg;
+	int rc = 0;
+
+	pclc = kzalloc(pclc_msgsize, GFP_KERNEL);
+	if (!pclc)
+		return -ENOMEM;
+	/* send SMC Proposal CLC message (peer ID, GID, MAC, VLAN) */
+	memcpy(&pclc->hdr2.gid, &roce_sugg->gid, sizeof(roce_sugg->gid));
+	memcpy(&pclc->hdr2.mac, &roce_sugg->mac, sizeof(roce_sugg->mac));
+	pclc->iparea_offset = 0;
+
+	pclc2 = (struct smc_proposal_clc_msg2 *)
+		((char *)pclc + sizeof(struct smc_proposal_clc_msg) +
+		 pclc->iparea_offset);
+
+	/* is it sufficient to use IP from connection itself? */
+	rc = smc_netinfo_by_tcpsk(&pclc2->outgoing_subnet,
+				  &pclc2->subnet_mask_bits, smc->tcpsocket);
+	memcpy(&pclc->hdr.ec_clce, SMC_EC, sizeof(SMC_EC));
+	memcpy(&pclc->hdr2.peer_id, local_peerid, sizeof(local_peerid));
+	pclc->hdr.type = SMC_CLC_PROPOSAL;
+	pclc->hdr.length = htons(pclc_msgsize);
+	pclc->hdr.flags = SMC_CLC_V1;
+	memcpy(&pclc2->ec_pclcf, SMC_EC, sizeof(SMC_EC));
+
+	vec.iov_base = pclc;
+	vec.iov_len = pclc_msgsize;
+	memset(&msg, 0, sizeof(struct msghdr));
+	rc = kernel_sendmsg(smc->tcpsocket, &msg, &vec, 1, pclc_msgsize);
+	kfree(pclc);
+	if (rc >= 0) {
+		if (rc < pclc_msgsize)
+			rc = -EPROTO;
+		else
+			rc = 0;
+	}
+	if (rc) {
+		smc->sk.sk_err = -rc;
+		return rc;
+	}
+
+	/* receive SMC Accept CLC message (GID, MAC, VLAN, QP )*/
+	rc = clc_wait_msg(smc, SMC_CLC_BLOCK, (char *)aclc,
+			  sizeof(struct smc_acc_conf_clc_msg),
+			  SMC_CLC_ACCEPTANCE, reason_code);
+	return rc;
+}
+
+static int smc_send_confirm(struct smc_sock *smc)
+{
+	struct smc_link *link;
+	struct smc_link_group *lgr;
+	struct smc_connection *conn = &smc->conn;
+	struct smc_acc_conf_clc_msg cclc;
+	struct msghdr msg;
+	struct kvec vec;
+	int rc = 0;
+
+	link = &conn->lgr->lnk[conn->lnk_idx];
+	lgr = link->lnk_grp;
+	/* send SMC Confirm CLC msg (MAC, GID, QP, link num, link user id) */
+	memset(&cclc, 0, sizeof(struct smc_acc_conf_clc_msg));
+	cclc.tcp_conn_idx = 1; /* as long as 1 RMB = 1 RMBE */
+	memcpy(cclc.hdr2.peer_id, local_peerid, sizeof(local_peerid));
+	memcpy(&cclc.hdr2.gid, &link->roce_defs.gid,
+	       sizeof(link->roce_defs.gid));
+	memcpy(&cclc.hdr2.mac, &link->roce_defs.mac,
+	       sizeof(link->roce_defs.mac));
+	hton_three(link->roce_qp->qp_num, cclc.qp_num);
+	hton_three(link->psn_initial, cclc.psn);
+	cclc.rmb_rkey =
+		htonl(conn->rmb_rx_elem->mr_rx[conn->lnk_idx]->rkey);
+	cclc.rmb_vaddr =
+		cpu_to_be64((u64)conn->rmb_rx_elem->rmb_rx_dma[conn->lnk_idx]);
+	memcpy(cclc.hdr.ec_clce, SMC_EC, sizeof(SMC_EC));
+	cclc.hdr.type = SMC_CLC_CONFIRMATION;
+	cclc.hdr.length = htons(sizeof(struct smc_acc_conf_clc_msg));
+	cclc.hdr.flags = SMC_CLC_V1;
+	cclc.rmb_alert_token = conn->alert_token_local;
+	cclc.flags2 = conn->rmb_rx_size_short +
+		      min(link->path_mtu, link->mtu_peer);
+	memcpy(cclc.ec_clcf, SMC_EC, sizeof(SMC_EC));
+
+	vec.iov_base = &cclc;
+	vec.iov_len = sizeof(struct smc_acc_conf_clc_msg);
+	memset(&msg, 0, sizeof(struct msghdr));
+	rc = kernel_sendmsg(smc->tcpsocket, &msg, &vec, 1,
+			    sizeof(struct smc_acc_conf_clc_msg));
+	if (rc >= 0) {
+		if (rc < sizeof(struct smc_acc_conf_clc_msg))
+			rc = -EPROTO;
+		else
+			rc = 0;
+	}
+	if (rc)
+		smc->sk.sk_err = -rc;
+	return rc;
+}
+
+static int smc_initial_map_rmb(struct smc_sock *smc)
+{
+	struct smc_link_group *lgr = smc->conn.lgr;
+	struct smc_link *link = &lgr->lnk[smc->conn.lnk_idx];
+	long rc = 0;
+
+	if (!smc->conn.tx_rmb_reused) {
+		rc = smc_map_rmbs_tx(lgr, smc->conn.lnk_idx,
+				     smc->conn.rmb_tx_size + SMC_EYE_CATCH_LEN,
+				     smc->conn.rmb_tx_elem);
+		if (rc)
+			goto out;
+	}
+	if (!smc->conn.rx_rmb_reused) {
+		rc = smc_map_rmbs_rx(lgr, smc->conn.lnk_idx,
+				     smc->conn.rmb_rx_size + SMC_EYE_CATCH_LEN,
+				     smc->conn.rmb_rx_elem);
+		if (rc)
+			goto out;
+		rc = smc_get_dma_mr(lgr, smc->conn.lnk_idx,
+				    smc->conn.rmb_rx_elem);
+		if (rc)
+			goto out;
+	}
+	return 0;
+
+out:
+	if (rc && smc_lnk_downing(&link->state)) {
+		release_sock(&smc->sk);
+		smc_link_down(lgr, link - &lgr->lnk[0]);
+		lock_sock(&smc->sk);
+	}
+	return (int)rc;
+}
+
+static int smc_announce_rmb(struct smc_sock *smc, int *reason_code)
+{
+	struct smc_link_group *lgr = smc->conn.lgr;
+	struct smc_link *link = &lgr->lnk[smc->conn.lnk_idx];
+	struct llc_qentry *qentry;
+	int rc = 0;
+
+	/* Announce new RMB */
+	if (smc->conn.tx_rmb_reused && smc->conn.rx_rmb_reused)
+		goto out;
+	if (!llc_initiate(lgr, LLC_GRP_CONF_RKEY)) { /* timeout */
+		smc_del_rmbs(smc);
+		*reason_code = SMC_CLC_DEC_TU;
+		rc = -ETIME;
+		goto out;
+	}
+	smc_map_rmbs(smc);
+	if (lgr->lgr_type != SINGLE && !smc->conn.rx_rmb_reused) {
+		rc = llc_do_confirm_rkey(link, smc->conn.rmb_rx_elem);
+		if (rc >= 0) {
+			if (lgr->role == SMC_CLNT)
+				release_sock(&smc->sk);
+			qentry = llc_wait(lgr, lgr->role, LLC_WAIT_TIMEO,
+					  LLC_CONFIRM_RKEY);
+			if (lgr->role == SMC_CLNT)
+				lock_sock(&smc->sk);
+			if ((!qentry) ||
+			    (qentry->msg.hd.flags & LLC_FLAG_RKEY_NEG)) {
+				kfree(qentry);
+				smc_del_rmbs(smc);
+				if (smc_lnk_downing(&link->state)) {
+					if (lgr->role == SMC_CLNT)
+						release_sock(&smc->sk);
+					smc_link_down(lgr, link - &lgr->lnk[0]);
+					if (lgr->role == SMC_CLNT)
+						lock_sock(&smc->sk);
+				}
+				*reason_code = SMC_CLC_DEC_TU;
+				rc = -ETIME;
+				goto out_stop;
+			}
+			kfree(qentry);
+			rc = 0;
+		} else {
+			*reason_code = SMC_CLC_DEC_SEND;
+			rc = -EPIPE;
+		}
+	}
+out_stop:
+	llc_stop(lgr, LLC_GRP_CONF_RKEY);
+out:
+	return rc;
+}
+
+static int smc_clnt_conf_first_lnk(struct smc_sock *smc,
+				   struct smc_roce_defs *roce_sugg,
+				   int *reason_code)
+{
+	struct smc_link_group *lgr = smc->conn.lgr;
+	struct smc_link *link = &smc->conn.lgr->lnk[smc->conn.lnk_idx];
+	struct llc_confirm_msg *conf_llc;
+	struct llc_qentry *qentry;
+	int rc = 0;
+
+	/* receive CONFIRM LINK request over RoCE fabric */
+	qentry = llc_wait(lgr, LLC_SERV, LLC_WAIT_FIRST_TIMEO,
+			  LLC_CONFIRM_LINK);
+	if (!qentry) {
+		/* clc decl received or llc timeout */
+		lgr->lgr_type = NONE;
+		lgr->llc_ctl[LLC_SERV].active = LLC_GRP_NONE;
+		wake_up_interruptible(&lgr->llc_waiter);
+		rc = llc_get_fail_cause(lgr, LLC_NO_NOTIFY, smc);
+		return rc;
+	}
+	conf_llc = (struct llc_confirm_msg *)&qentry->msg;
+	link->link_id = conf_llc->link_num;
+	lgr->rtok[smc->conn.rtok_idx].link_id[smc->conn.lnk_idx] =
+		link->link_id;
+	lgr->max_links = SMC_MAX_SYM_LINKS;
+	kfree(qentry);
+	rc = smc_modify_qp_rts(link);
+	if (rc) {
+		*reason_code = SMC_CLC_DEC_INT;
+		return rc;
+	}
+	smc_check_qp_attr(link);
+	/* send CONFIRM LINK response over RoCE fabric */
+	rc = llc_send_confirm_link(link, (u8 *)link->roce_defs.mac,
+				   &roce_sugg->gid, LLC_RESP, LLC_SERV);
+	if (rc < 0) {
+		*reason_code = SMC_CLC_DEC_TCL;
+		return rc;
+	}
+	atomic_set(&link->state, SMC_LINK_UP);
+	return rc;
+}
+
+static int smc_clnt_add_lnk(struct smc_sock *smc, int *reason_code)
+{
+	struct smc_link_group *lgr = smc->conn.lgr;
+	struct smc_link *link = &smc->conn.lgr->lnk[smc->conn.lnk_idx];
+	struct llc_qentry *qentry;
+	int rc = 0;
+
+	release_sock(&smc->sk);
+	qentry = llc_wait(lgr, LLC_SERV, LLC_WAIT_FIRST_TIMEO,
+			  LLC_ADD_LINK);
+	lock_sock(&smc->sk);
+	if (!qentry) {
+		lgr->lgr_type = NONE;
+		lgr->llc_ctl[LLC_SERV].active = LLC_GRP_NONE;
+		wake_up_interruptible(&lgr->llc_waiter);
+		rc = llc_get_fail_cause(lgr, LLC_SERV, smc);
+		return rc;
+	}
+	rc = llc_cli_add_link(link, qentry, smc);
+	lgr->llc_ctl[LLC_SERV].active = LLC_GRP_NONE;
+	wake_up_interruptible(&lgr->llc_waiter);
+	if (rc == -ENOLINK)
+		*reason_code = SMC_LLC_DEL_NOLNK;
+	return rc;
+}
+
+static void smc_save_peer_info(struct smc_sock *smc,
+			       struct smc_acc_conf_clc_msg *clc)
+{
+	smc->conn.local_tx_ctrl.ctrl_token = clc->rmb_alert_token;
+	smc->conn.peer_rx_buf_len =
+		smc_uncompress_bufsize(clc->flags2 & 0xf0) - SMC_EYE_CATCH_LEN;
+	smc->conn.peer_tcp_conn_idx = clc->tcp_conn_idx;
+	atomic_set(&smc->conn.rx_buf_space, smc->conn.peer_rx_buf_len);
+}
+
+static void smc_save_link_info(struct smc_link *link,
+			       struct smc_acc_conf_clc_msg *clc)
+{
+	memcpy(link->gid_peer, &clc->hdr2.gid, sizeof(link->gid_peer));
+	memcpy(link->mac_peer, clc->hdr2.mac, sizeof(link->mac_peer));
+	ntoh_three(&link->psn_peer, clc->psn);
+	link->mtu_peer = clc->flags2 & 0x0f;
+}
+
+static int smc_switch_to_tcp(struct smc_sock *smc, int reason_code)
+{
+	struct smc_link_group *lgr = smc->conn.lgr;
+	struct smc_link *link = &smc->conn.lgr->lnk[smc->conn.lnk_idx];
+	int rc;
+
+	smc->use_tcp = 1;
+	if (reason_code && (reason_code != SMC_CLC_DEC_REPLY)) {
+		rc = clc_send_decline(smc, reason_code, 0);
+		if (rc < sizeof(struct smc_decline_clc_msg))
+			return rc;
+	}
+	if (lgr) {
+		if (smc->new_lgr && link) {
+			atomic_set(&link->state, SMC_LINK_DOWN);
+			lgr->lgr_type = NONE;
+		}
+		if (lgr->lgr_type == NONE) {
+			spin_lock_bh(&smc_lgr_list.lock);
+			list_del_init(&lgr->list);
+			spin_unlock_bh(&smc_lgr_list.lock);
+		}
+	}
+	smc_free_conn(smc);
+	return 0;
+}
+
+static void smc_init_after_clc_handshake(struct smc_sock *smc)
+{
+	struct sock *sk = &smc->sk;
+	struct tcp_sock *tp = tcp_sk(smc->tcpsocket->sk);
+	u32 keepalive_time;
+
+	INIT_DELAYED_WORK(&smc->write_work, smc_write_worker);
+	init_waitqueue_head(&smc->destruct_waiter);
+	if (sk->sk_state  == SMC_INIT)
+		sk->sk_state = SMC_ACTIVE;
+	if (smc->use_tcp)
+		goto out;
+	if (sock_flag(sk, SOCK_KEEPOPEN)) {
+		keepalive_time = tp->keepalive_time ? : TCP_KEEPALIVE_TIME;
+		if (keepalive_time)
+			sk_reset_timer(sk, &sk->sk_timer,
+				       jiffies + (unsigned long)keepalive_time);
+	}
+	sk->sk_data_ready = smc_sock_wake_rx;
+	sk->sk_write_space = smc_sock_wake_tx;
+	sk->sk_state_change = smc_sock_state_change;
+	/* to return meaningful values with getsockopt */
+	sk->sk_sndbuf = smc->conn.rmb_tx_size;
+	sk->sk_rcvbuf = smc->conn.rmb_rx_size;
+out:
+	return;
+}
+
+static int smc_connect(struct smc_sock *smc)
+{
+	struct sock *sk = &smc->sk;
+	struct socket *sock = sk->sk_socket;
+	struct tcp_sock *tp = tcp_sk(smc->tcpsocket->sk);
+	int rc = 0;
+	struct sockaddr_in *inaddr =  (struct sockaddr_in *)smc->addr;
+	struct smc_acc_conf_clc_msg aclc;
+	struct smc_link_group *lgr = NULL;
+	struct smc_link *link = NULL;
+	struct smc_roce_defs roce_sugg;
+	u32 tmp_qpnum;
+	char pnet_id[SMC_MAX_PNET_ID_LEN];
+	int reason_code = 0;
+
+	/* check if peer is smc capable */
+	if (!tp->syn_smc) {
+		smc->use_tcp = 1;
+		goto out_connected;
+	}
+
+	smc_find_roce_resources(&roce_sugg, pnet_id, inaddr,
+				smc->tcpsocket->sk);
+	if (!roce_sugg.ibdev) {
+		reason_code = SMC_CLC_DEC_CUC;
+		goto decline;
+	}
+	/* do inband token exchange */
+	rc = smc_send_proposal(smc, &roce_sugg, &aclc, &reason_code);
+	if (rc)
+		goto out_err;
+	if (reason_code) { /* switch to tcp */
+		smc->use_tcp = 1;
+		goto out_connected;
+	}
+
+	/* allocate connection/link group*/
+	ntoh_three(&tmp_qpnum, aclc.qp_num);
+	smc->new_lgr = aclc.hdr.flags & SMC_FIRST_CONTACT;
+	rc = smc_create_conn(smc, inaddr->sin_addr.s_addr, SMC_CLNT,
+			     &roce_sugg, &aclc.hdr2, tmp_qpnum);
+	if (rc == -ENOLINK) /* link groups out of sync */
+		goto out_err;
+	if (rc) {
+		/* insufficient memory */
+		reason_code = SMC_CLC_DEC_RIM;
+		goto decline;
+	}
+	lgr = smc->conn.lgr;
+	link = &smc->conn.lgr->lnk[smc->conn.lnk_idx];
+	strncpy(lgr->pnet_id, pnet_id, sizeof(pnet_id));
+	smc_save_peer_info(smc, &aclc);
+	lock_sock(sk);
+
+	rc = smc_create_rmbs(smc);
+	if (rc) {
+		/* insufficient memory */
+		reason_code = SMC_CLC_DEC_RIM;
+		goto decline;
+	}
+	atomic_set(&smc->conn.tx_buf_space, smc->conn.rmb_tx_size);
+	if (smc->new_lgr) {
+		rc = smc_initial_map_rmb(smc);
+		if (rc) {
+			reason_code = SMC_CLC_DEC_RIM;
+			goto decline;
+		}
+		link->qp_num_peer = tmp_qpnum;
+		smc_save_link_info(link, &aclc);
+	}
+	rc = smc_rtoken_handling(lgr, smc, &aclc);
+	if (rc) {
+		reason_code = SMC_CLC_DEC_INT;
+		goto decline;
+	}
+	if (smc->new_lgr) {
+		rc = smc_ready_link(link);
+		if (rc) {
+			reason_code = SMC_CLC_DEC_INT;
+			goto decline;
+		}
+		lgr->llc_ctl[LLC_SERV].active = LLC_GRP_ADD_LINK;
+		lgr->llc_ctl[LLC_SERV].qentry = NULL;
+		lgr->lgr_type = SINGLE;
+	} else { /* link already active */
+		rc = smc_announce_rmb(smc, &reason_code);
+		if (rc) {
+			reason_code = SMC_CLC_DEC_TU;
+			goto decline;
+		}
+	}
+	rc = smc_send_confirm(smc);
+	if (rc)
+		goto out_err;
+
+	if (smc->new_lgr) {
+		/* QP confirmation over RoCE fabric */
+		rc = smc_clnt_conf_first_lnk(smc, &roce_sugg, &reason_code);
+		if (rc)
+			goto decline;
+		/* receive ADD LINK request over RoCE fabric */
+		rc = smc_clnt_add_lnk(smc, &reason_code);
+		if (rc == -ENOLINK)
+			goto out_connected;
+		if (rc == -ETIMEDOUT)
+			goto out_err;
+		if (rc)
+			goto decline;
+	}
+
+out_connected:
+	sock->state = SS_CONNECTED;
+	smc_init_after_clc_handshake(smc);
+	/* copy setsockopt settings to tcpsocket to be prepared for fallback */
+	smc_copy_sockopt_settings(smc->tcpsocket->sk, sk);
+	/* to return meaningful values with getsockopt */
+	if (lgr) {
+		release_sock(sk);
+		if (mutex_is_locked(&lgr->conf_mutex))
+			mutex_unlock(&lgr->conf_mutex);
+	}
+	smc_apply_tmp_sockopts(sk->sk_socket, &smc->tmp_sockopts);
+	return 0;
+
+decline:
+	if (!smc_switch_to_tcp(smc, reason_code))
+		goto out_connected;
+out_err:
+	if (lgr) {
+		if (smc->new_lgr)
+			lgr->lgr_type = NONE;
+		release_sock(sk);
+		if (mutex_is_locked(&lgr->conf_mutex))
+			mutex_unlock(&lgr->conf_mutex);
+	}
+	smc->use_tcp = 1;
+	smc->sk.sk_state = SMC_CLOSED;
+	return -1;
+}
+
+static int smc_sock_connect(struct socket *sock, struct sockaddr *addr,
+			    int alen, int flags)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc = smc_sk(sk);
+	struct tcp_sock *tp = tcp_sk(smc->tcpsocket->sk);
+	int rc;
+
+	/* set SMC capability on tcp-socket */
+	tp->syn_smc = 1;
+	smc->addr = addr;
+
+	rc = kernel_connect(smc->tcpsocket, addr, alen, flags);
+	if (!rc || (rc == -EINPROGRESS)) { /* tbd: change EINPROGRESS handl. */
+		rc = smc_connect(smc);
+		if (rc)
+			rc = sock_error(sk);
+	} else {
+		smc->use_tcp = 1;
+		sk->sk_state = SMC_CLOSED;
+		sk->sk_err = -rc;
+		sk->sk_state_change(sk);
+	}
+
+	return rc;
+}
+
+static int smc_sock_listen(struct socket *sock, int backlog)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc = smc_sk(sk);
+	struct tcp_sock *tp = tcp_sk(smc->tcpsocket->sk);
+	int rc;
+
+	lock_sock(sk);
+	/* copy setsockopt settings to tcpsocket */
+	smc_copy_sockopt_settings(smc->tcpsocket->sk, sk);
+	/* set SMC capability on tcp-socket */
+	tp->syn_smc = 1;
+	rc = kernel_listen(smc->tcpsocket, backlog);
+
+	if (!rc) {
+		sk->sk_max_ack_backlog = backlog;
+		sk->sk_ack_backlog = 0;
+		sk->sk_state = SMC_LISTEN;
+		if (!smc->use_tcp) {
+			INIT_WORK(&smc->tcp_listen_work, smc_tcp_listen_worker);
+			schedule_work(&smc->tcp_listen_work);
+		}
+	}
+
+	release_sock(sk);
+	return rc;
+}
+
+static void smc_accept_enqueue(struct sock *parent, struct sock *sk)
+{
+	struct smc_sock *par = smc_sk(parent);
+
+	sock_hold(sk);
+	spin_lock(&par->accept_q_lock);
+	list_add_tail(&smc_sk(sk)->accept_q, &par->accept_q);
+	spin_unlock(&par->accept_q_lock);
+	sk_acceptq_added(parent);
+}
+
+static void smc_accept_unlink(struct sock *sk)
+{
+	struct smc_sock *par = smc_sk(sk)->listen_smc;
+
+	spin_lock(&par->accept_q_lock);
+	list_del_init(&smc_sk(sk)->accept_q);
+	spin_unlock(&par->accept_q_lock);
+	sk_acceptq_removed(&smc_sk(sk)->listen_smc->sk);
+	sock_put(sk);
+}
+
+static struct sock *smc_accept_dequeue(struct sock *parent,
+				       struct socket *newsock)
+{
+	struct smc_sock *isk, *n;
+	struct sock *sk;
+
+	list_for_each_entry_safe(isk, n, &smc_sk(parent)->accept_q, accept_q) {
+		sk = (struct sock *)isk;
+		lock_sock(sk);
+
+		smc_accept_unlink(sk);
+		if (newsock)
+			sock_graft(sk, newsock);
+		release_sock(sk);
+		return sk;
+	}
+	return NULL;
+}
+
+static int smc_sock_accept(struct socket *sock, struct socket *newsock,
+			   int flags)
+{
+	DECLARE_WAITQUEUE(wait, current);
+	struct sock *sk = sock->sk, *nsk;
+	long timeo;
+	int rc = 0;
+
+	lock_sock_nested(sk, SINGLE_DEPTH_NESTING);
+	timeo = sock_rcvtimeo(sk, flags & O_NONBLOCK);
+
+	/* Wait for an incoming connection */
+	add_wait_queue_exclusive(sk_sleep(sk), &wait);
+	while (!(nsk = smc_accept_dequeue(sk, newsock))) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		if (!timeo) {
+			rc = -EAGAIN;
+			break;
+		}
+
+		release_sock(sk);
+		timeo = schedule_timeout(timeo);
+		lock_sock_nested(sk, SINGLE_DEPTH_NESTING);
+
+		if (signal_pending(current)) {
+			rc = sock_intr_errno(timeo);
+			break;
+		}
+	}
+
+	set_current_state(TASK_RUNNING);
+	remove_wait_queue(sk_sleep(sk), &wait);
+
+	if (rc) {
+		release_sock(sk);
+		goto done;
+	}
+	rc = sock_error(nsk);
+	if (rc) {
+		release_sock(sk);
+		goto done;
+	}
+
+	newsock->state = SS_CONNECTED;
+	release_sock(sk);
+	smc_apply_tmp_sockopts(newsock, &smc_sk(sk)->tmp_sockopts);
+
+	/* don't get value from tmp_sockopts as TCP will mangle the value */
+	timeo = 0;
+	if (smc_sk(sk)->tmp_sockopts.set & SMC_SOCKOPTS_DEFER_ACCEPT)
+		timeo = smc_getsockopt_from_tcp(smc_sk(nsk), TCP_DEFER_ACCEPT);
+
+	if (!rc && timeo && !(flags & O_NONBLOCK)) {
+		int rc = 0;
+
+		timeo = msecs_to_jiffies(timeo * 1000);
+		if (smc_sk(nsk)->use_tcp) {
+			lock_sock(smc_sk(nsk)->tcpsocket->sk);
+			rc = sk_wait_data(smc_sk(nsk)->tcpsocket->sk, &timeo);
+			release_sock(smc_sk(nsk)->tcpsocket->sk);
+		} else {
+			lock_sock(nsk);
+			rc = smc_wait_rx_data(smc_sk(nsk), 1, 1, timeo);
+			release_sock(nsk);
+		}
+	}
+done:
+	return rc;
+}
+
+static int smc_getsockopt_from_tcp(struct smc_sock *smc, int optname)
+{
+	char optval[10];
+	int optlen;
+	int rc;
+
+	optlen = sizeof(optlen);
+	memset(optval, 0, sizeof(optval));
+	rc = kernel_getsockopt(smc->tcpsocket, SOL_TCP, optname, optval,
+			       &optlen);
+	if (rc)
+		return -EINVAL;
+	memcpy(&rc, optval, optlen);
+	return rc;
+}
+
+static void smc_keepalive_timer(unsigned long);
+static void smc_sock_destruct(struct sock *);
+
+static int smc_send_accept(struct smc_sock *new_smc,
+			   struct smc_acc_conf_clc_msg *cclc, int *reason_code)
+{
+	struct smc_link *link;
+	struct smc_link_group *lgr;
+	struct smc_connection *conn = &new_smc->conn;
+	struct smc_acc_conf_clc_msg aclc;
+	struct msghdr msg;
+	struct kvec vec;
+	int len, rc = 0;
+
+	link = &conn->lgr->lnk[conn->lnk_idx];
+	lgr = link->lnk_grp;
+	/* send SMC Accept CLC message (GID, MAC, VLAN, QP) */
+	memset(&aclc, 0, sizeof(struct smc_acc_conf_clc_msg));
+	aclc.hdr.flags = SMC_CLC_V1; /* smc version */
+	if (new_smc->new_lgr)
+		aclc.hdr.flags |= SMC_FIRST_CONTACT;
+	aclc.tcp_conn_idx = 1; /* as long as 1 RMB = 1 RMBE */
+	memcpy(&aclc.hdr2.gid, &link->roce_defs.gid,
+	       sizeof(link->roce_defs.gid));
+	memcpy(&aclc.hdr2.mac, link->roce_defs.mac,
+	       sizeof(link->roce_defs.mac));
+	hton_three(link->roce_qp->qp_num, aclc.qp_num);
+	hton_three(link->psn_initial, aclc.psn);
+	aclc.rmb_rkey =
+		htonl(conn->rmb_rx_elem->mr_rx[conn->lnk_idx]->rkey);
+	aclc.rmb_vaddr =
+		cpu_to_be64((u64)conn->rmb_rx_elem->rmb_rx_dma[conn->lnk_idx]);
+	memcpy(aclc.hdr.ec_clce, SMC_EC, sizeof(SMC_EC));
+	memcpy(aclc.hdr2.peer_id, local_peerid, sizeof(local_peerid));
+	aclc.hdr.type = SMC_CLC_ACCEPTANCE;
+	aclc.hdr.length = htons(sizeof(struct smc_acc_conf_clc_msg));
+	aclc.rmb_alert_token = conn->alert_token_local;
+	aclc.flags2 = conn->rmb_rx_size_short + link->path_mtu;
+	memcpy(aclc.ec_clcf, SMC_EC, sizeof(SMC_EC));
+
+	vec.iov_base = &aclc;
+	vec.iov_len = sizeof(struct smc_acc_conf_clc_msg);
+	memset(&msg, 0, sizeof(struct msghdr));
+	len = kernel_sendmsg(new_smc->tcpsocket, &msg, &vec, 1,
+			     sizeof(struct smc_acc_conf_clc_msg));
+	if (len < sizeof(struct smc_acc_conf_clc_msg)) {
+		*reason_code = SMC_CLC_DEC_SEND;
+		goto out;
+	}
+
+	/* receive SMC Confirm CLC message (MAC, GID, QP, link #, link user id)
+	 */
+	rc = clc_wait_msg(new_smc, SMC_CLC_BLOCK, (char *)cclc,
+			  sizeof(struct smc_acc_conf_clc_msg),
+			  SMC_CLC_CONFIRMATION, reason_code);
+out:
+	return rc;
+}
+
+static int smc_serv_conf_first_lnk(struct smc_sock *smc,
+				   struct smc_roce_defs *roce_sugg,
+				   int *reason_code)
+{
+	struct smc_link_group *lgr = smc->conn.lgr;
+	struct smc_link *link = &smc->conn.lgr->lnk[smc->conn.lnk_idx];
+	struct llc_qentry *qentry;
+	int rc = 0;
+
+	/* send CONFIRM LINK request over the RoCE fabric */
+	lgr->llc_ctl[LLC_SERV].active = LLC_GRP_ADD_LINK;
+	rc = llc_send_confirm_link(link, (u8 *)link->roce_defs.mac,
+				   &roce_sugg->gid, LLC_REQ, LLC_SERV);
+	if (rc < 0) {
+		*reason_code = SMC_CLC_DEC_TCL;
+		lgr->lgr_type = NONE;
+		goto out;
+	}
+	/* receive CONFIRM LINK response over the RoCE fabric */
+	qentry = llc_wait(lgr, LLC_SERV, LLC_WAIT_FIRST_TIMEO,
+			  LLC_CONFIRM_LINK);
+	if (!qentry) {
+		lgr->llc_ctl[LLC_SERV].active = LLC_GRP_NONE;
+		lgr->lgr_type = NONE;
+		wake_up_interruptible(&lgr->llc_waiter);
+		rc = llc_get_fail_cause(lgr, LLC_SERV, smc);
+		if (rc == -ECOMM)
+			*reason_code = SMC_CLC_DEC_SEND;
+		if (!rc) /* clc decline received */
+			rc = -EOPNOTSUPP;
+	} else {
+		kfree(qentry);
+		atomic_set(&link->state, SMC_LINK_UP);
+	}
+out:
+	return rc;
+}
+
+static int smc_serv_add_lnk(struct smc_sock *smc, int *reason_code)
+{
+	struct smc_link_group *lgr = smc->conn.lgr;
+	struct smc_link *link = &smc->conn.lgr->lnk[smc->conn.lnk_idx];
+	struct smc_roce_defs roce_sugg;
+	int rc = 0;
+
+	lgr->llc_ctl[LLC_SERV].qentry = NULL;
+	roce_sugg.ibdev = NULL;
+	roce_sugg.port = 0;
+	roce_sugg.vlan = lgr->vlan;
+	smc_find_alt_roce_resources(&roce_sugg, lgr, link);
+	rc = llc_srv_add_link(link, &roce_sugg, smc);
+	lgr->llc_ctl[LLC_SERV].active = LLC_GRP_NONE;
+	wake_up_interruptible(&lgr->llc_waiter);
+	return rc;
+}
+
+static void smc_listen_worker(struct work_struct *work)
+{
+	struct smc_sock *new_smc = container_of(work, struct smc_sock,
+						listen_work);
+	struct sock *newsmcsk = &new_smc->sk;
+	struct socket *newtcpsocket = new_smc->tcpsocket;
+	struct tcp_sock *ntp = tcp_sk(newtcpsocket->sk);
+	struct smc_sock *lsmc = new_smc->listen_smc;
+	struct sockaddr_in peeraddr;
+	char pclc_buf[sizeof(struct smc_proposal_clc_msg)
+		    + sizeof(struct smc_proposal_clc_msg2) + 40];
+	struct smc_proposal_clc_msg *pclc =
+		(struct smc_proposal_clc_msg *)&pclc_buf;
+	struct smc_proposal_clc_msg2 *pclc2;
+	struct smc_acc_conf_clc_msg cclc;
+	struct smc_link_group *lgr = NULL;
+	struct smc_link *link = NULL;
+	struct smc_roce_defs roce_sugg;
+	__be32 subnet = 0;
+	int reason_code = 0;
+	int rc = 0, len;
+	char pnet_id[SMC_MAX_PNET_ID_LEN];
+	u8 mlen = 0;
+
+	/* check if peer is smc capable */
+	if (!ntp->syn_smc) {
+		new_smc->use_tcp = 1;
+		goto out_connected;
+	}
+
+	kernel_getpeername(newtcpsocket, (struct sockaddr *)&peeraddr, &len);
+	new_smc->new_lgr = 0;
+	/* do inband token exchange
+	 * receive SMC Proposal CLC message (peer ID, GID, MAC, VLAN)
+	 */
+	rc = clc_wait_msg(new_smc, SMC_CLC_BLOCK, (char *)&pclc_buf,
+			  sizeof(pclc_buf), SMC_CLC_PROPOSAL, &reason_code);
+	if (rc)
+		goto out_err;
+	if (reason_code)
+			goto decline;
+
+	smc_find_roce_resources(&roce_sugg, pnet_id, &peeraddr,
+				newtcpsocket->sk);
+	if (!roce_sugg.ibdev) {
+		reason_code = SMC_CLC_DEC_CUC;
+		goto decline;
+	}
+
+	/* is it sufficient to use IP from connection itself? */
+	rc = smc_netinfo_by_tcpsk(&subnet, &mlen, newtcpsocket);
+	pclc2 = (struct smc_proposal_clc_msg2 *)
+		((char *)(pclc) + sizeof(struct smc_proposal_clc_msg)
+	       + pclc->iparea_offset);
+	if ((pclc2->outgoing_subnet != subnet) ||
+	    (pclc2->subnet_mask_bits != mlen)) {
+		reason_code = SMC_CLC_DEC_CUC;
+		goto decline;
+	}
+
+	/* allocate connection/link group*/
+	rc = smc_create_conn(new_smc, peeraddr.sin_addr.s_addr,
+			     SMC_SERV, &roce_sugg, &pclc->hdr2, 0);
+	if (rc == -ENOLINK)
+		goto out_err;
+	if (rc) {
+		reason_code = SMC_CLC_DEC_RIM;
+		goto decline;
+	}
+	lgr = new_smc->conn.lgr;
+	link = &new_smc->conn.lgr->lnk[new_smc->conn.lnk_idx];
+
+	if (lgr->lgr_type == NONE) {
+		reason_code = SMC_CLC_DEC_RIM;
+		goto decline;
+	}
+	rc = smc_create_rmbs(new_smc);
+	if (rc) {
+		reason_code = SMC_CLC_DEC_RIM;
+		goto decline;
+	}
+	atomic_set(&new_smc->conn.tx_buf_space, new_smc->conn.rmb_tx_size);
+
+	/* Announce RMB Rtoken */
+	if (new_smc->new_lgr) {
+		rc = smc_initial_map_rmb(new_smc);
+		if (rc) {
+			reason_code = SMC_CLC_DEC_RIM;
+			goto decline;
+		}
+	} else {
+		rc = smc_announce_rmb(new_smc, &reason_code);
+		if (rc)
+			goto decline;
+	}
+	strncpy(lgr->pnet_id, pnet_id, sizeof(pnet_id));
+	rc = smc_send_accept(new_smc, &cclc, &reason_code);
+	if (rc)
+		goto out_err;
+	if (reason_code)
+		goto decline;
+
+	smc_save_peer_info(new_smc, &cclc);
+	if (new_smc->new_lgr) {
+		ntoh_three(&link->qp_num_peer, cclc.qp_num);
+		smc_save_link_info(link, &cclc);
+	}
+	rc = smc_rtoken_handling(lgr, new_smc,
+				 (struct smc_acc_conf_clc_msg *)&cclc);
+	if (rc) {
+		reason_code = SMC_CLC_DEC_INT;
+		goto decline;
+	}
+
+	if (new_smc->new_lgr) {
+		rc = smc_ready_link(link);
+		if (rc) {
+			reason_code = SMC_CLC_DEC_INT;
+			goto decline;
+		}
+		lgr->max_links = SMC_MAX_SYM_LINKS;
+		lgr->lgr_type = SINGLE;
+		rc = smc_serv_conf_first_lnk(new_smc, &roce_sugg, &reason_code);
+		if (rc)
+			goto decline;
+		rc = smc_serv_add_lnk(new_smc, &reason_code);
+		if (rc == -ENOLINK)
+			goto out_connected;
+		else if (rc < 0)
+			goto out_err;
+	}
+
+out_connected:
+	if (lgr && mutex_is_locked(&lgr->conf_mutex))
+		mutex_unlock(&lgr->conf_mutex);
+	smc_sock_proc_create(newsmcsk);
+	sk_refcnt_debug_inc(newsmcsk);
+	if (!new_smc->use_tcp)
+		setup_timer(&newsmcsk->sk_timer, smc_keepalive_timer,
+			    (unsigned long)newsmcsk);
+	smc_init_after_clc_handshake(new_smc);
+	if (lsmc->sk.sk_state == SMC_LISTEN) {
+		smc_accept_enqueue(&lsmc->sk, newsmcsk);
+	} else {
+		smc_destruct_non_accepted(newsmcsk);
+		new_smc = NULL;
+	}
+
+	/* Wake up accept */
+	lsmc->sk.sk_data_ready(&lsmc->sk);
+	sock_put(&lsmc->sk);
+	return;
+
+decline:
+	if (!smc_switch_to_tcp(new_smc, reason_code))
+		goto out_connected;
+out_err:
+	if (lgr && mutex_is_locked(&lgr->conf_mutex))
+		mutex_unlock(&lgr->conf_mutex);
+	smc_free_conn(new_smc);
+	if (new_smc->proc) {
+		smc_sock_proc_remove(new_smc->proc_name);
+		new_smc->proc = NULL;
+	}
+
+	if (!newsmcsk->sk_err)
+		newsmcsk->sk_err = EPROTO;
+	newsmcsk->sk_state = SMC_CLOSED;
+	sock_set_flag(newsmcsk, SOCK_ZAPPED);
+	sock_set_flag(newsmcsk, SOCK_DEAD);
+	sock_put(newsmcsk);
+	sock_put(&lsmc->sk);
+}
+
+static void smc_tcp_listen_worker(struct work_struct *work)
+{
+	struct smc_sock *lsmc = container_of(work, struct smc_sock,
+					tcp_listen_work);
+	struct sock *newsmcsk;
+	struct smc_sock *new_smc = NULL;
+	struct socket *newtcpsocket = NULL;
+	struct tcp_sock *ntp;
+	int rc = 0;
+
+	while (lsmc->sk.sk_state == SMC_LISTEN) {
+		rc = kernel_accept(lsmc->tcpsocket, &newtcpsocket, 0);
+		if (lsmc->sk.sk_state == SMC_CLOSED) {
+			if (newtcpsocket)
+				sock_release(newtcpsocket);
+			goto out;
+		}
+		if (rc) {
+			/* find out if there is an error we have to
+			 * restart tcp accept
+			 */
+			lsmc->sk.sk_err = -rc;
+			goto out_error;
+		}
+		ntp = tcp_sk(newtcpsocket->sk);
+
+		newsmcsk = smc_sock_alloc(NULL, PF_SMC, GFP_KERNEL);
+		if (!newsmcsk) {
+			lsmc->sk.sk_err = ENOMEM;
+			sock_release(newtcpsocket);
+			goto out_error;
+		}
+
+		new_smc = smc_sk(newsmcsk);
+		new_smc->tcpsocket = newtcpsocket;
+		new_smc->listen_smc = lsmc;
+		sock_hold(&lsmc->sk); /* sock_put in smc_listen_worker */
+		INIT_WORK(&new_smc->listen_work, smc_listen_worker);
+		smc_copy_sockopt_settings(newsmcsk, lsmc->tcpsocket->sk);
+		schedule_work(&new_smc->listen_work);
+	}
+
+out_error:
+	lsmc->sk.sk_data_ready(&lsmc->sk); /* wake up accept socket */
+out:
+	return;
+}
+
+static int smc_sock_getname(struct socket *sock, struct sockaddr *addr,
+			    int *len, int peer)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc = smc_sk(sk);
+	int rc;
+
+	rc = smc->tcpsocket->ops->getname(smc->tcpsocket, addr, len, peer);
+	return rc;
+}
+
+static int smc_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
+			    struct msghdr *msg, size_t len)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc = smc_sk(sk);
+	int rc;
+
+	lock_sock(sk);
+	if (sk->sk_shutdown & SEND_SHUTDOWN) {
+		rc = -EPIPE;
+		goto out;
+	}
+
+	if (smc->use_tcp) {
+		rc = smc->tcpsocket->ops->sendmsg(iocb, smc->tcpsocket, msg,
+						  len);
+	} else {
+		if (smc_close_received(smc)) {
+			rc = -ECONNRESET;
+			goto out;
+		}
+		if (smc->conn.local_tx_ctrl.conn_state_flags.abnormal_close) {
+			rc = -ENOTCONN;
+			goto out;
+		}
+		if (sk->sk_err) {
+			rc = -EPIPE;
+			goto out;
+		}
+
+		rc = smc_conn_send(smc, iocb, msg, len);
+	}
+out:
+	rc = sk_stream_error(sk, msg->msg_flags, rc);
+	release_sock(sk);
+
+	return rc;
+}
+
+static int smc_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
+			    struct msghdr *msg, size_t len, int flags)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc = smc_sk(sk);
+	int rc = 0;
+
+	lock_sock(sk);
+	if (smc->use_tcp) {
+		if (!smc->tcpsocket)
+			return -ENOTCONN;
+		rc = smc->tcpsocket->ops->recvmsg(iocb, smc->tcpsocket, msg,
+						  len, flags);
+	} else {
+		rc = smc_conn_recv(smc, iocb, msg, len, flags);
+	}
+	release_sock(sk);
+	return rc;
+}
+
+static unsigned int smc_accept_poll(struct sock *parent)
+{
+	struct smc_sock *isk;
+	struct sock *sk;
+
+	lock_sock(parent);
+	list_for_each_entry(isk, &smc_sk(parent)->accept_q, accept_q) {
+		sk = (struct sock *)isk;
+
+		if (sk->sk_state == SMC_ACTIVE) {
+			release_sock(parent);
+			return POLLIN | POLLRDNORM;
+		}
+	}
+	release_sock(parent);
+
+	return 0;
+}
+
+static unsigned int smc_sock_poll(struct file *file, struct socket *sock,
+				  poll_table *wait)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc = smc_sk(sk);
+	unsigned int mask = 0;
+
+	if (smc->use_tcp || (sk->sk_state == SMC_INIT)) {
+		mask = smc->tcpsocket->ops->poll(file, smc->tcpsocket, wait);
+	} else {
+		sock_poll_wait(file, sk_sleep(sk), wait);
+		if (sk->sk_state == SMC_LISTEN)
+			return smc_accept_poll(sk);
+		if (sk->sk_err)
+			mask |= POLLERR;
+		if ((sk->sk_shutdown == SHUTDOWN_MASK) ||
+		    (sk->sk_state == SMC_CLOSED))
+			mask |= POLLHUP;
+		if (sk->sk_shutdown & RCV_SHUTDOWN)
+			mask |= POLLIN | POLLRDNORM | POLLRDHUP;
+		if (smc_to_read(smc))
+			mask |= POLLIN | POLLRDNORM;
+		if (sk->sk_state == SMC_APPLCLW1)
+			mask |= POLLIN;
+		if (!(sk->sk_shutdown & SEND_SHUTDOWN)) {
+			if (atomic_read(&smc->conn.tx_buf_space)) {
+				mask |= POLLOUT | POLLWRNORM;
+			} else {
+				set_bit(SOCK_ASYNC_NOSPACE,
+					&sk->sk_socket->flags);
+				set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+			}
+		} else {
+			mask |= POLLOUT | POLLWRNORM;
+		}
+		if ((smc->conn.rx_urg_state & SMC_URG_VALID) &&
+		    !(smc->conn.rx_urg_state & (SMC_URG_READ | SMC_URG_RECV)))
+			mask |= POLLPRI;
+	}
+	return mask;
+}
+
+static int smc_conn_shutdown(struct smc_sock *smc, int how)
+{
+	struct sock *sk = &smc->sk;
+	int rc = 0, ret = 0, old_state;
+
+	if (how == SHUT_RD)
+		return rc;
+
+	lock_sock(sk);
+	old_state = sk->sk_state;
+
+	if (how == SHUT_RDWR) {
+		smc_sk_release(smc, 1);
+		goto out;
+	}
+
+	/* how = SHUT_WR */
+	switch (sk->sk_state) {
+	/* Normal termination - Actice close parts */
+	case SMC_ACTIVE:
+	case SMC_PEERCLW1:
+		smc_wait_close(smc);
+		sk->sk_state = SMC_PEERCLW1;
+		/* fall through */
+	case SMC_PEERCLW2:
+		/* if shutdown(both) and unread data then connection reset
+		 * if outstanding data to be written or RDMA not compl,
+		 * then mask conn as pending close
+		 */
+		smc->conn.local_tx_ctrl.conn_state_flags.sending_done = 1;
+		ret = smc_ctrl_send(&smc->conn, smc->conn.lnk_idx);
+		break;
+	/* Normal termination - Passive close parts */
+	case SMC_APPLCLW1:
+		smc_wait_close(smc);
+		sk->sk_state = SMC_APPLCLW2;
+		smc->conn.local_tx_ctrl.conn_state_flags.sending_done = 1;
+		ret = smc_ctrl_send(&smc->conn, smc->conn.lnk_idx);
+		break;
+	default:
+		break;
+	}
+
+out:
+	if (old_state != sk->sk_state)
+		sk->sk_state_change(&smc->sk);
+	release_sock(sk);
+	if (ret)
+		rc = -ENOTCONN;
+	return rc;
+}
+
+static int smc_sock_shutdown(struct socket *sock, int how)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc = smc_sk(sk);
+	int rc = 0, how2 = how++;
+
+	if (how > SHUT_RDWR)
+		return -EINVAL;
+
+	kernel_sock_shutdown(smc->tcpsocket, how);
+
+	sk->sk_shutdown |= how2;
+
+	if (!smc->use_tcp)
+		rc = smc_conn_shutdown(smc, how);
+	return rc;
+}
+
+static u32 smc_keepalive_time_elapsed(struct smc_sock *smc)
+{
+	struct smc_link *link;
+	struct smc_link_group *lgr;
+
+	lgr = smc->conn.lgr;
+	link = &lgr->lnk[smc->conn.lnk_idx];
+	return (u32)jiffies - link->rcv_tstamp;
+}
+
+static int smc_sock_setsockopt(struct socket *sock, int level, int optname,
+			       char __user *optval, unsigned int optlen)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc = smc_sk(sk);
+	struct tcp_sock *tp = tcp_sk(smc->tcpsocket->sk);
+	struct timer_list *cork_timer = &smc->cork_timer;
+	int val;
+	int valbool;
+	u32 ka_tim, elapsed = 0;
+	int rc = 0;
+
+	lock_sock(sk);
+	if (level != SOL_SMC && level != SOL_TCP)
+		goto fallback;
+	switch (optname) {
+	case SMC_KEEPALIVE:
+		if (get_user(val, (int __user *)optval))
+			return -EFAULT;
+		valbool = val ? 1 : 0;
+		rc = kernel_setsockopt(smc->tcpsocket, SOL_SOCKET,
+				       SO_KEEPALIVE, (char *)&val,
+				       sizeof(val));
+		if (rc || smc->use_tcp)
+			goto ret;
+		if (sk->sk_state == SMC_ACTIVE) {
+			ka_tim = tp->keepalive_time ? : TCP_KEEPALIVE_TIME;
+			if (valbool && !sock_flag(sk, SOCK_KEEPOPEN))
+				sk_reset_timer(sk, &sk->sk_timer,
+					       jiffies + (unsigned long)ka_tim);
+			else if (!valbool)
+				sk_stop_timer(sk, &sk->sk_timer);
+		}
+		if (valbool)
+			sock_set_flag(sk, SOCK_KEEPOPEN);
+		else
+			sock_reset_flag(sk, SOCK_KEEPOPEN);
+		break;
+	case TCP_KEEPIDLE:
+		rc = smc->tcpsocket->ops->setsockopt(smc->tcpsocket, SOL_TCP,
+			optname, optval, optlen);
+		if (rc || smc->use_tcp)
+			goto ret;
+		if (get_user(val, (int __user *)optval))
+			return -EFAULT;
+		ka_tim = val;
+		if (sk->sk_state == SMC_ACTIVE) {
+			if (ka_tim && sock_flag(sk, SOCK_KEEPOPEN)) {
+				elapsed = smc_keepalive_time_elapsed(smc);
+				if (ka_tim > elapsed)
+					elapsed = ka_tim - elapsed;
+				sk_reset_timer(sk, &sk->sk_timer,
+					       jiffies + elapsed);
+			} else {
+				sk_stop_timer(sk, &sk->sk_timer);
+			}
+		}
+		break;
+	case TCP_CORK:
+		if (optlen < sizeof(int))
+			return -EINVAL;
+		if (get_user(val, (int __user *)optval))
+			return -EFAULT;
+		if (sk->sk_state == SMC_INIT || sk->sk_state == SMC_LISTEN) {
+			smc->tmp_sockopts.cork = val;
+			smc->tmp_sockopts.set |= SMC_SOCKOPTS_CORK;
+		} else {
+			rc = smc->tcpsocket->ops->setsockopt(smc->tcpsocket,
+					level, optname, optval, optlen);
+			if (!rc && !smc->use_tcp) {
+				if (!val && timer_pending(cork_timer)) {
+					del_timer_sync(cork_timer);
+					destroy_timer_on_stack(cork_timer);
+					smc_write_data(smc);
+				}
+			}
+		}
+		break;
+	case TCP_DEFER_ACCEPT:
+		if (optlen < sizeof(int))
+			return -EINVAL;
+		if (sk->sk_state == SMC_INIT || sk->sk_state == SMC_LISTEN) {
+			if (get_user(val, (int __user *)optval))
+				return -EFAULT;
+			smc->tmp_sockopts.defer_accept = val;
+			smc->tmp_sockopts.set |= SMC_SOCKOPTS_DEFER_ACCEPT;
+		} else {
+			goto fallback;
+		}
+		break;
+	case TCP_NODELAY:
+		if (optlen < sizeof(int))
+			return -EINVAL;
+		if (get_user(val, (int __user *)optval))
+			return -EFAULT;
+		if (sk->sk_state == SMC_INIT || sk->sk_state == SMC_LISTEN) {
+			smc->tmp_sockopts.nodelay = val;
+			smc->tmp_sockopts.set |= SMC_SOCKOPTS_NODELAY;
+		} else {
+			if (!smc->use_tcp) {
+				if (val && timer_pending(cork_timer)) {
+					del_timer_sync(cork_timer);
+					destroy_timer_on_stack(cork_timer);
+					smc_write_data(smc);
+				}
+			}
+			goto fallback;
+		}
+		break;
+	default:
+		goto fallback;
+	}
+	goto ret;
+fallback:
+	if (level == SOL_SMC)
+		level = SOL_TCP;
+	rc = smc->tcpsocket->ops->setsockopt(smc->tcpsocket, level,
+		optname, optval, optlen);
+ret:
+	release_sock(sk);
+	return rc;
+}
+
+static int smc_sock_getsockopt(struct socket *sock, int level, int optname,
+			       char __user *optval, int __user *optlen)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc = smc_sk(sk);
+	int val, len;
+	int rc = 0;
+
+	if (level == SOL_SMC)
+		level = SOL_TCP;
+	if (smc->use_tcp)
+		return smc->tcpsocket->ops->getsockopt(smc->tcpsocket, level,
+						       optname, optval, optlen);
+	if (get_user(len, optlen))
+		return -EFAULT;
+	if (len < 0)
+		return -EINVAL;
+
+	if (level == SOL_IP) {
+		switch (optname) {
+		case IP_MTU:
+			if (sock->state != SS_CONNECTED || !smc->conn.lgr)
+				return -ENOTCONN;
+			val = ib_mtu_enum_to_int(
+				smc->conn.lgr->lnk[smc->conn.lnk_idx].mtu_peer);
+				break;
+		default:
+			goto fallback;
+		}
+	} else {
+		if (level != SOL_TCP)
+			goto fallback;
+	}
+	/* level is SOL_TCP */
+	switch (optname) {
+	case TCP_CORK:
+		if (sk->sk_state == SMC_INIT ||
+		    sk->sk_state == SMC_LISTEN) {
+			val = !!smc->tmp_sockopts.cork;
+		} else {
+			goto fallback;
+		}
+		break;
+	case TCP_DEFER_ACCEPT:
+		if (sk->sk_state == SMC_INIT ||
+		    sk->sk_state == SMC_LISTEN) {
+			val = smc->tmp_sockopts.defer_accept;
+		} else {
+			goto fallback;
+		}
+		break;
+	case TCP_NODELAY:
+		if (sk->sk_state == SMC_INIT ||
+		    sk->sk_state == SMC_LISTEN) {
+			val = !!smc->tmp_sockopts.nodelay;
+		} else {
+			goto fallback;
+		}
+		break;
+	default:
+		goto fallback;
+	}
+
+	if (len < sizeof(val) && len > 0 && val >= 0 && val <= 255) {
+		unsigned char ucval = (unsigned char)val;
+
+		len = 1;
+		if (put_user(len, optlen))
+			return -EFAULT;
+		if (copy_to_user(optval, &ucval, 1))
+			return -EFAULT;
+	} else {
+		len = min_t(unsigned int, sizeof(int), len);
+		if (put_user(len, optlen))
+			return -EFAULT;
+		if (copy_to_user(optval, &val, len))
+			return -EFAULT;
+	}
+
+fallback:
+	return rc;
+}
+
+static int smc_sock_ioctl(struct socket *sock, unsigned int cmd,
+			  unsigned long arg)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc = smc_sk(sk);
+	struct smc_connection *conn = &smc->conn;
+	int answ;
+	struct smc_curs urg, c_curs;
+
+	if (smc->use_tcp)
+		return smc->tcpsocket->ops->ioctl(smc->tcpsocket, cmd, arg);
+
+	switch (cmd) {
+	case SIOCINQ:
+		if (sk->sk_state == SMC_LISTEN)
+			return -EINVAL;
+
+		if (sk->sk_state == SMC_INIT)
+			answ = 0;
+		else
+			answ = smc_to_read(smc);
+		break;
+	case SIOCATMARK:
+		if ((sk->sk_state == SMC_INIT) ||
+		    (sk->sk_state == SMC_LISTEN)) {
+			answ = 0;
+		} else {
+			struct smc_e_ctrl *tx_ctrl = &conn->local_tx_ctrl;
+
+			urg.s.lcurs = atomic64_read(&conn->rx_urg_curs.s.acurs);
+			if (!sock_flag(&smc->sk, SOCK_URGINLINE))
+				smc_curs_add(conn->rmb_rx_size, &urg.s.curs, 1);
+
+			c_curs.s.lcurs =
+				atomic64_read(&tx_ctrl->c_curs.s.acurs);
+			if ((conn->rx_urg_state & SMC_URG_VALID) &&
+			    (urg.s.curs.c == c_curs.s.curs.c) &&
+			    (urg.s.curs.w == c_curs.s.curs.w))
+				answ = 1;
+			else
+				answ = 0;
+		}
+		break;
+	case SIOCOUTQ:
+		/* output queue size (not send + not acked) */
+		if (sk->sk_state == SMC_LISTEN)
+			return -EINVAL;
+
+		if (sk->sk_state == SMC_INIT)
+			answ = 0;
+		else
+			answ = smc->conn.rmb_tx_size -
+					atomic_read(&smc->conn.tx_buf_space);
+		break;
+	case SIOCOUTQNSD:
+		/* output queue size (not send only) for smc always 0 */
+		if (sk->sk_state == SMC_LISTEN)
+			return -EINVAL;
+
+		answ = 0;
+		break;
+	default:
+		return -ENOIOCTLCMD;
+	}
+
+	return put_user(answ, (int __user *)arg);
+}
+
+static ssize_t smc_sock_sendpage(struct socket *sock, struct page *page,
+				 int offset, size_t size, int flags)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc = smc_sk(sk);
+	int rc = 0;
+
+	if (smc->use_tcp)
+		rc = smc->tcpsocket->ops->sendpage(smc->tcpsocket, page,
+						   offset, size, flags);
+	else
+		rc = sock_no_sendpage(sock, page, offset, size, flags);
+
+	return rc;
+}
+
+static ssize_t smc_sock_splice_read(struct socket *sock, loff_t *ppos,
+				    struct pipe_inode_info *pipe, size_t len,
+				    unsigned int flags)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc = smc_sk(sk);
+	int rc = 0;
+
+	if (smc->use_tcp) {
+		rc = smc->tcpsocket->ops->splice_read(smc->tcpsocket, ppos,
+						      pipe, len, flags);
+	} else {
+		if (*ppos)
+			/* we don't support offsets on our socket */
+			return -ESPIPE;
+		lock_sock(sk);
+		rc = smc_conn_splice_read(smc, pipe, len, flags);
+		release_sock(sk);
+	}
+
+	return rc;
+}
+
+/* must look like tcp */
+static const struct proto_ops smc_sock_ops = {
+	.family		= PF_SMC,
+	.owner		= THIS_MODULE,
+	.release	= smc_sock_release,
+	.bind		= smc_sock_bind,
+	.connect	= smc_sock_connect,
+	.socketpair	= sock_no_socketpair,
+	.accept		= smc_sock_accept,
+	.getname	= smc_sock_getname,
+	.poll		= smc_sock_poll,
+	.ioctl		= smc_sock_ioctl,
+	.listen		= smc_sock_listen,
+	.shutdown	= smc_sock_shutdown,
+	.setsockopt	= smc_sock_setsockopt,
+	.getsockopt	= smc_sock_getsockopt,
+	.sendmsg	= smc_sock_sendmsg,
+	.recvmsg	= smc_sock_recvmsg,
+	.mmap		= sock_no_mmap,
+	.sendpage	= smc_sock_sendpage,
+	.splice_read	= smc_sock_splice_read,
+};
+
+static int smc_sock_init_tcp(struct smc_sock *smc)
+{
+	int rc;
+
+	rc = sock_create_kern(PF_INET, SOCK_STREAM, IPPROTO_TCP,
+			      &smc->tcpsocket);
+	smc->sk.sk_rcvbuf = max_t(size_t, smc_def_rcvbuf_size,
+					  smc->tcpsocket->sk->sk_rcvbuf);
+	smc->sk.sk_sndbuf = max_t(size_t, smc_def_sndbuf_size,
+					  smc->tcpsocket->sk->sk_sndbuf);
+	tcp_sk(smc->tcpsocket->sk)->nonagle |= TCP_NAGLE_OFF|TCP_NAGLE_PUSH;
+	return rc;
+}
+
+static void smc_timer_worker(struct work_struct *);
+
+static void smc_sock_destruct(struct sock *sk)
+{
+	struct smc_sock *smc = smc_sk(sk);
+
+	if (sk->sk_state != SMC_CLOSED)
+		return;
+	sk->sk_state = SMC_DESTRUCT;
+	if (!sock_flag(sk, SOCK_DEAD))
+		return;
+
+	sk_stop_timer(sk, &sk->sk_timer);
+	if (timer_pending(&smc->fin_timer)) {
+		del_timer_sync(&smc->fin_timer);
+		destroy_timer_on_stack(&smc->fin_timer);
+	}
+
+	smc_free_conn(smc);
+	if (smc->proc) {
+		smc_sock_proc_remove(smc->proc_name);
+		smc->proc = NULL;
+	}
+
+	sk_refcnt_debug_dec(sk);
+}
+
+static void smc_release_worker(struct work_struct *work)
+{
+	struct smc_sock *smc = container_of(work, struct smc_sock,
+					release_work);
+
+	if (delayed_work_pending(&smc->write_work))
+		cancel_delayed_work_sync(&smc->write_work);
+	lock_sock(&smc->sk); /* make sure smc_sock_release is done */
+	smc_wait_for_pending_sends(smc);
+	release_sock(&smc->sk);
+	sock_put(&smc->sk);
+}
+
+static void smc_timer_worker(struct work_struct *work)
+{
+	struct smc_sock *smc = container_of(work, struct smc_sock,
+					timer_work);
+	struct tcp_sock *tp = tcp_sk(smc->tcpsocket->sk);
+	struct smc_link *link;
+	struct smc_link_group *lgr;
+	struct llc_qentry *qentry;
+	int i, probes, rest_time, lnk_idx;
+
+	lgr = smc->conn.lgr;
+	probes = tp->keepalive_probes ? : TCP_KEEPALIVE_PROBES;
+	for (i = 0; i <= SMC_MAX_SYM_LINKS; i++) {
+		link = &lgr->lnk[i];
+		lnk_idx = link - &lgr->lnk[0];
+		if (atomic_read(&link->state) != SMC_LINK_UP)
+			continue;
+		/* initiate keepalive */
+		rest_time = llc_initiate(lgr, LLC_GRP_TEST_LINK);
+		if (!rest_time) {
+			link->probes_out++;
+			if ((link->probes_out >= probes) &&
+			    (cmpxchg(&lgr->lnk_down[lnk_idx], 0, 1) == 0)) {
+				schedule_work(&lgr->link_down_work);
+			}
+			return;
+		}
+		if (llc_send_test_link(link, "KEEPALIVE_CHECK")) {
+			llc_stop(lgr, LLC_GRP_TEST_LINK);
+			return;
+		}
+		qentry = llc_wait(lgr, LLC_TESTLINK, LLC_WAIT_TIMER_TIMEO,
+				  LLC_TEST_LINK);
+		if (!qentry) {
+			link->probes_out++;
+			if ((link->probes_out >= probes) &&
+			    (cmpxchg(&lgr->lnk_down[lnk_idx], 0, 1) == 0)) {
+				schedule_work(&lgr->link_down_work);
+			}
+		} else {
+			link->probes_out = 0;
+		}
+		kfree(qentry);
+		llc_stop(lgr, LLC_GRP_TEST_LINK);
+	}
+}
+
+static void smc_keepalive_timer(unsigned long data)
+{	/* derived from tcp_keepalive_timer() */
+	struct sock *sk = (struct sock *)data;
+	struct smc_sock *smc = smc_sk(sk);
+	struct tcp_sock *tp = tcp_sk(smc->tcpsocket->sk);
+	struct inet_connection_sock *icsk = inet_csk(smc->tcpsocket->sk);
+	u32 elapsed, time, intvl;
+
+	/* Only process if socket is not in use. */
+	bh_lock_sock(sk);
+	if (sock_owned_by_user(sk)) {
+		/* Try again later */
+		sk_reset_timer(sk, &sk->sk_timer, jiffies + HZ/20);
+		goto out;
+	}
+
+	if (sk->sk_state == SMC_LISTEN)
+		goto out;
+	if (!sock_flag(sk, SOCK_KEEPOPEN) || (sk->sk_state != SMC_ACTIVE))
+		goto out;
+
+	time = tp->keepalive_time ? : TCP_KEEPALIVE_TIME;
+	if (!time)
+		goto out;
+	intvl = tp->keepalive_intvl ? : TCP_KEEPALIVE_INTVL;
+	elapsed = smc_keepalive_time_elapsed(smc);
+
+	if ((elapsed >= intvl) &&
+	    (!icsk->icsk_user_timeout ||
+	     (elapsed >= icsk->icsk_user_timeout))) {
+		schedule_work(&smc->timer_work);
+		elapsed = intvl;
+	}
+
+	sk_reset_timer(sk, &sk->sk_timer, jiffies + (unsigned long)elapsed);
+out:
+	bh_unlock_sock(sk);
+	sock_put(sk);
+}
+
+static void smc_corked_write_cb(unsigned long arg)
+{
+	struct smc_sock *smc = (struct smc_sock *)arg;
+
+	if (!delayed_work_pending(&smc->write_work))
+		schedule_delayed_work(&smc->write_work, 0);
+}
+
+static void smc_fin_cb(unsigned long arg)
+{
+	struct smc_sock *smc = (struct smc_sock *)arg;
+	struct sock *tcpsk;
+
+	sock_hold(&smc->sk);
+	smc->sk.sk_err = ETIMEDOUT;
+	smc->conn.local_tx_ctrl.conn_state_flags.abnormal_close = 1;
+	smc->conn.local_rx_ctrl.conn_state_flags.abnormal_close = 1;
+	if (smc->tcpsocket && smc->tcpsocket->sk) {
+		smc->tcpsocket->sk->sk_err = ECONNABORTED;
+		smc->tcpsocket->sk->sk_data_ready(smc->tcpsocket->sk);
+	}
+	smc->sk.sk_state = SMC_CLOSED;
+	smc->sk.sk_shutdown = smc->sk.sk_shutdown | RCV_SHUTDOWN;
+	if (smc->tcpsocket) {
+		tcpsk = smc->tcpsocket->sk;
+		tcpsk->sk_shutdown = tcpsk->sk_shutdown | RCV_SHUTDOWN;
+	}
+	sock_set_flag(&smc->sk, SOCK_DEAD);
+	smc->sk.sk_state_change(&smc->sk);
+	wake_up_interruptible(&smc->rx_waiter);
+	smc_sock_wake_tx(&smc->sk);
+	smc_sock_wake_rx(&smc->sk);
+	sock_put(&smc->sk);
+	if (cmpxchg(&smc->sock_put_done, 0, 1) == 0)
+		schedule_work(&smc->release_work);
+}
+
+static struct sock *smc_sock_alloc(struct socket *sock, int proto, gfp_t prio)
+{
+	struct sock *sk;
+	struct smc_sock *smc;
+
+	sk = sk_alloc(&init_net, PF_SMC, prio, &smc_proto);
+	if (!sk)
+		return NULL;
+	smc = smc_sk(sk);
+	smc->tcpsocket = NULL;
+	smc->use_tcp = 0;
+	memset(&smc->conn, 0, sizeof(struct smc_connection));
+	smc->spd = NULL;
+	smc->proc = NULL;
+
+	sock_init_data(sock, sk);
+	sk->sk_state = SMC_INIT;
+	INIT_LIST_HEAD(&smc->accept_q);
+	spin_lock_init(&smc->accept_q_lock);
+	sk->sk_destruct = smc_sock_destruct;
+	INIT_WORK(&smc->release_work, smc_release_worker);
+	INIT_WORK(&smc->timer_work, smc_timer_worker);
+	sock_reset_flag(sk, SOCK_ZAPPED);
+	sk->sk_protocol = proto;
+	init_waitqueue_head(&smc->splice_waiter);
+	setup_timer(&smc->cork_timer, smc_corked_write_cb, (unsigned long)smc);
+	setup_timer(&smc->fin_timer, smc_fin_cb, (unsigned long)smc);
+	smc_init_tmp_sockopts(smc);
+
+	return sk;
+}
+
+static int smc_sock_create(struct net *net, struct socket *sock, int protocol,
+			   int kern)
+{
+	struct sock *sk;
+	struct smc_sock *smc;
+	int rc = 0;
+
+	sock->state = SS_UNCONNECTED;
+
+	switch (sock->type) {
+	case SOCK_STREAM:
+		sock->ops = &smc_sock_ops;
+		break;
+	default:
+		return -ESOCKTNOSUPPORT;
+	}
+
+	sk = smc_sock_alloc(sock, protocol, GFP_KERNEL);
+	if (!sk)
+		return -ENOMEM;
+
+	smc = smc_sk(sk);
+	rc = smc_sock_init_tcp(smc);
+	if (rc)
+		goto out;
+	smc_sock_proc_create(sk);
+	setup_timer(&sk->sk_timer, smc_keepalive_timer, (unsigned long)sk);
+
+	sk_refcnt_debug_inc(sk);
+out:
+	return rc;
+}
+
+static const struct net_proto_family smc_sock_family_ops = {
+	.family	= AF_SMC,
+	.owner	= THIS_MODULE,
+	.create	= smc_sock_create,
+};
+
+static int __init af_smc_init(void)
+{
+	int rc;
+
+#ifdef CONFIG_PROC_FS
+	rc = smc_proc_init();
+	if (rc) {
+		rc = -EFAULT;
+		goto out;
+	}
+#else
+	pr_warn("smc requires /proc file system\n");
+	rc = -ENOENT;
+	goto out;
+#endif /* CONFIG_PROC_FS */
+
+	INIT_LIST_HEAD(&smc_ib_devices);
+	spin_lock_init(&smc_ib_dev_lock);
+	INIT_LIST_HEAD(&smc_lgr_list.list);
+	spin_lock_init(&smc_lgr_list.lock);
+	smc_lgr_list.create_conn_pending = 0;
+
+	rc = proto_register(&smc_proto, 0);
+	if (rc) {
+		pr_warn("smc proto_register fails with %d\n", rc);
+		goto out;
+	}
+
+	rc = sock_register(&smc_sock_family_ops);
+	if (rc) {
+		pr_warn("smc sock_register fails with %d\n", rc);
+		goto out_proto;
+	}
+
+	rc = ib_register_client(&smc_ib_client);
+	if (rc)
+		goto out_sock;
+
+	return 0;
+
+out_sock:
+	sock_unregister(PF_SMC);
+out_proto:
+	proto_unregister(&smc_proto);
+out:
+	return rc;
+}
+
+static void __exit af_smc_exit(void)
+{
+	ib_unregister_client(&smc_ib_client);
+	sock_unregister(PF_SMC);
+	proto_unregister(&smc_proto);
+	smc_proc_exit();
+}
+
+module_init(af_smc_init);
+module_exit(af_smc_exit);
+
+MODULE_AUTHOR("Ursula Braun <ursula.braun@de.ibm.com>");
+MODULE_DESCRIPTION("smc socket address family");
+MODULE_VERSION(VERSION);
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NETPROTO(PF_SMC);
diff --git a/net/smc/af_smc.h b/net/smc/af_smc.h
new file mode 100644
index 0000000..fa0a672
--- /dev/null
+++ b/net/smc/af_smc.h
@@ -0,0 +1,669 @@
+/*
+ *  Shared Memory Communications over RDMA (SMC-R) and ROCE
+ *
+ *  Definitions for the SMC module
+ *
+ *  Copyright IBM Corp. 2014
+ *
+ *  Author(s):  Ursula Braun <ursula.braun@de.ibm.com>
+ */
+
+#include <linux/types.h>
+#include <net/tcp_states.h>
+
+extern struct list_head smc_ib_devices;
+extern struct ib_client smc_ib_client;
+
+struct smc_lgr_list_struct {
+	struct list_head list;
+	spinlock_t lock;	/* protects list of link groups */
+	u32 create_conn_pending;
+};
+
+extern struct smc_lgr_list_struct smc_lgr_list; /* list of link groups */
+extern u32 smc_ctrl_buf_cnt;		/* # of ctrl buffers per link */
+extern u32 smc_max_conn_per_lgr;	/* max. # of connections per lgr */
+extern atomic_t smc_lgr_num;		/* for creation of a unique lgr id */
+extern atomic_t smc_reconfiguring;	/* signal port adding / deleting */
+extern unsigned int smc_def_sndbuf_size;	/* minimum sndbuf size */
+extern unsigned int smc_def_rcvbuf_size;	/* minimum rcvbuf size */
+
+#define SMC_VERSION 0x10			/* first 4 bits */
+#define SMC_LOCAL_PEERID_RESET	"%%%%%%%%"
+
+#define SMC_MAX_PNET_ID_LEN	16
+
+#define SMC_FIRST_CONTACT 0x08			/* bit 4 */
+#define SMC_LINK_GROUP_OUT_OF_SYNCH 0x08	/* bit 4 */
+
+#define SMC_MAX_CQE 32768	/* max. # of completion queue elements */
+#define SMC_MAX_WRE 1024	/* max. # of work requests in flight per QP */
+#define SMC_MAX_POLL_CQE 10	/* max. # of compl. queue elements in 1 poll */
+#define SMC_KEEPALIVE 99	/* to be defined finitely */
+#define SMC_MAX_SYM_LINKS 2	/* max. # of symmetric links */
+#define SMC_MAX_RMB 255		/* max. # of RMBs/connections per link group */
+#define SMC_MIN_RMBE_SIZE 16384	/* minimum size of an RMBE */
+
+#define SMC_EYE_CATCHER_TX	"RMBT"
+#define SMC_EYE_CATCHER		"RMBE"
+#define SMC_EYE_CATCH_LEN	4
+#define SMC_RMBE_SIZE_VALUES	16
+
+#define SMC_LNK_EYE_CATCHER	"SMC_LINK"
+#define SMC_LNK_EYE_CATCH_LEN	8
+
+#define SMC_SIZE_OF_CTRL_DATA	44
+#define SMC_SIZE_OF_CTRL_BUF	sizeof(struct rmb_e_ctrl)
+
+#define SMC_URG_VALID		0x01
+#define SMC_URG_RECV		0x02
+#define SMC_URG_READ		0x04
+#define SMC_URG_MASK		0x03
+
+#define SMC_CLC_V1		0x10
+
+#define SMC_CLC_PROPOSAL	0x01
+#define SMC_CLC_ACCEPTANCE	0x02
+#define SMC_CLC_CONFIRMATION	0x03
+#define SMC_CLC_DECLINE		0x04
+
+#define SMC_CLC_BLOCK		0
+#define SMC_CLC_NONBLOCK	1
+
+#define SMC_QP_TIMEOUT			10
+#define SMC_MIN_RNR_TIMER		5
+#define SMC_RETRY_CNT			7
+#define SMC_RNR_RETRY			7 /* infinite */
+#define LLC_WAIT_FIRST_TIMEO		(5*HZ)
+#define LLC_WAIT_TIMEO			(2*HZ)
+#define LLC_WAIT_TIMER_TIMEO		HZ
+/* #define SMC_FREE_LGR_TIMEO		(600*HZ) */
+#define SMC_FREE_LGR_TIMEO		(LLC_WAIT_TIMEO + 5*HZ) /* zOS: 10min */
+#define SMC_WAIT_PENDING_SENDS_TIMEO	LLC_WAIT_TIMEO
+#define SMC_WAIT_FREE_CTRL_BUF_TIMEO	HZ
+#define SMC_WAIT_RX_SPACE_TIMEO		(20*HZ)
+#define SMC_WAIT_TX_SPACE_TIMEO		(20*HZ)
+
+#define SMC_CLC_DEC_RUI		0x01000000  /* insufficient resources         */
+#define SMC_CLC_DEC_RIM		0x01010000  /* insufficient memory resources  */
+#define SMC_CLC_DEC_RIQ		0x01020000  /* insufficient QP resources      */
+#define SMC_CLC_DEC_TU		0x02000000  /* timeout                        */
+#define SMC_CLC_DEC_TPC		0x02010000  /* timeout w4 proposal            */
+#define SMC_CLC_DEC_TAS		0x02020000  /* timeout w4 accept              */
+#define SMC_CLC_DEC_TCC		0x02030000  /* timeout w4 confirm             */
+#define SMC_CLC_DEC_TCL		0x02040000  /* timeout w4 QP confirm          */
+#define SMC_CLC_DEC_CUC		0x03000000  /* configuration error            */
+#define SMC_CLC_DEC_CSLV	0x03010000  /* server lacks RoCE acc. to VLAN */
+#define SMC_CLC_DEC_CNIC	0x03020000  /* RNIC error                     */
+#define SMC_CLC_DEC_SU		0x04000000  /* synchronization error          */
+#define SMC_CLC_DEC_SFCB	0x04010000  /* first contact bit expected     */
+#define SMC_CLC_DEC_FORM	0x05000000  /* format error in received resp. */
+#define SMC_CLC_DEC_REPLY	0x06000000  /* reply to a received decline    */
+#define SMC_CLC_DEC_SEND	0x07000000  /* sending problem                */
+#define SMC_CLC_DEC_INT		0x99990000  /* internal error                 */
+
+#define SMC_LLC_DEL_NOLNK	0x00100000  /* Unknown Link ID (no link)      */
+#define SMC_LLC_DEL_NOLGR	0x00200000  /* Unknown Link Group             */
+
+#define SMC_SOCKOPTS_CORK		0x00000001
+#define SMC_SOCKOPTS_DEFER_ACCEPT	0x00000002
+#define SMC_SOCKOPTS_NODELAY		0x00000004
+
+#define smc_sk(__sk) ((struct smc_sock *)__sk)
+
+#define smc_lnk_downing(state) \
+	(atomic_cmpxchg(state, SMC_LINK_UP, SMC_LINK_DOWN) == SMC_LINK_UP)
+
+#define smc_stop_received(conn) \
+	(conn->local_rx_ctrl.conn_state_flags.sending_done || \
+	 conn->local_rx_ctrl.conn_state_flags.abnormal_close || \
+	 conn->local_rx_ctrl.conn_state_flags.closed_conn)
+
+#define smc_close_received(smc) \
+	(smc->conn.local_rx_ctrl.conn_state_flags.abnormal_close || \
+	 smc->conn.local_rx_ctrl.conn_state_flags.closed_conn)
+
+enum smc_role {		/* possible roles of a link group */
+	SMC_CLNT,	/* client */
+	SMC_SERV	/* server */
+};
+
+enum smc_state {	/* possible states of an SMC socket */
+	SMC_ACTIVE	= TCP_ESTABLISHED,	/* (1) connected */
+	SMC_INIT	= TCP_SYN_SENT,		/* (2) */
+	SMC_CLOSED	= TCP_CLOSE,		/* (7) */
+	SMC_LISTEN	= TCP_LISTEN,	/* (10)required for SO_ACCEPTCONN */
+	SMC_PEERCLW1	= 20,
+	SMC_PEERCLW2	= 21,
+	SMC_APPLCLW1	= 22,
+	SMC_APPLCLW2	= 23,
+	SMC_APPLFINCLW	= 24,
+	SMC_PEERFINCLW	= 25,
+	SMC_PEERABORTW	= 26,
+	SMC_PROCESSABORT = 27,
+	SMC_DESTRUCT	= 32
+};
+
+enum smc_link_state {	/* possible states of a link */
+	SMC_LINK_DOWN,
+	SMC_LINK_ACTIVATING,
+	SMC_LINK_UP,
+	SMC_LINK_FREED
+};
+
+enum llc_ctl_ind {	/* possible llc event control range */
+	LLC_CLNT,	/* as in smc_role */
+	LLC_SERV,	/* as in smc_role */
+	LLC_TESTLINK,
+	LLC_NO_NOTIFY
+};
+
+enum llc_msg_group {	/* classifies llc events */
+	LLC_GRP_NONE		= 0,
+	LLC_GRP_CONF_RKEY	= 1,
+	LLC_GRP_ADD_LINK	= 2,
+	LLC_GRP_DEL_LINK	= 3,
+	LLC_GRP_TEST_LINK	= 4
+};
+
+struct llc_ctl {	/* llc event data */
+	struct llc_qentry	*qentry;	/* llc event data */
+	enum llc_msg_group	active;		/* current llc event group */
+	int			lnk_idx;	/* active link for llc event */
+	int			ctrl_elem;	/* used ctrl buffer element */
+	int			wc_status;	/* status of sent llc event */
+};
+
+struct rmb_conn_state_flags {
+	u8	sending_done : 1;
+	u8	closed_conn : 1;
+	u8	abnormal_close : 1;
+	u8	reserved : 5;
+} __packed;
+
+struct rmb_producer_flags {
+	u8	 write_blocked : 1;	/* Writing Blocked, no rx buf space */
+	u8	 urg_data_pending : 1;	/* Urgent Data Pending */
+	u8	 urg_data_present : 1;	/* Urgent Data Present */
+	u8	 cons_curs_upd_req : 1;	/* cursor update requested,
+						 *not used in Linux
+					 */
+	u8	 last_msg_valid_req : 1;/* message replay due to failover */
+	u8	 reserved : 3;
+} __packed;
+
+/* in host byte order */
+struct smc_cursor {		/* SMC cursor - an offset in an RMBE */
+	u8	reserved0;
+	u8	reserved;
+	u16	w;		/* window wrap sequence number */
+	u32	c;		/* cursor (= offset) part */
+} __aligned(8);
+
+struct smc_curs {		/* overlay for atomic cursor handling */
+	union {
+		struct smc_cursor	curs;
+		atomic64_t		acurs;
+		long long		lcurs;
+	} s;
+} __aligned(8);
+
+/* in host byte order */
+struct smc_e_ctrl {		/* RMBE control information */
+	u8				ctrl_type;	/* type = 0xFE */
+	u8				ctrl_len;	/* length = 44 */
+	u16				ctrl_seq;	/* connection seq # */
+	u32				ctrl_token;	/* alert_token */
+	struct smc_curs			p_curs;		/* producer cursor */
+	struct smc_curs			c_curs;		/* consumer cursor,
+							 * piggy backed ctrl
+							 */
+	struct rmb_producer_flags	p_flags;	/* conn. tx/rx status */
+	struct rmb_conn_state_flags	conn_state_flags; /* peer conn. status*/
+	u8				reserved[18];
+	u8				reserved1[4];	/* fill up to dw */
+} __packed __aligned(8);
+
+/* in network byte order */
+struct rmb_cursor {		/* SMC cursor */
+	u8	reserved0;
+	u8	reserved;
+	__be16	wwrap_seq;
+	__be32	count;
+} __aligned(8);
+
+struct rmb_curs {
+	union {
+		struct	rmb_cursor	curs;
+		atomic64_t		acurs;
+		long long		lcurs;
+	} r;
+} __aligned(8);
+
+/* in network byte order */
+struct rmb_e_ctrl {
+	u8				ctrl_type;
+	u8				ctrl_len;
+	__be16				ctrl_seq;
+	__be32				ctrl_token;
+	struct rmb_curs			p_curs;
+	struct rmb_curs			c_curs;
+	struct rmb_producer_flags	prod_flags;
+	struct rmb_conn_state_flags	conn_state_flags;
+	u8				reserved[18];
+	u8				reserved1[4];
+} __packed __aligned(8);
+
+struct rmb_e {
+	u8	rmb_eye[SMC_EYE_CATCH_LEN]; /* eye catcher "RMBE" / "RMBT" */
+	char	buffer[];
+} __packed;
+
+enum lgr_type {		/* link status of a link group */
+	INIT,
+	SINGLE,
+	ASYMMETRIC,
+	SYMMETRIC,
+	NONE
+};
+
+struct pending_send {	/* control data for a pending send request */
+	struct smc_connection	*conn;		/* socket connection */
+	struct smc_curs		cursor;		/* tx RMBE cursor sent */
+	struct smc_curs		p_cursor;	/* rx RMBE cursor produced */
+	u64			wr_id_send;	/* work request id sent */
+	u16			ctrl_seq;	/* conn. tx sequence # */
+	u8			post_ctl;	/* llc event control index */
+	u8			reserved;
+};
+
+struct tx_sge {		/* scatter gather element for a send request */
+	u32 offset;
+	u32 len;
+};
+
+struct smc_rtoken {			/* address/key of remote RMB */
+	u64		vaddr[SMC_MAX_SYM_LINKS + 1];
+	u32		rkey[SMC_MAX_SYM_LINKS + 1];
+	atomic_t	active;			/* used / unused entry */
+	u8		link_id[SMC_MAX_SYM_LINKS + 1];		/* link ref. */
+	u8		reserved[7 - SMC_MAX_SYM_LINKS];
+};
+
+struct rmb_tx_addrs {			/* tx RMBE info */
+	struct list_head	list;
+	struct rmb_e		*rmb_tx_dma[SMC_MAX_SYM_LINKS+1]; /* mapped */
+	struct rmb_e		*rmb_tx;	/* tx RMBE address */
+	u32			used;		/* currently used / unused */
+};
+
+struct rmb_rx_addrs {			/* rx RMBE info */
+	struct list_head	list;
+	struct rmb_e		*rmb_rx_dma[SMC_MAX_SYM_LINKS+1]; /* mapped */
+	struct rmb_e		*rmb_rx;	/* rx RMBE address */
+	struct ib_mr		*mr_rx[SMC_MAX_SYM_LINKS+1];	/* rkey */
+	u32			used;		/* currently used / unused */
+};
+
+struct smc_roce_defs {			/* ib-device infos for a link */
+	struct smc_ib_device	*ibdev;
+	union ib_gid		gid;
+	unsigned short		vlan;
+	char			mac[6];
+	u8			sgid_idx;
+	u8			port;
+};
+
+/* SMC Link - long living - for more than 1 SMC Connection */
+struct smc_link {
+	char			lnk_eyecatch[8];
+	struct smc_link_group	*lnk_grp;
+	struct ib_pd		*roce_pd;	/* IB protection domain,
+						 * unique for every ROCE QP
+						 */
+	struct ib_qp		*roce_qp;	/* IB queue pair */
+	struct ib_qp_attr	qp_attr;	/* IB queue pair attributes */
+	struct smc_roce_defs	roce_defs;	/* ib-device infos */
+	atomic_t		state;		/* link state */
+	enum ib_mtu		mtu_peer;	/* mtu size of peer */
+	enum ib_mtu		path_mtu;	/* used mtu */
+	u32			qp_num_peer;	/* QP # of peer */
+	char			mac_peer[6];	/* = gid[8:10] || gid[13:15] */
+	char			gid_peer[16];	/* gid of peer */
+	u8			link_id;	/* unique # within link group */
+
+	struct rmb_e_ctrl	*ctrl_buf_tx;	/* for send of WR_SENDs */
+	dma_addr_t		ctrl_dma_tx;	/* mapped addr for ctrl buff */
+	struct ib_send_wr	*send_wr;	/* send work requests area */
+	struct ib_mr		*mr_tx;		/* from ib_get_dma_mr */
+	struct ib_sge		*send_sge;	/* send scatter gather area */
+	struct pending_send	*pending;	/* in-flight sends area */
+	unsigned long		*pending_bit_mask; /* used ctrl_buf_tx elems  */
+	u64			wr_id_send;	/* seq # of last sent WQE */
+	u32			psn_initial;	/* starting send WQE seq # */
+	u32			send_wr_num;	/* # of send ctrl buffers */
+
+	struct rmb_e_ctrl	*ctrl_buf_rx;	/* for recv of WR_SENDs */
+	dma_addr_t		ctrl_dma_rx;	/* mapped addr for ctrl buff */
+	struct ib_recv_wr	*recv_wr;	/* recv work requests area */
+	struct ib_sge		*recv_sge;	/* recv scatter gather area */
+	u64			wr_id_recv;	/* seq # of last recv WQE */
+	u32			psn_peer;	/* starting recv WQE seq # */
+	u32			recv_wr_num;	/* # of recv ctrl buffers */
+	u32			rcv_tstamp;	/* time of last recv event */
+
+	struct work_struct	llc_add_link_work; /* llc add event worker */
+	struct work_struct	llc_del_link_work; /* llc del event worker */
+	struct work_struct	llc_conf_rkey_work;/* llc confirm rkey worker*/
+	struct work_struct	llc_del_rkey_work; /* llc del rkey worker */
+	wait_queue_head_t	wqe_waiter;	/* w4 free ctrl_buf_tx elem */
+	unsigned int		probes_out;	/* # of TESTLINK probes */
+};
+
+/* SMC Link Group */
+struct smc_link_group {
+	struct list_head	list;
+	enum smc_role		role;		/* client or server */
+	enum lgr_type		lgr_type;	/* link status for lgr */
+	u32			lgr_id;		/* unique lgr id */
+	__be32			daddr;		/* destination ip address */
+	__be32			subnet;	/* subnet mask */
+	u8			mask_len;	/* # of significant mask bits */
+	unsigned short		vlan;		/* vlan id of lgr */
+	char			pnet_id[SMC_MAX_PNET_ID_LEN];
+						/* pnet_id of ROCEs */
+	char			peer_peer_id[8];/* unique system id of peer */
+	u8			max_links;	/* allowed # of links (2) */
+	u8			asymm_link;	/* index of asymmetric link */
+	struct mutex		conf_mutex;	/* link added or removed */
+	struct rb_root		conns_all;	/* connection tree */
+	rwlock_t		conns_lock;	/* protects conns_all */
+	unsigned int		conns_num;	/* current # of connections */
+	struct list_head	rmb_tx_bufs[16]; /* tx buffers */
+	struct list_head	rmb_rx_bufs[16]; /* rx buffers */
+	struct smc_rtoken	rtok[SMC_MAX_RMB]; /* remote addr/key pairs */
+	struct smc_link		lnk[SMC_MAX_SYM_LINKS+1]; /* links */
+	struct list_head	llc_event_q;	/* queue for llc events */
+	spinlock_t		llc_event_q_lock; /* protects llc_event_q */
+	struct llc_qentry	*delayed_q;	/* postpone llc event handl. */
+	struct work_struct	llc_event_work; /* llc event worker */
+	struct llc_ctl		llc_ctl[3];	/* llc event controller */
+	spinlock_t		llc_ctl_lock;	/* protects llc_ctl */
+	wait_queue_head_t	llc_waiter;	/* w4 next llc event */
+	struct workqueue_struct	*llc_wq;	/* work queue for llc events */
+	struct work_struct	link_down_work;	/* removing link from lgr */
+	atomic_t		link_num;	/* unique id last added link */
+	u32			lnk_down[SMC_MAX_SYM_LINKS+1];
+						/* link down in progress */
+	struct delayed_work	free_lgr_work;	/* delayed freeing of an lgr */
+	char			nwm_data[16];	/* network management data */
+	u8			nwm_flags;	/* network management flags */
+};
+
+struct smc_connection {
+	struct rb_node		alert_node;
+	struct smc_link_group	*lgr;		/* link group of connection */
+	u32			alert_token_local; /* created with custom logic
+						    * to address RMB and RMBE
+						    */
+	int			lnk_idx;	/* link currently used */
+
+	int			rtok_idx;	/* idx to peer rkey/addr */
+	int			peer_rx_buf_len; /* without eyecatcher */
+	u8			peer_tcp_conn_idx; /* from tcp handshake */
+
+	struct smc_e_ctrl	local_tx_ctrl;	/* preparation for sending */
+	struct smc_curs		local_tx_ctrl_fin; /* last completed target
+						    * offset
+						    */
+	struct smc_curs		tx_curs_prep;	/* tx - prepared data */
+	struct smc_curs		tx_curs_sent;	/* tx - sent data */
+	struct smc_curs		tx_curs_fin;	/* tx - confirmed by peer */
+	struct smc_curs		tx_urg_curs;	/* position of urgent byte */
+	atomic_t		tx_buf_space;	/* remaining space in tx rmb */
+	u16			tx_seq;		/* sequence # for WR SENDs */
+	u16			tx_seq_fin;	/* sequence # confirmed */
+	spinlock_t		send_lock;	/* protect wr_sends */
+	/* tx buffer */
+	struct rmb_tx_addrs	*rmb_tx_elem;	/* tx RMBE addresses */
+	int			rmb_tx_size;	/* tx RMBE size <== sock wmem */
+	int			rmb_tx_size_short;
+	int			tx_rmb_reused;	/* new / reused RMB */
+
+	struct smc_e_ctrl	local_rx_ctrl;	/* filled during event_handl. */
+	struct smc_curs		rx_curs_confirmed; /* confirmed to peer */
+	struct smc_curs		local_rx_spliced; /* pos of in-flight data */
+	struct smc_curs		rx_urg_curs;	/* cursor to urgent data */
+	u8			rx_urg_data;	/* 1 byte urgent data */
+	u8			rx_urg_state;	/* urg data avail / rcvd */
+	u16			ctrl_seq_rcvd;	/* seq # of last recv */
+	atomic_t		rx_buf_space;	/* remaining space in rx rmb */
+	atomic_t		bytes_to_rcv;	/* arrived data,
+						 *not yet received
+						 */
+	/* rx buffer */
+	struct rmb_rx_addrs	*rmb_rx_elem;
+	int			rmb_rx_size;	/* rx RMBE size <== sock rmem */
+	int			rmb_rx_size_short;
+	int			rx_rmb_reused;	/* new / reused TMB */
+						/* for Linux always 1 */
+};
+
+struct smc_ib_device {				/* list of ib-devices */
+	struct list_head	list;
+	struct ib_device	*dev;
+	struct ib_device_attr	attr;		/* ib device attributes */
+	struct ib_port_attr	pattr[2];	/* ib dev. port attributes */
+	struct ib_event_handler	event_handler;	/* global ib_event handler */
+	struct ib_cq		*roce_cq_send;	/* send completion queue */
+	struct ib_cq		*roce_cq_recv;	/* recv completion queue */
+	struct tasklet_struct	recv_tasklet;
+	struct tasklet_struct	send_tasklet;
+	struct work_struct	port_err_work;	/* port error worker */
+	struct work_struct	port_add_work;	/* port add worker */
+	u32			port_err[2];	/* port error triggered */
+	u32			port_add[2];	/* port add triggered */
+};
+
+/* eye catcher "SMCR" EBCDIC */
+static const char SMC_EC[] = {0xe2, 0xd4, 0xc3, 0xd9};
+
+struct smc_clc_msg_hdr {	/* header1 of clc messages */
+	u8 ec_clce[4];		/* eye catcher */
+	u8 type;		/* proposal / accept / confirm / decline */
+	__be16 length;
+	u8 flags;
+} __packed;
+
+struct smc_clc_msg_hdr2 {	/* header2 of clc messages */
+	u8 peer_id[8];		/* unique system id */
+	union ib_gid gid;
+	u8 mac[6];
+} __packed;
+
+struct smc_proposal_clc_msg {	/* proposal clc message */
+	struct smc_clc_msg_hdr hdr;
+	struct smc_clc_msg_hdr2 hdr2;
+	__u16 iparea_offset;	/* offset to IP address information area */
+} __packed;
+
+struct smc_proposal_clc_msg2 {
+	__be32 outgoing_subnet;	/* subnet mask */
+	u8 subnet_mask_bits;	/* number of significant bits in mask */
+	u8 reserved[2];
+	u8 n;			/* number of IPv6 prefixes in prefix array */
+	u8 ec_pclcf[4];		/* eye catcher "SMCR" EBCDIC */
+} __packed;
+
+struct smc_acc_conf_clc_msg {	/* accept / confirm clc message */
+	struct smc_clc_msg_hdr hdr;
+	struct smc_clc_msg_hdr2 hdr2;
+	u8 qp_num[3];		/* QP number */
+	__be32 rmb_rkey;	/* RMB rkey */
+	u8 tcp_conn_idx;	/* TCP connection index, which RMBE in RMB */
+	__be32 rmb_alert_token; /* unique connection id */
+	u8 flags2;		/* server's RMB buf size (compressed notation)
+				 * + QP mtu
+				 */
+	u8 reserved;
+	__be64 rmb_vaddr;	/* RMB virtual address */
+	u8 reserved2;
+	u8 psn[3];		/* initial packet sequence number */
+	u8 ec_clcf[4]; /* eye catcher "SMCR" EBCDIC */
+} __packed;
+
+struct smc_decline_clc_msg {
+	struct smc_clc_msg_hdr hdr;
+	u8 peer_id[8];		/* sender peer_id */
+	u32 peer_diagnosis;	/* diagnosis information */
+	u8 reserved2[4];
+	u8 ec_dclcf[4]; /* eye catcher "SMCR" EBCDIC */
+} __packed;
+
+struct smc_tmp_sockopts {
+	unsigned int	set;	/* indicates what sockopts were user-set */
+	int		cork;
+	int		defer_accept;
+	int		nodelay;
+};
+
+struct smc_sock {		/* smc socket */
+	struct sock sk;
+	struct socket *tcpsocket;		/* internal tcp socket */
+	struct smc_connection conn;		/* connection */
+	struct sockaddr *addr;			/* inet connect address */
+	bool new_lgr;				/* new lgr created for conn. */
+	bool use_tcp;				/* fallback to tcp */
+	struct smc_sock *listen_smc;		/* listen parent */
+	struct work_struct tcp_listen_work;	/* handle tcp socket accepts */
+	struct work_struct listen_work;		/* prepare new accept socket */
+	struct list_head	accept_q;	/* sockets to be accepted */
+	spinlock_t		accept_q_lock;	/* protects accept_q */
+	struct work_struct release_work;	/* w4 finished sents before
+						 * closing socket finally
+						 */
+	wait_queue_head_t destruct_waiter;	/* w4 pending sends */
+	struct timer_list	fin_timer;	/* ensure socket closing even
+						 * if peer is gone
+						 */
+	u32 sock_put_done;			/* allow race free closing */
+	struct work_struct timer_work;		/* keepalive TESTLINK sending */
+	struct delayed_work write_work;		/* RDMA writes of tx data */
+	wait_queue_head_t rx_waiter;		/* w4 space in rx RMBE */
+	wait_queue_head_t	splice_waiter;
+	struct splice_pipe_desc *spd;
+	struct timer_list	cork_timer;
+	struct smc_tmp_sockopts tmp_sockopts;
+	struct proc_dir_entry *proc;
+	char proc_name[32];			/* sockname in /proc/net/smc */
+};
+
+int smc_create_conn(struct smc_sock *, __be32, enum smc_role,
+		    struct smc_roce_defs *, struct smc_clc_msg_hdr2 *, u32);
+void smc_find_roce_resources(struct smc_roce_defs *, char *,
+			     struct sockaddr_in *, struct sock *);
+void smc_find_alt_roce_resources(struct smc_roce_defs *,
+				 struct smc_link_group *, struct smc_link *);
+int smc_gid_by_dev(struct smc_roce_defs *);
+int smc_netinfo_by_tcpsk(__be32 *, u8 *, struct socket *);
+int smc_pnet_by_ibdev(u8, char *, struct smc_ib_device *);
+int smc_get_ib_mac(struct smc_roce_defs *);
+int smc_create_link(struct smc_link_group *, int, struct smc_roce_defs *);
+int smc_port_active(struct smc_ib_device *, u8);
+int smc_ready_link(struct smc_link *);
+void smc_link_down(struct smc_link_group *, int);
+int smc_find_rtoken_by_link(struct smc_link_group *, int, u32);
+int smc_modify_qp_rts(struct smc_link *);
+int clc_wait_msg(struct smc_sock *, int, char *, int, u8, int *);
+int clc_send_decline(struct smc_sock *, u32, u8);
+
+int smc_create_rmbs(struct smc_sock *);
+int smc_del_rmbs(struct smc_sock *);
+int smc_map_rmbs_tx(struct smc_link_group *, int, int,
+		    struct rmb_tx_addrs *);
+int smc_map_rmbs_rx(struct smc_link_group *, int, int,
+		    struct rmb_rx_addrs *);
+long smc_get_dma_mr(struct smc_link_group *, int, struct rmb_rx_addrs *);
+long smc_map_rmbs(struct smc_sock *);
+long smc_map_rmbs_to_link(struct smc_link_group *, int);
+int smc_get_rtoken(struct smc_link_group *);
+u8 smc_compress_bufsize(int);
+int smc_uncompress_bufsize(u8);
+
+int smc_conn_send(struct smc_sock *, struct kiocb *, struct msghdr *, size_t);
+int smc_conn_recv(struct smc_sock *, struct kiocb *, struct msghdr *, size_t,
+		  int);
+int smc_to_read(struct smc_sock *);
+int smc_get_ctrl_buf(struct smc_link *, u32 *);
+int smc_wr_send(struct smc_link *, struct smc_connection *, u64, u32);
+int smc_wait_rx_data(struct smc_sock *, int, bool, long);
+void smc_sock_wake_tx(struct sock *);
+void smc_sock_wake_rx(struct sock *);
+void smc_send_tasklet_fn(unsigned long);
+void smc_recv_tasklet_fn(unsigned long);
+ssize_t smc_conn_splice_read(struct smc_sock *, struct pipe_inode_info *,
+			     size_t, unsigned int);
+void smc_write_worker(struct work_struct *);
+void smc_write_data(struct smc_sock *);
+
+void smc_free_conn(struct smc_sock *);
+void smc_free_link(struct smc_link_group *, int);
+void smc_free_lgr(struct smc_link_group *);
+int smc_wait_no_pending_sends_on_link(struct smc_link *);
+int smc_ctrl_send(struct smc_connection *, int);
+int smc_send_close(struct smc_sock *);
+int smc_switch_conns(struct smc_link_group *, int, int);
+void smc_terminate_conn(struct smc_link_group *);
+void smc_conn_term(struct smc_sock *);
+int smc_prepared_sends(struct smc_connection *);
+int smc_pending_sends(struct smc_connection *);
+void smc_clear_pending_sends(struct smc_connection *);
+
+int smc_sock_proc_create(struct sock *);
+void smc_sock_proc_remove(char *);
+int smc_proc_init(void);
+void smc_proc_exit(void);
+void smc_check_dev_attr(struct smc_ib_device *);
+void smc_check_port_attr(struct smc_ib_device *, int);
+void smc_check_qp_attr(struct smc_link *);
+void smc_cq_handler_recv(struct ib_cq *, void *);
+void smc_cq_handler_send(struct ib_cq *, void *);
+void smc_cq_event_handler(struct ib_event *, void *);
+
+static inline void hton_three(u32 host, u8 *net)
+{
+	u32 t;
+
+	t = cpu_to_be32(host);
+	memcpy(net, ((u8 *)&t) + 1, 3);
+}
+
+static inline void ntoh_three(u32 *host, u8 *net)
+{
+	u32 t = 0;
+
+	memcpy(((u8 *)&t) + 1, net, 3);
+	*host = be32_to_cpu(t);
+}
+
+static inline void smc_curs_dec(int size, struct smc_cursor *curs)
+{
+	if (!curs->c)
+		curs->w--;
+	curs->c = (curs->c + size - 1) % size;
+}
+
+static inline void smc_curs_add(int size, struct smc_cursor *curs, int value)
+{
+	curs->w += (curs->c + value) / size;
+	curs->c = (curs->c + value) % size;
+}
+
+/* calculate cursor difference between old and new, where old <= new */
+static inline int smc_curs_diff(unsigned int size, struct smc_curs *old,
+				struct smc_curs *new)
+{
+	if (old->s.curs.w != new->s.curs.w)
+		return max_t(int, 0, ((size - old->s.curs.c) + new->s.curs.c));
+	return max_t(int, 0, (new->s.curs.c - old->s.curs.c));
+}
diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c
new file mode 100644
index 0000000..18e42b0
--- /dev/null
+++ b/net/smc/smc_core.c
@@ -0,0 +1,3112 @@
+/*
+ *  Shared Memory Communications over RDMA (SMC-R) and ROCE
+ *
+ *  Basic Transport Functions exploiting Infiniband API
+ *
+ *  Copyright IBM Corp. 2014
+ *
+ *  Author(s):  Ursula Braun <ursula.braun@de.ibm.com>
+ *              Frank Blaschka <blaschka@linux.vnet.ibm.com>
+ *              Stefan Raspl <raspl@linux.vnet.ibm.com>
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/interrupt.h>
+#include <linux/slab.h>
+#include <linux/skbuff.h>
+#include <linux/init.h>
+#include <linux/poll.h>
+#include <linux/socket.h>
+#include <linux/pci.h>
+#include <linux/wait.h>
+#include <linux/kthread.h>
+#include <linux/hardirq.h>
+#include <net/tcp.h>
+#include <net/sock.h>
+#include <linux/types.h>
+#include <asm/byteorder.h>
+#include <rdma/ib_verbs.h>
+#include <linux/splice.h>
+#include <linux/mm.h>
+
+#include "af_smc.h"
+#include "smc_llc.h"
+
+#define LGR_RECONFIGURING 1
+
+/* Find the connection associated with the given alert token in the link group.
+ * Requires @conns_lock.
+ * @token	alert token to search for
+ * @lgr		 link group to search in
+ * Returns connection associated with token if found, NULL otherwise.
+ */
+static inline
+struct smc_connection *smc_find_conn(u32 token, struct smc_link_group *lgr)
+{
+	struct rb_node *node;
+	struct smc_connection *res = NULL;
+
+	node = lgr->conns_all.rb_node;
+	while (node) {
+		struct smc_connection *cur = rb_entry(node,
+					struct smc_connection, alert_node);
+
+		if (cur->alert_token_local > token) {
+			node = node->rb_left;
+		} else {
+			if (cur->alert_token_local < token) {
+				node = node->rb_right;
+			} else {
+				res = cur;
+				break;
+			}
+		}
+	}
+
+	return res;
+}
+
+/* Register connection's alert token in our lookup structure.
+ * Requires @conns_lock.
+ * @smc		connection to register
+ * Returns 0 on success, != otherwise.
+ */
+static void _smc_register_alert_token(struct smc_connection *conn)
+{
+	struct rb_node **link, *parent = NULL;
+	u32 token = conn->alert_token_local;
+
+	link = &conn->lgr->conns_all.rb_node;
+	while (*link) {
+		struct smc_connection *cur = rb_entry(*link,
+					struct smc_connection, alert_node);
+
+		parent = *link;
+		if (cur->alert_token_local > token)
+			link = &parent->rb_left;
+		else
+			link = &parent->rb_right;
+	}
+	/* Put the new node there */
+	rb_link_node(&conn->alert_node, parent, link);
+	rb_insert_color(&conn->alert_node, &conn->lgr->conns_all);
+}
+
+/* Register connection in link group by assigning an alert token
+ * registered in a search tree.
+ * Requires lgr->conns_lock being held.
+ * Note that '0' is a reserved value and not assigned.
+ */
+static void smc_register_in_lgr(struct smc_connection *conn)
+{
+	static atomic_t nexttoken = ATOMIC_INIT(0);
+
+	while (!conn->alert_token_local) {
+		conn->alert_token_local = atomic_inc_return(&nexttoken);
+		if (smc_find_conn(conn->alert_token_local, conn->lgr))
+			conn->alert_token_local = 0;
+	}
+	_smc_register_alert_token(conn);
+	conn->lgr->conns_num++;
+}
+
+/* Unregister and reset the alert token of the given connection
+ */
+static void smc_unregister_in_lgr(struct smc_connection *conn)
+{
+	struct smc_link_group *lgr = conn->lgr;
+
+	if (conn->alert_token_local) {
+		conn->alert_token_local = 0;
+		write_lock_bh(&lgr->conns_lock);
+		rb_erase(&conn->alert_node, &lgr->conns_all);
+		lgr->conns_num--;
+		write_unlock_bh(&lgr->conns_lock);
+	}
+}
+
+static void smc_sock_wake_rx_for_tx(struct sock *sk)
+{
+	struct smc_sock *smc = smc_sk(sk);
+	struct socket *sock = sk->sk_socket;
+
+	if (sock && (sock->state == SS_CONNECTED) &&
+	    atomic_read(&smc->conn.rx_buf_space))
+		wake_up_interruptible(&smc->rx_waiter);
+}
+
+static void smc_free_rmbs(struct smc_connection *conn)
+{
+	int i;
+
+	if (conn->rmb_tx_elem) {
+		i = ror8(conn->rmb_tx_size_short, 4);
+		cmpxchg(&conn->rmb_tx_elem->used, 1, 0);
+	}
+	if (conn->rmb_rx_elem) {
+		i = ror8(conn->rmb_rx_size_short, 4);
+		cmpxchg(&conn->rmb_rx_elem->used, 1, 0);
+	}
+}
+
+static void smc_unmap_rmbs(struct smc_link_group *lgr, int lnk_idx)
+{
+	int i;
+	struct rmb_tx_addrs *txkp;
+	struct rmb_rx_addrs *rxkp;
+	struct smc_roce_defs *rocdefs = &lgr->lnk[lnk_idx].roce_defs;
+
+	for (i = 0; i < 16; i++) {
+		list_for_each_entry(txkp, &lgr->rmb_tx_bufs[i], list) {
+			if (txkp->rmb_tx_dma[lnk_idx])
+				ib_dma_unmap_single(rocdefs->ibdev->dev,
+					(dma_addr_t)txkp->rmb_tx_dma[lnk_idx],
+					smc_uncompress_bufsize(rol8(i, 4)),
+					DMA_TO_DEVICE);
+			txkp->rmb_tx_dma[lnk_idx] = NULL;
+		}
+		list_for_each_entry(rxkp, &lgr->rmb_rx_bufs[i], list) {
+			if (rxkp->mr_rx[lnk_idx])
+				ib_dereg_mr(rxkp->mr_rx[lnk_idx]);
+			rxkp->mr_rx[lnk_idx] = NULL;
+			if (rxkp->rmb_rx_dma[lnk_idx])
+				ib_dma_unmap_single(rocdefs->ibdev->dev,
+					(dma_addr_t)rxkp->rmb_rx_dma[lnk_idx],
+					smc_uncompress_bufsize(rol8(i, 4)),
+					DMA_FROM_DEVICE);
+			rxkp->rmb_rx_dma[lnk_idx] = NULL;
+		}
+	}
+}
+
+static void smc_clear_rtokens(struct smc_link_group *lgr, int lnk_idx)
+{
+	int i;
+
+	for (i = 0; i < SMC_MAX_RMB; i++) {
+		lgr->rtok[i].rkey[lnk_idx] = 0;
+		lgr->rtok[i].vaddr[lnk_idx] = 0;
+		lgr->rtok[i].link_id[lnk_idx] = 0;
+	}
+}
+
+static void smc_free_link_mem(struct smc_link *lnk)
+{
+	kfree(lnk->pending);
+	lnk->pending = NULL;
+	kfree(lnk->pending_bit_mask);
+	lnk->pending_bit_mask = NULL;
+	kfree(lnk->send_sge);
+	lnk->send_sge = NULL;
+	kfree(lnk->recv_sge);
+	lnk->recv_sge = NULL;
+	kfree(lnk->recv_wr);
+	lnk->recv_wr = NULL;
+	kfree(lnk->send_wr);
+	lnk->send_wr = NULL;
+	kfree(lnk->ctrl_buf_tx);
+	lnk->ctrl_buf_tx = NULL;
+	kfree(lnk->ctrl_buf_rx);
+	lnk->ctrl_buf_rx = NULL;
+}
+
+static int smc_modify_qp_init(struct smc_link *link)
+{
+	struct ib_qp_attr qp_attr;
+	int rc = 0;
+
+	memset(&qp_attr, 0, sizeof(qp_attr));
+	qp_attr.qp_state = IB_QPS_INIT;
+	qp_attr.pkey_index = 0;
+	qp_attr.port_num = link->roce_defs.port;
+	qp_attr.qp_access_flags = IB_ACCESS_LOCAL_WRITE
+				| IB_ACCESS_REMOTE_WRITE;
+	rc = ib_modify_qp(link->roce_qp, &qp_attr,
+			  IB_QP_STATE | IB_QP_PKEY_INDEX | IB_QP_ACCESS_FLAGS |
+			  IB_QP_PORT);
+	return rc;
+}
+
+static int smc_modify_qp_rtr(struct smc_link *link)
+{
+	struct ib_qp_attr qp_attr;
+	int rc = 0;
+	enum ib_qp_attr_mask qp_attr_mask =
+		IB_QP_STATE | IB_QP_AV | IB_QP_PATH_MTU | IB_QP_DEST_QPN |
+		IB_QP_RQ_PSN | IB_QP_MAX_DEST_RD_ATOMIC | IB_QP_MIN_RNR_TIMER |
+		IB_QP_SMAC;
+
+	memset(&qp_attr, 0, sizeof(qp_attr));
+	qp_attr.qp_state = IB_QPS_RTR;
+	qp_attr.path_mtu = min(link->path_mtu, link->mtu_peer);
+	qp_attr.ah_attr.port_num = link->roce_defs.port;
+	qp_attr.ah_attr.ah_flags = IB_AH_GRH;
+	qp_attr.ah_attr.grh.hop_limit = 1;
+	memcpy(&qp_attr.ah_attr.grh.dgid, link->gid_peer,
+	       sizeof(link->gid_peer));
+	qp_attr.ah_attr.grh.sgid_index = link->roce_defs.sgid_idx;
+	if (link->roce_defs.vlan) {
+		qp_attr.ah_attr.vlan_id = link->roce_defs.vlan;
+		qp_attr.vlan_id = link->roce_defs.vlan;
+		qp_attr_mask |= IB_QP_VID;
+	}
+	memcpy(&qp_attr.ah_attr.dmac, link->mac_peer,
+	       sizeof(link->mac_peer));
+	qp_attr.dest_qp_num = link->qp_num_peer;
+	qp_attr.rq_psn = link->psn_peer; /* starting receive packet seq # */
+	qp_attr.max_dest_rd_atomic = 1;  /* max # of resources for incoming
+					  * requests
+					  */
+	qp_attr.min_rnr_timer = SMC_MIN_RNR_TIMER;
+	memcpy(&qp_attr.smac, link->roce_defs.mac,
+	       sizeof(link->roce_defs.mac));
+
+	rc = ib_modify_qp(link->roce_qp, &qp_attr, qp_attr_mask);
+	return rc;
+}
+
+int smc_modify_qp_rts(struct smc_link *link)
+{
+	struct ib_qp_attr qp_attr;
+	int rc = 0;
+
+	memset(&qp_attr, 0, sizeof(qp_attr));
+	qp_attr.qp_state = IB_QPS_RTS;
+	qp_attr.timeout = SMC_QP_TIMEOUT;	/* local ack timeout */
+	qp_attr.retry_cnt = SMC_RETRY_CNT;	/* retry count */
+	qp_attr.rnr_retry = SMC_RNR_RETRY;	/* RNR retries, 7=infinite */
+	qp_attr.sq_psn = link->psn_initial;	/* starting send packet seq # */
+	qp_attr.max_rd_atomic = 1;	/* # of outstanding RDMA reads and
+					 * atomic ops allowed
+					 */
+	rc = ib_modify_qp(link->roce_qp, &qp_attr,
+			  IB_QP_STATE | IB_QP_TIMEOUT | IB_QP_RETRY_CNT |
+			  IB_QP_SQ_PSN | IB_QP_RNR_RETRY |
+			  IB_QP_MAX_QP_RD_ATOMIC);
+	return rc;
+}
+
+static int smc_modify_qp_reset(struct smc_link *link)
+{
+	struct ib_qp_attr qp_attr;
+	int rc = 0;
+
+	memset(&qp_attr, 0, sizeof(qp_attr));
+	qp_attr.qp_state = IB_QPS_RESET;
+	rc = ib_modify_qp(link->roce_qp, &qp_attr, IB_QP_STATE);
+	return rc;
+}
+
+static inline int smc_outstanding_post_recv(struct smc_link *link)
+{
+	int rc = 0;
+	struct ib_recv_wr *bad_recv_wr = NULL;
+	u32 index;
+	u64 wr_id;
+
+	wr_id = link->wr_id_recv++; /* tasklet context, thus not atomic */
+	index = wr_id % link->recv_wr_num;
+	link->recv_wr[index].wr_id = wr_id;
+	rc = ib_post_recv(link->roce_qp, &link->recv_wr[index], &bad_recv_wr);
+	return rc;
+}
+
+int smc_ready_link(struct smc_link *link)
+{
+	struct smc_link_group *lgr = link->lnk_grp;
+	int rc = 0;
+	u32 i;
+
+	rc = smc_modify_qp_init(link);
+	if (rc)
+		goto out;
+
+	rc = smc_modify_qp_rtr(link);
+	if (rc)
+		goto out;
+	smc_check_qp_attr(link);
+	rc = ib_req_notify_cq(link->roce_defs.ibdev->roce_cq_recv,
+			      IB_CQ_SOLICITED_MASK);
+	if (rc)
+		goto out;
+	for (i = 0; i < link->recv_wr_num; i++)
+		rc = smc_outstanding_post_recv(link);
+	smc_check_qp_attr(link);
+
+	if (lgr->role == SMC_SERV) {
+		rc = smc_modify_qp_rts(link);
+		if (rc)
+			goto out;
+		smc_check_qp_attr(link);
+	}
+out:
+	return rc;
+}
+
+static void smc_free_spd(struct smc_sock *);
+
+void smc_free_conn(struct smc_sock *smc)
+{
+	struct smc_link_group *lgr = smc->conn.lgr;
+	int empty;
+
+	if (lgr) {
+		/* can be called from sk_free in atomic context */
+		smc_clear_pending_sends(&smc->conn);
+		smc_free_rmbs(&smc->conn);
+		smc->conn.rmb_tx_elem = NULL;
+		smc->conn.rmb_rx_elem = NULL;
+		smc_unregister_in_lgr(&smc->conn);
+		empty = RB_EMPTY_ROOT(&smc->conn.lgr->conns_all);
+		if (empty && (smc->conn.lgr->role == SMC_SERV))
+			schedule_delayed_work(&lgr->free_lgr_work,
+					      SMC_FREE_LGR_TIMEO);
+		smc->conn.lgr = NULL;
+	}
+	if (smc->spd)
+		smc_free_spd(smc);
+}
+
+void smc_free_link(struct smc_link_group *lgr, int lnk_idx)
+{
+	struct smc_link *lnk = &lgr->lnk[lnk_idx];
+	struct smc_ib_device *ibdev = lnk->roce_defs.ibdev;
+	enum smc_link_state old_state;
+
+	old_state = atomic_cmpxchg(&lnk->state, SMC_LINK_DOWN, SMC_LINK_FREED);
+	if (old_state != SMC_LINK_DOWN) {
+		if (old_state == SMC_LINK_FREED)
+			while (lnk->roce_defs.ibdev)
+				msleep(10000);
+		return;
+	}
+	memset(lnk->lnk_eyecatch, 0, SMC_LNK_EYE_CATCH_LEN);
+	lnk->link_id = 0;
+	lnk->lnk_grp = NULL;
+	if (!lnk->roce_defs.ibdev)
+		return;
+	smc_modify_qp_reset(lnk);
+	if (lnk->roce_qp) {
+		ib_destroy_qp(lnk->roce_qp);
+		lnk->roce_qp = NULL;
+	}
+	smc_unmap_rmbs(lgr, lnk_idx);
+	lnk->roce_defs.ibdev = NULL;
+	smc_clear_rtokens(lgr, lnk_idx);
+	if (lnk->roce_pd) {
+		ib_dealloc_pd(lnk->roce_pd);
+		lnk->roce_pd = NULL;
+	}
+	if (lnk->mr_tx) {
+		ib_dereg_mr(lnk->mr_tx);
+		lnk->mr_tx = NULL;
+	}
+	if (lnk->ctrl_dma_rx) {
+		ib_dma_unmap_single(ibdev->dev, lnk->ctrl_dma_rx,
+				(sizeof(struct rmb_e_ctrl) * lnk->recv_wr_num),
+				    DMA_FROM_DEVICE);
+		lnk->ctrl_dma_rx = 0;
+	}
+	if (lnk->ctrl_dma_tx) {
+		ib_dma_unmap_single(ibdev->dev, lnk->ctrl_dma_tx,
+				(sizeof(struct rmb_e_ctrl) * lnk->send_wr_num),
+				    DMA_TO_DEVICE);
+		lnk->ctrl_dma_tx = 0;
+	}
+	smc_free_link_mem(lnk);
+}
+
+static int smc_pending_sends_on_link(struct smc_link *link)
+{
+	u32 i;
+
+	i = find_first_bit(link->pending_bit_mask, link->send_wr_num);
+	if (i < link->send_wr_num)
+		return 1;
+	return 0;
+}
+
+int smc_wait_no_pending_sends_on_link(struct smc_link *link)
+{
+	int rc = 1;
+
+	if (smc_pending_sends_on_link(link))
+		rc = wait_event_interruptible_timeout(link->wqe_waiter,
+			!smc_pending_sends_on_link(link),
+			SMC_WAIT_PENDING_SENDS_TIMEO);
+	return rc;
+}
+
+void smc_free_lgr(struct smc_link_group *lgr)
+{
+	struct rmb_tx_addrs *entrytx, *tmptx;
+	struct rmb_rx_addrs *entryrx, *tmprx;
+	int i, rc;
+
+	for (i = 0; i <= SMC_MAX_SYM_LINKS; i++) {
+		if (smc_lnk_downing(&lgr->lnk[i].state))
+			rc = smc_wait_no_pending_sends_on_link(&lgr->lnk[i]);
+		smc_free_link(lgr, i);
+	}
+	destroy_workqueue(lgr->llc_wq);
+	list_for_each_entry_safe(entrytx, tmptx, &lgr->rmb_tx_bufs[i], list) {
+		list_del(&entrytx->list);
+		kfree(entrytx->rmb_tx);
+		kfree(entrytx);
+	}
+	list_for_each_entry_safe(entryrx, tmprx, &lgr->rmb_rx_bufs[i], list) {
+		list_del(&entryrx->list);
+		kfree(entryrx->rmb_rx);
+		kfree(entryrx);
+	}
+	kfree(lgr);
+}
+
+static void smc_free_lgr_worker(struct work_struct *work)
+{
+	struct smc_link_group *lgr = container_of(work, struct smc_link_group,
+						  free_lgr_work.work);
+	struct llc_qentry *qentry;
+	int i, rest_time, rc, peer_notified = 0;
+
+	/* server only */
+	spin_lock_bh(&smc_lgr_list.lock);
+	read_lock_bh(&lgr->conns_lock);
+	rc = RB_EMPTY_ROOT(&lgr->conns_all);
+	read_unlock_bh(&lgr->conns_lock);
+	if (!rc) {
+		spin_unlock_bh(&smc_lgr_list.lock);
+		return;
+	}
+	if (atomic_read(&smc_reconfiguring)) {
+		/* postpone freeing */
+		spin_unlock_bh(&smc_lgr_list.lock);
+		schedule_delayed_work(&lgr->free_lgr_work,
+				      LLC_WAIT_FIRST_TIMEO);
+		return;
+	}
+	list_del_init(&lgr->list);
+	spin_unlock_bh(&smc_lgr_list.lock);
+	for (i = 0; i <= SMC_MAX_SYM_LINKS; i++) {
+		if (!smc_lnk_downing(&lgr->lnk[i].state) ||
+		    (lgr->lgr_type == NONE) ||
+		    peer_notified)
+			continue;
+		rest_time = llc_initiate(lgr, LLC_GRP_DEL_LINK);
+		if (!rest_time)		/* timeout */
+			continue;
+		if (!&lgr->lnk[i].lnk_grp) {	/* link already freed */
+			llc_stop(lgr, LLC_GRP_DEL_LINK);
+			continue;
+		}
+		atomic_set(&lgr->lnk[i].state, SMC_LINK_UP);
+		rc = llc_send_del_link(&lgr->lnk[i], NULL, LLC_FLAG_DEL_ORDERLY,
+				       LLC_DEL_PROG_INIT_TERM, LLC_SERV);
+		if (rc >= 0) {
+			lgr->llc_ctl[LLC_SERV].qentry = NULL;
+			qentry = llc_wait(lgr, LLC_SERV, LLC_WAIT_TIMEO,
+					  LLC_DEL_LINK);
+			if (qentry)
+				peer_notified = 1;
+		}
+		llc_stop(lgr, LLC_GRP_DEL_LINK);
+		atomic_set(&lgr->lnk[i].state, SMC_LINK_DOWN);
+	}
+	llc_kill_waiters(lgr);
+	cancel_work_sync(&lgr->llc_event_work);
+	msleep(1000);
+	smc_free_lgr(lgr);
+}
+
+static inline int smc_splice_in_use(const struct smc_sock *smc)
+{
+	return smc->spd != NULL;
+}
+
+static int smc_splice_in_progress(struct smc_sock *smc)
+{
+	struct smc_curs curs;
+	struct smc_curs spl_curs;
+
+	spl_curs.s.lcurs = atomic64_read(&smc->conn.local_rx_spliced.s.acurs);
+	if (spl_curs.s.curs.reserved0) {
+		curs.s.lcurs =
+		       atomic64_read(&smc->conn.local_tx_ctrl.c_curs.s.acurs);
+		if (smc_curs_diff(smc->conn.rmb_rx_size, &curs, &spl_curs))
+			return 1;
+	}
+
+	return 0;
+}
+
+static inline int smc_find_pending_send(struct smc_link *link, u64 wr_id)
+{
+	u32 i;
+
+	for (i = 0; i < link->send_wr_num; i++) {
+		if (link->pending[i].wr_id_send == wr_id)
+			return i;
+	}
+	return link->send_wr_num;
+}
+
+static void smc_flag_sock_err(struct smc_sock *smc)
+{
+	int old_state;
+
+	sock_hold(&smc->sk);
+	lock_sock(&smc->sk);
+	old_state = smc->sk.sk_state;
+	smc->sk.sk_err = ECONNABORTED;
+	smc->conn.local_tx_ctrl.conn_state_flags.abnormal_close = 1;
+	smc->conn.local_rx_ctrl.conn_state_flags.abnormal_close = 1;
+	if (smc->tcpsocket && smc->tcpsocket->sk) {
+		smc->tcpsocket->sk->sk_err = ECONNABORTED;
+		smc->tcpsocket->sk->sk_data_ready(smc->tcpsocket->sk);
+	}
+	smc_conn_term(smc);
+	if (!sock_flag(&smc->sk, SOCK_DEAD))
+		smc->sk.sk_error_report(&smc->sk);
+	release_sock(&smc->sk);
+	if (old_state != SMC_INIT) {
+		wake_up_interruptible(&smc->rx_waiter);
+		smc_sock_wake_tx(&smc->sk);
+		smc_sock_wake_rx(&smc->sk);
+		cancel_delayed_work_sync(&smc->write_work);
+	}
+	sock_put(&smc->sk);
+	if ((old_state != SMC_INIT) &&
+	    (smc->sk.sk_state == SMC_CLOSED) &&
+	    (sock_flag(&smc->sk, SOCK_DEAD)) &&
+	    (cmpxchg(&smc->sock_put_done, 0, 1) == 0))
+		schedule_work(&smc->release_work);
+}
+
+void smc_terminate_conn(struct smc_link_group *lgr)
+{
+	struct smc_sock *smc;
+	struct rb_node *node;
+
+	spin_lock_bh(&smc_lgr_list.lock);
+	list_del_init(&lgr->list);
+	spin_unlock_bh(&smc_lgr_list.lock);
+again:
+	read_lock_bh(&lgr->conns_lock);
+	for (node = rb_first(&lgr->conns_all); node; node = rb_next(node)) {
+		smc = container_of(rb_entry(node, struct smc_connection,
+					    alert_node),
+				   struct smc_sock, conn);
+		if (smc->sk.sk_err != ECONNABORTED) {
+			read_unlock_bh(&lgr->conns_lock);
+			smc_flag_sock_err(smc);
+			goto again;
+		}
+	}
+	read_unlock_bh(&lgr->conns_lock);
+}
+
+static int smc_write_space(struct smc_sock *);
+
+static void smc_switch_cursor(struct smc_sock *smc, int to_lnk_idx)
+{
+	struct smc_connection *conn = &smc->conn;
+	struct smc_curs cons, fin;
+	int diff;
+
+	atomic64_set(&conn->tx_curs_sent.s.acurs,
+		     atomic64_read(&conn->tx_curs_fin.s.acurs));
+	fin.s.lcurs = atomic64_read(&conn->local_tx_ctrl_fin.s.acurs);
+	atomic64_set(&conn->local_tx_ctrl.p_curs.s.acurs, fin.s.lcurs);
+	cons.s.lcurs = atomic64_read(&conn->local_rx_ctrl.c_curs.s.acurs);
+	if (((cons.s.curs.w > fin.s.curs.w) ||
+	     ((cons.s.curs.w == fin.s.curs.w) &&
+	      (cons.s.curs.c > fin.s.curs.c))) ||
+	    (!cons.s.curs.w && (fin.s.curs.w == 0xffff))) {
+		diff = smc_curs_diff(conn->peer_rx_buf_len, &fin, &cons);
+		smc_curs_add(conn->rmb_tx_size,
+			     &conn->tx_curs_sent.s.curs, diff);
+		smc_curs_add(conn->peer_rx_buf_len,
+			     &conn->local_tx_ctrl.p_curs.s.curs, diff);
+	}
+	atomic_set(&smc->conn.rx_buf_space, smc_write_space(smc));
+	if ((smc->sk.sk_state != SMC_INIT) &&
+	    (smc->sk.sk_state != SMC_CLOSED) &&
+	    (smc->sk.sk_state != SMC_DESTRUCT)) {
+		conn->local_tx_ctrl.p_flags.last_msg_valid_req = 1;
+		smc_ctrl_send(conn, conn->lnk_idx);
+		conn->local_tx_ctrl.p_flags.last_msg_valid_req = 0;
+		schedule_delayed_work(&smc->write_work, 0);
+		smc_sock_wake_rx_for_tx(&smc->sk);
+	}
+}
+
+int smc_switch_conns(struct smc_link_group *lgr, int lnk_idx, int dev_err)
+{
+	struct smc_sock *smc;
+	struct smc_connection *conn;
+	struct smc_roce_defs *rd_idx = &lgr->lnk[lnk_idx].roce_defs;
+	int to_lnk_idx, i, found = 0;
+	struct rb_node *node;
+
+	wake_up(&lgr->lnk[lnk_idx].wqe_waiter);
+	for (i = 0; i <= SMC_MAX_SYM_LINKS; i++) {
+		struct smc_roce_defs *rd_i = &lgr->lnk[i].roce_defs;
+
+		if ((atomic_read(&lgr->lnk[i].state) != SMC_LINK_UP) ||
+		    (i == lnk_idx))
+			continue;
+		if (dev_err && (rd_i->ibdev == rd_idx->ibdev) &&
+		    (rd_i->port == rd_idx->port))
+			continue;
+		found = 1;
+		to_lnk_idx = i;
+		break;
+	}
+	if (!found) {
+		lgr->lgr_type = NONE;
+		wake_up_interruptible(&lgr->llc_waiter);
+		smc_terminate_conn(lgr);
+		return -ENOENT;
+	}
+
+again:
+	read_lock_bh(&lgr->conns_lock);
+	for (node = rb_first(&lgr->conns_all); node; node = rb_next(node)) {
+		conn = rb_entry(node, struct smc_connection, alert_node);
+		if (conn->lnk_idx != lnk_idx)
+			continue;
+		smc = container_of(conn, struct smc_sock, conn);
+		if ((smc->sk.sk_state == SMC_CLOSED) ||
+		    (smc->sk.sk_state == SMC_PEERCLW2) ||
+		    (smc->sk.sk_state == SMC_PEERFINCLW) ||
+		    (smc->sk.sk_state == SMC_APPLFINCLW) ||
+		    (smc->sk.sk_state == SMC_APPLCLW2) ||
+		    (smc->sk.sk_state == SMC_PROCESSABORT)) {
+			conn->lnk_idx = to_lnk_idx;
+			continue;
+		}
+		sock_hold(&smc->sk);
+		read_unlock_bh(&lgr->conns_lock);
+		lock_sock(&smc->sk);
+		conn->lnk_idx = to_lnk_idx;
+		if (!atomic64_read(&smc->conn.tx_curs_prep.s.acurs)) {
+			release_sock(&smc->sk);
+			sock_put(&smc->sk);
+			goto again;
+		}
+		smc_switch_cursor(smc, to_lnk_idx);
+		release_sock(&smc->sk);
+		sock_put(&smc->sk);
+		goto again;
+	}
+	read_unlock_bh(&lgr->conns_lock);
+	return to_lnk_idx;
+}
+
+void smc_cq_event_handler(struct ib_event *evt, void *ptr)
+{
+	return;
+}
+
+static void smc_qp_event_handler(struct ib_event *evt, void *ptr)
+{
+	struct smc_link *link = (struct smc_link *)ptr;
+	struct smc_link_group *lgr = link->lnk_grp;
+	struct smc_roce_defs *rocdefs = &link->roce_defs;
+	struct smc_ib_device *smc_ibdev = (struct smc_ib_device *)evt->device;
+	int lnk_idx;
+
+	lnk_idx = link - &lgr->lnk[0];
+	switch (evt->event) {
+	case IB_EVENT_DEVICE_FATAL:	/* 8 */
+		if (cmpxchg(&smc_ibdev->port_err[rocdefs->port - 1], 0, 1) == 0)
+			schedule_work(&rocdefs->ibdev->port_err_work);
+		break;
+	case IB_EVENT_GID_CHANGE:	 /* 17 */
+	case IB_EVENT_PORT_ERR:		 /* 10 */
+	case IB_EVENT_QP_ACCESS_ERR:	 /* 3 */
+		if ((atomic_read(&link->state) == SMC_LINK_UP) &&
+		    (cmpxchg(&lgr->lnk_down[lnk_idx], 0, 1) == 0))
+			schedule_work(&lgr->link_down_work);
+		break;
+	case IB_EVENT_COMM_EST:		 /* 4 */
+	case IB_EVENT_PORT_ACTIVE:	 /* 9 */
+	default:
+		break;
+	}
+}
+
+static inline void smc_send_tasklet_conn(struct smc_sock *smc)
+{
+	if (smc->sk.sk_socket && atomic_read(&smc->conn.tx_buf_space) &&
+	    test_bit(SOCK_NOSPACE, &smc->sk.sk_socket->flags))
+		smc_sock_wake_tx(&smc->sk);
+	if (smc->sk.sk_state != SMC_ACTIVE)
+		wake_up(&smc->destruct_waiter);
+}
+
+static inline void smc_send_tasklet_wc(struct ib_wc *wc)
+{
+	struct smc_link_group *lgr;
+	struct smc_link *link;
+	struct smc_sock *smc;
+	struct pending_send pnd_snd;
+	u32 pnd_snd_idx;
+	int i, diff;
+
+	link = wc->qp->qp_context;
+	if (!link->lnk_grp ||
+	    (memcmp(link->lnk_eyecatch, SMC_LNK_EYE_CATCHER,
+		    SMC_LNK_EYE_CATCH_LEN)))
+		return;
+	pnd_snd_idx = smc_find_pending_send(link, wc->wr_id);
+	if (pnd_snd_idx == link->send_wr_num)
+		return;
+	memcpy(&pnd_snd, &link->pending[pnd_snd_idx],
+	       sizeof(struct pending_send));
+	if (!test_and_clear_bit(pnd_snd_idx, link->pending_bit_mask))
+		return;
+	lgr = link->lnk_grp;
+	if (wc->status) {
+		int lnk_idx = link - &lgr->lnk[0];
+
+		for_each_set_bit(i, link->pending_bit_mask, link->send_wr_num)
+			clear_bit(i, link->pending_bit_mask);
+		if ((wc->wr_id != 1) &&
+		    (cmpxchg(&lgr->lnk_down[lnk_idx], 0, 1) == 0))
+			schedule_work(&lgr->link_down_work);
+	}
+	if (pnd_snd.conn) {
+		smc = container_of(pnd_snd.conn, struct smc_sock, conn);
+		bh_lock_sock(&smc->sk);
+		if ((!wc->status) &&
+		    (link == &lgr->lnk[pnd_snd.conn->lnk_idx])) {
+			diff = smc_curs_diff(pnd_snd.conn->rmb_tx_size,
+					     &pnd_snd.conn->tx_curs_fin,
+					     &pnd_snd.cursor);
+			atomic_add(diff, &pnd_snd.conn->tx_buf_space);
+			atomic64_set(&pnd_snd.conn->tx_curs_fin.s.acurs,
+				     pnd_snd.cursor.s.lcurs);
+			atomic64_set(&pnd_snd.conn->local_tx_ctrl_fin.s.acurs,
+				     pnd_snd.p_cursor.s.lcurs);
+			pnd_snd.conn->tx_seq_fin = pnd_snd.ctrl_seq;
+		}
+		wake_up(&link->wqe_waiter);
+		smc_send_tasklet_conn(smc);
+		bh_unlock_sock(&smc->sk);
+	} else {
+		if (pnd_snd.post_ctl != LLC_NO_NOTIFY) {
+			lgr->llc_ctl[pnd_snd.post_ctl].ctrl_elem =
+							LLC_SEND_POSTED;
+			lgr->llc_ctl[pnd_snd.post_ctl].wc_status = wc->status;
+			wake_up_interruptible(&lgr->llc_waiter);
+		}
+		wake_up(&link->wqe_waiter);
+	}
+}
+
+void smc_send_tasklet_fn(unsigned long data)
+{
+	struct smc_ib_device *ibdev = (struct smc_ib_device *)data;
+	struct ib_wc wc[SMC_MAX_POLL_CQE];
+	int i = 0, rc, rc1 = 0;
+	int polled = 0;
+
+again:
+	polled++;
+	do {
+		rc = ib_poll_cq(ibdev->roce_cq_send, SMC_MAX_POLL_CQE, wc);
+		if (polled == 1) {
+			rc1 = ib_req_notify_cq(ibdev->roce_cq_send,
+					       IB_CQ_NEXT_COMP |
+					       IB_CQ_REPORT_MISSED_EVENTS);
+		}
+		if (!rc)
+			break;
+		for (i = 0; i < rc; i++)
+			smc_send_tasklet_wc(&wc[i]);
+	} while (rc > 0);
+	if (polled == 1)
+		goto again;
+}
+
+void smc_cq_handler_send(struct ib_cq *ib_cq, void *cq_context)
+{
+	struct smc_ib_device *ibdev = (struct smc_ib_device *)cq_context;
+
+	tasklet_schedule(&ibdev->send_tasklet);
+}
+
+static inline
+void smc_save_cursor(struct smc_curs *local, struct rmb_curs *peer)
+{
+	struct smc_curs temp, old;
+
+	old.s.lcurs = atomic64_read(&local->s.acurs);
+	temp.s.lcurs = atomic64_read(&peer->r.acurs);
+	temp.s.curs.c = ntohl(temp.s.curs.c);
+	temp.s.curs.w = ntohs(temp.s.curs.w);
+	if ((old.s.curs.w > temp.s.curs.w) && temp.s.curs.w)
+		return;
+	if ((old.s.curs.w == temp.s.curs.w) &&
+	    (old.s.curs.c > temp.s.curs.c))
+		return;
+	atomic64_set(&local->s.acurs, temp.s.lcurs);
+}
+
+static inline
+void smc_set_cursor(struct smc_curs *local, struct rmb_cursor *peer)
+{
+	struct smc_curs temp;
+
+	temp.s.lcurs = atomic64_read(&local->s.acurs);
+	peer->count = htonl(temp.s.curs.c);
+	peer->wwrap_seq = htons(temp.s.curs.w);
+}
+
+static inline
+void smc_save_ctrl(struct smc_e_ctrl *local, struct rmb_e_ctrl *peer)
+{
+	local->p_flags = peer->prod_flags;
+	local->conn_state_flags = peer->conn_state_flags;
+	smc_save_cursor(&local->p_curs, &peer->p_curs);
+	smc_save_cursor(&local->c_curs, &peer->c_curs);
+	local->ctrl_type = peer->ctrl_type;
+	local->ctrl_len = peer->ctrl_len;
+	local->ctrl_seq = ntohs(peer->ctrl_seq);
+	local->ctrl_token = peer->ctrl_token;
+}
+
+static inline
+void smc_set_ctrl(struct smc_e_ctrl *local, struct rmb_e_ctrl *peer)
+{
+	memcpy((char *)peer, (char *)local, SMC_SIZE_OF_CTRL_DATA);
+	peer->prod_flags = local->p_flags;
+	peer->conn_state_flags = local->conn_state_flags;
+	smc_set_cursor(&local->p_curs, &peer->p_curs.r.curs);
+	smc_set_cursor(&local->c_curs, &peer->c_curs.r.curs);
+	peer->ctrl_seq = htons(local->ctrl_seq);
+	peer->ctrl_token = local->ctrl_token;
+}
+
+static void smc_update_cons_curs(struct smc_sock *);
+
+static void smc_recv_validate(struct smc_sock *smc, struct smc_link *link,
+			      u32 index)
+{
+	struct smc_connection *conn = &smc->conn;
+	u16 tmp;
+
+	/* check that seqnum was seen before */
+	tmp = conn->ctrl_seq_rcvd - ntohs(link->ctrl_buf_rx[index].ctrl_seq);
+	if (tmp > 0x7fff) {
+		/* drop connection */
+		conn->local_tx_ctrl.conn_state_flags.abnormal_close = 1;
+		conn->local_rx_ctrl.conn_state_flags.abnormal_close = 1;
+		if (smc->tcpsocket && smc->tcpsocket->sk) {
+			smc->tcpsocket->sk->sk_err = ECONNABORTED;
+			smc->tcpsocket->sk->sk_data_ready(smc->tcpsocket->sk);
+		}
+		conn->lnk_idx = link - &conn->lgr->lnk[0];
+		smc_conn_term(smc);
+		wake_up_interruptible(&smc->rx_waiter);
+		smc_sock_wake_tx(&smc->sk);
+		smc_sock_wake_rx(&smc->sk);
+		if ((smc->sk.sk_state == SMC_CLOSED) &&
+		    (sock_flag(&smc->sk, SOCK_DEAD)) &&
+		    (cmpxchg(&smc->sock_put_done, 0, 1) == 0)) {
+			schedule_work(&smc->release_work);
+		}
+	} else {
+		smc_update_cons_curs(smc);
+	}
+}
+
+static void smc_recv_action(struct smc_sock *smc,
+			    struct smc_link *link, u32 index)
+{
+	struct smc_connection *conn = &smc->conn;
+	struct smc_curs prod, cons_old, prod_old;
+	int to_read, diff;
+
+	if (link->ctrl_buf_rx[index].prod_flags.last_msg_valid_req) {
+		smc_recv_validate(smc, link, index);
+		return;
+	}
+	prod_old.s.lcurs = atomic64_read(&conn->local_rx_ctrl.p_curs.s.acurs);
+	cons_old.s.lcurs = atomic64_read(&conn->local_rx_ctrl.c_curs.s.acurs);
+	smc_save_ctrl(&conn->local_rx_ctrl, &link->ctrl_buf_rx[index]);
+	if ((conn->local_rx_ctrl.ctrl_seq - (u16)(conn->ctrl_seq_rcvd + 1)) >
+		0x7fff) {
+		return;
+	}
+	conn->ctrl_seq_rcvd = conn->local_rx_ctrl.ctrl_seq;
+	diff = smc_curs_diff(conn->peer_rx_buf_len, &cons_old,
+			     &conn->local_rx_ctrl.c_curs);
+	atomic_add(diff, &conn->rx_buf_space);
+	diff = smc_curs_diff(conn->rmb_rx_size, &prod_old,
+			     &conn->local_rx_ctrl.p_curs);
+	atomic_add(diff, &conn->bytes_to_rcv);
+
+	if (conn->local_rx_ctrl.conn_state_flags.abnormal_close)
+		smc->sk.sk_err = ECONNRESET;
+	if (smc_stop_received(conn)) {
+		smc->sk.sk_shutdown |= RCV_SHUTDOWN;
+		sock_set_flag(&smc->sk, SOCK_DONE);
+		smc_conn_term(smc);
+		smc_sock_wake_tx(&smc->sk);
+		smc_sock_wake_rx(&smc->sk);
+	}
+
+	/* piggy backed tx info */
+	smc_sock_wake_rx_for_tx(&smc->sk);
+
+	if ((smc->sk.sk_state == SMC_CLOSED) &&
+	    smc_close_received(smc) &&
+	    sock_flag(&smc->sk, SOCK_DEAD) &&
+	    !smc->sk.sk_socket &&
+	    (cmpxchg(&smc->sock_put_done, 0, 1) == 0)) {
+		/* socket is closed and peer has confirmed close, now we are
+		 * allowed to clean up our sock/rmbe
+		 */
+		schedule_work(&smc->release_work);
+		return;
+	}
+
+	/* socket connected but not accepted */
+	if (!smc->sk.sk_socket)
+		return;
+
+	/* data available */
+	if (conn->local_rx_ctrl.p_flags.urg_data_present) {
+		prod.s.lcurs =
+			atomic64_read(&conn->local_rx_ctrl.p_curs.s.acurs);
+		smc_curs_dec(conn->rmb_rx_size, &prod.s.curs);
+		atomic64_set(&conn->rx_urg_curs.s.acurs, prod.s.lcurs);
+		/* set urg_data to previous byte */
+		conn->rx_urg_data =
+			conn->rmb_rx_elem->rmb_rx->buffer[prod.s.curs.c];
+		conn->rx_urg_state = SMC_URG_VALID;
+		sk_send_sigurg(&smc->sk);
+	}
+	to_read = smc_to_read(smc);
+	if ((conn->local_rx_ctrl.p_flags.write_blocked) ||
+	    (conn->local_rx_ctrl.p_flags.cons_curs_upd_req))
+		smc_update_cons_curs(smc);
+	if (to_read ||
+	    conn->local_rx_ctrl.p_flags.urg_data_pending ||
+	    smc_stop_received(conn) ||
+	    smc->sk.sk_shutdown & RCV_SHUTDOWN)
+		smc_sock_wake_rx(&smc->sk);
+}
+
+static inline void smc_recv_conn_update(struct rmb_e_ctrl *ctrl,
+					struct smc_link *link, u64 wr_id)
+{
+	struct smc_link_group *lgr = link->lnk_grp;
+	struct smc_connection *connection;
+	struct smc_sock *smc;
+	u32 index;
+
+	/* lookup connection */
+	read_lock_bh(&lgr->conns_lock);
+	connection = smc_find_conn(ctrl->ctrl_token, lgr);
+	read_unlock_bh(&lgr->conns_lock);
+	if (connection && connection->alert_token_local) {
+		smc = container_of(connection, struct smc_sock, conn);
+		sock_hold(&smc->sk);
+		index = wr_id % link->recv_wr_num;
+		bh_lock_sock(&smc->sk);
+		smc_recv_action(smc, link, index);
+		bh_unlock_sock(&smc->sk);
+		sock_put(&smc->sk);
+	}
+}
+
+static inline void smc_recv_process_wqs(struct ib_wc wc[], int num)
+{
+	struct smc_link *link;
+	struct smc_link_group *lgr;
+	struct rmb_e_ctrl *ctrl;
+	int i, idx;
+	u32 index;
+
+	for (i = 0; i < num; i++) {
+		link = wc[i].qp->qp_context;
+		if (memcmp(link->lnk_eyecatch, SMC_LNK_EYE_CATCHER,
+			   SMC_LNK_EYE_CATCH_LEN))
+			continue;
+		lgr = link->lnk_grp;
+		if ((atomic_read(&link->state) == SMC_LINK_DOWN) ||
+		    (atomic_read(&link->state) == SMC_LINK_FREED))
+			continue;
+		if (wc[i].status == IB_WC_SUCCESS) {
+			index = wc[i].wr_id % link->recv_wr_num;
+			ctrl = (struct rmb_e_ctrl *)&link->ctrl_buf_rx[index];
+			link->rcv_tstamp = (u32)jiffies; /* not yet used */
+			if (ctrl->ctrl_type == RMBE_CTRL)
+				smc_recv_conn_update(ctrl, link, wc[i].wr_id);
+			else
+				llc_enqueue(link, (struct llc_msg *)ctrl);
+			smc_outstanding_post_recv(link);
+		} else {
+			/* handle status errors */
+			/* terminate all connections of this lgr abnormally */
+			switch (wc[i].status) {
+			case IB_WC_RETRY_EXC_ERR:
+			case IB_WC_RNR_RETRY_EXC_ERR:
+			case IB_WC_WR_FLUSH_ERR:
+				idx = link - &lgr->lnk[0];
+				if ((atomic_read(&link->state) == SMC_LINK_UP)
+				 && (cmpxchg(&lgr->lnk_down[idx], 0, 1) == 0))
+					schedule_work(&lgr->link_down_work);
+				break;
+			default:
+				smc_outstanding_post_recv(link);
+				break;
+			}
+			continue;
+		}
+	}
+}
+
+void smc_recv_tasklet_fn(unsigned long data)
+{
+	struct smc_ib_device *ibdev = (struct smc_ib_device *)data;
+	struct ib_wc wc[SMC_MAX_POLL_CQE];
+	int rc, rc1;
+	int polled = 0;
+
+again:
+	polled++;
+	do {
+		memset(&wc, 0, sizeof(wc));
+		rc = ib_poll_cq(ibdev->roce_cq_recv, SMC_MAX_POLL_CQE, wc);
+		if (polled == 1) {
+			rc1 = ib_req_notify_cq(ibdev->roce_cq_recv,
+					       IB_CQ_SOLICITED_MASK
+					     | IB_CQ_REPORT_MISSED_EVENTS);
+		}
+		if (!rc)
+			break;
+		smc_recv_process_wqs(&wc[0], rc);
+	} while (rc > 0);
+	if ((polled == 1))
+		goto again;
+}
+
+void smc_cq_handler_recv(struct ib_cq *ib_cq, void *cq_context)
+{
+	struct smc_ib_device *ibdev = (struct smc_ib_device *)cq_context;
+
+	tasklet_schedule(&ibdev->recv_tasklet);
+}
+
+static int smc_alloc_link_mem(struct smc_link *link)
+{
+	/* allocate link related memory */
+	link->ctrl_buf_rx = (struct rmb_e_ctrl *)
+		kzalloc(link->recv_wr_num * sizeof(struct rmb_e_ctrl),
+			GFP_KERNEL);
+	if (!link->ctrl_buf_rx)
+		goto no_mem;
+	link->ctrl_buf_tx = (struct rmb_e_ctrl *)
+		kzalloc(link->send_wr_num * sizeof(struct rmb_e_ctrl),
+			GFP_KERNEL);
+	if (!link->ctrl_buf_tx)
+		goto no_mem_ctrl_buf_rx;
+	link->send_wr = (struct ib_send_wr *)
+		kzalloc(link->send_wr_num * sizeof(struct ib_send_wr),
+			GFP_KERNEL);
+	if (!link->send_wr)
+		goto no_mem_ctrl_buf_tx;
+	link->recv_wr = (struct ib_recv_wr *)
+		kzalloc(link->recv_wr_num * sizeof(struct ib_recv_wr),
+			GFP_KERNEL);
+	if (!link->recv_wr)
+		goto no_mem_send_wr;
+	link->send_sge = (struct ib_sge *)
+		kzalloc(link->send_wr_num * sizeof(struct ib_sge),
+			GFP_KERNEL);
+	if (!link->send_sge)
+		goto no_mem_recv_wr;
+	link->recv_sge = (struct ib_sge *)
+		kzalloc(link->recv_wr_num * sizeof(struct ib_sge),
+			GFP_KERNEL);
+	if (!link->recv_sge)
+		goto no_mem_send_sge;
+	link->pending_bit_mask = kcalloc(BITS_TO_LONGS(link->send_wr_num),
+					 sizeof(unsigned long), GFP_KERNEL);
+	if (!link->pending_bit_mask)
+		goto no_mem_recv_sge;
+	link->pending = (struct pending_send *)
+		kzalloc(link->send_wr_num * sizeof(struct pending_send),
+			GFP_KERNEL);
+	if (!link->pending)
+		goto no_mem_pending_bit_mask;
+	return 0;
+
+no_mem_pending_bit_mask:
+	kfree(link->pending_bit_mask);
+no_mem_recv_sge:
+	kfree(link->recv_sge);
+no_mem_send_sge:
+	kfree(link->send_sge);
+no_mem_recv_wr:
+	kfree(link->recv_wr);
+no_mem_send_wr:
+	kfree(link->send_wr);
+no_mem_ctrl_buf_tx:
+	kfree(link->ctrl_buf_tx);
+no_mem_ctrl_buf_rx:
+	kfree(link->ctrl_buf_rx);
+no_mem:
+	return -ENOMEM;
+}
+
+static void smc_init_wr_sqe(struct smc_link *lnk)
+{
+	u32 i;
+
+	for (i = 0; i < lnk->send_wr_num; i++) {
+		lnk->send_wr[i].next = NULL;
+		lnk->send_wr[i].sg_list = &lnk->send_sge[i];
+		lnk->send_wr[i].num_sge = 1;
+		lnk->send_wr[i].opcode = IB_WR_SEND;
+		lnk->send_wr[i].send_flags = IB_SEND_SIGNALED
+					   | IB_SEND_SOLICITED | IB_SEND_INLINE;
+		lnk->send_sge[i].addr =
+				lnk->ctrl_dma_tx + i * SMC_SIZE_OF_CTRL_BUF;
+		lnk->send_sge[i].length = SMC_SIZE_OF_CTRL_DATA;
+		lnk->send_sge[i].lkey = lnk->mr_tx->lkey;
+	}
+	for (i = 0; i < lnk->recv_wr_num; i++) {
+		lnk->recv_wr[i].next = NULL;
+		lnk->recv_wr[i].sg_list = &lnk->recv_sge[i];
+		lnk->recv_wr[i].num_sge = 1;
+		lnk->recv_sge[i].addr =
+				lnk->ctrl_dma_rx + i * SMC_SIZE_OF_CTRL_BUF;
+		lnk->recv_sge[i].length = SMC_SIZE_OF_CTRL_BUF;
+		lnk->recv_sge[i].lkey = lnk->mr_tx->lkey;
+	}
+}
+
+int smc_create_link(struct smc_link_group *lgr, int lnk_idx,
+		    struct smc_roce_defs *rocdefs)
+{
+	struct smc_ib_device *smc_ibdev = rocdefs->ibdev;
+	struct ib_device *ibdev;
+	struct smc_link *lnk = &lgr->lnk[lnk_idx];
+	int i, rc = 0;
+
+	if (list_empty(&smc_ib_devices))
+		return -ENODEV;
+	memset(lnk, 0, sizeof(struct smc_link));
+	atomic_set(&lnk->state, SMC_LINK_ACTIVATING);
+	init_waitqueue_head(&lnk->wqe_waiter);
+	INIT_WORK(&lnk->llc_add_link_work, llc_process_add_link);
+	INIT_WORK(&lnk->llc_del_link_work, llc_process_del_link);
+	INIT_WORK(&lnk->llc_conf_rkey_work, llc_process_confirm_rkey);
+	INIT_WORK(&lnk->llc_del_rkey_work, llc_process_delete_rkey);
+	ibdev = smc_ibdev->dev;
+	memcpy(&lnk->roce_defs, rocdefs, sizeof(struct smc_roce_defs));
+	lnk->lnk_grp = lgr;
+	lnk->path_mtu = smc_ibdev->pattr[rocdefs->port - 1].active_mtu;
+	while (1) {
+		lnk->link_id = atomic_inc_return(&lgr->link_num);
+		if (!lnk->link_id)
+			continue;
+		for (i = 0; i <= SMC_MAX_SYM_LINKS; i++) {
+			if ((i != lnk_idx) &&
+			    (lgr->lnk[i].link_id == lnk->link_id))
+				continue;
+		}
+		break;
+	}
+	/* create PD */
+	lnk->roce_pd = ib_alloc_pd(ibdev);
+	if (IS_ERR(lnk->roce_pd)) {
+		atomic_set(&lnk->state, SMC_LINK_DOWN);
+		rc = PTR_ERR(lnk->roce_pd);
+		lnk->roce_pd = NULL;
+		return rc;
+	}
+	/* create QP */
+	{
+	struct ib_qp_init_attr qp_attr = {
+		.event_handler = smc_qp_event_handler,
+		.qp_context = lnk,
+		.send_cq = smc_ibdev->roce_cq_send,
+		.recv_cq = smc_ibdev->roce_cq_recv,
+		.srq = NULL,
+		.cap = {
+			.max_send_wr = 3 * smc_ctrl_buf_cnt,
+			.max_recv_wr = smc_ctrl_buf_cnt,
+			.max_send_sge = 2,
+			.max_recv_sge = 1,
+			.max_inline_data = SMC_SIZE_OF_CTRL_BUF,
+		},
+		.sq_sig_type = IB_SIGNAL_REQ_WR,
+		.qp_type = IB_QPT_RC,
+	};
+	lnk->roce_qp = ib_create_qp(lnk->roce_pd, &qp_attr);
+	if (IS_ERR(lnk->roce_qp)) {
+		atomic_set(&lnk->state, SMC_LINK_DOWN);
+		rc = PTR_ERR(lnk->roce_qp);
+		lnk->roce_qp = NULL;
+		goto dealloc_pd;
+	}
+	}
+	smc_check_qp_attr(lnk);
+	rc = smc_alloc_link_mem(lnk);
+	if (rc) {
+		atomic_set(&lnk->state, SMC_LINK_DOWN);
+		goto destroy_qp;
+	}
+	lnk->wr_id_send = 0;
+	lnk->wr_id_recv = 0;
+	lnk->mr_tx = ib_get_dma_mr(lnk->roce_pd, IB_ACCESS_LOCAL_WRITE);
+	if (IS_ERR(lnk->mr_tx)) {
+		atomic_set(&lnk->state, SMC_LINK_DOWN);
+		rc = PTR_ERR(lnk->mr_tx);
+		lnk->mr_tx = NULL;
+		goto free_mem;
+	}
+	lnk->ctrl_dma_rx = ib_dma_map_single(ibdev, lnk->ctrl_buf_rx,
+				(sizeof(struct rmb_e_ctrl) * lnk->recv_wr_num),
+					     DMA_FROM_DEVICE);
+	if (ib_dma_mapping_error(ibdev, lnk->ctrl_dma_rx)) {
+		rc = -EIO;
+		goto dereg_mr;
+	}
+	lnk->ctrl_dma_tx = ib_dma_map_single(ibdev, lnk->ctrl_buf_tx,
+				sizeof(struct rmb_e_ctrl) * lnk->send_wr_num,
+					     DMA_TO_DEVICE);
+	if (ib_dma_mapping_error(ibdev, lnk->ctrl_dma_tx)) {
+		rc = -EIO;
+		goto dma_unmap;
+	}
+	get_random_bytes_arch(((char *)&lnk->psn_initial) + 1, 3);
+	smc_init_wr_sqe(lnk);
+	memcpy(lnk->lnk_eyecatch, SMC_LNK_EYE_CATCHER, SMC_LNK_EYE_CATCH_LEN);
+	return 0;
+
+dma_unmap:
+	ib_dma_unmap_single(ibdev, lnk->ctrl_dma_rx,
+			    (sizeof(struct rmb_e_ctrl) * lnk->recv_wr_num),
+			    DMA_FROM_DEVICE);
+dereg_mr:
+	ib_dereg_mr(lnk->mr_tx);
+	lnk->mr_tx = NULL;
+free_mem:
+	smc_free_link_mem(lnk);
+destroy_qp:
+	ib_destroy_qp(lnk->roce_qp);
+	lnk->roce_qp = NULL;
+dealloc_pd:
+	ib_dealloc_pd(lnk->roce_pd);
+	lnk->roce_pd = NULL;
+	lnk->roce_defs.ibdev = NULL;
+	return rc;
+}
+
+static inline
+struct rmb_tx_addrs *smc_get_tx_rmb_slot(struct smc_link_group *lgr,
+					 int start)
+{
+	struct rmb_tx_addrs *slot;
+
+	list_for_each_entry(slot, &lgr->rmb_tx_bufs[start], list) {
+		if (cmpxchg(&slot->used, 0, 1) == 0)
+			return slot;
+	}
+	return NULL;
+}
+
+static inline
+struct rmb_rx_addrs *smc_get_rx_rmb_slot(struct smc_link_group *lgr,
+					 int start)
+{
+	struct rmb_rx_addrs *slot;
+
+	list_for_each_entry(slot, &lgr->rmb_rx_bufs[start], list) {
+		if (cmpxchg(&slot->used, 0, 1) == 0)
+			return slot;
+	}
+	return NULL;
+}
+
+int smc_map_rmbs_tx(struct smc_link_group *lgr, int lnk_idx, int tx_size,
+		    struct rmb_tx_addrs *elem)
+{
+	struct smc_ib_device *dev = lgr->lnk[lnk_idx].roce_defs.ibdev;
+	int rc = 0;
+
+	if (elem->rmb_tx_dma[lnk_idx])
+		return rc; /* already mapped */
+	elem->rmb_tx_dma[lnk_idx] =
+		(struct rmb_e *)ib_dma_map_single(dev->dev, elem->rmb_tx,
+						  tx_size,
+						  DMA_TO_DEVICE);
+	if (ib_dma_mapping_error(dev->dev,
+				 (dma_addr_t)elem->rmb_tx_dma[lnk_idx]))
+		rc = -EIO;
+	return rc;
+}
+
+int smc_map_rmbs_rx(struct smc_link_group *lgr, int lnk_idx, int rx_size,
+		    struct rmb_rx_addrs *elem)
+{
+	struct smc_ib_device *dev = lgr->lnk[lnk_idx].roce_defs.ibdev;
+	int rc = 0;
+
+	if (elem->rmb_rx_dma[lnk_idx])
+		return rc; /* already mapped */
+	elem->rmb_rx_dma[lnk_idx] =
+		(struct rmb_e *)ib_dma_map_single(dev->dev, elem->rmb_rx,
+						  rx_size,
+						  DMA_FROM_DEVICE);
+	if (ib_dma_mapping_error(dev->dev,
+				 (dma_addr_t)elem->rmb_rx_dma[lnk_idx]))
+		rc = -EIO;
+	return rc;
+}
+
+long smc_get_dma_mr(struct smc_link_group *lgr, int lnk_idx,
+		    struct rmb_rx_addrs *elem)
+{
+	struct ib_mr *mr;
+	long rc = 0;
+
+	if (elem->mr_rx[lnk_idx])
+		return 0; /* already done */
+	/* obtain unique key -
+	 * next invocation of ib_get_dma_mr returns a different key!
+	 */
+	mr = ib_get_dma_mr(lgr->lnk[lnk_idx].roce_pd,
+			   IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE);
+	if (!IS_ERR(mr)) {
+		elem->mr_rx[lnk_idx] = mr;
+	} else {
+		elem->mr_rx[lnk_idx] = NULL;
+		rc = PTR_ERR(mr);
+	}
+	return rc;
+}
+
+long smc_map_rmbs_to_link(struct smc_link_group *lgr, int lnk_idx)
+{
+	struct rmb_tx_addrs *tx_entry;
+	struct rmb_rx_addrs *rx_entry;
+	long rc = 0;
+	int i;
+
+	for (i = 0; i < 16; i++) {
+		list_for_each_entry(tx_entry, &lgr->rmb_tx_bufs[i], list) {
+			rc = smc_map_rmbs_tx(lgr, lnk_idx,
+					     smc_uncompress_bufsize(rol8(i, 4)),
+					     tx_entry);
+			if (rc)
+				goto out;
+		}
+		list_for_each_entry(rx_entry, &lgr->rmb_rx_bufs[i], list) {
+			rc = smc_map_rmbs_rx(lgr, lnk_idx,
+					     smc_uncompress_bufsize(rol8(i, 4)),
+					     rx_entry);
+			if (rc)
+				goto out;
+		}
+		list_for_each_entry(rx_entry, &lgr->rmb_rx_bufs[i], list) {
+			rc = smc_get_dma_mr(lgr, lnk_idx, rx_entry);
+			if (rc)
+				goto out;
+		}
+	}
+	return rc;
+
+out:
+	smc_link_down(lgr, lnk_idx);
+	return rc;
+}
+
+long smc_map_rmbs(struct smc_sock *smc)
+{
+	struct smc_link_group *lgr = smc->conn.lgr;
+	long rc = 0;
+	int i;
+
+	for (i = 0; i <= SMC_MAX_SYM_LINKS; i++) {
+		if (atomic_read(&lgr->lnk[i].state) != SMC_LINK_UP)
+			continue;
+		if (!smc->conn.tx_rmb_reused) {
+			rc = smc_map_rmbs_tx(lgr, i,
+					     smc->conn.rmb_tx_size +
+						SMC_EYE_CATCH_LEN,
+					     smc->conn.rmb_tx_elem);
+			if (rc) {
+				smc_link_down(lgr, i);
+				continue;
+			}
+		}
+		if (!smc->conn.rx_rmb_reused) {
+			rc = smc_map_rmbs_rx(lgr, i,
+					     smc->conn.rmb_rx_size +
+						SMC_EYE_CATCH_LEN,
+					     smc->conn.rmb_rx_elem);
+			if (rc) {
+				smc_link_down(lgr, i);
+				continue;
+			}
+			rc = smc_get_dma_mr(lgr, i,
+					    smc->conn.rmb_rx_elem);
+			if (rc) {
+				smc_link_down(lgr, i);
+				continue;
+			}
+		}
+	}
+	return rc;
+}
+
+int smc_create_rmbs(struct smc_sock *smc)
+{
+	struct smc_connection *conn = &smc->conn;
+	struct smc_link_group *lgr = conn->lgr;
+	struct rmb_tx_addrs *tx_rmb = NULL;
+	struct rmb_rx_addrs *rx_rmb = NULL;
+	int rmem, wmem, tmp_sl, tmp_ss, sl, ss;
+
+	rmem = smc->sk.sk_rcvbuf;
+	wmem = smc->sk.sk_sndbuf;
+	ss = ror8(smc_compress_bufsize(wmem), 4);
+	sl = smc_uncompress_bufsize(rol8(ss, 4));
+	for (tmp_sl = sl, tmp_ss = ss;
+	     tmp_sl >= SMC_MIN_RMBE_SIZE && tmp_ss >= 0;
+	     tmp_sl = tmp_sl >> 1, tmp_ss--) {
+		tx_rmb = smc_get_tx_rmb_slot(lgr, tmp_ss);
+		if (tx_rmb) {
+			conn->tx_rmb_reused = 1;
+		} else {
+			tx_rmb = (struct rmb_tx_addrs *)
+				kzalloc(sizeof(struct rmb_tx_addrs),
+					GFP_KERNEL);
+			if (!tx_rmb)
+				return -ENOMEM;
+			tx_rmb->rmb_tx = kzalloc(tmp_sl,
+						 GFP_KERNEL | __GFP_NOWARN |
+						 __GFP_NOMEMALLOC);
+			tx_rmb->used = 1;
+			if (tx_rmb->rmb_tx) {
+				list_add(&tx_rmb->list,
+					 &lgr->rmb_tx_bufs[tmp_ss]);
+			}
+		}
+		if (tx_rmb->rmb_tx) {
+			conn->rmb_tx_elem = tx_rmb;
+			memset(conn->rmb_tx_elem->rmb_tx, 0, tmp_sl);
+			break;
+		}
+	}
+	if (!conn->rmb_tx_elem) {
+		kfree(tx_rmb);
+		return -ENOMEM;
+	}
+	conn->rmb_tx_size = tmp_sl - SMC_EYE_CATCH_LEN;
+	conn->rmb_tx_size_short = rol8(tmp_ss, 4);
+
+	ss = ror8(smc_compress_bufsize(rmem), 4);
+	sl = smc_uncompress_bufsize(rol8(ss, 4));
+	for (tmp_sl = sl, tmp_ss = ss;
+	     tmp_sl >= SMC_MIN_RMBE_SIZE && tmp_ss >= 0;
+	     tmp_sl = tmp_sl >> 1, tmp_ss--) {
+		rx_rmb = smc_get_rx_rmb_slot(lgr, tmp_ss);
+		if (rx_rmb) {
+			conn->rx_rmb_reused = 1;
+		} else {
+			rx_rmb = (struct rmb_rx_addrs *)
+				kzalloc(sizeof(struct rmb_rx_addrs),
+					GFP_KERNEL);
+			if (!rx_rmb)
+				break;
+			rx_rmb->rmb_rx = kzalloc(tmp_sl,
+						 GFP_KERNEL | __GFP_NOWARN |
+						 __GFP_NOMEMALLOC);
+			rx_rmb->used = 1;
+			if (rx_rmb->rmb_rx)
+				list_add(&rx_rmb->list,
+					 &lgr->rmb_rx_bufs[tmp_ss]);
+		}
+		if (rx_rmb && rx_rmb->rmb_rx) {
+			conn->rmb_rx_elem = rx_rmb;
+			memset(conn->rmb_rx_elem->rmb_rx, 0, tmp_sl);
+			break;
+		}
+	}
+	if (!conn->rmb_rx_elem) {
+		cmpxchg(&tx_rmb->used, 1, 0);
+		kfree(rx_rmb);
+		return -ENOMEM;
+	}
+	conn->rmb_rx_size = tmp_sl - SMC_EYE_CATCH_LEN;
+	conn->rmb_rx_size_short = rol8(tmp_ss, 4);
+	memset(tx_rmb->rmb_tx, 0 , sizeof(struct rmb_e));
+	memcpy(tx_rmb->rmb_tx->rmb_eye, SMC_EYE_CATCHER_TX, SMC_EYE_CATCH_LEN);
+	memcpy(rx_rmb->rmb_rx->rmb_eye, SMC_EYE_CATCHER, SMC_EYE_CATCH_LEN);
+
+	return 0;
+}
+
+int smc_del_rmbs(struct smc_sock *smc)
+{
+	struct smc_connection *conn = &smc->conn;
+	struct smc_link_group *lgr = conn->lgr;
+	struct rmb_tx_addrs *txkp = conn->rmb_tx_elem;
+	struct rmb_rx_addrs *rxkp = conn->rmb_rx_elem;
+	int i, tmp_ss;
+
+	for (i = 0; i <= SMC_MAX_SYM_LINKS; i++) {
+		if (atomic_read(&lgr->lnk[i].state) != SMC_LINK_UP)
+			continue;
+		if (txkp->rmb_tx_dma[i]) {
+			ib_dma_unmap_single(lgr->lnk[i].roce_defs.ibdev->dev,
+					    (dma_addr_t)txkp->rmb_tx_dma[i],
+					    conn->rmb_tx_size_short,
+					    DMA_TO_DEVICE);
+			txkp->rmb_tx_dma[i] = NULL;
+		}
+		if (rxkp->mr_rx[i]) {
+			ib_dereg_mr(rxkp->mr_rx[i]);
+			rxkp->mr_rx[i] = NULL;
+		}
+		if (rxkp->rmb_rx_dma[i]) {
+			ib_dma_unmap_single(lgr->lnk[i].roce_defs.ibdev->dev,
+					    (dma_addr_t)rxkp->rmb_rx_dma[i],
+					    conn->rmb_rx_size_short,
+					    DMA_FROM_DEVICE);
+			rxkp->rmb_rx_dma[i] = NULL;
+		}
+	}
+	tmp_ss = ror8(conn->rmb_tx_size_short, 4);
+	list_del(&conn->rmb_tx_elem->list);
+	kfree(txkp->rmb_tx);
+	kfree(txkp);
+	conn->rmb_tx_elem = NULL;
+
+	tmp_ss = ror8(conn->rmb_rx_size_short, 4);
+	list_del(&conn->rmb_rx_elem->list);
+	kfree(rxkp->rmb_rx);
+	kfree(rxkp);
+	conn->rmb_rx_elem = NULL;
+
+	return 0;
+}
+
+static struct smc_link *smc_link_match(struct smc_link_group *lgr,
+				       struct smc_clc_msg_hdr2 *hdr2,
+				       u32 qp_num, enum smc_role role,
+				       unsigned long *flags)
+{
+	int i;
+
+	if (mutex_is_locked(&lgr->conf_mutex)) {
+		write_unlock_bh(&lgr->conns_lock);
+		spin_unlock_bh(&smc_lgr_list.lock);
+		mutex_lock(&lgr->conf_mutex);
+		mutex_unlock(&lgr->conf_mutex);
+		spin_lock_bh(&smc_lgr_list.lock);
+		write_lock_bh(&lgr->conns_lock);
+		return (struct smc_link *)LGR_RECONFIGURING;
+	}
+	for (i = 0; i <= SMC_MAX_SYM_LINKS; i++) {
+		if ((atomic_read(&lgr->lnk[i].state) == SMC_LINK_UP) &&
+		    !memcmp(lgr->lnk[i].gid_peer, &hdr2->gid, 16) &&
+		    !memcmp(lgr->lnk[i].mac_peer, hdr2->mac, 6) &&
+		    ((role == SMC_SERV) ||
+		     (lgr->lnk[i].qp_num_peer == qp_num)))
+			return &lgr->lnk[i];
+	}
+	return NULL;
+}
+
+static int smc_find_link(struct smc_link_group *lgr, int alt)
+{
+	int first = -ENOENT;
+	int second = -ENOENT;
+	int i;
+
+	for (i = 0; i <= SMC_MAX_SYM_LINKS; i++) {
+		if ((atomic_read(&lgr->lnk[i].state) == SMC_LINK_UP) &&
+		    (i != lgr->asymm_link)) {
+			first = i;
+			break;
+		}
+	}
+	if (!alt)
+		return first;
+	for (i = ++first; i <= SMC_MAX_SYM_LINKS; i++) {
+		if ((atomic_read(&lgr->lnk[i].state) == SMC_LINK_UP) &&
+		    (i != lgr->asymm_link)) {
+			second = i;
+			break;
+		}
+	}
+	return second;
+}
+
+static void smc_link_down_worker(struct work_struct *work)
+{
+	int i;
+
+	struct smc_link_group *lgr
+		= container_of(work, struct smc_link_group, link_down_work);
+
+	for (i = 0; i <= SMC_MAX_SYM_LINKS; i++) {
+		if (lgr->lnk_down[i]) {
+			lgr->lnk_down[i] = 0;
+			if (smc_lnk_downing(&lgr->lnk[i].state)) {
+				mutex_lock(&lgr->conf_mutex);
+				smc_link_down(lgr, i);
+				mutex_unlock(&lgr->conf_mutex);
+			}
+		}
+	}
+}
+
+static int smc_create_lgr(struct smc_sock *smc, __be32 target,
+			  enum smc_role role, struct smc_clc_msg_hdr2 *hdr2)
+{
+	struct smc_link_group *lgr;
+	int i;
+	char wq_name[11];
+
+	/* create a new link group */
+	lgr = kzalloc(sizeof(*lgr), GFP_KERNEL);
+	if (!lgr) {
+		smc_lgr_list.create_conn_pending = 0;
+		return -ENOMEM;
+	}
+	for (i = 0; i < 16; i++) {
+		INIT_LIST_HEAD(&lgr->rmb_tx_bufs[i]);
+		INIT_LIST_HEAD(&lgr->rmb_rx_bufs[i]);
+	}
+	memcpy(lgr->peer_peer_id, hdr2->peer_id, 8);
+	lgr->daddr = target;
+	lgr->role = role;
+	lgr->lgr_type = INIT;
+	spin_lock_init(&lgr->llc_ctl_lock);
+	INIT_LIST_HEAD(&lgr->llc_event_q);
+	spin_lock_init(&lgr->llc_event_q_lock);
+	lgr->delayed_q = NULL;
+	init_waitqueue_head(&lgr->llc_waiter);
+	INIT_WORK(&lgr->llc_event_work, llc_event_worker);
+	INIT_DELAYED_WORK(&lgr->free_lgr_work, smc_free_lgr_worker);
+	lgr->conns_all = RB_ROOT;
+	rwlock_init(&lgr->conns_lock);
+	lgr->lgr_id = atomic_add_return(256, &smc_lgr_num);
+	smc->conn.lgr = lgr;
+	write_lock_bh(&lgr->conns_lock);
+	smc_register_in_lgr(&smc->conn);
+	write_unlock_bh(&lgr->conns_lock);
+	mutex_init(&lgr->conf_mutex);
+	lgr->lnk[0].lnk_grp = lgr;
+	lgr->asymm_link = SMC_MAX_SYM_LINKS + 2;
+	spin_lock_bh(&smc_lgr_list.lock);
+	list_add_tail(&lgr->list, &smc_lgr_list.list);
+	smc_lgr_list.create_conn_pending = 0;
+	spin_unlock_bh(&smc_lgr_list.lock);
+	mutex_lock(&lgr->conf_mutex);
+	smc->conn.lnk_idx = 0;
+	snprintf(wq_name, sizeof(wq_name), "smc_wq_%u", lgr->lgr_id);
+	lgr->llc_wq = create_singlethread_workqueue(wq_name);
+	INIT_WORK(&lgr->link_down_work, smc_link_down_worker);
+	return 0;
+}
+
+static int smc_check_lgr_consistency(struct smc_sock *smc)
+{
+	u32 reason;
+	u8 flag;
+
+	if (!smc->conn.lgr && !smc->new_lgr) {
+		smc_lgr_list.create_conn_pending = 0;
+		/* send decline with flag */
+		reason = SMC_CLC_DEC_SU; /* synchronization error */
+		flag = SMC_LINK_GROUP_OUT_OF_SYNCH;
+		clc_send_decline(smc, reason, flag);
+		smc->sk.sk_err = ENOLINK;
+		return -ENOLINK;
+	}
+	if (smc->conn.lgr && smc->new_lgr) {
+		/* something is wrong with this link group */
+		spin_lock_bh(&smc_lgr_list.lock);
+		list_del_init(&smc->conn.lgr->list);
+		spin_unlock_bh(&smc_lgr_list.lock);
+		smc_unregister_in_lgr(&smc->conn); /* takes conns_lock */
+		/* send decline with flag */
+		reason = SMC_CLC_DEC_SU; /* synchronization error */
+		flag = SMC_LINK_GROUP_OUT_OF_SYNCH;
+		clc_send_decline(smc, reason, flag);
+		/* terminate connections */
+		smc->sk.sk_err = ENOLINK;
+		smc_terminate_conn(smc->conn.lgr);
+		return -ENOLINK;
+	}
+	return 0;
+}
+
+int smc_create_conn(struct smc_sock *smc, __be32 target, enum smc_role role,
+		    struct smc_roce_defs *rocdefs,
+		    struct smc_clc_msg_hdr2 *hdr2,
+		    u32 arrival_qp_num)
+{
+	struct smc_connection *conn = &smc->conn;
+	struct smc_link_group *lgr;
+	struct smc_link *link;
+	unsigned long flags;
+	int alt = 0, rc;
+
+	conn->lgr = NULL;
+	while (cmpxchg(&smc_lgr_list.create_conn_pending, 0, 1) != 0)
+		msleep(20);
+	spin_lock_bh(&smc_lgr_list.lock);
+again:
+	list_for_each_entry(lgr, &smc_lgr_list.list, list) {
+		write_lock_bh(&lgr->conns_lock);
+		if ((!memcmp(lgr->peer_peer_id, hdr2->peer_id, 8)) &&
+		    (lgr->role == role) &&
+		    (lgr->vlan == rocdefs->vlan) &&
+		    (role == SMC_CLNT ||
+		     lgr->conns_num < smc_max_conn_per_lgr)) {
+			link = smc_link_match(lgr, hdr2, arrival_qp_num, role,
+					      &flags);
+			if (!link) {
+				write_unlock_bh(&lgr->conns_lock);
+				continue;
+			}
+			if (link == (struct smc_link *)LGR_RECONFIGURING) {
+				write_unlock_bh(&lgr->conns_lock);
+				goto again;
+			}
+			conn->lgr = lgr;
+			smc_lgr_list.create_conn_pending = 0;
+			if (role == SMC_SERV) {
+				if (lgr->lgr_type == SYMMETRIC)
+					/* try load balancing */
+					alt = lgr->conns_num % 2;
+				conn->lnk_idx = smc_find_link(lgr, alt);
+			} else {
+				conn->lnk_idx = link - &lgr->lnk[0];
+			}
+			smc_register_in_lgr(conn);
+			write_unlock_bh(&lgr->conns_lock);
+			break;
+		}
+		write_unlock_bh(&lgr->conns_lock);
+	}
+	spin_unlock_bh(&smc_lgr_list.lock);
+	if (role == SMC_CLNT) {
+		rc = smc_check_lgr_consistency(smc);
+		if (rc)
+			return -ENOLINK;
+	}
+	if (!conn->lgr) {
+		smc->new_lgr = 1;
+		rc = smc_create_lgr(smc, target, role, hdr2);
+		if (rc)
+			return rc;
+		lgr = conn->lgr;
+		rc = smc_create_link(lgr, 0, rocdefs);
+		if (rc) {
+			lgr->lgr_type = NONE;
+			mutex_unlock(&lgr->conf_mutex);
+			conn->lgr = NULL;
+			spin_lock_bh(&smc_lgr_list.lock);
+			list_del(&lgr->list);
+			spin_unlock_bh(&smc_lgr_list.lock);
+			kfree(lgr);
+			return rc;
+		}
+		link = &lgr->lnk[conn->lnk_idx];
+	} else {
+		mutex_lock(&lgr->conf_mutex);
+		smc->new_lgr = 0;
+	}
+	conn->local_tx_ctrl.ctrl_type = RMBE_CTRL;
+	conn->local_tx_ctrl.ctrl_len = SMC_SIZE_OF_CTRL_DATA;
+	conn->tx_seq = 0;
+	spin_lock_init(&conn->send_lock);
+	atomic_set(&conn->bytes_to_rcv, 0);
+	conn->lgr->vlan = rocdefs->vlan;
+	init_waitqueue_head(&smc->rx_waiter);
+	return 0;
+}
+
+u8 smc_compress_bufsize(int n)
+{
+	u8 compressed = 0;
+
+	n = (n-1) >> 14;
+	compressed = ilog2(n) + 1;
+	if (compressed > SMC_RMBE_SIZE_VALUES)
+		compressed = SMC_RMBE_SIZE_VALUES;
+	compressed = rol8(compressed, 4);
+	return compressed;
+}
+
+int smc_uncompress_bufsize(u8 x)
+{
+	u8 left_bits = ror8(x, 4);
+	u32 size;
+
+	size = 0x00000001 << (((int)left_bits) + 14);
+	return size;
+}
+
+static int smc_rdma_write(struct smc_connection *conn, int target_offset,
+			  int lnk_idx, int num, struct tx_sge sge[])
+{
+	struct smc_link_group *lgr = conn->lgr;
+	struct smc_link *link;
+	struct ib_sge sge_send[2];
+	struct ib_send_wr send_wr;
+	struct ib_send_wr *failed_wr;
+	int i, rc;
+
+	memset(&send_wr, 0, sizeof(send_wr));
+	memset(&sge_send, 0, 2 * sizeof(struct ib_sge));
+	link = &lgr->lnk[lnk_idx];
+	for (i = 0; i < num; i++) {
+		sge_send[i].addr = ((u64)conn->rmb_tx_elem->rmb_tx_dma[lnk_idx])
+				 + SMC_EYE_CATCH_LEN + sge[i].offset;
+		sge_send[i].length = sge[i].len;
+		sge_send[i].lkey = link->mr_tx->lkey;
+	}
+	send_wr.wr_id =
+		(u64)atomic64_inc_return((atomic64_t *)&link->wr_id_send);
+	send_wr.opcode = IB_WR_RDMA_WRITE;
+	send_wr.wr.rdma.remote_addr =
+		lgr->rtok[conn->rtok_idx].vaddr[lnk_idx]
+	      + target_offset + SMC_EYE_CATCH_LEN
+	      + ((conn->peer_tcp_conn_idx - 1)
+	       * (conn->peer_rx_buf_len + SMC_EYE_CATCH_LEN));
+	send_wr.wr.rdma.rkey = lgr->rtok[conn->rtok_idx].rkey[lnk_idx];
+	send_wr.num_sge = num;
+	send_wr.sg_list = sge_send;
+	failed_wr = &send_wr;
+	rc = ib_post_send(link->roce_qp, &send_wr, &failed_wr);
+	if (rc) {
+		struct smc_roce_defs *rocd;
+
+		rocd = &link->roce_defs;
+		conn->local_tx_ctrl.conn_state_flags.abnormal_close = 1;
+			if (cmpxchg(&rocd->ibdev->port_err[rocd->port - 1],
+				    0, 1) == 0)
+				schedule_work(&rocd->ibdev->port_err_work);
+	}
+	return rc;
+}
+
+static inline int smc_get_free_ctrl_buf(struct smc_link *link, u32 *elem)
+{
+	*elem = link->send_wr_num;
+	if ((atomic_read(&link->state) == SMC_LINK_DOWN) ||
+	    (atomic_read(&link->state) == SMC_LINK_FREED)) {
+		return -EPIPE;
+	}
+	for_each_clear_bit(*elem, link->pending_bit_mask, link->send_wr_num) {
+		if (!test_and_set_bit(*elem, link->pending_bit_mask))
+			return 0;
+	}
+	*elem = link->send_wr_num;
+	return -EBUSY;
+}
+
+int smc_get_ctrl_buf(struct smc_link *link, u32 *elem)
+{
+	int rc = 0;
+
+	if (in_softirq()) {
+		rc = smc_get_free_ctrl_buf(link, elem);
+		if (rc)
+			return rc;
+	} else {
+		rc = wait_event_interruptible_timeout(link->wqe_waiter,
+				(smc_get_free_ctrl_buf(link, elem) != -EBUSY),
+				SMC_WAIT_FREE_CTRL_BUF_TIMEO);
+		if (!rc) {
+			/* timeout - switch conns */
+			return -EPIPE;
+		}
+		if (rc == -ERESTARTSYS)
+			return rc;
+		if (*elem == link->send_wr_num)
+			return -EPIPE;
+	}
+	return 0;
+}
+
+static inline int smc_add_pending_send(struct smc_link *link,
+				       struct smc_connection *conn, u32 *elem)
+{
+	u64 wr_id;
+	int rc = 0;
+
+	wr_id = (u64)atomic64_inc_return((atomic64_t *)&link->wr_id_send);
+	rc = smc_get_ctrl_buf(link, elem);
+	if (rc < 0)
+		return rc;
+	memset(&link->pending[*elem], 0, sizeof(struct pending_send));
+	link->pending[*elem].conn = conn;
+	link->pending[*elem].wr_id_send = wr_id;
+	link->send_wr[*elem].wr_id = wr_id;
+	return 0;
+}
+
+int smc_ctrl_send(struct smc_connection *conn, int lnk_idx)
+{
+	struct smc_link *link;
+	struct rmb_e_ctrl ctrl;
+	int rc = 0;
+	u32 elem;
+
+	link = &conn->lgr->lnk[lnk_idx];
+	rc = smc_add_pending_send(link, conn, &elem);
+	if (rc)
+		return rc;
+	spin_lock_bh(&conn->send_lock);
+	if (conn->local_tx_ctrl.p_flags.last_msg_valid_req) {
+		conn->local_tx_ctrl.ctrl_seq = conn->tx_seq_fin;
+	} else {
+		conn->tx_seq++;
+		conn->local_tx_ctrl.ctrl_seq = conn->tx_seq;
+	}
+	link->pending[elem].cursor.s.curs = conn->tx_curs_sent.s.curs;
+	link->pending[elem].p_cursor.s.curs =
+		conn->local_tx_ctrl.p_curs.s.curs;
+	link->pending[elem].ctrl_seq = conn->tx_seq;
+	smc_set_ctrl(&conn->local_tx_ctrl, &ctrl);
+	rc = smc_wr_send(link, conn, (u64)&ctrl, elem);
+	if (!rc) {
+		atomic64_set(&conn->rx_curs_confirmed.s.acurs,
+			    atomic64_read(&conn->local_tx_ctrl.c_curs.s.acurs));
+	} else {
+		test_and_clear_bit(elem, link->pending_bit_mask);
+	}
+	spin_unlock_bh(&conn->send_lock);
+	return rc;
+}
+
+/* Send wr via ib_post_send.
+ * Requires conn->send_lock being held if entered with an smc_connection
+ */
+int smc_wr_send(struct smc_link *link, struct smc_connection *conn, u64 addr,
+		u32 index)
+{
+	struct ib_send_wr *failed_wr;
+	struct smc_roce_defs *rocdefs = &link->roce_defs;
+	struct smc_ib_device *ibdev = rocdefs->ibdev;
+	int rc;
+
+	rc = ib_req_notify_cq(ibdev->roce_cq_send,
+			      IB_CQ_SOLICITED_MASK |
+			      IB_CQ_REPORT_MISSED_EVENTS);
+	memcpy(&link->ctrl_buf_tx[index], (void *)addr, SMC_SIZE_OF_CTRL_DATA);
+	failed_wr = &link->send_wr[index];
+	rc = ib_post_send(link->roce_qp, &link->send_wr[index], &failed_wr);
+	if (rc) {
+		if ((atomic_read(&link->state) != SMC_LINK_FREED) &&
+		    (cmpxchg(&ibdev->port_err[rocdefs->port - 1], 0, 1) == 0))
+				/* try failover to other link */
+			schedule_work(&ibdev->port_err_work);
+		if (conn) {
+			if (!conn->local_rx_ctrl.p_flags.write_blocked &&
+			    !conn->local_rx_ctrl.p_flags.cons_curs_upd_req) {
+				/* not invoked in softirq context */
+				spin_unlock_bh(&conn->send_lock);
+				msleep(100); /* delay to enable port_err_work
+					      * to be done
+					      */
+				spin_lock_bh(&conn->send_lock);
+			}
+		} else {
+			msleep(100);
+		}
+		rc = 0;
+	}
+	return rc;
+}
+
+static int smc_write_space(struct smc_sock *smc)
+{
+	struct smc_curs prod;
+	struct smc_curs cons;
+	int buffer_len = smc->conn.peer_rx_buf_len;
+	int space;
+
+	prod.s.lcurs = atomic64_read(&smc->conn.local_tx_ctrl.p_curs.s.acurs);
+	cons.s.lcurs = atomic64_read(&smc->conn.local_rx_ctrl.c_curs.s.acurs);
+
+	/* determine rx_buf space */
+	space = buffer_len - smc_curs_diff(buffer_len, &cons, &prod);
+
+	return space;
+}
+
+static int smc_wait_rx_space(struct smc_sock *smc)
+{
+	struct sock *sk = &smc->sk;
+	struct smc_connection *conn = &smc->conn;
+	int space, rc = 0;
+
+	space = atomic_read(&smc->conn.rx_buf_space);
+	if (space)
+		return space;
+
+	release_sock(sk);
+	rc = wait_event_interruptible_timeout(smc->rx_waiter,
+		atomic_read(&smc->conn.rx_buf_space) ||
+		sk->sk_err ||
+		smc_stop_received(conn),
+		SMC_WAIT_RX_SPACE_TIMEO);
+	if ((rc == -ERESTARTSYS) || !rc) {
+		/* interrupted or timeout */
+		smc_flag_sock_err(smc);
+		space = sock_error(sk);
+		lock_sock(sk);
+		goto out;
+	}
+	lock_sock(sk);
+	space = atomic_read(&smc->conn.rx_buf_space);
+out:
+	return space;
+}
+
+static int smc_wait_tx_space(struct smc_sock *smc, int flags)
+{   /* derived from sk_stream_wait_memory */
+	int rc = 0;
+	struct sock *sk = &smc->sk;
+	long timeo = sock_sndtimeo(sk, flags & MSG_DONTWAIT);
+	DEFINE_WAIT(wait);
+
+	if (timeo == MAX_SCHEDULE_TIMEOUT)
+		timeo = (prandom_u32() % (HZ / 5)) + 2;
+	set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN) ||
+	    smc->conn.local_tx_ctrl.conn_state_flags.sending_done) {
+		rc = -EPIPE;
+		goto out;
+	}
+	if (smc_close_received(smc)) {
+		rc = -ECONNRESET;
+		goto out;
+	}
+	if (!timeo) {
+		rc = -EAGAIN;
+		goto out;
+	}
+	if (fatal_signal_pending(current)) {
+		rc = sock_intr_errno(timeo);
+		goto out;
+	}
+	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+	if (atomic_read(&smc->conn.tx_buf_space))
+		goto out;
+	set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+	rc = sk_wait_event(sk, &timeo, sk->sk_err ||
+			   (sk->sk_shutdown & SEND_SHUTDOWN) ||
+		smc->conn.local_tx_ctrl.conn_state_flags.sending_done ||
+			   smc_close_received(smc) ||
+			   atomic_read(&smc->conn.tx_buf_space));
+	clear_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN) ||
+	    smc->conn.local_tx_ctrl.conn_state_flags.sending_done) {
+		rc = -EPIPE;
+	}
+	if (smc_close_received(smc))
+		rc = -ECONNRESET;
+out:
+	finish_wait(sk_sleep(sk), &wait);
+	return rc;
+}
+
+int smc_prepared_sends(struct smc_connection *conn)
+{
+	struct smc_curs prep;
+	struct smc_curs sent;
+
+	prep.s.lcurs = atomic64_read(&conn->tx_curs_prep.s.acurs);
+	sent.s.lcurs = atomic64_read(&conn->tx_curs_sent.s.acurs);
+	return smc_curs_diff(conn->rmb_tx_size, &sent, &prep);
+}
+
+int smc_pending_sends(struct smc_connection *conn)
+{
+	struct smc_link *lnk;
+	u32 i, j;
+
+	for (j = 0; j <= SMC_MAX_SYM_LINKS; j++) {
+		lnk = &conn->lgr->lnk[j];
+		if (!lnk->lnk_grp)
+			continue;
+		for_each_set_bit(i, lnk->pending_bit_mask, lnk->send_wr_num) {
+			if (lnk->pending[i].conn == conn)
+				return 1;
+		}
+	}
+	return 0;
+}
+
+void smc_clear_pending_sends(struct smc_connection *conn)
+{
+	struct smc_link *lnk;
+	u32 i, j;
+
+	for (j = 0; j <= SMC_MAX_SYM_LINKS; j++) {
+		lnk = &conn->lgr->lnk[j];
+		if (!lnk->lnk_grp)
+			continue;
+		for_each_set_bit(i, lnk->pending_bit_mask, lnk->send_wr_num) {
+			if (lnk->pending[i].conn == conn)
+				clear_bit(i, lnk->pending_bit_mask);
+		}
+	}
+}
+
+static inline int smc_give_up_send(struct smc_sock *smc, int copied)
+{
+	if (smc->sk.sk_shutdown & SEND_SHUTDOWN ||
+	    smc->conn.local_tx_ctrl.conn_state_flags.abnormal_close)
+		return -EPIPE;
+	if (smc_close_received(smc))
+		return copied ? copied : -ECONNRESET;
+	return 0;
+}
+
+int smc_conn_send(struct smc_sock *smc, struct kiocb *iocb, struct msghdr *msg,
+		  size_t len)
+{
+	struct smc_connection *conn = &smc->conn;
+	struct tcp_sock *tp = tcp_sk(smc->tcpsocket->sk);
+	struct smc_curs prep;
+	unsigned long max_wait_for_tx_space;
+	int copy, copied = 0, to_send = len;
+	int writespace;
+	int tx_top = 0, tx_bot = 0;
+	int rc = 0;
+	int tx_cnt_prep;
+	char *buf;
+
+	if (timer_pending(&smc->cork_timer)) {
+		del_timer_sync(&smc->cork_timer);
+		destroy_timer_on_stack(&smc->cork_timer);
+	}
+	max_wait_for_tx_space =  SMC_WAIT_TX_SPACE_TIMEO + jiffies;
+again:
+	if ((smc->sk.sk_state != SMC_ACTIVE) &&
+	    (smc->sk.sk_state != SMC_APPLCLW1))
+		return (smc->sk.sk_state == SMC_INIT
+		      ? -ENOTCONN : -ECONNRESET);
+
+	writespace = atomic_read(&conn->tx_buf_space);
+	if (!writespace) {
+		writespace = smc_wait_tx_space(smc, msg->msg_flags);
+		if (writespace < 0)
+			return ((copied && (writespace == -EAGAIN))
+			       ? copied : writespace);
+		if (!writespace) {
+			rc = smc_give_up_send(smc, copied);
+			if (rc)
+				return rc;
+			if (msg->msg_flags & MSG_DONTWAIT)
+				return copied ? copied : -EAGAIN;
+			if ((smc->sk.sk_err) ||
+			    (time_after_eq(jiffies, max_wait_for_tx_space))) {
+				return copied ? copied : -EPIPE;
+			}
+			goto again;
+		}
+	}
+	if (smc->sk.sk_err ||
+	    smc->sk.sk_shutdown & SEND_SHUTDOWN)
+		return -EPIPE;
+
+	writespace = atomic_read(&conn->tx_buf_space);
+	rc = smc_give_up_send(smc, copied);
+	if (rc)
+		return rc;
+
+	if (msg->msg_flags & MSG_OOB) {
+		if (writespace < len) {
+			/* to_send ??? */
+			conn->local_tx_ctrl.p_flags.urg_data_pending = 1;
+			rc = smc_ctrl_send(conn, conn->lnk_idx);
+			conn->local_tx_ctrl.p_flags.urg_data_pending = 0;
+		}
+	}
+
+	copy = min_t(size_t, to_send, writespace);
+	/* determine start of tx_buf */
+	prep.s.lcurs = atomic64_read(&conn->tx_curs_prep.s.acurs);
+	tx_cnt_prep = prep.s.curs.c;
+	buf = conn->rmb_tx_elem->rmb_tx->buffer;
+	/* determine tx_buf pieces - bottom and top of tx_buf */
+	if (tx_cnt_prep + copy <= conn->rmb_tx_size) {
+		tx_top = 0;
+		tx_bot = copy;
+		if (memcpy_fromiovec(buf + tx_cnt_prep, msg->msg_iov, copy))
+			return -EFAULT;
+	} else {
+		tx_bot = conn->rmb_tx_size - tx_cnt_prep;
+		tx_top = copy - tx_bot;
+		if (memcpy_fromiovec(buf + tx_cnt_prep, msg->msg_iov, tx_bot))
+			return -EFAULT;
+		if (memcpy_fromiovec(buf, msg->msg_iov, tx_top))
+			return -EFAULT;
+	}
+	smc_curs_add(conn->rmb_tx_size, &prep.s.curs, copy);
+	atomic64_set(&conn->tx_curs_prep.s.acurs, prep.s.lcurs);
+	atomic_sub(copy, &conn->tx_buf_space);
+
+	if (msg->msg_flags & MSG_OOB)
+		atomic64_set(&conn->tx_urg_curs.s.acurs, prep.s.lcurs);
+
+	if ((tp->nonagle & TCP_NAGLE_CORK || msg->msg_flags & MSG_MORE) &&
+	    (writespace > copy)) {
+		if (!timer_pending(&smc->cork_timer))
+			/* cancelled at the beginning ? */
+			mod_timer(&smc->cork_timer,
+				  jiffies + msecs_to_jiffies(200));
+	} else {
+		if (atomic_read(&conn->rx_buf_space))
+			smc_write_data(smc);
+		else if (!delayed_work_pending(&smc->write_work))
+			schedule_delayed_work(&smc->write_work, 0);
+	}
+
+	copied = copied + copy;
+	to_send = to_send - copy;
+	if (copied < len)
+		goto again;
+
+	return copied;
+}
+
+static inline void smc_fill_sge(int *num, struct tx_sge sge[], int offset1,
+				int len1, int offset2, int len2)
+{
+	memset(sge, 0, 2 * sizeof(struct tx_sge));
+	sge[0].offset = offset1;
+	sge[0].len = len1;
+	if (len2) {
+		*num = 2;
+		sge[1].offset = offset2;
+		sge[1].len = len2;
+	} else {
+		*num = 1;
+	}
+}
+
+static inline void smc_write_data_adapt(struct smc_connection *conn,
+					struct smc_curs *prod,
+					struct smc_curs *sent, int len)
+{
+	smc_curs_add(conn->peer_rx_buf_len, &prod->s.curs, len);
+	atomic_sub(len, &conn->rx_buf_space);
+	smc_curs_add(conn->rmb_tx_size, &sent->s.curs, len);
+}
+
+void smc_write_data(struct smc_sock *smc)
+{
+	struct smc_link *lnk;
+	struct smc_connection *conn = &smc->conn;
+	int copy, space_left1, space_left2, send_len, to_send;
+	int writespace;
+	struct smc_curs prod;
+	struct smc_curs cons;
+	struct smc_curs sent;
+	struct smc_curs prep;
+	struct tx_sge sge[2];
+	int tx_top = 0, tx_bot = 0;
+	int tx_top1 = 0, tx_top2 = 0;
+	int tx_bot1 = 0, tx_bot2 = 0;
+	int rc = 0, num, urgent = 0;
+	u8 lnk_idx;
+
+	lnk_idx = conn->lnk_idx;
+	lnk = &conn->lgr->lnk[lnk_idx];
+	sent.s.lcurs = atomic64_read(&conn->tx_curs_sent.s.acurs);
+	prep.s.lcurs = atomic64_read(&conn->tx_urg_curs.s.acurs);
+	if (!prep.s.curs.w && !prep.s.curs.c)
+		prep.s.lcurs = atomic64_read(&conn->tx_curs_prep.s.acurs);
+	else
+		urgent = 1;
+	to_send = smc_curs_diff(conn->rmb_tx_size, &sent, &prep);
+	if (!to_send)
+		goto send_ctrl;
+	writespace = atomic_read(&conn->rx_buf_space);
+	if (writespace <= 0)
+		return;
+	if (find_first_zero_bit(lnk->pending_bit_mask, lnk->send_wr_num) ==
+		lnk->send_wr_num) {
+		schedule_delayed_work(&smc->write_work, HZ/10);
+		return;
+	}
+	copy = min_t(size_t, to_send, writespace);
+	if (sent.s.curs.c + copy <= conn->rmb_tx_size) {
+		tx_top = 0;
+		tx_bot = copy;
+	} else {
+		tx_bot = conn->rmb_tx_size - sent.s.curs.c;
+		tx_top = copy - tx_bot;
+	}
+	prod.s.lcurs = atomic64_read(&conn->local_tx_ctrl.p_curs.s.acurs);
+	cons.s.lcurs = atomic64_read(&conn->local_rx_ctrl.c_curs.s.acurs);
+	if (prod.s.curs.w == cons.s.curs.w) {
+		space_left1 = conn->peer_rx_buf_len - prod.s.curs.c;
+		space_left2 = cons.s.curs.c;
+
+		send_len = min_t(size_t, copy, space_left1);
+		if (send_len <= tx_bot) {
+			tx_bot1 = send_len;
+			tx_bot2 = tx_bot - tx_bot1;
+			tx_top1 = 0;
+			tx_top2 = tx_top;
+		} else {
+			tx_bot1 = tx_bot;
+			tx_bot2 = 0;
+			tx_top1 = send_len - tx_bot;
+			tx_top2 = tx_top - tx_top1;
+		}
+		smc_fill_sge(&num, sge, sent.s.curs.c, tx_bot1, 0, tx_top1);
+		rc = smc_rdma_write(conn, prod.s.curs.c, lnk_idx, num, sge);
+		if (rc)
+			return;
+		copy -= send_len;
+		smc_write_data_adapt(conn, &prod, &sent, send_len);
+
+		if (copy && space_left2 && (tx_bot2 + tx_top2 > 0)) {
+			send_len = min_t(size_t, copy, space_left2);
+			if (tx_bot2 > send_len) {
+				tx_bot2 = send_len;
+				tx_top2 = 0;
+			} else {
+				if (tx_bot2 + tx_top2 > send_len)
+					tx_top2 = send_len - tx_bot2;
+			}
+			if (tx_bot2)
+				smc_fill_sge(&num, sge, sent.s.curs.c,
+					     tx_bot2, tx_top1, tx_top2);
+			else if (tx_top2)
+				smc_fill_sge(&num, sge, tx_top1, tx_top2, 0, 0);
+			rc = smc_rdma_write(conn, 0, lnk_idx, num, sge);
+			if (rc)
+				return;
+			smc_write_data_adapt(conn, &prod, &sent,
+					     tx_bot2 + tx_top2);
+		}
+	} else {
+		space_left1 = cons.s.curs.c - prod.s.curs.c;
+		send_len = min_t(size_t, copy, space_left1);
+		if (send_len <= tx_bot) {
+			tx_bot = send_len;
+			tx_top = 0;
+		} else {
+			if ((send_len - tx_bot) <= tx_top)
+				tx_top = send_len - tx_bot;
+		}
+		smc_fill_sge(&num, sge, sent.s.curs.c, tx_bot, 0, tx_top);
+		rc = smc_rdma_write(conn, prod.s.curs.c, lnk_idx, num, sge);
+		if (rc)
+			return;
+		smc_write_data_adapt(conn, &prod, &sent, send_len);
+	}
+	atomic64_set(&conn->local_tx_ctrl.p_curs.s.acurs, prod.s.lcurs);
+	atomic64_set(&conn->tx_curs_sent.s.acurs, sent.s.lcurs);
+
+	/* send cursor updates and signal peer */
+	conn->local_tx_ctrl.p_flags.write_blocked =
+		(to_send > atomic_read(&conn->rx_buf_space)) ? 1 : 0;
+
+	if (urgent) {
+		conn->local_tx_ctrl.p_flags.urg_data_pending = 1;
+		conn->local_tx_ctrl.p_flags.urg_data_present = 1;
+	}
+
+send_ctrl:
+	rc = smc_ctrl_send(conn, lnk_idx);
+	if (rc)
+		/* failover is scheduled */
+		return;
+
+	if (urgent) {
+		conn->local_tx_ctrl.p_flags.urg_data_pending = 0;
+		conn->local_tx_ctrl.p_flags.urg_data_present = 0;
+		atomic64_set(&conn->tx_urg_curs.s.acurs, 0);
+			/* could be lost in case of failover */
+	}
+
+	prep.s.lcurs = atomic64_read(&conn->tx_urg_curs.s.acurs);
+	if (!prep.s.curs.w && !prep.s.curs.c)
+		prep.s.lcurs = atomic64_read(&conn->tx_curs_prep.s.acurs);
+	if (smc_curs_diff(conn->rmb_tx_size, &sent, &prep) &&
+	    (smc->sk.sk_state != SMC_CLOSED)) {
+		schedule_delayed_work(&smc->write_work, 0);
+	} else {
+		if (wq_has_sleeper(smc->sk.sk_wq) &&
+		    atomic_read(&conn->tx_buf_space) &&
+		    test_bit(SOCK_NOSPACE, &smc->sk.sk_socket->flags))
+			smc_sock_wake_tx(&smc->sk);
+	}
+}
+
+void smc_write_worker(struct work_struct *work)
+{
+	int rc;
+
+	struct smc_sock *smc = container_of(work, struct smc_sock,
+		write_work.work);
+
+	lock_sock(&smc->sk);
+again:
+	if (!smc_prepared_sends(&smc->conn))
+		goto out;
+	rc = smc_wait_rx_space(smc);
+	if (rc < 0)
+		goto out;
+	if (!rc) {
+		if (!smc->conn.local_tx_ctrl.conn_state_flags.abnormal_close &&
+		    !smc->conn.local_rx_ctrl.conn_state_flags.abnormal_close &&
+		    (smc->sk.sk_state != SMC_CLOSED))
+			goto again;
+		else
+			goto out;
+	}
+	if (!smc->conn.local_tx_ctrl.conn_state_flags.abnormal_close &&
+	    !smc->conn.local_rx_ctrl.conn_state_flags.abnormal_close &&
+	    (smc->sk.sk_state != SMC_CLOSED))
+		smc_write_data(smc);
+out:
+	release_sock(&smc->sk);
+}
+
+int smc_send_close(struct smc_sock *smc)
+{
+	if (smc_to_read(smc))
+		smc->conn.local_tx_ctrl.conn_state_flags.abnormal_close = 1;
+	else
+		smc->conn.local_tx_ctrl.conn_state_flags.closed_conn = 1;
+	if ((smc->sk.sk_err != ECONNABORTED) &&
+	    (smc->conn.lgr->lgr_type != NONE))
+		smc_ctrl_send(&smc->conn, smc->conn.lnk_idx);
+	wake_up_interruptible(&smc->rx_waiter);
+	return 0;
+}
+
+int smc_to_read(struct smc_sock *smc)
+{
+	int rc;
+	struct smc_curs prod; /* to receive */
+	struct smc_curs cons; /* already consumed */
+	struct smc_curs spl_cons; /* spliced data in flight */
+	struct smc_curs urg;
+
+	if (((smc->conn.rx_urg_state & SMC_URG_MASK) != SMC_URG_VALID) &&
+	    !smc_splice_in_use(smc))
+		return atomic_read(&smc->conn.bytes_to_rcv);
+
+	/* local rx cursor consumer_c is up to date */
+	prod.s.lcurs = atomic64_read(&smc->conn.local_rx_ctrl.p_curs.s.acurs);
+	cons.s.lcurs = atomic64_read(&smc->conn.local_tx_ctrl.c_curs.s.acurs);
+
+	if ((smc->conn.rx_urg_state & SMC_URG_MASK) == SMC_URG_VALID) {
+		urg.s.lcurs = atomic64_read(&smc->conn.rx_urg_curs.s.acurs);
+		if (smc_curs_diff(smc->conn.rmb_rx_size, &cons, &urg))
+			prod.s.lcurs =
+				atomic64_read(&smc->conn.rx_urg_curs.s.acurs);
+	}
+	if (smc_splice_in_use(smc)) {
+		spl_cons.s.lcurs =
+			atomic64_read(&smc->conn.local_rx_spliced.s.acurs);
+		if (spl_cons.s.curs.reserved0)
+			cons = spl_cons;
+	}
+
+	rc = smc_curs_diff(smc->conn.rmb_rx_size, &cons, &prod);
+	return (rc == -EALREADY) ? 0 : rc;
+}
+
+static void smc_update_cons_curs(struct smc_sock *smc)
+{
+	struct smc_connection *conn = &smc->conn;
+	int rc = 0, to_confirm;
+	struct smc_curs cfed;
+	struct smc_curs cons;
+
+	cons.s.lcurs = atomic64_read(&conn->local_tx_ctrl.c_curs.s.acurs);
+	cfed.s.lcurs = atomic64_read(&conn->rx_curs_confirmed.s.acurs);
+	to_confirm = smc_curs_diff(conn->rmb_rx_size, &cfed, &cons);
+
+	if (conn->local_rx_ctrl.p_flags.cons_curs_upd_req ||
+	    ((to_confirm > conn->rmb_rx_size / 10) &&
+	     ((to_confirm / (conn->rmb_rx_size / 2) > 0) ||
+	      conn->local_rx_ctrl.p_flags.write_blocked ||
+	      conn->local_rx_ctrl.p_flags.urg_data_pending))) {
+		rc = smc_ctrl_send(conn, conn->lnk_idx);
+		if (rc)
+			return;
+		atomic64_set(&conn->rx_curs_confirmed.s.acurs,
+			atomic64_read(&conn->local_tx_ctrl.c_curs.s.acurs));
+	}
+	if (conn->local_rx_ctrl.p_flags.write_blocked &&
+	    !smc_to_read(smc))
+		conn->local_rx_ctrl.p_flags.write_blocked = 0;
+	conn->local_rx_ctrl.p_flags.cons_curs_upd_req = 0;
+}
+
+static void smc_pipe_buf_noop(struct pipe_inode_info *pipe,
+			      struct pipe_buffer *buf)
+{
+	;
+}
+
+static int smc_pipe_buf_steal(struct pipe_inode_info *pipe,
+			      struct pipe_buffer *buf)
+{
+	return 1;
+}
+
+struct smc_pipe_buf_priv {
+	struct smc_sock *smc;
+	unsigned int     len;
+};
+
+static void smc_pipe_buf_release(struct pipe_inode_info *pipe,
+				 struct pipe_buffer *buf)
+{
+	struct smc_curs curs;
+	struct smc_pipe_buf_priv *priv
+		= (struct smc_pipe_buf_priv *)buf->private;
+	struct smc_sock *smc = priv->smc;
+
+	/* Update cursors when we reached the last page */
+	curs.s.lcurs = atomic64_read(&smc->conn.local_tx_ctrl.c_curs.s.acurs);
+	smc_curs_add(smc->conn.rmb_rx_size, &curs.s.curs, priv->len);
+	atomic64_set(&smc->conn.local_tx_ctrl.c_curs.s.acurs, curs.s.lcurs);
+	smc_update_cons_curs(smc);
+	wake_up(&smc->splice_waiter);
+	kfree((void *)buf->private);
+}
+
+static const struct pipe_buf_operations smc_pipe_ops = {
+	.can_merge = 0,
+	.confirm = generic_pipe_buf_confirm,
+	.get = smc_pipe_buf_noop,
+	.release = smc_pipe_buf_release,
+	.steal = smc_pipe_buf_steal
+};
+
+static void smc_splice_spd_release(struct splice_pipe_desc *spd, unsigned int i)
+{
+	;
+}
+
+static void smc_free_spd(struct smc_sock *smc)
+{
+	if (smc->spd) {
+		kfree(smc->spd->partial);
+		smc->spd->partial = NULL;
+		kfree(smc->spd->pages);
+		smc->spd->pages = NULL;
+		kfree(smc->spd);
+		smc->spd = NULL;
+	}
+}
+
+static int smc_alloc_spd(struct smc_sock *smc)
+{
+	int msize = smc->conn.rmb_rx_size / PAGE_SIZE + 1;
+
+	smc->spd = kzalloc(sizeof(*smc->spd), GFP_KERNEL);
+	if (!smc->spd)
+		return -ENOMEM;
+	smc->spd->pages = kcalloc(msize, sizeof(struct page), GFP_KERNEL);
+	if (!smc->spd->pages)
+		goto error;
+	smc->spd->partial = kcalloc(msize, sizeof(struct partial_page),
+				    GFP_KERNEL);
+	if (!smc->spd->partial)
+		goto error;
+	smc->spd->nr_pages_max = msize;
+	smc->spd->ops = &smc_pipe_ops;
+	smc->spd->spd_release = smc_splice_spd_release;
+
+	return 0;
+
+error:
+	smc_free_spd(smc);
+	return -ENOMEM;
+}
+
+/* no extra handling of splice options required:
+ *   SPLICE_F_MOVE doesn't apply and can be ignored
+ *   SPLICE_F_NONBLOCK is handled by splice_to_pipe
+ *   SPLICE_F_MORE doesn't apply (fdout is a pipe)
+ *   SPLICE_F_GIFT is unused
+ */
+static int smc_splice_to_pipe(struct smc_sock *smc,
+			      struct pipe_inode_info *pipe,
+			      unsigned int flags, void *src, int len)
+{
+	struct partial_page *ppage;
+	struct splice_pipe_desc *spd;
+	struct smc_pipe_buf_priv *priv;
+	int rc, i;
+
+	if (!len)
+		return 0;
+	if (!smc->spd && smc_alloc_spd(smc))
+		return -ENOMEM;
+	spd = smc->spd;
+	spd->nr_pages = 0;
+	spd->flags = flags;
+
+	while (len) {
+		spd->pages[spd->nr_pages] = virt_to_page(src);
+		ppage = &spd->partial[spd->nr_pages];
+		ppage->offset = (unsigned long)src & ~PAGE_MASK;
+		ppage->len = min_t(int, PAGE_SIZE - ppage->offset, len);
+		src += ppage->len;
+		len -= ppage->len;
+		priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+		if (!priv)
+			goto error;
+		priv->smc = smc;
+		priv->len = ppage->len;
+		ppage->private = (unsigned long)priv;
+		spd->nr_pages++;
+	}
+
+	rc = splice_to_pipe(pipe, spd);
+	if (rc < 0 && smc->sk.sk_err)
+		goto error;
+	return rc;
+
+error:
+	for (i = 0; i < spd->nr_pages; ++i)
+		kfree((void *)spd->partial[i].private);
+	return -EFAULT;
+}
+
+/* Wait for data to arrive
+ *   @smc    smc socket
+ *   @len    num bytes to wait for
+ *   @wall   don't return until full request is fulfilled
+ *   @timeo  max seconds to wait, 0 for no timeout
+ * Returns boolean value or -EAGAIN in case timeout expired.
+ */
+int smc_wait_rx_data(struct smc_sock *smc, int len, bool wall,
+		     long timeo)
+{
+	int rc;
+	struct sock *sk = &smc->sk;
+	struct smc_connection *conn = &smc->conn;
+	int target;
+	DEFINE_WAIT(wait);
+
+	if ((smc->conn.rx_urg_state & SMC_URG_MASK) == SMC_URG_VALID)
+		target = 1;
+	else
+		target = sock_rcvlowat(sk, wall, len);
+	rc = smc_to_read(smc);
+	if (rc >= target)
+		return 1;
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+	set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+	rc = sk_wait_event(sk, &timeo,
+			   (sk->sk_err != 0) ||
+			   sk->sk_shutdown & RCV_SHUTDOWN ||
+			   sock_flag(sk, SOCK_DONE) ||
+			   (smc_to_read(smc) >= target) ||
+			   smc_stop_received(conn));
+	clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+	finish_wait(sk_sleep(sk), &wait);
+	return ((rc || timeo) ? rc : -EAGAIN);
+}
+
+static inline void smc_skip_urg_data(struct smc_sock *smc,
+				     struct smc_curs *cons,
+				     struct smc_curs *urg)
+{
+	if (((smc->conn.rx_urg_state & SMC_URG_MASK) == SMC_URG_VALID) &&
+	    (cons->s.curs.c == urg->s.curs.c) &&
+	    (cons->s.curs.w == urg->s.curs.w)) {
+		if (!sock_flag(&smc->sk, SOCK_URGINLINE))
+			smc_curs_add(smc->conn.rmb_rx_size, &cons->s.curs, 1);
+		smc->conn.rx_urg_state |= SMC_URG_RECV;
+	}
+}
+
+/* derived from tcp_recv_urg */
+static int smc_conn_recv_urg(struct smc_sock *smc, struct msghdr *msg,
+			     size_t len, unsigned int flags)
+{
+	int rc = 0;
+
+	if (sock_flag(&smc->sk, SOCK_URGINLINE) ||
+	    !(smc->conn.rx_urg_state & SMC_URG_VALID) ||
+	    (smc->conn.rx_urg_state & SMC_URG_READ))
+		return -EINVAL;
+
+	if (!(flags &  MSG_PEEK))
+		smc->conn.rx_urg_state |= SMC_URG_READ;
+
+	msg->msg_flags |= MSG_OOB;
+
+	if (len > 0) {
+		if (!(flags & MSG_TRUNC))
+			rc = memcpy_toiovec(msg->msg_iov,
+					    &smc->conn.rx_urg_data, 1);
+		len = 1;
+	} else {
+		msg->msg_flags |= MSG_TRUNC;
+	}
+	atomic_dec(&smc->conn.bytes_to_rcv);
+
+	return rc ? -EFAULT : len;
+}
+
+static inline int smc_eye_catch_check(struct smc_sock *smc)
+{
+	if (memcmp(smc->conn.rmb_rx_elem->rmb_rx->rmb_eye,
+		   SMC_EYE_CATCHER, SMC_EYE_CATCH_LEN)) {
+		BUG_ON(1);
+		return -EFAULT;
+	}
+	return 0;
+}
+
+int smc_conn_recv(struct smc_sock *smc, struct kiocb *iocb, struct msghdr *msg,
+		  size_t len, int flags)
+{
+	struct smc_connection *conn = &smc->conn;
+	int rc = 0;
+	int toread = 0, space_left, copy, buffer_len;
+	int target;		/* Read at least these many bytes */
+	char *buffer;
+	struct smc_curs prod;
+	struct smc_curs cons;
+	struct smc_curs urg;
+	struct smc_curs spl_cons;
+	long timeo;
+	int loop = 0;
+
+	msg->msg_namelen = 0;
+
+	if (smc->sk.sk_state == SMC_INIT)
+		return -ENOTCONN;
+
+	buffer_len = conn->rmb_rx_size;
+	buffer =  conn->rmb_rx_elem->rmb_rx->buffer;
+	len = min_t(size_t, len, conn->rmb_rx_size);
+
+	if (smc_eye_catch_check(smc))
+		return -EFAULT;
+
+	if (flags & MSG_OOB)
+		return smc_conn_recv_urg(smc, msg, len, flags);
+
+again:
+	target = sock_rcvlowat(&smc->sk, flags & MSG_WAITALL, len);
+	timeo = sock_rcvtimeo(&smc->sk, flags & MSG_DONTWAIT);
+	if (timeo == MAX_SCHEDULE_TIMEOUT)
+		timeo = MAX_SCHEDULE_TIMEOUT - 1;
+	if (fatal_signal_pending(current)) {
+		rc = timeo ? sock_intr_errno(timeo) : -EAGAIN;
+		return rc;
+	}
+	rc = smc_wait_rx_data(smc, target, flags & MSG_WAITALL, timeo);
+	if ((rc == -EAGAIN) || (rc == -ERESTARTSYS))
+		return rc;
+	if (!rc)
+		goto again;
+	if (smc_splice_in_use(smc)) {
+		if (smc_splice_in_progress(smc) && (flags &  MSG_DONTWAIT))
+			return -EAGAIN;
+		wait_event_interruptible(smc->splice_waiter,
+					 !smc_splice_in_progress(smc));
+	}
+	toread = smc_to_read(smc);
+	rc = 0;
+
+	if (!toread &&
+	    (smc->sk.sk_err ||
+	     smc->sk.sk_shutdown & RCV_SHUTDOWN ||
+	     sock_flag(&smc->sk, SOCK_DONE) ||
+	     smc_stop_received(conn)))
+		return sock_error(&smc->sk);
+
+	prod.s.lcurs = atomic64_read(&conn->local_rx_ctrl.p_curs.s.acurs);
+	cons.s.lcurs = atomic64_read(&conn->local_tx_ctrl.c_curs.s.acurs);
+	if (!toread)
+		goto check_repeat;
+
+	if ((conn->rx_urg_state & SMC_URG_MASK) == SMC_URG_VALID) {
+		urg.s.lcurs = atomic64_read(&conn->rx_urg_curs.s.acurs);
+		if (smc_curs_diff(conn->rmb_rx_size, &cons, &urg))
+			prod = urg;
+		else /* data preceding urg already received */
+			conn->rx_urg_state |= SMC_URG_RECV;
+	} else {
+		urg.s.lcurs = 0;
+	}
+
+	if ((toread < target) && !smc_stop_received(conn))
+		goto check_repeat;
+
+	if (prod.s.curs.w == cons.s.curs.w) {
+		space_left = prod.s.curs.c - cons.s.curs.c;
+		copy = min_t(size_t, len, space_left);
+		if (!(flags & MSG_TRUNC)) {
+			if (memcpy_toiovec(msg->msg_iov,
+					   buffer + cons.s.curs.c, copy))
+				return -EFAULT;
+		}
+		len -= copy;
+		rc += copy;
+	} else {
+		space_left = buffer_len - cons.s.curs.c;
+		if (space_left) {
+			copy = min_t(size_t, len, space_left);
+			if (!(flags & MSG_TRUNC)) {
+				if (memcpy_toiovec(msg->msg_iov,
+						   buffer + cons.s.curs.c,
+						   copy))
+					return -EFAULT;
+			}
+			len -= copy;
+			rc += copy;
+		}
+		if (len) {
+			space_left = prod.s.curs.c;
+			copy = min_t(size_t, len, space_left);
+			if (!(flags & MSG_TRUNC)) {
+				if (memcpy_toiovec(msg->msg_iov, buffer, copy))
+					return -EFAULT;
+			}
+			len -= copy;
+			rc += copy;
+		}
+	}
+
+	/* update cursors */
+	if (!(flags &  MSG_PEEK)) {
+		smc_curs_add(buffer_len, &cons.s.curs, rc);
+		smc_skip_urg_data(smc, &cons, &urg);
+		atomic_sub(rc, &conn->bytes_to_rcv);
+		atomic64_set(&conn->local_tx_ctrl.c_curs.s.acurs, cons.s.lcurs);
+		spl_cons.s.lcurs =
+			atomic64_read(&conn->local_rx_spliced.s.acurs);
+		if (spl_cons.s.curs.reserved0)
+			atomic64_set(&conn->local_rx_spliced.s.acurs,
+				     cons.s.lcurs);
+		/* send consumer cursor update if required */
+		smc_update_cons_curs(smc);
+	}
+check_repeat:
+	if ((toread < target) &&
+	    !smc_stop_received(conn) &&
+	    !conn->local_tx_ctrl.conn_state_flags.abnormal_close) {
+		loop = 0;
+		goto again;
+	}
+
+	return rc;
+}
+
+ssize_t smc_conn_splice_read(struct smc_sock *smc, struct pipe_inode_info *pipe,
+			     size_t len, unsigned int flags)
+{
+	struct smc_connection *conn = &smc->conn;
+	int rc = 0, ret = 0;
+	int toread = 0, space_left, copy, buffer_len;
+	int target = 1;		/* read at least these many bytes */
+	char *buffer;
+	struct smc_curs prod;
+	struct smc_curs cons;
+	struct smc_curs spl_cons;
+	struct smc_curs urg;
+	long timeo;
+	int loop = 0;
+
+	if (smc->sk.sk_state == SMC_INIT)
+		return -ENOTCONN;
+
+	buffer_len = conn->rmb_rx_size;
+	buffer =  conn->rmb_rx_elem->rmb_rx->buffer;
+	len = min_t(size_t, len, conn->rmb_rx_size);
+
+	if (smc_eye_catch_check(smc))
+		return -EFAULT;
+
+again:
+	timeo = sock_rcvtimeo(&smc->sk, 0);
+	if (timeo == MAX_SCHEDULE_TIMEOUT)
+		timeo = MAX_SCHEDULE_TIMEOUT - 1;
+	if (fatal_signal_pending(current)) {
+		rc = timeo ? sock_intr_errno(timeo) : -EAGAIN;
+		return rc;
+	}
+	rc = smc_wait_rx_data(smc, target, 0, timeo);
+	if ((rc == -EAGAIN) || (rc == -ERESTARTSYS))
+		return rc;
+	if (!rc) {
+		if ((loop++ > 1000) &&
+		    (sock_rcvtimeo(&smc->sk, 0) == MAX_SCHEDULE_TIMEOUT))
+			return -EFAULT;
+		goto again;
+	}
+	toread = smc_to_read(smc);
+
+	if (!toread &&
+	    (smc->sk.sk_err ||
+	     smc->sk.sk_shutdown & RCV_SHUTDOWN ||
+	     sock_flag(&smc->sk, SOCK_DONE) ||
+	     smc_stop_received(conn)))
+		return sock_error(&smc->sk);
+
+	rc = 0;
+	prod.s.lcurs = atomic64_read(&conn->local_rx_ctrl.p_curs.s.acurs);
+	cons.s.lcurs = atomic64_read(&conn->local_tx_ctrl.c_curs.s.acurs);
+	if (!toread)
+		goto check_repeat;
+
+	if ((conn->rx_urg_state & SMC_URG_MASK) == SMC_URG_VALID) {
+		urg.s.lcurs = atomic64_read(&conn->rx_urg_curs.s.acurs);
+		if (smc_curs_diff(conn->rmb_rx_size, &cons, &urg))
+			prod = urg;
+		else /* data preceding urg already received */
+			conn->rx_urg_state |= SMC_URG_RECV;
+	} else {
+		urg.s.lcurs = 0;
+	}
+
+	if ((toread < target) && !smc_stop_received(conn))
+		goto check_repeat;
+
+	if (prod.s.curs.w == cons.s.curs.w) {
+		space_left = prod.s.curs.c - cons.s.curs.c;
+		copy = min_t(size_t, len, space_left);
+		rc = smc_splice_to_pipe(smc, pipe, flags,
+					buffer + cons.s.curs.c, copy);
+		if (rc < 0)
+			return -EFAULT;
+		len -= rc;
+	} else {
+		space_left = buffer_len - cons.s.curs.c;
+		if (space_left) {
+			copy = min_t(size_t, len, space_left);
+			rc = smc_splice_to_pipe(smc, pipe, flags,
+						buffer + cons.s.curs.c,
+						copy);
+			if (rc < 0)
+				return -EFAULT;
+			len -= rc;
+		}
+		if (len) {
+			space_left = prod.s.curs.c;
+			copy = min_t(size_t, len, space_left);
+			ret = smc_splice_to_pipe(smc, pipe, flags, buffer,
+						 copy);
+			if (ret < 0)
+				return -EFAULT;
+			len -= ret;
+			rc += ret;
+		}
+	}
+
+	/* update cursors */
+	spl_cons.s.lcurs = atomic64_read(&conn->local_rx_spliced.s.acurs);
+	if (!spl_cons.s.curs.reserved0) {
+		/* no previous splice in progress, initialize to current */
+		spl_cons = cons;
+		spl_cons.s.curs.reserved0 = 1;
+	}
+	smc_curs_add(buffer_len, &spl_cons.s.curs, rc);
+	smc_skip_urg_data(smc, &spl_cons, &urg);
+	atomic64_set(&conn->local_rx_spliced.s.acurs, spl_cons.s.lcurs);
+	/* we update cursors in a callback after splicing completed */
+check_repeat:
+	if ((toread < target) &&
+	    !smc_stop_received(conn) &&
+	    !conn->local_tx_ctrl.conn_state_flags.abnormal_close) {
+		loop = 0;
+		goto again;
+	}
+
+	return rc;
+}
+
+void smc_check_qp_attr(struct smc_link *lnk)
+{
+	int rc;
+	struct ib_qp_attr *attr = &lnk->qp_attr;
+	struct ib_qp_init_attr init_attr;
+
+	memset(attr, 0 , sizeof(struct ib_qp_attr));
+	memset(&init_attr, 0 , sizeof(struct ib_qp_init_attr));
+	rc = ib_query_qp(lnk->roce_qp, attr,
+			 IB_QP_STATE |
+			 IB_QP_CUR_STATE |
+			 IB_QP_PKEY_INDEX |
+			 IB_QP_PORT |
+			 IB_QP_QKEY |
+			 IB_QP_AV |
+			 IB_QP_PATH_MTU |
+			 IB_QP_TIMEOUT |
+			 IB_QP_RETRY_CNT |
+			 IB_QP_RNR_RETRY |
+			 IB_QP_RQ_PSN |
+			 IB_QP_ALT_PATH |
+			 IB_QP_MIN_RNR_TIMER |
+			 IB_QP_SQ_PSN |
+			 IB_QP_PATH_MIG_STATE |
+			 IB_QP_CAP |
+			 IB_QP_VID |
+			 IB_QP_DEST_QPN,
+			 &init_attr);
+
+	lnk->send_wr_num = min_t(size_t, smc_ctrl_buf_cnt,
+				 lnk->qp_attr.cap.max_send_wr);
+	lnk->recv_wr_num = min_t(size_t, smc_ctrl_buf_cnt * 10,
+				 lnk->qp_attr.cap.max_recv_wr);
+}
+
+void smc_check_port_attr(struct smc_ib_device *smc_ibdev, int port_num)
+{
+	struct ib_device *dev = smc_ibdev->dev;
+	struct ib_port_attr *pattr;
+	int rc;
+
+	pattr = &smc_ibdev->pattr[port_num];
+	memset(pattr, 0, sizeof(struct ib_port_attr));
+	rc = ib_query_port(dev, port_num + 1, pattr);
+}
+
+void smc_check_dev_attr(struct smc_ib_device *smc_ibdev)
+{
+	struct ib_device *dev = smc_ibdev->dev;
+	struct ib_device_attr *attr = &smc_ibdev->attr;
+	int i, rc;
+
+	memset(attr, 0, sizeof(struct ib_device_attr));
+	rc = ib_query_device(dev, attr);
+
+	for (i = 0; i < 2; i++)
+		smc_check_port_attr(smc_ibdev, i);
+}
diff --git a/net/smc/smc_llc.c b/net/smc/smc_llc.c
new file mode 100644
index 0000000..27ed1e8
--- /dev/null
+++ b/net/smc/smc_llc.c
@@ -0,0 +1,1472 @@
+/*
+ *  Shared Memory Communications over RDMA (SMC-R) and ROCE
+ *
+ *  SMC-R Link Layer Control
+ *
+ *  Copyright IBM Corp. 2014
+ *
+ *  Author(s):  Klaus Wacker <Klaus.Wacker@de.ibm.com>
+ *              Ursula Braun <ursula.braun@de.ibm.com>
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/interrupt.h>
+#include <linux/slab.h>
+#include <linux/skbuff.h>
+#include <linux/init.h>
+#include <linux/poll.h>
+#include <linux/socket.h>
+#include <linux/pci.h>
+#include <linux/wait.h>
+#include <linux/kthread.h>
+#include <linux/hardirq.h>
+#include <linux/types.h>
+#include <net/tcp.h>
+#include <net/sock.h>
+#include <asm/byteorder.h>
+#include <rdma/ib_verbs.h>
+#include <linux/splice.h>
+#include <linux/mm.h>
+
+#include "af_smc.h"
+#include "smc_llc.h"
+
+static enum llc_msg_group llc_msg_to_grp(enum llc_msg_type type)
+{
+	enum llc_msg_group grp;
+
+	switch (type) {
+	case LLC_ADD_LINK:
+		grp = LLC_GRP_ADD_LINK;
+		break;
+	case LLC_DEL_LINK:
+		grp = LLC_GRP_DEL_LINK;
+		break;
+	case LLC_CONFIRM_RKEY:
+		grp = LLC_GRP_CONF_RKEY;
+		break;
+	case LLC_TEST_LINK:
+		grp = LLC_GRP_TEST_LINK;
+		break;
+	default:
+		grp = LLC_GRP_NONE;
+	}
+	return grp;
+}
+
+int llc_enqueue(struct smc_link *lnk, struct llc_msg *msg)
+{
+	struct smc_link_group *lgr;
+	struct llc_qentry *qentry;
+
+	lgr = lnk->lnk_grp;
+	qentry = kzalloc(sizeof(*qentry), GFP_ATOMIC);
+	if (!qentry)
+		return -ENOMEM;
+	qentry->link = lnk;
+	memcpy(&qentry->msg, msg, sizeof(struct llc_msg));
+	if (msg->hd.flags & LLC_FLAG_RESP) {
+		switch (msg->hd.type) {
+		case LLC_ADD_LINK:
+		case LLC_DEL_LINK:
+		case LLC_CONFIRM_LINK:
+		case LLC_ADD_LINK_CONT:
+			lgr->llc_ctl[LLC_SERV].qentry = qentry;
+			break;
+		case LLC_CONFIRM_RKEY:
+		case LLC_CONFIRM_RKEY_CONT:
+		case LLC_DELETE_RKEY:
+			lgr->llc_ctl[lgr->role].qentry = qentry;
+			break;
+		case LLC_TEST_LINK:
+			lgr->llc_ctl[LLC_TESTLINK].qentry = qentry;
+			break;
+		default:
+			llc_send_del_link(lnk, NULL, 0, LLC_DEL_PROT_VIOL,
+					  LLC_NO_NOTIFY);
+			smc_terminate_conn(lgr);
+			break;
+		}
+		wake_up_interruptible(&lgr->llc_waiter);
+		return 0;
+	}
+	spin_lock_bh(&lgr->llc_event_q_lock);
+	list_add_tail(&qentry->list, &lgr->llc_event_q);
+	spin_unlock_bh(&lgr->llc_event_q_lock);
+	queue_work(lgr->llc_wq, &lgr->llc_event_work);
+
+	return 0;
+}
+
+int llc_initiate(struct smc_link_group *lgr, enum llc_msg_group llc_grp)
+{
+	enum llc_msg_group llc_grp_allowed;
+	int peer;
+	enum llc_ctl_ind llc_seq;
+	int rest_time = 1;
+
+	llc_grp_allowed = (llc_grp == LLC_GRP_CONF_RKEY) ?
+				LLC_GRP_CONF_RKEY : LLC_GRP_NONE;
+	peer = !lgr->role;
+	switch (llc_grp) {
+	case LLC_GRP_CONF_RKEY:
+		llc_seq = (enum llc_ctl_ind)lgr->role;
+		break;
+	case LLC_GRP_TEST_LINK:
+		llc_seq = 2;
+		peer = 2;
+		llc_grp_allowed = LLC_GRP_TEST_LINK;
+		break;
+	default:
+		llc_seq = LLC_SERV;
+	}
+reserve_llc:
+	spin_lock_bh(&lgr->llc_ctl_lock);
+	if ((lgr->llc_ctl[llc_seq].active == LLC_GRP_NONE) &&
+	    (lgr->llc_ctl[peer].active <= llc_grp_allowed)) {
+		lgr->llc_ctl[llc_seq].active = llc_grp;
+		spin_unlock_bh(&lgr->llc_ctl_lock);
+		return rest_time;
+	}
+	spin_unlock_bh(&lgr->llc_ctl_lock);
+	rest_time = wait_event_interruptible_timeout(lgr->llc_waiter,
+		((lgr->llc_ctl[llc_seq].active == LLC_GRP_NONE) &&
+		 (lgr->llc_ctl[peer].active <= llc_grp_allowed)),
+		LLC_WAIT_TIMEO);
+	if (!rest_time)
+		return rest_time;
+	goto reserve_llc;
+}
+
+void llc_stop(struct smc_link_group *lgr, int llc_grp)
+{
+	enum llc_ctl_ind llc_seq;
+
+	switch (llc_grp) {
+	case LLC_GRP_CONF_RKEY:
+		llc_seq = (enum llc_ctl_ind)lgr->role;
+		break;
+	case LLC_GRP_TEST_LINK:
+		llc_seq = 2;
+		break;
+	default:
+		llc_seq = LLC_SERV;
+	}
+	spin_lock_bh(&lgr->llc_ctl_lock);
+	lgr->llc_ctl[llc_seq].active = LLC_GRP_NONE;
+	spin_unlock_bh(&lgr->llc_ctl_lock);
+	if (lgr->delayed_q &&
+	    (llc_grp != LLC_GRP_TEST_LINK)) {
+		queue_work(lgr->llc_wq, &lgr->llc_event_work);
+	} else {
+		wake_up_interruptible(&lgr->llc_waiter);
+	}
+}
+
+struct llc_qentry *llc_wait(struct smc_link_group *lgr, enum smc_role initiator,
+			    int time_out, u8 exp_msg)
+{
+	struct llc_ctl *ctl = &lgr->llc_ctl[initiator];
+
+	wait_event_interruptible_timeout(lgr->llc_waiter,
+					 (ctl->qentry ||
+					 ((ctl->ctrl_elem == LLC_SEND_POSTED) &&
+					  ctl->wc_status) ||
+					 (lgr->lgr_type == NONE)),
+					 time_out);
+	if (IS_ERR(ctl->qentry) ||	/* waiter has been killed */
+	    !ctl->qentry) {
+		ctl->qentry = NULL;
+		goto out;
+	}
+	if (((initiator == SMC_SERV) ||
+	     (exp_msg != LLC_CONFIRM_LINK)) &&
+	    (ctl->ctrl_elem != LLC_SEND_POSTED)) {
+		/* cancel post req when send completes after llc msg arrival */
+		lgr->lnk[ctl->lnk_idx].pending[ctl->ctrl_elem].post_ctl =
+			LLC_NO_NOTIFY; /* mark as cancelled */
+	}
+	if ((exp_msg) && (ctl->qentry->msg.hd.type != exp_msg)) {
+		kfree(ctl->qentry);
+		ctl->qentry = NULL;
+	}
+out:
+	return ctl->qentry;
+}
+
+static int llc_add_pending_send(struct smc_link *link,
+				enum llc_ctl_ind ctl_idx, u32 *elem)
+{
+	u64 wr_id;
+	int rc = 0;
+
+	wr_id = (u64)atomic64_inc_return((atomic64_t *)&link->wr_id_send);
+	rc = smc_get_ctrl_buf(link, elem);
+	if (rc < 0)
+		return rc;
+	memset(&link->pending[*elem], 0, sizeof(struct pending_send));
+	link->pending[*elem].wr_id_send = wr_id;
+	link->pending[*elem].post_ctl = ctl_idx;
+	if (ctl_idx != LLC_NO_NOTIFY)
+		link->lnk_grp->llc_ctl[ctl_idx].ctrl_elem = *elem;
+	link->send_wr[*elem].wr_id = wr_id;
+	return 0;
+}
+
+static inline int llc_send_msg(struct smc_link *link, struct llc_msg *msg,
+			       enum llc_ctl_ind ctl_idx)
+{
+	struct smc_link_group *lgr;
+	u32 index;
+	int rc;
+
+	if ((atomic_read(&link->state) != SMC_LINK_UP) || !link->lnk_grp)
+		return -EPIPE;
+	lgr = link->lnk_grp;
+	if (lgr->lgr_type == NONE)
+		return -EPIPE;
+	/* send llc message */
+	rc = llc_add_pending_send(link, ctl_idx, &index);
+	rc = smc_wr_send(link, NULL, (u64)msg, index);
+	return rc;
+}
+
+int llc_send_confirm_link(struct smc_link *link, u8 mac[], union ib_gid *gid,
+			  enum llc_reqresp reqresp, enum llc_ctl_ind ctl_idx)
+{
+	struct llc_confirm_msg confllc;
+	struct smc_link_group *lgr = link->lnk_grp;
+	u32 index;
+	int rc = 0;
+
+	memset(&confllc, 0, sizeof(confllc));
+	confllc.hd.type = LLC_CONFIRM_LINK;
+	confllc.hd.length = sizeof(struct llc_confirm_msg);
+	if (reqresp == LLC_RESP)
+		confllc.hd.flags = 0x80;
+	else
+		confllc.hd.flags = 0x00;
+	lgr->llc_ctl[LLC_SERV].qentry = NULL;
+	memcpy(confllc.sender_mac, mac, 6);
+	memcpy(confllc.sender_ipv6, gid, 16);
+	confllc.max_links = lgr->max_links;
+	confllc.link_num = link->link_id;
+	confllc.link_uid = htonl(lgr->lgr_id + link->link_id);
+
+	hton_three(link->roce_qp->qp_num, confllc.sender_qp_num);
+	/* send llc message */
+	if (ctl_idx != LLC_NO_NOTIFY)
+		lgr->llc_ctl[ctl_idx].lnk_idx = link - &lgr->lnk[0];
+	rc = llc_add_pending_send(link, ctl_idx, &index);
+	rc = smc_wr_send(link, NULL, (u64)&confllc, index);
+	return rc;
+}
+
+int llc_send_add_link(struct smc_link *link, struct smc_roce_defs *rocdefs,
+		      struct smc_link *linkw, enum llc_reqresp reqresp,
+		      enum llc_ctl_ind ctl_idx)
+{
+	struct llc_add_link_msg addllc;
+	struct smc_link_group *lgr = link->lnk_grp;
+	int rc = 0;
+
+	memset(&addllc, 0, sizeof(addllc));
+	addllc.hd.type = LLC_ADD_LINK;
+	addllc.hd.length = sizeof(struct llc_add_link_msg);
+	if (reqresp == LLC_RESP) {
+		addllc.hd.flags = 0x80;
+		addllc.flags2 = min(linkw->path_mtu, linkw->mtu_peer);
+	} else {
+		addllc.hd.flags = 0x00;
+		if (linkw)
+			addllc.flags2 = linkw->path_mtu;
+		else
+			addllc.flags2 = link->path_mtu;
+		if (lgr->role == SMC_SERV)
+			lgr->llc_ctl[LLC_SERV].qentry = NULL;
+	}
+	memcpy(addllc.sender_mac, &rocdefs->mac, 6);
+	memcpy(addllc.sender_ipv6, &rocdefs->gid, 16);
+	if (linkw) {
+		addllc.link_num = linkw->link_id;
+		hton_three(linkw->roce_qp->qp_num, addllc.sender_qp_num);
+		hton_three(linkw->psn_initial, addllc.initial_psn);
+	}
+	/* send llc message */
+	if (ctl_idx != LLC_NO_NOTIFY)
+		lgr->llc_ctl[ctl_idx].lnk_idx = link - &lgr->lnk[0];
+	rc = llc_send_msg(link, (struct llc_msg *)&addllc, ctl_idx);
+	return rc;
+}
+
+int llc_send_del_link(struct smc_link *link, struct smc_link *link2,
+		      u8 ord_flag, u32 reason, enum llc_ctl_ind ctl_idx)
+{
+	struct llc_del_link_msg delllc;
+
+	memset(&delllc, 0, sizeof(delllc));
+	delllc.hd.type = LLC_DEL_LINK;
+	delllc.hd.length = sizeof(struct llc_del_link_msg);
+	delllc.hd.flags = ord_flag;
+	if (link2) {
+		delllc.link_num = link2->link_id;
+	} else {
+		delllc.link_num = 0;
+		delllc.hd.flags |= LLC_FLAG_DEL_ALL;
+	}
+	delllc.reason = htonl(reason);
+
+	return llc_send_msg(link, (struct llc_msg *)&delllc, ctl_idx);
+}
+
+int llc_do_confirm_rkey(struct smc_link *link, struct rmb_rx_addrs *rmb_rx_elem)
+{
+	struct llc_confirm_rkey_msg confrkeyllc;
+	struct smc_link_group *lgr = link->lnk_grp;
+	int prim_link_id, rt_idx, i, prim_lnk_idx;
+
+	memset(&confrkeyllc, 0, sizeof(confrkeyllc));
+	confrkeyllc.hd.type = LLC_CONFIRM_RKEY;
+	confrkeyllc.hd.length = sizeof(struct llc_confirm_rkey_msg);
+	confrkeyllc.hd.flags = 0x00;
+	lgr->llc_ctl[lgr->role].qentry = NULL;
+
+	prim_lnk_idx = link - &lgr->lnk[0];
+	confrkeyllc.rt[0].rmb_key =
+		htonl(rmb_rx_elem->mr_rx[prim_lnk_idx]->rkey);
+	confrkeyllc.rt[0].rmb_vaddr =
+		cpu_to_be64((u64)rmb_rx_elem->rmb_rx_dma[prim_lnk_idx]);
+
+	prim_link_id = link->link_id;
+	rt_idx = 1;
+	for (i = 0; i <= SMC_MAX_SYM_LINKS; i++) {
+		if ((lgr->lnk[i].link_id == prim_link_id) ||
+		    (atomic_read(&lgr->lnk[i].state) != SMC_LINK_UP))
+			continue;
+		confrkeyllc.rt[rt_idx].link_id = lgr->lnk[i].link_id;
+		confrkeyllc.rt[rt_idx].rmb_key =
+			htonl(rmb_rx_elem->mr_rx[i]->rkey);
+		confrkeyllc.rt[rt_idx].rmb_vaddr =
+			cpu_to_be64((u64)rmb_rx_elem->rmb_rx_dma[i]);
+		rt_idx = rt_idx + 1;
+	}
+	confrkeyllc.rt[0].link_id = rt_idx - 1;
+	if (rt_idx == 1) /* nothing to confirm */
+		WARN_ON(1);
+
+	return llc_send_msg(link, (struct llc_msg *)&confrkeyllc,
+			    (enum llc_ctl_ind)lgr->role);
+}
+
+int llc_do_del_rkey(struct smc_link *link, struct rmb_rx_addrs *rmb_rx_elem)
+{
+	struct llc_delete_rkey_msg delrkeyllc;
+	struct smc_link_group *lgr = link->lnk_grp;
+	int prim_lnk_idx;
+
+	memset(&delrkeyllc, 0, sizeof(delrkeyllc));
+	delrkeyllc.hd.type = LLC_DELETE_RKEY;
+	delrkeyllc.hd.length = sizeof(struct llc_delete_rkey_msg);
+	delrkeyllc.hd.flags = 0x00;
+	lgr->llc_ctl[lgr->role].qentry = NULL;
+
+	prim_lnk_idx = link - &lgr->lnk[0];
+	delrkeyllc.num_rkeys = 1;
+	delrkeyllc.rk[0] =
+		htonl(rmb_rx_elem->mr_rx[prim_lnk_idx]->rkey);
+
+	return llc_send_msg(link, (struct llc_msg *)&delrkeyllc,
+			    (enum llc_ctl_ind)lgr->role);
+}
+
+struct bufs_list_pos {
+	struct list_head	*head;
+	int			ind;
+	struct rmb_rx_addrs	*elem;
+};
+
+static void llc_get_next_rx_rmb_slot(struct smc_link_group *lgr,
+				     struct bufs_list_pos *bufs_pos)
+{
+	int start;
+
+	start = bufs_pos->ind;
+	if (bufs_pos->elem && bufs_pos->elem->list.next !=
+		&bufs_pos->head[start]) {
+		bufs_pos->elem =
+			(struct rmb_rx_addrs *)bufs_pos->elem->list.next;
+		return;
+	}
+	while (start < (SMC_RMBE_SIZE_VALUES - 1)) {
+		start++;
+		if (bufs_pos->head[start].next !=
+			&bufs_pos->head[start]) {
+			bufs_pos->elem = (struct rmb_rx_addrs *)
+						bufs_pos->head[start].next;
+			bufs_pos->ind = start;
+			return;
+		}
+	}
+}
+
+static int llc_add_link_cont(struct smc_link *link, int lnk_idx, u8 link_num,
+			     u8 *num_rkeys_todo)
+{
+	struct smc_link_group *lgr = link->lnk_grp;
+	struct llc_add_link_cont_msg addc_llcs;
+	struct bufs_list_pos pos = {
+		.head = lgr->rmb_rx_bufs,
+		.ind = -1,
+		.elem = NULL,
+	};
+	int prim_lnk_idx, i;
+	u8 n;
+
+	prim_lnk_idx = link - &lgr->lnk[0];
+	addc_llcs.link_num = link_num;
+	addc_llcs.num_rkeys = *num_rkeys_todo;
+	n = *num_rkeys_todo;
+	memset(&addc_llcs.reserved2, 0,
+	       sizeof(struct llc_add_link_cont_msg) -
+		      offsetof(struct llc_add_link_cont_msg, reserved2));
+	for (i = 0; i < min_t(u8, n, 2); i++) {
+next_rmb_slot:
+		llc_get_next_rx_rmb_slot(lgr, &pos);
+		if (!pos.elem) {
+			addc_llcs.num_rkeys = addc_llcs.num_rkeys -
+							*num_rkeys_todo;
+			*num_rkeys_todo = 0;
+			break;
+		}
+		if (!pos.elem->mr_rx[prim_lnk_idx])
+			goto next_rmb_slot;
+		addc_llcs.rt[i].rmb_key =
+			htonl(pos.elem->mr_rx[prim_lnk_idx]->rkey);
+		addc_llcs.rt[i].rmb_key_new =
+			htonl(pos.elem->mr_rx[lnk_idx]->rkey);
+		addc_llcs.rt[i].rmb_vaddr_new =
+			cpu_to_be64((u64)pos.elem->rmb_rx_dma[lnk_idx]);
+		(*num_rkeys_todo)--;
+	}
+	addc_llcs.hd.type = LLC_ADD_LINK_CONT;
+	addc_llcs.hd.length = sizeof(struct llc_msg);
+	addc_llcs.hd.version = SMC_CLC_V1;
+	if (lgr->role == SMC_SERV)
+		addc_llcs.hd.flags = 0x00;
+	else
+		addc_llcs.hd.flags = 0x80;
+	llc_send_msg(link, (struct llc_msg *)&addc_llcs, LLC_SERV);
+	return 0;
+}
+
+int llc_send_test_link(struct smc_link *link, u8 udata[])
+{
+	struct llc_test_link_msg testllc;
+	struct smc_link_group *lgr = link->lnk_grp;
+
+	testllc.hd.type = LLC_TEST_LINK;
+	memset(&testllc.user_data, 0, sizeof(testllc.user_data));
+	strncpy(testllc.user_data, udata, sizeof(testllc.user_data));
+	testllc.hd.length = sizeof(struct llc_test_link_msg);
+	testllc.hd.flags = 0x00;
+	lgr->llc_ctl[LLC_TESTLINK].qentry = NULL;
+	testllc.hd.version = SMC_CLC_V1;
+	return llc_send_msg(link, (struct llc_msg *)&testllc, LLC_TESTLINK);
+}
+
+int llc_get_fail_cause(struct smc_link_group *lgr, enum llc_ctl_ind initiator,
+		       struct smc_sock *smc)
+{
+	struct smc_decline_clc_msg dclc;
+	int reason_code, rc;
+
+	if ((initiator < 3) &&
+	    ((lgr->llc_ctl[initiator].ctrl_elem != LLC_SEND_POSTED) ||
+	     !lgr->llc_ctl[initiator].wc_status)) {
+		/* llc send failure */
+		return -ECOMM;
+	}
+	if (!smc)
+		return -ETIMEDOUT;
+	/* clc decl received or llc timeout */
+	rc = clc_wait_msg(smc, SMC_CLC_NONBLOCK, (char *)&dclc,
+			  sizeof(struct smc_decline_clc_msg),
+			  SMC_CLC_DECLINE, &reason_code);
+	if (rc)
+		smc->sk.sk_err = ETIMEDOUT;
+	/* clc decline received */
+	return rc;
+}
+
+static u8 llc_count_rx_rmb_slot(struct smc_link_group *lgr, int lnk_idx)
+{
+	struct rmb_rx_addrs *entry_rx;
+	int i;
+	u8 count;
+
+	count = 0;
+	for (i = 0; i < 16; i++) {
+		list_for_each_entry(entry_rx, &lgr->rmb_rx_bufs[i], list) {
+			if (entry_rx->mr_rx[lnk_idx])
+				count++;
+		}
+	}
+	return count;
+}
+
+int smc_find_rtoken_by_link(struct smc_link_group *lgr, int lnk_idx, u32 rkey)
+{
+	int i;
+
+	for (i = 0; i < SMC_MAX_RMB; i++) {
+		if ((lgr->rtok[i].rkey[lnk_idx] == rkey) &&
+		    (lgr->rtok[i].link_id[lnk_idx] ==
+						lgr->lnk[lnk_idx].link_id) &&
+		    (atomic_read(&lgr->rtok[i].active) == 1)) {
+			return i;
+		}
+	}
+	return -ENOENT;
+}
+
+static void llc_set_rtoken(struct smc_link_group *lgr, int link_n1, int link_n2,
+			   struct rmb_rtoken2 *rtoken)
+{
+	u32 rkey;
+	int rtok_idx;
+
+	rkey = ntohl(rtoken->rmb_key);
+	rtok_idx = smc_find_rtoken_by_link(lgr, link_n1, rkey);
+	if (rtok_idx == -ENOENT)
+		return;
+	lgr->rtok[rtok_idx].rkey[link_n2] = ntohl(rtoken->rmb_key_new);
+	lgr->rtok[rtok_idx].vaddr[link_n2] = be64_to_cpu(rtoken->rmb_vaddr_new);
+	lgr->rtok[rtok_idx].link_id[link_n2] = lgr->lnk[link_n2].link_id;
+}
+
+int smc_get_rtoken(struct smc_link_group *lgr)
+{
+	int i;
+
+	for (i = 0; i < SMC_MAX_RMB; i++) {
+		if (atomic_cmpxchg(&lgr->rtok[i].active, 0, 1) == 0)
+			return i;
+	}
+	return -ENOSPC;
+}
+
+static void llc_set_rtoken_by_link(struct smc_link_group *lgr, int link_n1,
+				   int rtoken_idx, struct rmb_rtoken3 *rtoken)
+{
+	int lnk_idx, found = 0;
+
+	for (lnk_idx = 0; lnk_idx <= SMC_MAX_SYM_LINKS; lnk_idx++) {
+		if (lgr->lnk[lnk_idx].link_id == link_n1) {
+			found = 1;
+			break;
+		}
+	}
+	if (!found) {
+		WARN_ON(1);
+		return;
+	}
+	lgr->rtok[rtoken_idx].rkey[lnk_idx] = ntohl(rtoken->rmb_key);
+	lgr->rtok[rtoken_idx].vaddr[lnk_idx] = be64_to_cpu(rtoken->rmb_vaddr);
+	lgr->rtok[rtoken_idx].link_id[lnk_idx] = link_n1;
+}
+
+static int smc_clear_rtokens_by_link(struct smc_link_group *lgr, int link_n1,
+				     __be32 rmb_rkey)
+{
+	int i, lnk_idx, rtoken_idx, found = 0;
+	u32 rkey;
+
+	for (i = 0; i <= SMC_MAX_SYM_LINKS; i++) {
+		if (lgr->lnk[i].link_id == link_n1) {
+			found = 1;
+			break;
+		}
+	}
+	if (!found)
+		return -ENODEV;
+	lnk_idx = i;
+	rkey = ntohl(rmb_rkey);
+	rtoken_idx = smc_find_rtoken_by_link(lgr, lnk_idx, rkey);
+	found = (rtoken_idx < 0 ? 0 : 1);
+	if (!found)
+		return -ENODEV;
+
+	for (i = 0; i <= SMC_MAX_SYM_LINKS; i++) {
+		lgr->rtok[rtoken_idx].rkey[i] = 0;
+		lgr->rtok[rtoken_idx].vaddr[i] = 0;
+		lgr->rtok[rtoken_idx].link_id[i] = 0;
+	}
+	atomic_set(&lgr->rtok[rtoken_idx].active, 0);
+	return 0;
+}
+
+static int llc_alloc_alt_link(struct smc_link_group *lgr,
+			      enum lgr_type lgr_new_t)
+{
+	int i, lnk_idx, total_links = 0;
+
+	if ((lgr->lgr_type != SINGLE) &&
+	    (lgr_new_t == ASYMMETRIC))
+		return -EMLINK;
+	if (lgr_new_t == ASYMMETRIC) {
+		lnk_idx = SMC_MAX_SYM_LINKS;
+		for (i = SMC_MAX_SYM_LINKS; i > 0; i--) {
+			if (atomic_read(&lgr->lnk[i].state) != SMC_LINK_UP) {
+				lnk_idx = i;
+				break;
+			}
+		}
+	} else {
+		lnk_idx = SMC_MAX_SYM_LINKS + 1;
+		total_links = 0;
+		for (i = 0; i <= SMC_MAX_SYM_LINKS; i++) {
+			if (atomic_read(&lgr->lnk[i].state) != SMC_LINK_UP) {
+				if (lnk_idx > SMC_MAX_SYM_LINKS)
+					lnk_idx = i;
+			} else {
+				total_links++;
+			}
+		}
+		if ((lgr->lgr_type == SYMMETRIC) &&
+		    (total_links >= SMC_MAX_SYM_LINKS))
+			return -EMLINK;
+		if (lnk_idx > SMC_MAX_SYM_LINKS)
+			return -EMLINK;
+	}
+	return lnk_idx;
+}
+
+static void llc_deny_req(struct llc_qentry *qentry, u8 flag, u8 retc,
+			 enum llc_ctl_ind ctl_idx)
+{
+	qentry->msg.hd.flags |= LLC_FLAG_RESP;
+	qentry->msg.hd.flags |= flag;
+	qentry->msg.hd.version |= retc;
+	llc_send_msg(qentry->link, &qentry->msg, ctl_idx);
+	kfree(qentry);
+}
+
+static void llc_save_add_link_info(struct smc_link *link,
+				   struct llc_add_link_msg *add_llc)
+{
+	memcpy(link->gid_peer, ((union ib_gid *)add_llc->sender_ipv6)->raw, 16);
+	memcpy(link->mac_peer, add_llc->sender_mac , 6);
+	ntoh_three(&link->qp_num_peer, add_llc->sender_qp_num);
+	ntoh_three(&link->psn_peer, add_llc->initial_psn);
+	link->mtu_peer = add_llc->flags2 & 0x0f;
+}
+
+static int llc_cli_rkey_exchange(struct smc_link *link,
+				 struct smc_link *link_new,
+				 struct smc_sock *smc, int lnk_idx)
+{
+	struct smc_link_group *lgr = link->lnk_grp;
+	struct llc_qentry *qentry = NULL;
+	struct llc_add_link_cont_msg *addc_llc;
+	int prim_lnk_idx, i;
+	u8 n, num_rkeys_send, num_rkeys_recv;
+
+	prim_lnk_idx = link - &lgr->lnk[0];
+	num_rkeys_send = llc_count_rx_rmb_slot(lgr, prim_lnk_idx);
+	do {
+		qentry = llc_wait(lgr, LLC_SERV, LLC_WAIT_FIRST_TIMEO,
+				  LLC_ADD_LINK_CONT);
+		if (!qentry) {
+			atomic_set(&link_new->state, SMC_LINK_DOWN);
+			smc_free_link(lgr, lnk_idx);
+			return llc_get_fail_cause(lgr, LLC_SERV, smc);
+		}
+		addc_llc = (struct llc_add_link_cont_msg *)&qentry->msg;
+		num_rkeys_recv = addc_llc->num_rkeys;
+		n = addc_llc->num_rkeys;
+		for (i = 0; i < min_t(u8, n, 2); i++) {
+			llc_set_rtoken(lgr, prim_lnk_idx, lnk_idx,
+				       &addc_llc->rt[i]);
+			num_rkeys_recv--;
+		}
+		lgr->llc_ctl[LLC_SERV].qentry = NULL;
+		kfree(qentry);
+		llc_add_link_cont(link, lnk_idx, link_new->link_id,
+				  &num_rkeys_send);
+	} while (num_rkeys_send || num_rkeys_recv);
+	return 0;
+}
+
+static int llc_cli_conf_link(struct smc_link *link,
+			     struct smc_roce_defs *rocedef,
+			     struct smc_link *link_new, int lnk_idx,
+			     enum lgr_type lgr_new_t)
+{
+	struct smc_link_group *lgr = link->lnk_grp;
+	struct llc_qentry *qentry = NULL;
+	struct llc_del_link_msg *del_llc;
+	int rc = 0;
+
+	/* receive CONFIRM LINK request over RoCE fabric */
+	qentry = llc_wait(lgr, LLC_SERV, LLC_WAIT_FIRST_TIMEO, 0);
+	if (!qentry) {
+		atomic_set(&link_new->state, SMC_LINK_DOWN);
+		smc_free_link(lgr, lnk_idx);
+		return -ENOLINK;
+	}
+	if (qentry->msg.hd.type == LLC_CONFIRM_LINK) {
+		rc = smc_modify_qp_rts(link_new);
+		if (rc)
+			return -ENOLINK;
+		smc_check_qp_attr(link_new);
+		/* send CONFIRM LINK response over RoCE fabric */
+		lgr->llc_ctl[LLC_SERV].qentry = NULL;
+		rc = llc_send_confirm_link(link_new,
+					   (u8 *)&rocedef->mac,
+					   &rocedef->gid, LLC_RESP,
+					   LLC_NO_NOTIFY);
+		kfree(qentry);
+		if (rc) {
+			atomic_set(&link_new->state, SMC_LINK_DOWN);
+			rc = llc_send_del_link(link, link_new, 0,
+					       LLC_DEL_LOST_PATH,
+					       LLC_NO_NOTIFY);
+			if (rc && smc_lnk_downing(&link->state))
+				smc_link_down(lgr, link - &lgr->lnk[0]);
+			return -ENOLINK;
+		}
+		atomic_set(&link_new->state, SMC_LINK_UP);
+		lgr->lgr_type = lgr_new_t;
+	} else {
+		del_llc = (struct llc_del_link_msg *)&qentry->msg;
+		lgr->llc_ctl[LLC_SERV].qentry = NULL;
+		qentry->msg.hd.flags |= LLC_FLAG_RESP;
+		llc_send_msg(link, &qentry->msg, LLC_SERV);
+		atomic_set(&link_new->state, SMC_LINK_DOWN);
+		smc_free_link(lgr, lnk_idx);
+		kfree(qentry);
+		return -ENOLINK;
+	}
+	return 0;
+}
+
+int llc_cli_add_link(struct smc_link *link, struct llc_qentry *qentry,
+		     struct smc_sock *smc)
+{
+	struct smc_link_group *lgr = link->lnk_grp;
+	struct smc_link *link_new;
+	struct llc_add_link_msg *add_llc;
+	struct smc_roce_defs rocedef;
+	enum lgr_type lgr_new_t = SYMMETRIC;
+	int lnk_idx, rc;
+
+	rocedef.ibdev = NULL;
+	smc_find_alt_roce_resources(&rocedef, lgr, link);
+	add_llc = (struct llc_add_link_msg *)&qentry->msg;
+	if (!memcmp(add_llc->sender_ipv6, link->gid_peer, 16) &&
+	    !memcmp(add_llc->sender_mac, link->mac_peer, 6)) {
+		if (!rocedef.ibdev) {
+			llc_deny_req(qentry, LLC_FLAG_ADD_LNK_REJ,
+				     LLC_FLAG_NO_ALT_PATH, LLC_NO_NOTIFY);
+			return 0;
+		}
+		lgr_new_t = ASYMMETRIC;
+	}
+	if (!rocedef.ibdev) {
+		lgr_new_t = ASYMMETRIC;
+		memcpy(&rocedef, &link->roce_defs,
+		       sizeof(struct smc_roce_defs));
+	}
+	lnk_idx = llc_alloc_alt_link(lgr, lgr_new_t);
+	if (lnk_idx < 0) {
+		llc_deny_req(qentry, LLC_FLAG_ADD_LNK_REJ,
+			     LLC_FLAG_NO_ALT_PATH, LLC_NO_NOTIFY);
+		return 0;
+	}
+	rc = smc_create_link(lgr, lnk_idx, &rocedef);
+	if (rc) {
+		llc_deny_req(qentry, LLC_FLAG_ADD_LNK_REJ,
+			     LLC_FLAG_NO_ALT_PATH, LLC_NO_NOTIFY);
+		return 0;
+	}
+	link_new = &lgr->lnk[lnk_idx];
+	llc_save_add_link_info(link_new, add_llc);
+	rc = smc_ready_link(link_new);
+	if (rc) {
+		atomic_set(&link_new->state, SMC_LINK_DOWN);
+		llc_deny_req(qentry, LLC_FLAG_ADD_LNK_REJ,
+			     LLC_FLAG_NO_ALT_PATH, LLC_NO_NOTIFY);
+		smc_free_link(lgr, lnk_idx);
+		return 0;
+	}
+	link_new->link_id = add_llc->link_num;
+	kfree(qentry);
+	smc_map_rmbs_to_link(lgr, lnk_idx);
+	lgr->llc_ctl[LLC_SERV].qentry = NULL;
+	llc_send_add_link(link, &rocedef, link_new, LLC_RESP, LLC_SERV);
+	rc = llc_cli_rkey_exchange(link, link_new, smc, lnk_idx);
+	if (!rc)
+		rc = llc_cli_conf_link(link, &rocedef, link_new, lnk_idx,
+				       lgr_new_t);
+	return rc;
+}
+
+static int llc_srv_rkey_exchange(struct smc_link *link,
+				 struct smc_link *link_new,
+				 struct smc_sock *smc,
+				 int lnk_idx)
+{
+	struct smc_link_group *lgr = link->lnk_grp;
+	struct llc_qentry *qentry = NULL;
+	struct llc_add_link_cont_msg *addc_llc;
+	int prim_lnk_idx;
+	int i;
+	u8 n, num_rkeys_send, num_rkeys_recv;
+
+	prim_lnk_idx = link - &lgr->lnk[0];
+	num_rkeys_send = llc_count_rx_rmb_slot(lgr, prim_lnk_idx);
+	do {
+		lgr->llc_ctl[LLC_SERV].qentry = NULL;
+		llc_add_link_cont(link, lnk_idx, link_new->link_id,
+				  &num_rkeys_send);
+		qentry = llc_wait(lgr, LLC_SERV, LLC_WAIT_FIRST_TIMEO,
+				  LLC_ADD_LINK_CONT);
+		if (!qentry) {
+			atomic_set(&link_new->state, SMC_LINK_DOWN);
+			smc_free_link(lgr, lnk_idx);
+			return llc_get_fail_cause(lgr, LLC_SERV, smc);
+		}
+		addc_llc = (struct llc_add_link_cont_msg *)&qentry->msg;
+		num_rkeys_recv = addc_llc->num_rkeys;
+		n = addc_llc->num_rkeys;
+		for (i = 0; i < min_t(u8, n, 2); i++) {
+			llc_set_rtoken(lgr, prim_lnk_idx, lnk_idx,
+				       &addc_llc->rt[i]);
+			num_rkeys_recv--;
+		}
+		kfree(qentry);
+	} while (num_rkeys_send || num_rkeys_recv);
+	return 0;
+}
+
+static int llc_srv_conf_link(struct smc_link *link,
+			     struct smc_roce_defs *rocedef,
+			     struct smc_link *link_new, int lnk_idx,
+			     enum lgr_type lgr_new_t)
+{
+	struct smc_link_group *lgr = link->lnk_grp;
+	struct llc_qentry *qentry = NULL;
+	int rc;
+
+	/* send CONFIRM LINK request over the RoCE fabric */
+	lgr->llc_ctl[LLC_SERV].qentry = NULL;
+	rc = llc_send_confirm_link(link_new, (u8 *)&rocedef->mac,
+				   &rocedef->gid, LLC_REQ, LLC_SERV);
+	/* receive CONFIRM LINK response over the RoCE fabric */
+	if (!rc)
+		qentry = llc_wait(lgr, LLC_SERV, LLC_WAIT_FIRST_TIMEO,
+				  LLC_CONFIRM_LINK);
+	if (rc || !qentry) {
+		/* send DELETE LINK */
+		lgr->llc_ctl[LLC_SERV].qentry = NULL;
+		rc = llc_send_del_link(link, link_new, 0, LLC_DEL_LOST_PATH,
+				       LLC_NO_NOTIFY);
+		atomic_set(&link_new->state, SMC_LINK_DOWN);
+		if (rc)
+			smc_terminate_conn(lgr);
+		else
+			smc_free_link(lgr, lnk_idx);
+		return -ENOLINK;
+	}
+	atomic_set(&link_new->state, SMC_LINK_UP);
+	lgr->lgr_type = lgr_new_t;
+	if (lgr->lgr_type == ASYMMETRIC)
+		lgr->asymm_link = lnk_idx;
+	kfree(qentry);
+	return 0;
+}
+
+int llc_srv_add_link(struct smc_link *link, struct smc_roce_defs *rocedef,
+		     struct smc_sock *smc)
+{
+	struct smc_link_group *lgr = link->lnk_grp;
+	struct smc_link *link_new;
+	struct llc_qentry *qentry = NULL;
+	struct llc_add_link_msg *add_llc;
+	enum lgr_type lgr_new_t = SYMMETRIC;
+	int lnk_idx, rc = 0;
+
+	if (!rocedef->ibdev) {
+		lgr_new_t = ASYMMETRIC;
+		memcpy(rocedef, &link->roce_defs, sizeof(struct smc_roce_defs));
+	}
+	lnk_idx = llc_alloc_alt_link(lgr, lgr_new_t);
+	if (lnk_idx < 0)
+		return 0;
+	rc = smc_create_link(lgr, lnk_idx, rocedef);
+	if (rc)
+		return rc;
+	link_new = &lgr->lnk[lnk_idx];
+	rc = llc_send_add_link(link, rocedef, link_new, LLC_REQ, LLC_SERV);
+	if (!rc) {
+		/* receive ADD LINK response over the RoCE fabric */
+		qentry = llc_wait(lgr, LLC_SERV, LLC_WAIT_FIRST_TIMEO,
+				  LLC_ADD_LINK);
+	}
+	if (rc || !qentry) {
+		atomic_set(&link_new->state, SMC_LINK_DOWN);
+		smc_free_link(lgr, lnk_idx);
+		return llc_get_fail_cause(lgr, LLC_SERV, smc);
+	}
+	add_llc = (struct llc_add_link_msg *)&qentry->msg;
+	if (add_llc->hd.flags & LLC_FLAG_ADD_LNK_REJ) {
+		atomic_set(&link_new->state, SMC_LINK_DOWN);
+		smc_free_link(lgr, lnk_idx);
+		return -ENOLINK;
+	}
+	if ((lgr->lgr_type == SINGLE) &&
+	    (!memcmp(add_llc->sender_ipv6, link->gid_peer, 16) &&
+	    !memcmp(add_llc->sender_mac, link->mac_peer, 6)))
+		lgr_new_t = ASYMMETRIC;
+	llc_save_add_link_info(link_new, add_llc);
+	kfree(qentry);
+	smc_ready_link(link_new);
+	smc_map_rmbs_to_link(lgr, lnk_idx);
+	llc_srv_rkey_exchange(link, link_new, smc, lnk_idx);
+	rc = llc_srv_conf_link(link, rocedef, link_new, lnk_idx, lgr_new_t);
+	return rc;
+}
+
+static bool start_llc_agent(enum smc_role initiator,
+			    struct llc_qentry *qentry)
+{
+	struct smc_link_group *lgr = qentry->link->lnk_grp;
+
+	spin_lock_bh(&lgr->llc_ctl_lock);
+	if (lgr->llc_ctl[initiator].active) {
+		if ((initiator == SMC_SERV) &&
+		    ((qentry->msg.hd.type == LLC_ADD_LINK) ||
+		     (qentry->msg.hd.type == LLC_DEL_LINK)) &&
+		    !lgr->delayed_q)
+			lgr->delayed_q = qentry;
+		spin_unlock_bh(&lgr->llc_ctl_lock);
+		return 0;
+	}
+	lgr->llc_ctl[initiator].active = llc_msg_to_grp(qentry->msg.hd.type);
+	if (qentry == lgr->delayed_q)
+		lgr->delayed_q = NULL;
+	spin_unlock_bh(&lgr->llc_ctl_lock);
+	lgr->llc_ctl[initiator].qentry = qentry;
+	return 1;
+}
+
+void llc_kill_waiters(struct smc_link_group *lgr)
+{
+	int i;
+
+	for (i = 0; i < LLC_NO_NOTIFY; i++) {
+		if (lgr->llc_ctl[i].active && !lgr->llc_ctl[i].qentry)
+			lgr->llc_ctl[i].qentry = ERR_PTR(-EPIPE);
+	}
+	wake_up_interruptible(&lgr->llc_waiter);
+}
+
+static void llc_process_cli_add_link(struct smc_link_group *lgr,
+				     struct smc_link *link)
+{
+	struct llc_qentry *qentry;
+
+	qentry = lgr->llc_ctl[LLC_SERV].qentry;
+	lgr->llc_ctl[LLC_SERV].qentry = NULL;
+	mutex_lock(&lgr->conf_mutex);
+	llc_cli_add_link(link, qentry, NULL);
+	mutex_unlock(&lgr->conf_mutex);
+}
+
+static void llc_del_asym_link(struct smc_link_group *lgr, struct smc_link *link,
+			      u8 old_asym_lnk)
+{
+	struct llc_qentry *qentry;
+	struct llc_del_link_msg *del_llc_resp;
+	int rc;
+
+	lgr->asymm_link = SMC_MAX_SYM_LINKS + 2;
+	lgr->llc_ctl[LLC_SERV].active = LLC_GRP_DEL_LINK;
+	lgr->llc_ctl[LLC_SERV].qentry = NULL;
+	rc = smc_switch_conns(lgr, old_asym_lnk, 0);
+	smc_wait_no_pending_sends_on_link(&lgr->lnk[old_asym_lnk]);
+	if (rc == -ENOENT) {
+		smc_free_link(lgr, old_asym_lnk);
+		goto out;
+	}
+	rc = llc_send_del_link(link, &lgr->lnk[old_asym_lnk],
+			       LLC_FLAG_DEL_ORDERLY, LLC_DEL_NO_ASYM_NEEDED,
+			       LLC_SERV);
+	if (rc) {
+		if (smc_lnk_downing(&link->state))
+			smc_link_down(lgr, link - &lgr->lnk[0]);
+		goto out;
+	}
+	qentry = llc_wait(lgr, LLC_SERV, LLC_WAIT_TIMEO, LLC_DEL_LINK);
+	if (!qentry) {
+		if (smc_lnk_downing(&link->state))
+			smc_link_down(lgr, link - &lgr->lnk[0]);
+	} else {
+		del_llc_resp = (struct llc_del_link_msg *)&qentry->msg;
+		if ((ntohl(del_llc_resp->reason) != LLC_DEL_NO_ASYM_NEEDED) &&
+		    smc_lnk_downing(&link->state))
+			smc_link_down(lgr, link - &lgr->lnk[0]);
+	}
+	kfree(qentry);
+	atomic_set(&lgr->lnk[old_asym_lnk].state, SMC_LINK_DOWN);
+	smc_free_link(lgr, old_asym_lnk);
+out:
+	return;
+}
+
+static void llc_process_srv_add_link(struct smc_link_group *lgr,
+				     struct smc_link *link)
+{
+	struct llc_qentry *qentry;
+	struct llc_add_link_fake_msg *add_llc;
+	struct smc_roce_defs rocdefs;
+	int rc;
+	u8 old_asym_lnk;
+	enum lgr_type old_lgr_type;
+
+	rocdefs.ibdev = NULL;
+	rocdefs.port = 0;
+	qentry = lgr->llc_ctl[LLC_SERV].qentry;
+	add_llc = (struct llc_add_link_fake_msg *)&qentry->msg;
+	lgr->llc_ctl[LLC_SERV].qentry = NULL;
+	if (qentry->msg.hd.flags & LLC_FLAG_PORT_ADD) {
+		rocdefs.ibdev = add_llc->ibdev;
+		rocdefs.port = add_llc->port_num;
+		rocdefs.vlan = lgr->vlan;
+		rc = smc_gid_by_dev(&rocdefs);
+		if (rc) {
+			kfree(qentry);
+			wake_up_interruptible(&lgr->llc_waiter);
+			return;
+		}
+	} else {
+		smc_find_alt_roce_resources(&rocdefs, lgr, link);
+	}
+	kfree(qentry);
+	qentry = NULL;
+	old_lgr_type = lgr->lgr_type;
+	old_asym_lnk = lgr->asymm_link;
+	mutex_lock(&lgr->conf_mutex);
+	rc = llc_srv_add_link(link, &rocdefs, NULL);
+	if (!rc && (lgr->lgr_type == SYMMETRIC) &&
+	    (old_lgr_type == ASYMMETRIC) &&
+	    smc_lnk_downing(&lgr->lnk[old_asym_lnk].state)) {
+		/* delete the superfluos asymmetric link now */
+		llc_del_asym_link(lgr, link, old_asym_lnk);
+	}
+	mutex_unlock(&lgr->conf_mutex);
+}
+
+void llc_process_add_link(struct work_struct *work)
+{
+	struct smc_link *link = container_of(work, struct smc_link,
+					     llc_add_link_work);
+	struct smc_link_group *lgr = link->lnk_grp;
+
+	if (list_empty(&lgr->list) || (lgr->lgr_type == NONE)) {
+		/* link group to be deleted */
+		kfree(lgr->llc_ctl[LLC_SERV].qentry);
+		wake_up_interruptible(&lgr->llc_waiter);
+		goto out;
+	}
+	if (lgr->role == SMC_CLNT)
+		llc_process_cli_add_link(lgr, link);
+	else
+		llc_process_srv_add_link(lgr, link);
+	llc_stop(lgr, LLC_GRP_ADD_LINK);
+out:
+	return;
+}
+
+static void llc_process_cli_del_all(struct smc_link_group *lgr,
+				    struct smc_link *link,
+				    struct llc_qentry *qentry)
+{
+	struct llc_del_link_msg *del_llc;
+	int empty;
+
+	del_llc = (struct llc_del_link_msg *)&qentry->msg;
+	del_llc->reason = 0;
+	llc_send_msg(link, &qentry->msg, LLC_SERV);
+	lgr->llc_ctl[LLC_SERV].active = LLC_GRP_NONE;
+	wake_up_interruptible(&lgr->llc_waiter);
+	/* delete link group at all */
+	spin_lock_bh(&smc_lgr_list.lock);
+	if (!list_empty(&lgr->list)) {
+		list_del_init(&lgr->list);
+		spin_unlock_bh(&smc_lgr_list.lock);
+		read_lock_bh(&lgr->conns_lock);
+		empty = RB_EMPTY_ROOT(&lgr->conns_all);
+		read_unlock_bh(&lgr->conns_lock);
+		if (!empty)
+			smc_terminate_conn(lgr);
+		llc_kill_waiters(lgr);
+		cancel_work_sync(&lgr->llc_event_work);
+		smc_wait_no_pending_sends_on_link(link);
+		msleep(1000);
+		smc_free_lgr(lgr);
+	} else {
+		spin_unlock_bh(&smc_lgr_list.lock);
+	}
+}
+
+static void llc_process_cli_del_link(struct smc_link_group *lgr,
+				     struct smc_link *link)
+{
+	struct llc_qentry *qentry;
+	struct llc_del_link_msg *del_llc;
+	struct smc_roce_defs rocdefs;
+	int i, link_found;
+
+	qentry = lgr->llc_ctl[LLC_SERV].qentry;
+	del_llc = (struct llc_del_link_msg *)&qentry->msg;
+	lgr->llc_ctl[LLC_SERV].qentry = NULL;
+	qentry->msg.hd.flags |= LLC_FLAG_RESP;
+	if (qentry->msg.hd.flags & LLC_FLAG_DEL_ALL) {
+		llc_process_cli_del_all(lgr, link, qentry);
+		goto out;
+	}
+	mutex_lock(&lgr->conf_mutex);
+	/* delete single link */
+	link_found = 0;
+	for (i = 0; i <= SMC_MAX_SYM_LINKS; i++) {
+		if (lgr->lnk[i].link_id != del_llc->link_num)
+			continue;
+		link_found = 1;
+		if (ntohl(del_llc->reason) != LLC_DEL_NO_ASYM_NEEDED)
+			lgr->lgr_type = SINGLE;
+		if (smc_lnk_downing(&lgr->lnk[i].state)) {
+			smc_switch_conns(lgr, i, 0);
+			smc_wait_no_pending_sends_on_link(&lgr->lnk[i]);
+			del_llc->reason = 0;
+		}
+		smc_free_link(lgr, i);
+		llc_send_msg(link, &qentry->msg, LLC_SERV);
+		lgr->llc_ctl[LLC_SERV].active = LLC_GRP_NONE;
+		wake_up_interruptible(&lgr->llc_waiter);
+
+		if (lgr->lgr_type == SINGLE) {
+			/* invite to add asymm link */
+			rocdefs.ibdev = NULL;
+			smc_find_alt_roce_resources(&rocdefs, lgr, link);
+			if (!rocdefs.ibdev)
+				llc_send_add_link(link, &rocdefs, NULL,
+						  LLC_REQ, LLC_NO_NOTIFY);
+		}
+		break;
+	}
+	if (!link_found) {
+		del_llc->reason = htonl(SMC_LLC_DEL_NOLNK);
+		llc_send_msg(link, &qentry->msg, LLC_SERV);
+		lgr->llc_ctl[LLC_SERV].active = LLC_GRP_NONE;
+		wake_up_interruptible(&lgr->llc_waiter);
+	}
+	mutex_unlock(&lgr->conf_mutex);
+out:
+	kfree(qentry);
+}
+
+static void llc_process_srv_del_link(struct smc_link_group *lgr,
+				     struct smc_link *link)
+{
+	struct llc_qentry *qentry;
+	struct llc_del_link_msg *del_llc;
+	struct llc_del_link_msg *del_llc_resp;
+	struct smc_roce_defs rocdefs;
+	int i, lnk_idx = -1, found = 0;
+
+	qentry = lgr->llc_ctl[LLC_SERV].qentry;
+	del_llc = (struct llc_del_link_msg *)&qentry->msg;
+	lgr->llc_ctl[LLC_SERV].qentry = NULL;
+	if (qentry->msg.hd.flags & LLC_FLAG_DEL_ALL) {
+		/* delete entire lgr */
+		goto out;
+	}
+	/* delete single link */
+	for (i = 0; i <= SMC_MAX_SYM_LINKS; i++) {
+		if (lgr->lnk[i].link_id == del_llc->link_num) {
+			found = 1;
+			lnk_idx = i;
+		}
+	}
+	lgr->lgr_type = SINGLE;
+	lgr->asymm_link = SMC_MAX_SYM_LINKS + 2;
+	if (found && smc_lnk_downing(&lgr->lnk[lnk_idx].state)) {
+		smc_switch_conns(lgr, lnk_idx, 0);
+		smc_wait_no_pending_sends_on_link(&lgr->lnk[lnk_idx]);
+	}
+	if ((lgr->lgr_type != NONE) &&
+	    (found || (qentry->msg.hd.type == 0x80 + LLC_DEL_LINK))) {
+		lgr->llc_ctl[LLC_SERV].qentry = NULL;
+		qentry->msg.hd.type = LLC_DEL_LINK;
+		llc_send_msg(link, &qentry->msg, LLC_SERV);
+		qentry = llc_wait(lgr, LLC_SERV, LLC_WAIT_TIMEO,
+				  LLC_DEL_LINK);
+		if (qentry)
+			del_llc_resp = (struct llc_del_link_msg *)&qentry->msg;
+	}
+	if (found) {
+		mutex_lock(&lgr->conf_mutex);
+		smc_free_link(lgr, lnk_idx);
+		if (qentry && (lgr->lgr_type == SINGLE) &&
+		    !list_empty(&lgr->list)) {
+			/* setup asymm alt link */
+			rocdefs.ibdev = NULL;
+			smc_find_alt_roce_resources(&rocdefs, lgr, link);
+			if (!rocdefs.ibdev) {
+				lgr->llc_ctl[LLC_SERV].active =
+							LLC_GRP_ADD_LINK;
+				llc_srv_add_link(link, &rocdefs, NULL);
+			}
+		}
+		mutex_unlock(&lgr->conf_mutex);
+	}
+out:
+	kfree(qentry);
+	llc_stop(lgr, LLC_GRP_DEL_LINK);
+}
+
+void llc_process_del_link(struct work_struct *work)
+{
+	struct smc_link *link = container_of(work, struct smc_link,
+					     llc_del_link_work);
+	struct smc_link_group *lgr = link->lnk_grp;
+
+	if (lgr->role == SMC_CLNT)
+		llc_process_cli_del_link(lgr, link);
+	else
+		llc_process_srv_del_link(lgr, link);
+}
+
+void llc_process_confirm_rkey(struct work_struct *work)
+{
+	struct smc_link *link = container_of(work, struct smc_link,
+					     llc_conf_rkey_work);
+	struct smc_link_group *lgr = link->lnk_grp;
+	struct llc_qentry *qentry;
+	struct llc_confirm_rkey_msg *rk_llc;
+	int rt_idx = 0, i, rc = 0;
+	enum llc_ctl_ind initiator;
+	u8 num_entries, more = 0;
+
+	initiator = (lgr->role == SMC_SERV) ? LLC_CLNT : LLC_SERV;
+	qentry = lgr->llc_ctl[initiator].qentry;
+	rk_llc = (struct llc_confirm_rkey_msg *)&qentry->msg;
+	lgr->llc_ctl[initiator].qentry = NULL;
+	qentry->msg.hd.flags |= LLC_FLAG_RESP;
+	if (lgr->llc_ctl[LLC_SERV].active > LLC_GRP_CONF_RKEY) {
+		qentry->msg.hd.flags |= LLC_FLAG_RKEY_NEG;
+		qentry->msg.hd.flags |= LLC_FLAG_RKEY_RETRY;
+	} else {
+		num_entries = rk_llc->rt[0].link_id;
+		rt_idx = smc_get_rtoken(lgr);
+		llc_set_rtoken_by_link(lgr, link->link_id, rt_idx,
+				       &rk_llc->rt[0]);
+		for (i = 1; i <= min_t(u8, num_entries, 2); i++)
+			llc_set_rtoken_by_link(lgr, rk_llc->rt[i].link_id,
+					       rt_idx, &rk_llc->rt[i]);
+		more = (num_entries > 2) ? 1 : 0;
+	}
+	rc = llc_send_msg(link, &qentry->msg, LLC_NO_NOTIFY);
+	kfree(qentry);
+again:
+	if (more && (rc >= 0)) {
+		qentry = llc_wait(lgr, (enum smc_role)initiator, LLC_WAIT_TIMEO,
+				  LLC_CONFIRM_RKEY_CONT);
+		if (!qentry) {
+			more = 0;
+		} else {
+			struct llc_conf_rkey_cont_msg *rkc_llc =
+				(struct llc_conf_rkey_cont_msg *)&qentry->msg;
+			lgr->llc_ctl[initiator].qentry = NULL;
+			qentry->msg.hd.flags |= LLC_FLAG_RESP;
+			num_entries = rkc_llc->num_rkeys;
+			for (i = 0; i <= min_t(u8, num_entries, 2); i++) {
+				llc_set_rtoken_by_link(lgr,
+						       rkc_llc->rt[i].link_id,
+						       rt_idx, &rkc_llc->rt[i]);
+			}
+			more = (num_entries > 3) ? 1 : 0;
+			rc = llc_send_msg(link, &qentry->msg, LLC_NO_NOTIFY);
+			kfree(qentry);
+		}
+		goto again;
+	}
+	lgr->llc_ctl[initiator].active = LLC_GRP_NONE;
+}
+
+void llc_process_delete_rkey(struct work_struct *work)
+{
+	struct smc_link *link = container_of(work, struct smc_link,
+					     llc_del_rkey_work);
+	struct smc_link_group *lgr = link->lnk_grp;
+	struct llc_qentry *qentry;
+	struct llc_delete_rkey_msg *drk_llc;
+	int initiator;
+
+	initiator = (lgr->role == SMC_SERV) ? SMC_CLNT : SMC_SERV;
+	qentry = lgr->llc_ctl[initiator].qentry;
+	drk_llc = (struct llc_delete_rkey_msg *)&qentry->msg;
+	lgr->llc_ctl[initiator].qentry = NULL;
+	qentry->msg.hd.flags |= LLC_FLAG_RESP;
+	if (lgr->llc_ctl[LLC_SERV].active > LLC_GRP_CONF_RKEY) {
+		qentry->msg.hd.flags |= LLC_FLAG_RKEY_NEG;
+		qentry->msg.hd.flags |= LLC_FLAG_RKEY_RETRY;
+	} else {
+		int i, rc;
+		u8 local_mask = 0, err_val;
+
+		err_val = 0x80;
+		for (i = 0; i < min_t(u8, drk_llc->num_rkeys, 8); i++) {
+			rc = smc_clear_rtokens_by_link(lgr, link->link_id,
+						       drk_llc->rk[i]);
+			if (rc < 0)
+				local_mask = local_mask + err_val;
+			err_val = err_val/2;
+		}
+		if (local_mask) {
+			drk_llc->hd.flags |= LLC_FLAG_RKEY_NEG;
+			drk_llc->err_mask = local_mask;
+		}
+	}
+	llc_send_msg(link, &qentry->msg, initiator);
+	kfree(qentry);
+	lgr->llc_ctl[initiator].active = LLC_GRP_NONE;
+}
+
+static void llc_handle_event(struct llc_qentry *qentry,
+			     struct smc_link_group *lgr)
+{
+	struct smc_link *lnk = qentry->link;
+	struct llc_ctl *srv_ctl = &lgr->llc_ctl[LLC_SERV];
+	int initiator;
+
+	switch (qentry->msg.hd.type) {
+	case LLC_ADD_LINK:
+		if (lgr->role == SMC_CLNT) {
+			if (srv_ctl->active) {
+				/* some process is waiting for this response */
+				srv_ctl->qentry = qentry;
+				wake_up_interruptible(&lgr->llc_waiter);
+			} else if (start_llc_agent(SMC_SERV, qentry)) {
+				schedule_work(&lnk->llc_add_link_work);
+			}
+		} else if (start_llc_agent(SMC_SERV, qentry)) {
+			/* else on SERV handle client suggest */
+			schedule_work(&lnk->llc_add_link_work);
+		}
+		break;
+	case LLC_DEL_LINK:
+		if (lgr->role == SMC_CLNT) {
+			if (srv_ctl->active) {
+				/* DEL LINK REQ during ADD LINK SEQ */
+				srv_ctl->qentry = qentry;
+				wake_up_interruptible(&lgr->llc_waiter);
+			} else if (start_llc_agent(SMC_SERV, qentry)) {
+				schedule_work(&lnk->llc_del_link_work);
+			}
+		} else {
+			if (qentry->msg.hd.flags & LLC_FLAG_DEL_ALL) {
+				smc_terminate_conn(lgr);
+				kfree(qentry);
+			} else if ((srv_ctl->active == LLC_GRP_ADD_LINK) &&
+				   (!srv_ctl->qentry)) {
+				/* DEL LINK REQ during ADD LINK SEQ */
+				srv_ctl->qentry = qentry;
+				wake_up_interruptible(&lgr->llc_waiter);
+			} else if (start_llc_agent(SMC_SERV, qentry)) {
+				schedule_work(&lnk->llc_del_link_work);
+			}
+		}
+		break;
+	case LLC_CONFIRM_RKEY:
+		initiator = (lgr->role == SMC_SERV) ? SMC_CLNT : SMC_SERV;
+		if (start_llc_agent(initiator, qentry))
+			schedule_work(&lnk->llc_conf_rkey_work);
+		break;
+	case LLC_DELETE_RKEY:
+		initiator = (lgr->role == SMC_SERV) ? SMC_CLNT : SMC_SERV;
+		if (start_llc_agent(initiator, qentry))
+			schedule_work(&lnk->llc_del_rkey_work);
+		break;
+	case LLC_CONFIRM_RKEY_CONT:
+		initiator = (lgr->role == SMC_SERV) ? SMC_CLNT : SMC_SERV;
+		lgr->llc_ctl[initiator].qentry = qentry;
+		wake_up_interruptible(&lgr->llc_waiter);
+		break;
+	case LLC_CONFIRM_LINK:
+	case LLC_ADD_LINK_CONT:
+		if (lgr->llc_ctl[LLC_SERV].active) {
+			/* some process is waiting for this response */
+			srv_ctl->qentry = qentry;
+			wake_up_interruptible(&lgr->llc_waiter);
+		}
+		break;
+	case LLC_TEST_LINK:
+		initiator = (lgr->role == SMC_SERV) ? SMC_CLNT : SMC_SERV;
+		qentry->msg.hd.flags |= LLC_FLAG_RESP;
+		llc_send_msg(qentry->link, &qentry->msg, LLC_NO_NOTIFY);
+		kfree(qentry);
+		break;
+	case LLC_NWM_DATA:
+		lgr->nwm_flags = qentry->msg.hd.flags;
+		if (qentry->msg.hd.flags & LLC_FLAG_HOSTNAME)
+			strncpy(lgr->nwm_data, qentry->msg.data,
+				sizeof(lgr->nwm_data));
+		else
+			memcpy(lgr->nwm_data, qentry->msg.data,
+			       sizeof(lgr->nwm_data));
+		kfree(qentry);
+		break;
+	default:
+		if (!(qentry->msg.hd.type & LLC_OPT_MSG_CTRL)) {
+			/* LLC protocol violation */
+			llc_send_del_link(qentry->link, NULL, 0,
+					  LLC_DEL_PROT_VIOL, LLC_NO_NOTIFY);
+			smc_terminate_conn(lgr);
+		}
+		kfree(qentry);
+		break;
+	}
+}
+
+void llc_event_worker(struct work_struct *work)
+{
+	struct smc_link_group *lgr = container_of(work, struct smc_link_group,
+						  llc_event_work);
+	struct llc_qentry *qentry;
+
+	if ((!lgr->llc_ctl[LLC_SERV].active) &&
+	    (lgr->delayed_q) &&
+		(atomic_read(&lgr->delayed_q->link->state) != SMC_LINK_FREED)) {
+		llc_handle_event(lgr->delayed_q, lgr);
+	}
+
+again:
+	spin_lock_bh(&lgr->llc_event_q_lock);
+	if (!list_empty(&lgr->llc_event_q)) {
+		qentry = list_first_entry(&lgr->llc_event_q, struct llc_qentry,
+					  list);
+		list_del_init(&qentry->list);
+		spin_unlock_bh(&lgr->llc_event_q_lock);
+		llc_handle_event(qentry, lgr);
+		goto again;
+	}
+	spin_unlock_bh(&lgr->llc_event_q_lock);
+}
+
diff --git a/net/smc/smc_llc.h b/net/smc/smc_llc.h
new file mode 100644
index 0000000..901741d
--- /dev/null
+++ b/net/smc/smc_llc.h
@@ -0,0 +1,192 @@
+/*
+ *  Shared Memory Communications over RDMA (SMC-R) and ROCE
+ *
+ *  Definitions for LLC message handling
+ *
+ *  Copyright IBM Corp. 2014
+ *
+ *  Author(s):  Klaus Wacker <Klaus.Wacker@de.ibm.com>
+ *              Ursula Braun <Ursula Braun@de.ibm.com>
+ */
+
+#define LLC_DATA_LEN    40
+#define LLC_SEND_POSTED		0xffffffff
+
+#define LLC_FLAG_RESP		0x80
+#define LLC_FLAG_HOSTNAME	0x80
+#define LLC_FLAG_RKEY_DEL	0x40
+#define LLC_FLAG_RKEY_NEG	0x20
+#define LLC_FLAG_RKEY_RETRY	0x10
+#define LLC_FLAG_DEL_ORDERLY	0x20
+#define LLC_FLAG_DEL_ALL	0x40
+#define LLC_FLAG_ADD_LNK_REJ	0x40
+#define LLC_FLAG_NO_ALT_PATH	0x01
+#define LLC_FLAG_PORT_ADD	0x01    /* Linux-only enhancement */
+#define LLC_FLAGS_DEL_ALL_ORD	0x60
+
+/* LLC DELETE LINK Request Reason Codes */
+#define LLC_DEL_LOST_PATH	0x00010000
+#define LLC_DEL_OP_INIT_TERM	0x00020000
+#define LLC_DEL_PROG_INIT_TERM	0x00030000
+#define LLC_DEL_PROT_VIOL	0x00040000
+#define LLC_DEL_NO_ASYM_NEEDED	0x00050000
+
+enum llc_reqresp {
+	LLC_REQ,
+	LLC_RESP
+};
+
+enum llc_msg_type {
+	LLC_CONFIRM_LINK		= 0x01,
+	LLC_ADD_LINK			= 0x02,
+	LLC_ADD_LINK_CONT		= 0x03,
+	LLC_DEL_LINK			= 0x04,
+	LLC_CONFIRM_RKEY		= 0x06,
+	LLC_CONFIRM_RKEY_CONT		= 0x08,
+	LLC_DELETE_RKEY			= 0x09,
+	LLC_TEST_LINK			= 0x07,
+	LLC_OPT_MSG_CTRL		= 0x80,
+	LLC_NWM_DATA			= 0x8A,
+	RMBE_CTRL			= 0xFE,
+};
+
+struct rmb_rtoken {		/* RMB credentials given to peer */
+	__be32 rmb_key;		/* rkey */
+	__be64 rmb_vaddr;	/* RDMA virtual address */
+} __packed;
+
+struct rmb_rtoken2 {
+	__be32 rmb_key;
+	__be32 rmb_key_new;
+	__be64 rmb_vaddr_new;
+} __packed;
+
+struct rmb_rtoken3 {
+	u8   link_id;
+	__be32 rmb_key;
+	__be64 rmb_vaddr;
+} __packed;
+
+struct llc_hdr {
+	u8 type;
+	u8 length;	/* 44 */
+	u8 version;	/* 0x01 */
+	u8 flags;
+} __packed;
+
+struct llc_msg {
+	struct llc_hdr hd;
+	u8 data[LLC_DATA_LEN];
+} __packed;
+
+struct llc_confirm_msg {		/* type 0x01 */
+	struct llc_hdr hd;
+	u8 sender_mac[6];
+	u8 sender_ipv6[16];
+	u8 sender_qp_num[3];
+	u8 link_num;
+	__be32 link_uid;
+	u8 max_links;
+	u8 reserved[9];
+} __packed;
+
+struct llc_add_link_msg {		/* type 0x02 */
+	struct llc_hdr hd;
+	u8 sender_mac[6];
+	u8 reserved2[2];
+	u8 sender_ipv6[16];
+	u8 sender_qp_num[3];
+	u8 link_num;
+	u8 flags2;	/* QP mtu */
+	u8 initial_psn[3];
+	u8 reserved[8];
+} __packed;
+
+struct llc_add_link_cont_msg {	/* type 0x03 */
+	struct llc_hdr hd;
+	u8 link_num;
+	u8 num_rkeys;
+	u8 reserved2[2];
+	struct rmb_rtoken2 rt[2];
+	u8 reserved[4];
+} __packed;
+
+struct llc_del_link_msg {		/* type 0x04 */
+	struct llc_hdr hd;
+	u8 link_num;
+	__be32 reason;
+	u8 reserved[35];
+} __packed;
+
+struct llc_confirm_rkey_msg {	/* type 0x05 */
+	struct llc_hdr hd;
+	struct rmb_rtoken3 rt[3];
+	u8 reserved[1];
+} __packed;
+
+struct llc_conf_rkey_cont_msg {	/* type 0x08 */
+	struct llc_hdr hd;
+	u8 num_rkeys;
+	struct rmb_rtoken3 rt[3];
+} __packed;
+
+struct llc_delete_rkey_msg {	/* type 0x09 */
+	struct llc_hdr hd;
+	u8 num_rkeys;
+	u8 err_mask;
+	u8 reserved[2];
+	__be32 rk[8];
+	u8 reserved2[4];
+} __packed;
+
+struct llc_test_link_msg {		/* type 0x07 */
+	struct llc_hdr hd;
+	u8 user_data[16];
+	u8 reserved[24];
+} __packed;
+
+struct llc_nwm_data_msg {		/* type 0x8A */
+	struct llc_hdr hd;
+	u8 ident[16];
+	u8 reserved[24];
+} __packed;
+
+struct llc_add_link_fake_msg {		/* type 0x82 */
+	struct llc_hdr hd;
+	struct smc_ib_device *ibdev;
+	u8 port_num;
+	u8 reserved[31];
+} __packed;
+
+struct llc_qentry {
+	struct list_head list;
+	struct smc_link *link;
+	struct llc_msg msg;
+};
+
+void llc_init_workers(struct smc_link_group *);
+int llc_enqueue(struct smc_link *, struct llc_msg *);
+int llc_initiate(struct smc_link_group *, enum llc_msg_group);
+void llc_stop(struct smc_link_group *, int);
+struct llc_qentry *llc_wait(struct smc_link_group *, enum smc_role, int, u8);
+int llc_send_confirm_link(struct smc_link *, u8 *, union ib_gid *,
+			  enum llc_reqresp, enum llc_ctl_ind);
+int llc_do_confirm_rkey(struct smc_link *, struct rmb_rx_addrs *);
+int llc_send_test_link(struct smc_link *, u8 *);
+int llc_send_add_link(struct smc_link *, struct smc_roce_defs *,
+		      struct smc_link *, enum llc_reqresp, enum llc_ctl_ind);
+int llc_send_del_link(struct smc_link *, struct smc_link *, u8, u32,
+		      enum llc_ctl_ind);
+int llc_do_del_rkey(struct smc_link *, struct rmb_rx_addrs *);
+void llc_event_worker(struct work_struct *);
+void llc_process_add_link(struct work_struct *);
+void llc_process_del_link(struct work_struct *);
+void llc_process_confirm_rkey(struct work_struct *);
+void llc_process_delete_rkey(struct work_struct *);
+int llc_get_fail_cause(struct smc_link_group *, enum llc_ctl_ind,
+		       struct smc_sock *);
+int llc_cli_add_link(struct smc_link *, struct llc_qentry *, struct smc_sock *);
+int llc_srv_add_link(struct smc_link *, struct smc_roce_defs *,
+		     struct smc_sock *);
+void llc_check_rtokens(struct smc_link_group *);
+void llc_kill_waiters(struct smc_link_group *);
diff --git a/net/smc/smc_proc.c b/net/smc/smc_proc.c
new file mode 100644
index 0000000..d178283
--- /dev/null
+++ b/net/smc/smc_proc.c
@@ -0,0 +1,829 @@
+/*
+ *  Shared Memory Communications over RDMA (SMC-R) and ROCE
+ *
+ *  auxiliary functions
+ *
+ *  Copyright IBM Corp. 2014
+ *
+ *  Author(s):  Ursula Braun <ursula.braun@de.ibm.com>
+ *              Frank Blaschka <blaschka@linux.vnet.ibm.com>
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/interrupt.h>
+#include <linux/slab.h>
+#include <linux/skbuff.h>
+#include <linux/init.h>
+#include <linux/poll.h>
+#include <linux/socket.h>
+#include <linux/pci.h>
+#include <linux/seq_file.h>
+#include <linux/uaccess.h>
+#include <linux/workqueue.h>
+#include <linux/proc_fs.h>
+#include <linux/netdevice.h>
+#include <linux/if_vlan.h>
+#include <linux/inetdevice.h>
+#include <linux/types.h>
+#include <net/sock.h>
+#include <net/inet_sock.h>
+#include <net/tcp.h>
+#include <net/route.h>
+#include <asm/byteorder.h>
+#include <rdma/ib_verbs.h>
+#include <rdma/ib_addr.h>
+
+#include "af_smc.h"
+#include "smc_llc.h"
+
+struct smc_pnet_entry {
+	struct list_head list;
+	char dev_name[IFNAMSIZ];
+	char net_name[SMC_MAX_PNET_ID_LEN];
+	u8 port;
+	enum {
+		PNET_ETH,
+		PNET_IB
+	} type;
+};
+
+static struct proc_dir_entry *procfs_root;
+static struct proc_dir_entry *procfs_pnet_conf;
+static struct proc_dir_entry *procfs_buff_cnt;
+static struct proc_dir_entry *procfs_max_conn_per_lgr;
+static struct proc_dir_entry *procfs_sndbuf;
+static struct proc_dir_entry *procfs_rcvbuf;
+static struct list_head smc_pnet_list;
+static rwlock_t smc_pnet_list_lock;
+
+/* determine first gid of roce device  and derive mac from it */
+int smc_get_ib_mac(struct smc_roce_defs *rocdefs)
+{
+	int rc = 0;
+
+	rc = ib_query_gid(rocdefs->ibdev->dev, rocdefs->port, 0, &rocdefs->gid);
+	if (!rc) {
+		memcpy(&rocdefs->mac[0], &rocdefs->gid.raw[8], 3);
+		memcpy(&rocdefs->mac[3], &rocdefs->gid.raw[13], 3);
+		rocdefs->mac[0] &= ~0x02;
+	}
+	return rc;
+}
+
+int smc_port_active(struct smc_ib_device *dev, u8 port)
+{
+	struct ib_port_attr props;
+	int rc;
+
+	rc = ib_query_port(dev->dev, port, &props);
+	if (rc)
+		return 0;
+	if (props.state != IB_PORT_ACTIVE)
+		return 0;
+	return 1;
+}
+
+static void smc_ib_dev_by_pnet(struct smc_roce_defs *rocdefs, char *pnet,
+			       struct smc_link *link)
+{
+	struct smc_ib_device *dev = NULL;
+	struct smc_pnet_entry *entry;
+	int found = 0;
+
+	read_lock(&smc_pnet_list_lock);
+	list_for_each_entry(entry, &smc_pnet_list, list) {
+		if ((entry->type != PNET_IB) ||
+		    strncmp(pnet, entry->net_name, sizeof(entry->net_name)))
+			continue;
+		if (link &&
+		    !strncmp(entry->dev_name,
+			     link->roce_defs.ibdev->dev->name,
+			     sizeof(entry->dev_name)) &&
+		    (entry->port == link->roce_defs.port)) {
+			continue;
+		}
+		list_for_each_entry(dev, &smc_ib_devices, list) {
+			if (!strncmp(dev->dev->name, entry->dev_name,
+				     sizeof(entry->dev_name)) /* &&
+			    smc_free_capacity(dev) */) {
+				read_unlock(&smc_pnet_list_lock);
+				found = smc_port_active(dev, entry->port);
+				read_lock(&smc_pnet_list_lock);
+				if (found)
+					break;
+			}
+		}
+		if (found)
+			break;
+	}
+	read_unlock(&smc_pnet_list_lock);
+
+	if (!found)
+		return;
+
+	rocdefs->ibdev = dev;
+	rocdefs->port = entry->port;
+}
+
+int smc_pnet_by_ibdev(u8 port, char *pnet, struct smc_ib_device *dev)
+{
+	struct smc_pnet_entry *entry;
+	int rc = -EINVAL;
+
+	read_lock(&smc_pnet_list_lock);
+	list_for_each_entry(entry, &smc_pnet_list, list) {
+		if (entry->type == PNET_IB &&
+		    !strncmp(dev->dev->name, entry->dev_name,
+			     sizeof(entry->dev_name)) &&
+		    (port == entry->port)) {
+			rc = 0;
+			strncpy(pnet, entry->net_name, sizeof(entry->net_name));
+			break;
+		}
+	}
+	read_unlock(&smc_pnet_list_lock);
+	return rc;
+}
+
+static int smc_pnet_by_tcpsk(char *pnet, struct sock *sk)
+{
+	int rc = -EINVAL;
+	struct smc_pnet_entry *entry;
+	struct dst_entry *dst = sk_dst_get(sk);
+
+	if (!dst)
+		goto out;
+	if (!dst->dev)
+		goto out_rel;
+	read_lock(&smc_pnet_list_lock);
+	list_for_each_entry(entry, &smc_pnet_list, list) {
+		if (entry->type == PNET_ETH &&
+		    !strncmp(dst->dev->name, entry->dev_name,
+			     sizeof(entry->dev_name))) {
+			strncpy(pnet, entry->net_name, sizeof(entry->net_name));
+			rc = 0;
+			break;
+		}
+	}
+	read_unlock(&smc_pnet_list_lock);
+out_rel:
+	dst_release(dst);
+out:
+	return rc;
+}
+
+int smc_gid_by_dev(struct smc_roce_defs *rocdefs)
+{
+	int rc = 0;
+
+	rc = ib_query_gid(rocdefs->ibdev->dev, rocdefs->port, 0,
+			  &rocdefs->gid);
+	rocdefs->sgid_idx = 0;
+	smc_get_ib_mac(rocdefs);
+	return rc;
+}
+
+static int smc_gid_by_tcpsk(struct smc_roce_defs *rocdefs, struct sock *sk)
+{
+	struct dst_entry *dst = sk_dst_get(sk);
+	int rc;
+
+	rocdefs->vlan = 0;
+	if (dst) {
+		if (dst->dev) {
+			if (is_vlan_dev(dst->dev))
+				rocdefs->vlan = vlan_dev_vlan_id(dst->dev);
+		}
+		dst_release(dst);
+	}
+	rc = smc_gid_by_dev(rocdefs);
+	return rc;
+}
+
+void smc_find_roce_resources(struct smc_roce_defs *rocdefs, char *pnet,
+			     struct sockaddr_in *inaddr, struct sock *sk)
+{
+	int rc;
+
+	rocdefs->ibdev = NULL;
+	rocdefs->port = 0;
+	rc = smc_pnet_by_tcpsk(pnet, sk);
+	if (rc)
+		return;
+	smc_ib_dev_by_pnet(rocdefs, pnet, NULL);
+	if (!rocdefs->ibdev)
+		return;
+
+	rc = smc_gid_by_tcpsk(rocdefs, sk);
+	if (rc) {
+		rocdefs->ibdev = NULL;
+		return;
+	}
+}
+
+void smc_find_alt_roce_resources(struct smc_roce_defs *rocdefs,
+				 struct smc_link_group *lgr,
+				 struct smc_link *link)
+{
+	int rc;
+
+	smc_ib_dev_by_pnet(rocdefs, lgr->pnet_id, link);
+	if (!rocdefs->ibdev)
+		return;
+
+	rocdefs->vlan = lgr->vlan;
+	rc = smc_gid_by_dev(rocdefs);
+	if (rc) {
+			rocdefs->ibdev = NULL;
+			return;
+	}
+}
+
+int smc_netinfo_by_tcpsk(__be32 *subnet, u8 *mlen, struct socket *tcpsocket)
+{
+	struct dst_entry *dst = sk_dst_get(tcpsocket->sk);
+	struct sockaddr_in addr;
+	int rc = -ENODEV;
+	int len;
+
+	if (!dst)
+		goto out;
+	if (!dst->dev)
+		goto out_rel;
+		kernel_getsockname(tcpsocket,
+				   (struct sockaddr *)&addr, &len);
+	for_ifa(dst->dev->ip_ptr) {
+		if (ifa->ifa_address != addr.sin_addr.s_addr)
+			continue;
+		*mlen = inet_mask_len(ifa->ifa_mask);
+		*subnet = ifa->ifa_address & ifa->ifa_mask;
+		rc = 0;
+		break;
+	} endfor_ifa(dst->dev->ip_ptr);
+out_rel:
+	dst_release(dst);
+out:
+	return rc;
+}
+
+static void smc_print_area(struct seq_file *m, char *buf, int max_len,
+			   int pr_len)
+{
+	char fmtbuf[60];
+	int i, len;
+
+	len = min_t(size_t, max_len, pr_len);
+	while (len > 0) {
+		i = (len < 16) ? len : 16;
+		hex_dump_to_buffer(buf, i, 16, 4, fmtbuf, 60, 0);
+		seq_printf(m, "%p: %s\n", buf, fmtbuf);
+		buf += 16;
+		len -= 16;
+	}
+}
+
+static int smc_sock_show(struct seq_file *m, void *v)
+{
+	struct sock *sk = m->private;
+	struct smc_sock *smc;
+	struct sockaddr_in locl_addr, peer_addr;
+	int rc, len;
+
+	if (!sk)
+		return 0;
+
+	sock_hold(sk);
+	if (sock_flag(sk, SOCK_DEAD) || (sk->sk_state == SMC_DESTRUCT))
+		goto out;
+
+	smc = smc_sk(sk);
+	seq_printf(m, "state: %d\n", sk->sk_state);
+	seq_printf(m, "uid: %d\n",
+		   from_kuid_munged(seq_user_ns(m), sock_i_uid(sk)));
+	seq_printf(m, "inode: %ld\n", sock_i_ino(sk));
+
+	if (sk->sk_state == SMC_INIT)
+		goto out;
+
+	if (smc->tcpsocket) {
+		rc = smc->tcpsocket->ops->getname(smc->tcpsocket,
+						  (struct sockaddr *)&locl_addr,
+						  &len, 0);
+		if (!rc) {
+			seq_printf(m, "local_addr: %pI4\n",
+				   &locl_addr.sin_addr.s_addr);
+			seq_printf(m, "local_port: %d\n",
+				   ntohs(locl_addr.sin_port));
+		}
+	}
+
+	if (sk->sk_state == SMC_LISTEN)
+		goto out;
+
+	if (smc->tcpsocket) {
+		rc = smc->tcpsocket->ops->getname(smc->tcpsocket,
+						  (struct sockaddr *)&peer_addr,
+						  &len, 1);
+		if (!rc) {
+			seq_printf(m, "peer_addr: %pI4\n",
+				   &peer_addr.sin_addr.s_addr);
+			seq_printf(m, "peer_port: %d\n",
+				   ntohs(peer_addr.sin_port));
+		}
+	}
+
+	seq_printf(m, "tcp_fallback: %d\n", smc->use_tcp);
+	if (smc->use_tcp)
+		goto out;
+
+	if (smc->conn.lgr && (sk->sk_state != SMC_CLOSED)) {
+		seq_printf(m, "link group target: %#x\n",
+			   smc->conn.lgr->daddr);
+		seq_printf(m, "link group role: %d\n", smc->conn.lgr->role);
+		seq_puts(m, "gid_peer:\n");
+		smc_print_area(m, smc->conn.lgr->lnk[0].gid_peer, 16, 16);
+		smc_print_area(m, smc->conn.lgr->lnk[1].gid_peer, 16, 16);
+	}
+	seq_printf(m, "tx buffer len: %d\n", smc->conn.rmb_tx_size);
+	seq_printf(m, "rx buffer len: %d\n", smc->conn.rmb_rx_size);
+	seq_printf(m, "local alert token: %#x\n", smc->conn.alert_token_local);
+
+	seq_printf(m, "peer rx buffer len: %d\n", smc->conn.peer_rx_buf_len);
+	seq_printf(m, "local rx pc %d pw %d cc %d cw %d\n",
+		   smc->conn.local_rx_ctrl.p_curs.s.curs.c,
+		   smc->conn.local_rx_ctrl.p_curs.s.curs.w,
+		   smc->conn.local_rx_ctrl.c_curs.s.curs.c,
+		   smc->conn.local_rx_ctrl.c_curs.s.curs.w);
+	seq_printf(m, "local tx pc %d pw %d cc %d cw %d\n",
+		   smc->conn.local_tx_ctrl.p_curs.s.curs.c,
+		   smc->conn.local_tx_ctrl.p_curs.s.curs.w,
+		   smc->conn.local_tx_ctrl.c_curs.s.curs.c,
+		   smc->conn.local_tx_ctrl.c_curs.s.curs.w);
+	seq_printf(m, "tx producer_flags %#x conn_state_flags %#x\n",
+		   *(u8 *)&smc->conn.local_tx_ctrl.p_flags,
+		   *(u8 *)&smc->conn.local_tx_ctrl.conn_state_flags);
+	seq_printf(m, "rx producer_flags %#x conn_state_flags %#x\n",
+		   *(u8 *)&smc->conn.local_rx_ctrl.p_flags,
+		   *(u8 *)&smc->conn.local_rx_ctrl.conn_state_flags);
+
+	if (smc->conn.rmb_tx_elem &&
+	    smc->conn.rmb_tx_elem->rmb_tx &&
+	    smc->conn.rmb_tx_elem->rmb_tx->buffer) {
+		seq_puts(m, "tx buffer:\n");
+		smc_print_area(m, smc->conn.rmb_tx_elem->rmb_tx->buffer,
+			       smc->conn.rmb_tx_size, 15000);
+	}
+	if (smc->conn.rmb_rx_elem &&
+	    smc->conn.rmb_rx_elem->rmb_rx &&
+	    smc->conn.rmb_rx_elem->rmb_rx->buffer) {
+		seq_puts(m, "rx buffer:\n");
+		smc_print_area(m, smc->conn.rmb_rx_elem->rmb_rx->buffer,
+			       smc->conn.rmb_rx_size, 15000);
+	}
+
+out:
+	sock_put(sk);
+	return 0;
+}
+
+static int smc_sock_seq_open(struct inode *inode, struct file *filp)
+{
+	return single_open(filp, smc_sock_show, PDE_DATA(inode));
+}
+
+static const struct file_operations procfs_smc_sock_fops = {
+	.owner	 = THIS_MODULE,
+	.open	 = smc_sock_seq_open,
+	.read	 = seq_read,
+	.llseek	 = seq_lseek,
+	.release = single_release,
+};
+
+int smc_sock_proc_create(struct sock *sk)
+{
+	struct smc_sock *smc = smc_sk(sk);
+
+	sprintf(smc->proc_name, "Sx%p", sk);
+	smc->proc = proc_create_data(smc->proc_name,
+				     S_IFREG | S_IRUGO | S_IWUSR,
+				     procfs_root, &procfs_smc_sock_fops, sk);
+	return 0;
+}
+
+void smc_sock_proc_remove(char *name)
+{
+	remove_proc_entry(name, procfs_root);
+}
+
+static int smc_pnet_show(struct seq_file *m, void *v)
+{
+	struct smc_pnet_entry *entry;
+
+	read_lock(&smc_pnet_list_lock);
+	list_for_each_entry(entry, &smc_pnet_list, list) {
+		if (entry->type == PNET_IB)
+			seq_printf(m, "%-*s ib  %s %d\n", SMC_MAX_PNET_ID_LEN,
+				   entry->net_name, entry->dev_name,
+				   entry->port);
+		else
+			seq_printf(m, "%-*s eth %s\n", SMC_MAX_PNET_ID_LEN,
+				   entry->net_name, entry->dev_name);
+	}
+	read_unlock(&smc_pnet_list_lock);
+	return 0;
+}
+
+static struct smc_pnet_entry *smc_pnet_create_entry(int argc, char *argv[])
+{
+	struct smc_pnet_entry *entry;
+	long rc = 0;
+
+	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
+	if (!entry) {
+		rc = -ENOMEM;
+		goto out;
+	}
+	if (!strcmp(argv[2], "ib")) {
+		entry->type = PNET_IB;
+	} else if (!strcmp(argv[2], "eth")) {
+		if (argc > 4)
+			goto out;
+		entry->type = PNET_ETH;
+	} else {
+		goto out;
+	}
+	strncpy(entry->net_name, argv[1], sizeof(entry->net_name));
+	strncpy(entry->dev_name, argv[3], sizeof(entry->dev_name));
+
+	if (entry->type == PNET_IB) {
+		if (argc != 5 || kstrtou8(argv[4], 0, &entry->port)) {
+			rc = -EINVAL;
+			goto out;
+		}
+	}
+
+	return entry;
+
+out:
+	kfree(entry);
+	return ERR_PTR(rc);
+}
+
+/* Update the PNET ID table. Make sure entries are sorted by PNET ID
+ * for fancy output.
+ * @entry: entry to search for
+ * @del: delete existing entry if found, otherwise add.
+ *
+ * Returns 0 on success, <0 otherwise.
+ */
+static int smc_pnet_update(struct smc_pnet_entry *entry, bool del)
+{
+	struct smc_pnet_entry *tmp_entry, *n_entry;
+	int rc = -EINVAL;
+	int found = 0;
+
+	/* keep list sorted by PNET ID */
+	write_lock(&smc_pnet_list_lock);
+	list_for_each_entry_safe(tmp_entry, n_entry, &smc_pnet_list, list) {
+		if (entry->type == tmp_entry->type &&
+		    !strncmp(entry->dev_name, tmp_entry->dev_name,
+		    sizeof(entry->dev_name)) &&
+		    entry->port == tmp_entry->port) {
+			if (del) {
+				list_del(&tmp_entry->list);
+				kfree(entry);
+				rc = 0;
+			}
+			found = 1;
+			break;
+		}
+		if (strncmp(entry->net_name, tmp_entry->net_name,
+			    sizeof(entry->net_name)) < 0)
+			break;
+	}
+	if (!del && !found) {
+		list_add_tail(&entry->list, &tmp_entry->list);
+		rc = 0;
+	}
+	write_unlock(&smc_pnet_list_lock);
+
+	return rc;
+}
+
+/* add|del <PNET ID> eth|ib <device name> [<port>] */
+static ssize_t smc_pnet_write(struct file *file,
+			      const char __user *user_buffer,
+			      size_t count, loff_t *offset)
+{
+	char buf[128];
+	char *pos;
+	char *tok;
+	char *tmp;
+	char *argv[5];
+	int argc, rc = -EINVAL, del;
+	int len = min_t(size_t, count, sizeof(buf) - 1);
+	struct smc_pnet_entry *entry;
+
+	memset(buf, 0, sizeof(buf));
+	argc = 0;
+
+	if (copy_from_user(buf, user_buffer, len)) {
+		rc = -EFAULT;
+		goto out;
+	}
+	tmp = buf;
+	pos = strsep(&tmp, "\n");
+
+	while ((tok = strsep(&pos, " "))) {
+		if (!strcmp(tok, ""))
+			continue;
+		if (argc == 5)
+			break;
+		argv[argc] = tok;
+		argc++;
+	}
+
+	if (argc < 4 || tok)
+		goto out;
+
+	if (!strcmp(argv[0], "add"))
+		del = 0;
+	else if (!strcmp(argv[0], "del"))
+		del = 1;
+	else
+		goto out;
+	entry = smc_pnet_create_entry(argc, argv);
+	if (IS_ERR(entry)) {
+		rc = PTR_ERR(entry);
+		goto out;
+	}
+	rc = smc_pnet_update(entry, del);
+	if (!rc)
+		rc = count;
+out:
+	return rc;
+}
+
+static int smc_pnet_seq_open(struct inode *inode, struct file *filp)
+{
+	return single_open(filp, smc_pnet_show, PDE_DATA(inode));
+}
+
+static int smc_buff_cnt_show(struct seq_file *m, void *v)
+{
+	seq_printf(m, "%u\n", smc_ctrl_buf_cnt);
+	return 0;
+}
+
+static ssize_t smc_buff_cnt_write(struct file *file,
+				  const char __user *user_buffer,
+				  size_t count, loff_t *offset)
+{
+	unsigned int tmp;
+	int cnt, rc = 0;
+
+	cnt = kstrtouint_from_user(user_buffer, count, 0,  &tmp);
+	if ((cnt < 0) ||
+	    (tmp < 3) ||
+	    (tmp > SMC_MAX_WRE) ||
+	    ((smc_max_conn_per_lgr * 3 * tmp) > SMC_MAX_CQE)) {
+		rc = -EINVAL;
+		goto out;
+	}
+	spin_lock_bh(&smc_lgr_list.lock);
+	if (!list_empty(&smc_lgr_list.list)) {
+		rc = -EPERM;
+		goto out_unlock;
+	}
+	smc_ctrl_buf_cnt = tmp;
+	rc = count;
+out_unlock:
+	spin_unlock_bh(&smc_lgr_list.lock);
+out:
+	return rc;
+}
+
+static int smc_buff_cnt_seq_open(struct inode *inode, struct file *filp)
+{
+	return single_open(filp, smc_buff_cnt_show, PDE_DATA(inode));
+}
+
+static int smc_max_conn_per_lgr_show(struct seq_file *m, void *v)
+{
+	seq_printf(m, "%d\n", smc_max_conn_per_lgr);
+	return 0;
+}
+
+static ssize_t smc_max_conn_per_lgr_write(struct file *file,
+					  const char __user *user_buffer,
+					  size_t count, loff_t *offset)
+{
+	unsigned int tmp;
+	int cnt, rc = 0;
+
+	cnt = kstrtouint_from_user(user_buffer, count, 0,  &tmp);
+	if ((cnt < 0) ||
+	    (tmp < 1) ||
+	    (tmp > SMC_MAX_RMB) ||
+	    ((tmp * 3 * smc_ctrl_buf_cnt) > SMC_MAX_CQE)) {
+		rc = -EINVAL;
+		goto out;
+	}
+	smc_max_conn_per_lgr = tmp;
+	rc = count;
+out:
+	return rc;
+}
+
+static int smc_max_conn_per_lgr_seq_open(struct inode *inode, struct file *filp)
+{
+	return single_open(filp, smc_max_conn_per_lgr_show, PDE_DATA(inode));
+}
+
+static int smc_sndbuf_show(struct seq_file *m, void *v)
+{
+	seq_printf(m, "%d\n", smc_def_sndbuf_size);
+	return 0;
+}
+
+static ssize_t smc_sndbuf_write(struct file *file,
+				const char __user *user_buffer, size_t count,
+				loff_t *offset)
+{
+	unsigned int tmp;
+	int cnt, rc = 0;
+
+	cnt = kstrtouint_from_user(user_buffer, count, 0,  &tmp);
+	if ((cnt < 0) ||
+	    (tmp < SK_MEM_QUANTUM) ||
+	    (tmp > sysctl_wmem_max)) {
+		rc = -EINVAL;
+		goto out;
+	}
+	smc_def_sndbuf_size = tmp;
+	rc = count;
+out:
+	return rc;
+}
+
+static int smc_sndbuf_seq_open(struct inode *inode, struct file *filp)
+{
+	return single_open(filp, smc_sndbuf_show, PDE_DATA(inode));
+}
+
+static int smc_rcvbuf_show(struct seq_file *m, void *v)
+{
+	seq_printf(m, "%d\n", smc_def_rcvbuf_size);
+	return 0;
+}
+
+static ssize_t smc_rcvbuf_write(struct file *file,
+				const char __user *user_buffer,
+				size_t count, loff_t *offset)
+{
+	unsigned int tmp;
+	int cnt, rc = 0;
+
+	cnt = kstrtouint_from_user(user_buffer, count, 0,  &tmp);
+	if ((cnt < 0) ||
+	    (tmp < SK_MEM_QUANTUM) ||
+	    (tmp > sysctl_rmem_max)) {
+		rc = -EINVAL;
+		goto out;
+	}
+	smc_def_rcvbuf_size = tmp;
+	rc = count;
+out:
+	return rc;
+}
+
+static int smc_rcvbuf_seq_open(struct inode *inode, struct file *filp)
+{
+	return single_open(filp, smc_rcvbuf_show, PDE_DATA(inode));
+}
+
+static const struct file_operations procfs_pnet_fops = {
+	.owner	 = THIS_MODULE,
+	.open	 = smc_pnet_seq_open,
+	.read	 = seq_read,
+	.llseek	 = seq_lseek,
+	.write   = smc_pnet_write,
+	.release = single_release,
+};
+
+static const struct file_operations procfs_buff_cnt_fops = {
+	.owner	 = THIS_MODULE,
+	.open	 = smc_buff_cnt_seq_open,
+	.read	 = seq_read,
+	.llseek	 = seq_lseek,
+	.write   = smc_buff_cnt_write,
+	.release = single_release,
+};
+
+static const struct file_operations procfs_max_conn_per_lgr_fops = {
+	.owner	 = THIS_MODULE,
+	.open	 = smc_max_conn_per_lgr_seq_open,
+	.read	 = seq_read,
+	.llseek	 = seq_lseek,
+	.write   = smc_max_conn_per_lgr_write,
+	.release = single_release,
+};
+
+static const struct file_operations procfs_sndbuf_fops = {
+	.owner	 = THIS_MODULE,
+	.open	 = smc_sndbuf_seq_open,
+	.read	 = seq_read,
+	.llseek	 = seq_lseek,
+	.write   = smc_sndbuf_write,
+	.release = single_release,
+};
+
+static const struct file_operations procfs_rcvbuf_fops = {
+	.owner	 = THIS_MODULE,
+	.open	 = smc_rcvbuf_seq_open,
+	.read	 = seq_read,
+	.llseek	 = seq_lseek,
+	.write   = smc_rcvbuf_write,
+	.release = single_release,
+};
+
+int smc_proc_init(void)
+{
+	INIT_LIST_HEAD(&smc_pnet_list);
+	rwlock_init(&smc_pnet_list_lock);
+	procfs_root = proc_net_mkdir(&init_net, "smc", init_net.proc_net);
+	if (!procfs_root)
+		goto out;
+	procfs_pnet_conf =
+		proc_create_data("pnet_conf", S_IFREG | S_IRUGO | S_IWUSR,
+				 procfs_root, &procfs_pnet_fops, NULL);
+	if (!procfs_pnet_conf)
+		goto out_smc;
+	procfs_buff_cnt =
+		proc_create_data("ctrl_buffer_count",
+				 S_IFREG | S_IRUGO | S_IWUSR,
+				 procfs_root, &procfs_buff_cnt_fops, NULL);
+	if (!procfs_buff_cnt)
+		goto out_pnet_conf;
+	procfs_max_conn_per_lgr =
+		proc_create_data("max_conn_per_lgr",
+				 S_IFREG | S_IRUGO | S_IWUSR,
+				 procfs_root, &procfs_max_conn_per_lgr_fops,
+				 NULL);
+	if (!procfs_max_conn_per_lgr)
+		goto out_ctrl_buffer_count;
+	procfs_sndbuf = proc_create_data("sndbuf", S_IFREG | S_IRUGO | S_IWUSR,
+					 procfs_root, &procfs_sndbuf_fops,
+					 NULL);
+	if (!procfs_sndbuf)
+		goto out_max_conn_per_lgr;
+	procfs_rcvbuf = proc_create_data("rcvbuf", S_IFREG | S_IRUGO | S_IWUSR,
+					 procfs_root, &procfs_rcvbuf_fops,
+					 NULL);
+	if (!procfs_rcvbuf)
+		goto out_sndbuf;
+	return 0;
+
+out_sndbuf:
+	remove_proc_entry("sndbuf", procfs_root);
+out_max_conn_per_lgr:
+	remove_proc_entry("max_conn_per_lgr", procfs_root);
+out_ctrl_buffer_count:
+	remove_proc_entry("ctrl_buffer_count", procfs_root);
+out_pnet_conf:
+	remove_proc_entry("pnet_conf", procfs_root);
+out_smc:
+	remove_proc_entry("smc", init_net.proc_net);
+out:
+	return -EFAULT;
+}
+
+void smc_proc_exit(void)
+{
+	struct smc_pnet_entry *entry, *tmp_entry;
+
+	write_lock(&smc_pnet_list_lock);
+	list_for_each_entry_safe(entry, tmp_entry, &smc_pnet_list, list) {
+		list_del(&entry->list);
+		kfree(entry);
+	}
+	write_unlock(&smc_pnet_list_lock);
+
+	if (procfs_rcvbuf)
+		remove_proc_entry("rcvbuf", procfs_root);
+	if (procfs_sndbuf)
+		remove_proc_entry("sndbuf", procfs_root);
+	if (procfs_max_conn_per_lgr)
+		remove_proc_entry("max_conn_per_lgr", procfs_root);
+	if (procfs_buff_cnt)
+		remove_proc_entry("ctrl_buffer_count", procfs_root);
+	if (procfs_pnet_conf)
+		remove_proc_entry("pnet_conf", procfs_root);
+	if (procfs_root)
+		remove_proc_entry("smc", init_net.proc_net);
+}
-- 
1.8.5.5
