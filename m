From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH V3 net-next 15/15] smc: netlink interface for SMC sockets
Date: Thu, 24 Nov 2016 16:06:45 +0100
Message-ID: <20161124150645.90881-16-ubraun@linux.vnet.ibm.com>
References: <20161124150645.90881-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        utz.bacher@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:59329 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S966342AbcKXPHR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 10:07:17 -0500
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAOF3ipu119391
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 10:07:16 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0b-001b2d01.pphosted.com with ESMTP id 26wynpn1kr-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 10:07:16 -0500
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 24 Nov 2016 15:07:13 -0000
In-Reply-To: <20161124150645.90881-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support for SMC socket monitoring via netlink sockets of protocol
NETLINK_SOCK_DIAG.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 include/net/smc.h             |  20 ++++
 include/net/sock.h            |   3 +
 include/uapi/linux/netlink.h  |   1 +
 include/uapi/linux/smc_diag.h |  85 +++++++++++++++++
 net/smc/Kconfig               |   9 ++
 net/smc/Makefile              |   1 +
 net/smc/af_smc.c              |  43 ++++++++-
 net/smc/smc.h                 |   2 +
 net/smc/smc_close.c           |   1 +
 net/smc/smc_diag.c            | 215 ++++++++++++++++++++++++++++++++++++++++++
 10 files changed, 379 insertions(+), 1 deletion(-)
 create mode 100644 include/net/smc.h
 create mode 100644 include/uapi/linux/smc_diag.h
 create mode 100644 net/smc/smc_diag.c

diff --git a/include/net/smc.h b/include/net/smc.h
new file mode 100644
index 0000000..12d2635
--- /dev/null
+++ b/include/net/smc.h
@@ -0,0 +1,20 @@
+/*
+ *  Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ *  Definitions for the SMC module (socket related)
+ *
+ *  Copyright IBM Corp. 2016
+ *
+ *  Author(s):  Ursula Braun <ubraun@linux.vnet.ibm.com>
+ */
+#ifndef _SMC_H
+#define _SMC_H
+
+struct smc_hashinfo {
+	rwlock_t lock;
+	struct hlist_head ht;
+};
+
+int smc_hash_sk(struct sock *sk);
+void smc_unhash_sk(struct sock *sk);
+#endif	/* _SMC_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index cb4359b..e6bddcf 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -70,6 +70,7 @@
 #include <net/checksum.h>
 #include <net/tcp_states.h>
 #include <linux/net_tstamp.h>
+#include <net/smc.h>
 
 /*
  * This structure really needs to be cleaned up.
@@ -955,6 +956,7 @@ struct request_sock_ops;
 struct timewait_sock_ops;
 struct inet_hashinfo;
 struct raw_hashinfo;
+struct smc_hashinfo;
 struct module;
 
 /*
@@ -1063,6 +1065,7 @@ struct proto {
 		struct inet_hashinfo	*hashinfo;
 		struct udp_table	*udp_table;
 		struct raw_hashinfo	*raw_hash;
+		struct smc_hashinfo	*smc_hash;
 	} h;
 
 	struct module		*owner;
diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
index 0dba4e4..f3946a2 100644
--- a/include/uapi/linux/netlink.h
+++ b/include/uapi/linux/netlink.h
@@ -27,6 +27,7 @@
 #define NETLINK_ECRYPTFS	19
 #define NETLINK_RDMA		20
 #define NETLINK_CRYPTO		21	/* Crypto layer */
+#define NETLINK_SMC		22	/* SMC monitoring */
 
 #define NETLINK_INET_DIAG	NETLINK_SOCK_DIAG
 
