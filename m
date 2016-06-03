From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 02/15] smc: establish new socket family
Date: Fri,  3 Jun 2016 17:27:01 +0200
Message-ID: <201606031527.u53FQ009037283@mx0a-001b2d01.pphosted.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:26417 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752803AbcFCP1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 11:27:46 -0400
Received: from pps.filterd (m0048817.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u53FQ009037283
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2016 11:27:45 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23bc7r8x56-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 11:27:44 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 3 Jun 2016 16:27:41 +0100
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 * enable smc module loading and unloading
 * register new socket family
 * basic smc socket creation and deletion
 * use backing TCP socket to run CLC (Connection Layer Control)
   handshake of SMC protocol
 * Setup for infiniband traffic is implemented in follow-on patches.
   For now fallback to TCP socket is always used.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Utz Bacher <utz.bacher@de.ibm.com>
---
 MAINTAINERS            |   7 +
 include/linux/socket.h |   7 +-
 net/Kconfig            |   1 +
 net/Makefile           |   1 +
 net/smc/Kconfig        |  11 +
 net/smc/Makefile       |   2 +
 net/smc/af_smc.c       | 623 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/smc/smc.h          |  36 +++
 8 files changed, 687 insertions(+), 1 deletion(-)
 create mode 100644 net/smc/Kconfig
 create mode 100644 net/smc/Makefile
 create mode 100644 net/smc/af_smc.c
 create mode 100644 net/smc/smc.h

diff --git a/MAINTAINERS b/MAINTAINERS
index f8d5a37..fb3c883 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9983,6 +9983,13 @@ L:	linux-serial@vger.kernel.org
 S:	Maintained
 F:	drivers/tty/serial/
 
+SHARED MEMORY COMMUNICATIONS (SMC) SOCKETS
+M:	Ursula Braun <ursula.braun@linux.vnet.ibm.com>
+L:	linux-s390@vger.kernel.org
+W:	http://www.ibm.com/developerworks/linux/linux390/
+S:	Supported
+F:	net/smc/
+
 SYNOPSYS DESIGNWARE DMAC DRIVER
 M:	Viresh Kumar <vireshk@kernel.org>
 M:	Andy Shevchenko <andriy.shevchenko@linux.intel.com>
diff --git a/include/linux/socket.h b/include/linux/socket.h
index b5cc5a6..a4a1cc7 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -202,8 +202,12 @@ struct ucred {
 #define AF_VSOCK	40	/* vSockets			*/
 #define AF_KCM		41	/* Kernel Connection Multiplexor*/
 #define AF_QIPCRTR	42	/* Qualcomm IPC Router          */
+#define AF_SMC		43	/* smc sockets: reserve number for
+				 * PF_SMC protocol family that
+				 * reuses AF_INET address family
+				 */
 
-#define AF_MAX		43	/* For now.. */
+#define AF_MAX		44	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -251,6 +255,7 @@ struct ucred {
 #define PF_VSOCK	AF_VSOCK
 #define PF_KCM		AF_KCM
 #define PF_QIPCRTR	AF_QIPCRTR
+#define PF_SMC		AF_SMC
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
diff --git a/net/Kconfig b/net/Kconfig
index ff40562..1dfcb5e 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -57,6 +57,7 @@ source "net/packet/Kconfig"
 source "net/unix/Kconfig"
 source "net/xfrm/Kconfig"
 source "net/iucv/Kconfig"
+source "net/smc/Kconfig"
 
 config INET
 	bool "TCP/IP networking"
diff --git a/net/Makefile b/net/Makefile
index bdd1455..9e2ff8e 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -50,6 +50,7 @@ obj-$(CONFIG_MAC80211)		+= mac80211/
 obj-$(CONFIG_TIPC)		+= tipc/
 obj-$(CONFIG_NETLABEL)		+= netlabel/
 obj-$(CONFIG_IUCV)		+= iucv/
+obj-$(CONFIG_SMC)		+= smc/
 obj-$(CONFIG_RFKILL)		+= rfkill/
 obj-$(CONFIG_NET_9P)		+= 9p/
 obj-$(CONFIG_CAIF)		+= caif/
diff --git a/net/smc/Kconfig b/net/smc/Kconfig
new file mode 100644
index 0000000..bc02980
--- /dev/null
+++ b/net/smc/Kconfig
@@ -0,0 +1,11 @@
+config SMC
+	tristate "SMC socket protocol family"
+	depends on INET && INFINIBAND
+	---help---
+	  SMC-R provides a "sockets over RDMA" solution making use of
+	  RDMA over Converged Ethernet (RoCE) technology to upgrade
+	  AF_INET TCP connections transparently.
+	  The Linux implementation of the SMC-R solution is designed as
+	  a separate socket family SMC.
+
+	  Select this option if you want to run SMC socket applications
diff --git a/net/smc/Makefile b/net/smc/Makefile
new file mode 100644
index 0000000..c285c86
--- /dev/null
+++ b/net/smc/Makefile
@@ -0,0 +1,2 @@
+obj-$(CONFIG_SMC)	+= smc.o
+smc-y := af_smc.o
diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
new file mode 100644
index 0000000..ae3332c
--- /dev/null
+++ b/net/smc/af_smc.c
@@ -0,0 +1,623 @@
+/*
+ *  Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ *  AF_SMC protocol family socket handler keeping the AF_INET sock address type
+ *  applies to SOCK_STREAM sockets only
+ *  offers an alternative communication option for TCP-protocol sockets
+ *  applicable with RoCE-cards only
+ *
+ *  Copyright IBM Corp. 2016
+ *
+ *  Author(s):  Ursula Braun <ubraun@linux.vnet.ibm.com>
+ *              based on prototype from Frank Blaschka
+ */
+
+#define KMSG_COMPONENT "smc"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
+#include <linux/module.h>
+#include <linux/socket.h>
+#include <net/sock.h>
+
+#include "smc.h"
+
+static void smc_set_keepalive(struct sock *sk, int val)
+{
+	struct smc_sock *smc = smc_sk(sk);
+
+	smc->clcsock->sk->sk_prot->keepalive(smc->clcsock->sk, val);
+}
+
+static struct proto smc_proto = {
+	.name		= "SMC",
+	.owner		= THIS_MODULE,
+	.keepalive	= smc_set_keepalive,
+	.obj_size	= sizeof(struct smc_sock),
+	.slab_flags	= SLAB_DESTROY_BY_RCU,
+};
+
+static int smc_release(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc;
+
+	if (!sk)
+		goto out;
+
+	smc = smc_sk(sk);
+	lock_sock(sk);
+
+	sk->sk_state = SMC_CLOSED;
+	if (smc->clcsock) {
+		sock_release(smc->clcsock);
+		smc->clcsock = NULL;
+	}
+
+	/* detach socket */
+	sock_set_flag(sk, SOCK_ZAPPED);
+	sock_orphan(sk);
+	sock->sk = NULL;
+	release_sock(sk);
+
+	sock_put(sk);
+out:
+	return 0;
+}
+
+static void smc_destruct(struct sock *sk)
+{
+	if (sk->sk_state != SMC_CLOSED)
+		return;
+	if (!sock_flag(sk, SOCK_DEAD))
+		return;
+
+	sk_refcnt_debug_dec(sk);
+}
+
+static struct sock *smc_sock_alloc(struct net *net, struct socket *sock)
+{
+	struct smc_sock *smc;
+	struct sock *sk;
+
+	sk = sk_alloc(net, PF_SMC, GFP_KERNEL, &smc_proto, 0);
+	if (!sk)
+		return NULL;
+
+	sock_init_data(sock, sk); /* sets sk_refcnt to 1 */
+	sk->sk_state = SMC_INIT;
+	sk->sk_destruct = smc_destruct;
+	sk->sk_protocol = SMCPROTO_SMC;
+	sk_refcnt_debug_inc(sk);
+
+	smc = smc_sk(sk);
+	smc->clcsock = NULL;
+	smc->use_fallback = 0;
+
+	return sk;
+}
+
+static int smc_bind(struct socket *sock, struct sockaddr *uaddr,
+		    int addr_len)
+{
+	struct sockaddr_in *addr = (struct sockaddr_in *)uaddr;
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc;
+	int rc;
+
+	smc = smc_sk(sk);
+
+	/* replicate tests from inet_bind(), to be safe wrt. future changes */
+	rc = -EINVAL;
+	if (addr_len < sizeof(struct sockaddr_in))
+		goto out;
+
+	rc = -EAFNOSUPPORT;
+	/* accept AF_UNSPEC (mapped to AF_INET) only if s_addr is INADDR_ANY */
+	if ((addr->sin_family != AF_INET) &&
+	    ((addr->sin_family != AF_UNSPEC) ||
+	     (addr->sin_addr.s_addr != htonl(INADDR_ANY))))
+		goto out;
+
+	lock_sock(sk);
+
+	/* Check if socket is already active */
+	rc = -EINVAL;
+	if (sk->sk_state != SMC_INIT)
+		goto out_rel;
+
+	smc->clcsock->sk->sk_reuse = sk->sk_reuse;
+	rc = kernel_bind(smc->clcsock, uaddr, addr_len);
+
+out_rel:
+	release_sock(sk);
+out:
+	return rc;
+}
+
+static void smc_copy_sock_settings(struct sock *nsk, struct sock *osk,
+				   unsigned long mask)
+{
+	/* options we don't get control via setsockopt for */
+	nsk->sk_type = osk->sk_type;
+	nsk->sk_sndbuf = osk->sk_sndbuf;
+	nsk->sk_rcvbuf = osk->sk_rcvbuf;
+	nsk->sk_sndtimeo = osk->sk_sndtimeo;
+	nsk->sk_rcvtimeo = osk->sk_rcvtimeo;
+	nsk->sk_mark = osk->sk_mark;
+	nsk->sk_priority = osk->sk_priority;
+	nsk->sk_rcvlowat = osk->sk_rcvlowat;
+	nsk->sk_bound_dev_if = osk->sk_bound_dev_if;
+	nsk->sk_err = osk->sk_err;
+
+	nsk->sk_flags &= ~mask;
+	nsk->sk_flags |= osk->sk_flags & mask;
+}
+
+#define SK_FLAGS_SMC_TO_CLC ((1UL << SOCK_URGINLINE) | \
+			     (1UL << SOCK_KEEPOPEN) | \
+			     (1UL << SOCK_LINGER) | \
+			     (1UL << SOCK_BROADCAST) | \
+			     (1UL << SOCK_TIMESTAMP) | \
+			     (1UL << SOCK_DBG) | \
+			     (1UL << SOCK_RCVTSTAMP) | \
+			     (1UL << SOCK_RCVTSTAMPNS) | \
+			     (1UL << SOCK_LOCALROUTE) | \
+			     (1UL << SOCK_TIMESTAMPING_RX_SOFTWARE) | \
+			     (1UL << SOCK_RXQ_OVFL) | \
+			     (1UL << SOCK_WIFI_STATUS) | \
+			     (1UL << SOCK_NOFCS) | \
+			     (1UL << SOCK_FILTER_LOCKED))
+/* copy only relevant settings and flags of SOL_SOCKET level from smc to
+ * clc socket (since smc is not called for these options from net/core)
+ */
+static void smc_copy_sock_settings_to_clc(struct smc_sock *smc)
+{
+	smc_copy_sock_settings(smc->clcsock->sk, &smc->sk, SK_FLAGS_SMC_TO_CLC);
+}
+
+#define SK_FLAGS_CLC_TO_SMC ((1UL << SOCK_URGINLINE) | \
+			     (1UL << SOCK_KEEPOPEN) | \
+			     (1UL << SOCK_LINGER) | \
+			     (1UL << SOCK_DBG))
+/* copy only settings and flags relevant for smc from clc to smc socket */
+static void smc_copy_sock_settings_to_smc(struct smc_sock *smc)
+{
+	smc_copy_sock_settings(&smc->sk, smc->clcsock->sk, SK_FLAGS_CLC_TO_SMC);
+}
+
+static int smc_connect(struct socket *sock, struct sockaddr *addr,
+		       int alen, int flags)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc;
+	int rc = -EINVAL;
+
+	smc = smc_sk(sk);
+
+	/* separate smc parameter checking to be safe */
+	if (alen < sizeof(addr->sa_family))
+		goto out_err;
+	if (addr->sa_family != AF_INET)
+		goto out_err;
+
+	lock_sock(sk);
+	switch (sk->sk_state) {
+	default:
+		goto out;
+	case SMC_ACTIVE:
+		rc = -EISCONN;
+		goto out;
+	case SMC_INIT:
+		rc = 0;
+		break;
+	}
+
+	smc_copy_sock_settings_to_clc(smc);
+	rc = kernel_connect(smc->clcsock, addr, alen, flags);
+	if (rc)
+		goto out;
+
+	sk->sk_state = SMC_ACTIVE;
+
+	/* always use TCP fallback as transport mechanism for now;
+	 * This will change once RDMA transport is implemented
+	 */
+	smc->use_fallback = 1;
+
+out:
+	release_sock(sk);
+out_err:
+	return rc;
+}
+
+static int smc_clcsock_accept(struct smc_sock *lsmc, struct smc_sock **new_smc)
+{
+	struct sock *sk = &lsmc->sk;
+	struct socket *new_clcsock;
+	struct sock *new_sk;
+	int rc;
+
+	new_sk = smc_sock_alloc(sock_net(sk), NULL);
+	if (!new_sk) {
+		rc = -ENOMEM;
+		lsmc->sk.sk_err = ENOMEM;
+		*new_smc = NULL;
+		goto out;
+	}
+	*new_smc = smc_sk(new_sk);
+
+	rc = kernel_accept(lsmc->clcsock, &new_clcsock, 0);
+	if (rc) {
+		sock_put(new_sk);
+		*new_smc = NULL;
+		goto out;
+	}
+
+	(*new_smc)->clcsock = new_clcsock;
+out:
+	return rc;
+}
+
+static int smc_listen(struct socket *sock, int backlog)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc;
+	int rc;
+
+	smc = smc_sk(sk);
+	lock_sock(sk);
+
+	rc = -EINVAL;
+	if ((sk->sk_state != SMC_INIT) && (sk->sk_state != SMC_LISTEN))
+		goto out;
+
+	rc = 0;
+	if (sk->sk_state == SMC_LISTEN) {
+		sk->sk_max_ack_backlog = backlog;
+		goto out;
+	}
+	/* some socket options are handled in core, so we could not apply
+	 * them to the clc socket -- copy smc socket options to clc socket
+	 */
+	smc_copy_sock_settings_to_clc(smc);
+
+	rc = kernel_listen(smc->clcsock, backlog);
+	if (rc)
+		goto out;
+	sk->sk_max_ack_backlog = backlog;
+	sk->sk_ack_backlog = 0;
+	sk->sk_state = SMC_LISTEN;
+
+out:
+	release_sock(sk);
+	return rc;
+}
+
+static int smc_accept(struct socket *sock, struct socket *new_sock,
+		      int flags)
+{
+	struct smc_sock *new_smc;
+	struct sock *sk = sock->sk;
+	struct smc_sock *lsmc;
+	int rc;
+
+	lsmc = smc_sk(sk);
+	lock_sock(sk);
+
+	if (lsmc->sk.sk_state != SMC_LISTEN) {
+		rc = -EINVAL;
+		goto out;
+	}
+
+	rc = smc_clcsock_accept(lsmc, &new_smc);
+	if (rc)
+		goto out;
+	sock_graft(&new_smc->sk, new_sock);
+	new_smc->sk.sk_state = SMC_ACTIVE;
+
+	smc_copy_sock_settings_to_smc(new_smc);
+
+	/* always use TCP fallback as transport mechanism for now;
+	 * This will change once RDMA transport is implemented
+	 */
+	new_smc->use_fallback = 1;
+
+out:
+	release_sock(sk);
+	return rc;
+}
+
+static int smc_getname(struct socket *sock, struct sockaddr *addr,
+		       int *len, int peer)
+{
+	struct smc_sock *smc;
+
+	if (peer && (sock->sk->sk_state != SMC_ACTIVE))
+		return -ENOTCONN;
+
+	smc = smc_sk(sock->sk);
+
+	return smc->clcsock->ops->getname(smc->clcsock, addr, len, peer);
+}
+
+static int smc_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc;
+	int rc = -EPIPE;
+
+	smc = smc_sk(sk);
+	lock_sock(sk);
+	if (sk->sk_state != SMC_ACTIVE)
+		goto out;
+	if (smc->use_fallback)
+		rc = smc->clcsock->ops->sendmsg(smc->clcsock, msg, len);
+	else
+		rc = sock_no_sendmsg(sock, msg, len);
+out:
+	release_sock(sk);
+	return rc;
+}
+
+static int smc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
+		       int flags)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc;
+	int rc = -ENOTCONN;
+
+	smc = smc_sk(sk);
+	lock_sock(sk);
+	if ((sk->sk_state != SMC_ACTIVE) && (sk->sk_state != SMC_CLOSED))
+		goto out;
+
+	if (smc->use_fallback)
+		rc = smc->clcsock->ops->recvmsg(smc->clcsock, msg, len, flags);
+	else
+		rc = sock_no_recvmsg(sock, msg, len, flags);
+out:
+	release_sock(sk);
+	return rc;
+}
+
+static unsigned int smc_poll(struct file *file, struct socket *sock,
+			     poll_table *wait)
+{
+	struct sock *sk = sock->sk;
+	unsigned int mask = 0;
+	struct smc_sock *smc;
+
+	smc = smc_sk(sock->sk);
+	if ((sk->sk_state == SMC_INIT) || (sk->sk_state == SMC_LISTEN) ||
+	    smc->use_fallback) {
+		mask = smc->clcsock->ops->poll(file, smc->clcsock, wait);
+		/* if non-blocking connect finished ... */
+		lock_sock(sk);
+		if ((sk->sk_state == SMC_INIT) && (mask & POLLOUT)) {
+			sk->sk_state = SMC_ACTIVE;
+			/* always use TCP fallback as transport mechanism;
+			 * This will change once RDMA transport is implemented
+			 */
+			smc->use_fallback = 1;
+		}
+		release_sock(sk);
+	} else {
+		mask = sock_no_poll(file, sock, wait);
+	}
+
+	return mask;
+}
+
+static int smc_shutdown(struct socket *sock, int how)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc;
+	int rc = -EINVAL;
+
+	smc = smc_sk(sk);
+
+	if ((how < SHUT_RD) || (how > SHUT_RDWR))
+		goto out_err;
+
+	lock_sock(sk);
+
+	rc = -ENOTCONN;
+	if (sk->sk_state == SMC_CLOSED)
+		goto out;
+	if (smc->use_fallback) {
+		rc = kernel_sock_shutdown(smc->clcsock, how);
+		sk->sk_shutdown = smc->clcsock->sk->sk_shutdown;
+		if (sk->sk_shutdown == SHUTDOWN_MASK)
+			sk->sk_state = SMC_CLOSED;
+	} else {
+		rc = sock_no_shutdown(sock, how);
+	}
+
+out:
+	release_sock(sk);
+
+out_err:
+	return rc;
+}
+
+static int smc_setsockopt(struct socket *sock, int level, int optname,
+			  char __user *optval, unsigned int optlen)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc;
+
+	smc = smc_sk(sk);
+
+	/* generic setsockopts reaching us here always apply to the
+	 * CLC socket
+	 */
+	return smc->clcsock->ops->setsockopt(smc->clcsock, level, optname,
+					     optval, optlen);
+}
+
+static int smc_getsockopt(struct socket *sock, int level, int optname,
+			  char __user *optval, int __user *optlen)
+{
+	struct smc_sock *smc;
+
+	smc = smc_sk(sock->sk);
+	/* socket options apply to the CLC socket */
+	return smc->clcsock->ops->getsockopt(smc->clcsock, level, optname,
+					     optval, optlen);
+}
+
+static int smc_ioctl(struct socket *sock, unsigned int cmd,
+		     unsigned long arg)
+{
+	struct smc_sock *smc;
+
+	smc = smc_sk(sock->sk);
+	if (smc->use_fallback)
+		return smc->clcsock->ops->ioctl(smc->clcsock, cmd, arg);
+	else
+		return sock_no_ioctl(sock, cmd, arg);
+}
+
+static ssize_t smc_sendpage(struct socket *sock, struct page *page,
+			    int offset, size_t size, int flags)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc;
+	int rc = -EPIPE;
+
+	smc = smc_sk(sk);
+	lock_sock(sk);
+	if (sk->sk_state != SMC_ACTIVE)
+		goto out;
+	if (smc->use_fallback)
+		rc = kernel_sendpage(smc->clcsock, page, offset,
+				     size, flags);
+	else
+		rc = sock_no_sendpage(sock, page, offset, size, flags);
+
+out:
+	release_sock(sk);
+	return rc;
+}
+
+static ssize_t smc_splice_read(struct socket *sock, loff_t *ppos,
+			       struct pipe_inode_info *pipe, size_t len,
+				    unsigned int flags)
+{
+	struct sock *sk = sock->sk;
+	struct smc_sock *smc;
+	int rc = -ENOTCONN;
+
+	smc = smc_sk(sk);
+	lock_sock(sk);
+	if ((sk->sk_state != SMC_ACTIVE) && (sk->sk_state != SMC_CLOSED))
+		goto out;
+	if (smc->use_fallback) {
+		rc = smc->clcsock->ops->splice_read(smc->clcsock, ppos,
+						    pipe, len, flags);
+	} else {
+		rc = -EOPNOTSUPP;
+	}
+out:
+	release_sock(sk);
+	return rc;
+}
+
+/* must look like tcp */
+static const struct proto_ops smc_sock_ops = {
+	.family		= PF_SMC,
+	.owner		= THIS_MODULE,
+	.release	= smc_release,
+	.bind		= smc_bind,
+	.connect	= smc_connect,
+	.socketpair	= sock_no_socketpair,
+	.accept		= smc_accept,
+	.getname	= smc_getname,
+	.poll		= smc_poll,
+	.ioctl		= smc_ioctl,
+	.listen		= smc_listen,
+	.shutdown	= smc_shutdown,
+	.setsockopt	= smc_setsockopt,
+	.getsockopt	= smc_getsockopt,
+	.sendmsg	= smc_sendmsg,
+	.recvmsg	= smc_recvmsg,
+	.mmap		= sock_no_mmap,
+	.sendpage	= smc_sendpage,
+	.splice_read	= smc_splice_read,
+};
+
+static int smc_create(struct net *net, struct socket *sock, int protocol,
+		      int kern)
+{
+	struct smc_sock *smc;
+	struct sock *sk;
+	int rc;
+
+	rc = -ESOCKTNOSUPPORT;
+	if (sock->type != SOCK_STREAM)
+		goto out;
+
+	rc = -EPROTONOSUPPORT;
+	if ((protocol != IPPROTO_IP) && (protocol != IPPROTO_TCP))
+		goto out;
+
+	rc = -ENOBUFS;
+	sock->ops = &smc_sock_ops;
+	sk = smc_sock_alloc(net, sock);
+	if (!sk)
+		goto out;
+
+	/* create internal TCP socket for CLC handshake and fallback */
+	smc = smc_sk(sk);
+	rc = sock_create_kern(net, PF_INET, SOCK_STREAM,
+			      IPPROTO_TCP, &smc->clcsock);
+	if (rc)
+		sk_common_release(sk);
+
+out:
+	return rc;
+}
+
+static const struct net_proto_family smc_sock_family_ops = {
+	.family	= PF_SMC,
+	.owner	= THIS_MODULE,
+	.create	= smc_create,
+};
+
+static int __init smc_init(void)
+{
+	int rc;
+
+	rc = proto_register(&smc_proto, 1);
+	if (rc) {
+		pr_err("%s: proto_register fails with %d\n", __func__, rc);
+		goto out;
+	}
+
+	rc = sock_register(&smc_sock_family_ops);
+	if (rc) {
+		pr_err("%s: sock_register fails with %d\n", __func__, rc);
+		goto out_proto;
+	}
+
+	return 0;
+
+out_proto:
+	proto_unregister(&smc_proto);
+out:
+	return rc;
+}
+
+static void __exit smc_exit(void)
+{
+	sock_unregister(PF_SMC);
+	proto_unregister(&smc_proto);
+}
+
+module_init(smc_init);
+module_exit(smc_exit);
+
+MODULE_AUTHOR("Ursula Braun <ubraun@linux.vnet.ibm.com>");
+MODULE_DESCRIPTION("smc socket address family");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NETPROTO(PF_SMC);
diff --git a/net/smc/smc.h b/net/smc/smc.h
new file mode 100644
index 0000000..f282b27
--- /dev/null
+++ b/net/smc/smc.h
@@ -0,0 +1,36 @@
+/*
+ *  Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ *  Definitions for the SMC module (socket related)
+ *
+ *  Copyright IBM Corp. 2016
+ *
+ *  Author(s):  Ursula Braun <ursula.braun@linux.vnet.ibm.com>
+ */
+#ifndef _SMC_H
+#define _SMC_H
+
+#include <linux/socket.h>
+#include <linux/types.h>
+#include <net/sock.h>
+
+#define SMCPROTO_SMC		0	/* SMC protocol */
+
+enum smc_state {		/* possible states of an SMC socket */
+	SMC_ACTIVE	= 1,
+	SMC_INIT	= 2,
+	SMC_CLOSED	= 7,
+	SMC_LISTEN	= 10,
+};
+
+struct smc_sock {				/* smc sock container */
+	struct sock		sk;
+	struct socket		*clcsock;	/* internal tcp socket */
+	u8			use_fallback : 1; /* fallback to tcp */
+};
+
+static inline struct smc_sock *smc_sk(const struct sock *sk)
+{
+	return (struct smc_sock *)sk;
+}
+#endif	/* _SMC_H */
-- 
2.6.6