diff --git a/include/uapi/linux/smc_diag.h b/include/uapi/linux/smc_diag.h
new file mode 100644
index 0000000..0063919
--- /dev/null
+++ b/include/uapi/linux/smc_diag.h
@@ -0,0 +1,85 @@
+#ifndef _UAPI_SMC_DIAG_H_
+#define _UAPI_SMC_DIAG_H_
+
+#include <linux/types.h>
+#include <linux/inet_diag.h>
+#include <rdma/ib_verbs.h>
+
+/* Request structure */
+struct smc_diag_req {
+	__u8	diag_family;
+	__u8	pad[2];
+	__u8	diag_ext;		/* Query extended information */
+	struct inet_diag_sockid	id;
+};
+
+/* Base info structure. It contains socket identity (addrs/ports/cookie) based
+ * on the internal clcsock, and more SMC-related socket data
+ */
+struct smc_diag_msg {
+	__u8	diag_family;
+	__u8	diag_state;
+	__u8	diag_fallback;
+	__u8	diag_shutdown;
+	struct inet_diag_sockid id;
+
+	__u32	diag_uid;
+	__u64	diag_inode;
+};
+
+/* Extensions */
+
+enum {
+	SMC_DIAG_NONE,
+	SMC_DIAG_CONNINFO,
+	SMC_DIAG_LGRINFO,
+	SMC_DIAG_SHUTDOWN,
+	__SMC_DIAG_MAX,
+};
+
+#define SMC_DIAG_MAX (__SMC_DIAG_MAX - 1)
+
+/* SMC_DIAG_CONNINFO */
+
+struct smc_diag_cursor {
+	__u16	reserved;
+	__u16	wrap;
+	__u32	count;
+};
+
+struct smc_diag_conninfo {
+	__u32			token;		/* unique connection id */
+	__u32			sndbuf_size;	/* size of send buffer */
+	__u32			rmbe_size;	/* size of RMB element */
+	__u32			peer_rmbe_size;	/* size of peer RMB element */
+	/* local RMB element cursors */
+	struct smc_diag_cursor	rx_prod;	/* received producer cursor */
+	struct smc_diag_cursor	rx_cons;	/* received consumer cursor */
+	/* peer RMB element cursors */
+	struct smc_diag_cursor	tx_prod;	/* sent producer cursor */
+	struct smc_diag_cursor	tx_cons;	/* sent consumer cursor */
+	__u8			rx_prod_flags;	/* received producer flags */
+	__u8			rx_conn_state_flags; /* recvd connection flags*/
+	__u8			tx_prod_flags;	/* sent producer flags */
+	__u8			tx_conn_state_flags; /* sent connection flags*/
+	/* send buffer cursors */
+	struct smc_diag_cursor	tx_prep;	/* prepared to be sent cursor */
+	struct smc_diag_cursor	tx_sent;	/* sent cursor */
+	struct smc_diag_cursor	tx_fin;		/* confirmed sent cursor */
+};
+
+/* SMC_DIAG_LINKINFO */
+
+struct smc_diag_linkinfo {
+	__u8 link_id;			/* link identifier */
+	__u8 ibname[IB_DEVICE_NAME_MAX]; /* name of the RDMA device */
+	__u8 ibport;			/* RDMA device port number */
+	__u8 gid[40];			/* local GID */
+	__u8 peer_gid[40];		/* peer GID */
+};
+
+struct smc_diag_lgrinfo {
+	struct smc_diag_linkinfo	lnk[1];
+	__u8				role;
+};
+#endif /* _UAPI_SMC_DIAG_H_ */
diff --git a/net/smc/Kconfig b/net/smc/Kconfig
index bc02980..c717ef0 100644
--- a/net/smc/Kconfig
+++ b/net/smc/Kconfig
@@ -9,3 +9,12 @@ config SMC
 	  a separate socket family SMC.
 
 	  Select this option if you want to run SMC socket applications
+
+config SMC_DIAG
+	tristate "SMC: socket monitoring interface"
+	depends on SMC
+	---help---
+	  Support for SMC socket monitoring interface used by tools such as
+	  smcss.
+
+	  if unsure, say Y.
diff --git a/net/smc/Makefile b/net/smc/Makefile
index 5cf0caf..1881046 100644
--- a/net/smc/Makefile
+++ b/net/smc/Makefile
@@ -1,3 +1,4 @@
 obj-$(CONFIG_SMC)	+= smc.o
+obj-$(CONFIG_SMC_DIAG)	+= smc_diag.o
 smc-y := af_smc.o smc_pnet.o smc_ib.o smc_clc.o smc_core.o smc_wr.o smc_llc.o
 smc-y += smc_cdc.o smc_tx.o smc_rx.o smc_close.o
diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index 23f7d65..53cdef6 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -29,6 +29,7 @@
 #include <linux/in.h>
 #include <net/sock.h>
 #include <net/tcp.h>
+#include <net/smc.h>
 
 #include "smc.h"
 #include "smc_clc.h"
@@ -59,13 +60,48 @@ static void smc_set_keepalive(struct sock *sk, int val)
 	smc->clcsock->sk->sk_prot->keepalive(smc->clcsock->sk, val);
 }
 
-static struct proto smc_proto = {
+static struct smc_hashinfo smc_v4_hashinfo = {
+	.lock = __RW_LOCK_UNLOCKED(smc_v4_hashinfo.lock),
+};
+
+int smc_hash_sk(struct sock *sk)
+{
+	struct smc_hashinfo *h = sk->sk_prot->h.smc_hash;
+	struct hlist_head *head;
+
+	head = &h->ht;
+
+	write_lock_bh(&h->lock);
+	sk_add_node(sk, head);
+	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
+	write_unlock_bh(&h->lock);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(smc_hash_sk);
+
+void smc_unhash_sk(struct sock *sk)
+{
+	struct smc_hashinfo *h = sk->sk_prot->h.smc_hash;
+
+	write_lock_bh(&h->lock);
+	if (sk_del_node_init(sk))
+		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
+	write_unlock_bh(&h->lock);
+}
+EXPORT_SYMBOL_GPL(smc_unhash_sk);
+
+struct proto smc_proto = {
 	.name		= "SMC",
 	.owner		= THIS_MODULE,
 	.keepalive	= smc_set_keepalive,
+	.hash		= smc_hash_sk,
+	.unhash		= smc_unhash_sk,
 	.obj_size	= sizeof(struct smc_sock),
+	.h.smc_hash	= &smc_v4_hashinfo,
 	.slab_flags	= SLAB_DESTROY_BY_RCU,
 };
+EXPORT_SYMBOL_GPL(smc_proto);
 
 static int smc_release(struct socket *sock)
 {
@@ -109,6 +145,7 @@ static int smc_release(struct socket *sock)
 		schedule_delayed_work(&smc->sock_put_work,
 				      SMC_CLOSE_SOCK_PUT_DELAY);
 	}
+	sk->sk_prot->unhash(sk);
 	release_sock(sk);
 
 	sock_put(sk);
@@ -139,6 +176,7 @@ static struct sock *smc_sock_alloc(struct net *net, struct socket *sock)
 	sk->sk_state = SMC_INIT;
 	sk->sk_destruct = smc_destruct;
 	sk->sk_protocol = SMCPROTO_SMC;
+	sk->sk_prot->hash(sk);
 	sk_refcnt_debug_inc(sk);
 
 	smc = smc_sk(sk);
@@ -546,6 +584,7 @@ static int smc_clcsock_accept(struct smc_sock *lsmc, struct smc_sock **new_smc)
 		lsmc->sk.sk_err = -rc;
 		new_sk->sk_state = SMC_CLOSED;
 		sock_set_flag(new_sk, SOCK_DEAD);
+		sk->sk_prot->unhash(new_sk);
 		sock_put(new_sk);
 		*new_smc = NULL;
 		goto out;
@@ -555,6 +594,7 @@ static int smc_clcsock_accept(struct smc_sock *lsmc, struct smc_sock **new_smc)
 			sock_release(new_clcsock);
 		new_sk->sk_state = SMC_CLOSED;
 		sock_set_flag(new_sk, SOCK_DEAD);
+		sk->sk_prot->unhash(new_sk);
 		sock_put(new_sk);
 		*new_smc = NULL;
 		goto out;
@@ -1330,6 +1370,7 @@ static int __init smc_init(void)
 		pr_err("%s: sock_register fails with %d\n", __func__, rc);
 		goto out_proto;
 	}
+	INIT_HLIST_HEAD(&smc_v4_hashinfo.ht);
 
 	rc = smc_ib_register_client();
 	if (rc) {
diff --git a/net/smc/smc.h b/net/smc/smc.h
index 963b60f..38c3644 100644
--- a/net/smc/smc.h
+++ b/net/smc/smc.h
@@ -18,6 +18,8 @@
 
 #define SMCPROTO_SMC		0	/* SMC protocol */
 
+extern struct proto smc_proto;
+
 #ifdef ATOMIC64_INIT
 #define KERNEL_HAS_ATOMIC64
 #endif
diff --git a/net/smc/smc_close.c b/net/smc/smc_close.c
index d70c05b..03dfcc6 100644
--- a/net/smc/smc_close.c
+++ b/net/smc/smc_close.c
@@ -384,6 +384,7 @@ void smc_close_sock_put_work(struct work_struct *work)
 					    struct smc_sock,
 					    sock_put_work);
 
+	smc->sk.sk_prot->unhash(&smc->sk);
 	sock_put(&smc->sk);
 }
 
diff --git a/net/smc/smc_diag.c b/net/smc/smc_diag.c
new file mode 100644
index 0000000..d2d01cf
--- /dev/null
+++ b/net/smc/smc_diag.c
@@ -0,0 +1,215 @@
+/*
+ * Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ * Monitoring SMC transport protocol sockets
+ *
+ * Copyright IBM Corp. 2016
+ *
+ * Author(s):  Ursula Braun <ubraun@linux.vnet.ibm.com>
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/init.h>
+#include <linux/sock_diag.h>
+#include <linux/inet_diag.h>
+#include <linux/smc_diag.h>
+#include <net/netlink.h>
+#include <net/smc.h>
+
+#include "smc.h"
+#include "smc_core.h"
+
+static void smc_gid_be16_convert(__u8 *buf, u8 *gid_raw)
+{
+	sprintf(buf, "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x",
+		be16_to_cpu(((__be16 *)gid_raw)[0]),
+		be16_to_cpu(((__be16 *)gid_raw)[1]),
+		be16_to_cpu(((__be16 *)gid_raw)[2]),
+		be16_to_cpu(((__be16 *)gid_raw)[3]),
+		be16_to_cpu(((__be16 *)gid_raw)[4]),
+		be16_to_cpu(((__be16 *)gid_raw)[5]),
+		be16_to_cpu(((__be16 *)gid_raw)[6]),
+		be16_to_cpu(((__be16 *)gid_raw)[7]));
+}
+
+static void smc_diag_msg_common_fill(struct smc_diag_msg *r, struct sock *sk)
+{
+	struct smc_sock *smc = smc_sk(sk);
+
+	r->diag_family = sk->sk_family;
+	if (!smc->clcsock)
+		return;
+	r->id.idiag_sport = htons(smc->clcsock->sk->sk_num);
+	r->id.idiag_dport = smc->clcsock->sk->sk_dport;
+	r->id.idiag_if = smc->clcsock->sk->sk_bound_dev_if;
+	sock_diag_save_cookie(sk, r->id.idiag_cookie);
+	memset(&r->id.idiag_src, 0, sizeof(r->id.idiag_src));
+	memset(&r->id.idiag_dst, 0, sizeof(r->id.idiag_dst));
+	r->id.idiag_src[0] = smc->clcsock->sk->sk_rcv_saddr;
+	r->id.idiag_dst[0] = smc->clcsock->sk->sk_daddr;
+}
+
+static int smc_diag_msg_attrs_fill(struct sock *sk, struct sk_buff *skb,
+				   struct smc_diag_msg *r,
+				   struct user_namespace *user_ns)
+{
+	if (nla_put_u8(skb, SMC_DIAG_SHUTDOWN, sk->sk_shutdown))
+		return 1;
+
+	r->diag_uid = from_kuid_munged(user_ns, sock_i_uid(sk));
+	r->diag_inode = sock_i_ino(sk);
+	return 0;
+}
+
+static int __smc_diag_dump(struct sock *sk, struct sk_buff *skb,
+			   struct netlink_callback *cb,
+			   const struct smc_diag_req *req,
+			   struct nlattr *bc)
+{
+	struct smc_sock *smc = smc_sk(sk);
+	struct user_namespace *user_ns;
+	struct smc_diag_msg *r;
+	struct nlmsghdr *nlh;
+
+	nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
+			cb->nlh->nlmsg_type, sizeof(*r), NLM_F_MULTI);
+	if (!nlh)
+		return -EMSGSIZE;
+
+	r = nlmsg_data(nlh);
+	smc_diag_msg_common_fill(r, sk);
+	r->diag_state = sk->sk_state;
+	r->diag_fallback = smc->use_fallback;
+	user_ns = sk_user_ns(NETLINK_CB(cb->skb).sk);
+	if (smc_diag_msg_attrs_fill(sk, skb, r, user_ns))
+		goto errout;
+
+	if ((req->diag_ext & (1 << (SMC_DIAG_CONNINFO - 1))) && smc->conn.lgr) {
+		struct smc_connection *conn = &smc->conn;
+		struct smc_diag_conninfo cinfo = {
+			.token = conn->alert_token_local,
+			.sndbuf_size = conn->sndbuf_size,
+			.rmbe_size = conn->rmbe_size,
+			.peer_rmbe_size = conn->peer_rmbe_size,
+
+			.rx_prod.wrap = conn->local_rx_ctrl.prod.wrap,
+			.rx_prod.count = conn->local_rx_ctrl.prod.count,
+			.rx_cons.wrap = conn->local_rx_ctrl.cons.wrap,
+			.rx_cons.count = conn->local_rx_ctrl.cons.count,
+
+			.tx_prod.wrap = conn->local_tx_ctrl.prod.wrap,
+			.tx_prod.count = conn->local_tx_ctrl.prod.count,
+			.tx_cons.wrap = conn->local_tx_ctrl.cons.wrap,
+			.tx_cons.count = conn->local_tx_ctrl.cons.count,
+
+			.tx_prod_flags =
+				*(u8 *)&conn->local_tx_ctrl.prod_flags,
+			.tx_conn_state_flags =
+				*(u8 *)&conn->local_tx_ctrl.conn_state_flags,
+			.rx_prod_flags = *(u8 *)&conn->local_rx_ctrl.prod_flags,
+			.rx_conn_state_flags =
+				*(u8 *)&conn->local_rx_ctrl.conn_state_flags,
+
+			.tx_prep.wrap = conn->tx_curs_prep.wrap,
+			.tx_prep.count = conn->tx_curs_prep.count,
+			.tx_sent.wrap = conn->tx_curs_sent.wrap,
+			.tx_sent.count = conn->tx_curs_sent.count,
+			.tx_fin.wrap = conn->tx_curs_fin.wrap,
+			.tx_fin.count = conn->tx_curs_fin.count,
+		};
+
+		if (nla_put(skb, SMC_DIAG_CONNINFO, sizeof(cinfo), &cinfo) < 0)
+			goto errout;
+	}
+
+	if ((req->diag_ext & (1 << (SMC_DIAG_LGRINFO - 1))) && smc->conn.lgr) {
+		struct smc_diag_lgrinfo linfo = {
+			.role = smc->conn.lgr->role,
+			.lnk[0].ibport = smc->conn.lgr->lnk[0].ibport,
+			.lnk[0].link_id = smc->conn.lgr->lnk[0].link_id,
+		};
+
+		memcpy(linfo.lnk[0].ibname,
+		       smc->conn.lgr->lnk[0].smcibdev->ibdev->name,
+		       sizeof(smc->conn.lgr->lnk[0].smcibdev->ibdev->name));
+		smc_gid_be16_convert(linfo.lnk[0].gid,
+				     smc->conn.lgr->lnk[0].gid.raw);
+		smc_gid_be16_convert(linfo.lnk[0].peer_gid,
+				     smc->conn.lgr->lnk[0].peer_gid);
+
+		if (nla_put(skb, SMC_DIAG_LGRINFO, sizeof(linfo), &linfo) < 0)
+			goto errout;
+	}
+
+	nlmsg_end(skb, nlh);
+	return 0;
+
+errout:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
+static int smc_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	struct nlattr *bc = NULL;
+	struct hlist_head *head;
+	struct sock *sk;
+	int rc = 0;
+
+	read_lock(&smc_proto.h.smc_hash->lock);
+	head = &smc_proto.h.smc_hash->ht;
+	if (hlist_empty(head))
+		goto out;
+
+	sk_for_each(sk, head) {
+		if (!net_eq(sock_net(sk), net))
+			continue;
+		rc = __smc_diag_dump(sk, skb, cb, nlmsg_data(cb->nlh), bc);
+		if (rc)
+			break;
+	}
+
+out:
+	read_unlock(&smc_proto.h.smc_hash->lock);
+	return rc;
+}
+
+static int smc_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
+{
+	struct net *net = sock_net(skb->sk);
+
+	if (h->nlmsg_type == SOCK_DIAG_BY_FAMILY &&
+	    h->nlmsg_flags & NLM_F_DUMP) {
+		{
+			struct netlink_dump_control c = {
+				.dump = smc_diag_dump,
+				.min_dump_alloc = SKB_WITH_OVERHEAD(32768),
+			};
+			return netlink_dump_start(net->diag_nlsk, skb, h, &c);
+		}
+	}
+	return 0;
+}
+
+static const struct sock_diag_handler smc_diag_handler = {
+	.family = AF_SMC,
+	.dump = smc_diag_handler_dump,
+};
+
+static int __init smc_diag_init(void)
+{
+	return sock_diag_register(&smc_diag_handler);
+}
+
+static void __exit smc_diag_exit(void)
+{
+	sock_diag_unregister(&smc_diag_handler);
+}
+
+module_init(smc_diag_init);
+module_exit(smc_diag_exit);
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, 43 /* AF_SMC */);
-- 
2.8.4
