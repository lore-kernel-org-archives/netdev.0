From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 06/15] smc: connection and link group creation
Date: Fri,  3 Jun 2016 17:27:05 +0200
Message-ID: <201606031527.u53FQ150002690@mx0a-001b2d01.pphosted.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:35195 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752798AbcFCP1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 11:27:45 -0400
Received: from pps.filterd (m0049461.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u53FQ150002690
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2016 11:27:45 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23bbsej9m8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 11:27:44 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 3 Jun 2016 16:27:41 +0100
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* create smc_connection for SMC-sockets
* determine suitable link group for a connection
* create a new link group if necessary

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/Makefile   |   2 +-
 net/smc/af_smc.c   | 103 +++++++++++++--
 net/smc/smc.h      |  35 ++++++
 net/smc/smc_clc.c  |  31 ++++-
 net/smc/smc_clc.h  |   2 +-
 net/smc/smc_core.c | 358 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/smc/smc_core.h | 105 ++++++++++++++++
 7 files changed, 620 insertions(+), 16 deletions(-)
 create mode 100644 net/smc/smc_core.c
 create mode 100644 net/smc/smc_core.h

diff --git a/net/smc/Makefile b/net/smc/Makefile
index c0ad588..cb8bcd9 100644
--- a/net/smc/Makefile
+++ b/net/smc/Makefile
@@ -1,2 +1,2 @@
 obj-$(CONFIG_SMC)	+= smc.o
-smc-y := af_smc.o smc_pnet.o smc_ib.o smc_clc.o
+smc-y := af_smc.o smc_pnet.o smc_ib.o smc_clc.o smc_core.o
diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index f8c60db..d1e9098 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -31,9 +31,19 @@
 
 #include "smc.h"
 #include "smc_clc.h"
+#include "smc_core.h"
 #include "smc_ib.h"
 #include "smc_pnet.h"
 
+static DEFINE_MUTEX(smc_create_lgr_pending);	/* serialize link group
+						 * creation
+						 */
+
+struct smc_lgr_list smc_lgr_list = {		/* established link groups */
+	.lock = __SPIN_LOCK_UNLOCKED(smc_lgr_list.lock),
+	.list = LIST_HEAD_INIT(smc_lgr_list.list),
+};
+
 static void smc_tcp_listen_work(struct work_struct *);
 
 static void smc_set_keepalive(struct sock *sk, int val)
@@ -107,6 +117,7 @@ static struct sock *smc_sock_alloc(struct net *net, struct socket *sock)
 	smc = smc_sk(sk);
 	smc->clcsock = NULL;
 	smc->use_fallback = 0;
+	memset(&smc->conn, 0, sizeof(smc->conn));
 	smc->addr = NULL;
 	smc->listen_smc = NULL;
 	INIT_WORK(&smc->tcp_listen_work, smc_tcp_listen_work);
@@ -241,11 +252,31 @@ out:
 	return rc;
 }
 
+static void smc_conn_save_peer_info(struct smc_sock *smc,
+				    struct smc_clc_msg_accept_confirm *clc)
+{
+	smc->conn.peer_conn_idx = clc->conn_idx;
+}
+
+static void smc_link_save_peer_info(struct smc_link *link,
+				    struct smc_clc_msg_accept_confirm *clc)
+{
+	link->peer_qpn = ntoh24(clc->qpn);
+	memcpy(link->peer_gid, clc->lcl.gid.raw, SMC_GID_SIZE);
+	memcpy(link->peer_mac, clc->lcl.mac, sizeof(link->peer_mac));
+	link->peer_psn = ntoh24(clc->psn);
+	link->peer_mtu = clc->qp_mtu;
+}
+
 /* setup for RDMA connection of client */
 static int smc_connect_rdma(struct smc_sock *smc)
 {
+	struct sockaddr_in *inaddr = (struct sockaddr_in *)smc->addr;
 	struct smc_clc_msg_accept_confirm aclc;
+	int local_contact = SMC_FIRST_CONTACT;
 	struct smc_ib_device *smcibdev;
+	struct smc_link *link;
+	u8 srv_first_contact;
 	int reason_code = 0;
 	int rc = 0;
 	u8 ibport;
@@ -288,26 +319,43 @@ static int smc_connect_rdma(struct smc_sock *smc)
 	if (reason_code > 0)
 		goto decline_rdma;
 
-	/* tbd in follow-on patch: more steps to setup RDMA communcication,
-	 * create connection, link group, link
-	 */
+	srv_first_contact = aclc.hdr.flag;
+	mutex_lock(&smc_create_lgr_pending);
+	local_contact = smc_conn_create(smc, inaddr->sin_addr.s_addr, smcibdev,
+					ibport, &aclc.lcl, srv_first_contact);
+	if (local_contact < 0) {
+		rc = local_contact;
+		if (rc == -ENOMEM)
+			reason_code = SMC_CLC_DECL_MEM;/* insufficient memory*/
+		else if (rc == -ENOLINK)
+			reason_code = SMC_CLC_DECL_SYNCERR; /* synchr. error */
+		goto decline_rdma_unlock;
+	}
+	link = &smc->conn.lgr->lnk[SMC_SINGLE_LINK];
 
+	smc_conn_save_peer_info(smc, &aclc);
+	if (local_contact == SMC_FIRST_CONTACT)
+		smc_link_save_peer_info(link, &aclc);
 	/* tbd in follow-on patch: more steps to setup RDMA communcication,
 	 * create rmbs, map rmbs, rtoken_handling, modify_qp
 	 */
 
 	rc = smc_clc_send_confirm(smc);
 	if (rc)
-		goto out_err;
+		goto out_err_unlock;
 
 	/* tbd in follow-on patch: llc_confirm */
 
+	mutex_unlock(&smc_create_lgr_pending);
 out_connected:
 	smc_copy_sock_settings_to_clc(smc);
 	smc->sk.sk_state = SMC_ACTIVE;
 
-	return rc;
+	return rc ? rc : local_contact;
 
+decline_rdma_unlock:
+	mutex_unlock(&smc_create_lgr_pending);
+	smc_conn_free(&smc->conn);
 decline_rdma:
 	/* RDMA setup failed, switch back to TCP */
 	smc->use_fallback = 1;
@@ -318,6 +366,9 @@ decline_rdma:
 	}
 	goto out_connected;
 
+out_err_unlock:
+	mutex_unlock(&smc_create_lgr_pending);
+	smc_conn_free(&smc->conn);
 out_err:
 	return rc;
 }
@@ -486,10 +537,12 @@ static void smc_listen_work(struct work_struct *work)
 	struct socket *newclcsock = new_smc->clcsock;
 	struct smc_sock *lsmc = new_smc->listen_smc;
 	struct smc_clc_msg_accept_confirm cclc;
+	int local_contact = SMC_REUSE_CONTACT;
 	struct sock *newsmcsk = &new_smc->sk;
 	struct smc_clc_msg_proposal pclc;
 	struct smc_ib_device *smcibdev;
 	struct sockaddr_in peeraddr;
+	struct smc_link *link;
 	int reason_code = 0;
 	int rc = 0, len;
 	__be32 subnet;
@@ -537,15 +590,30 @@ static void smc_listen_work(struct work_struct *work)
 	/* get address of the peer connected to the internal TCP socket */
 	kernel_getpeername(newclcsock, (struct sockaddr *)&peeraddr, &len);
 
-	/* tbd in follow-on patch: more steps to setup RDMA communcication,
-	 * create connection, link_group, link
-	 */
+	/* allocate connection / link group */
+	mutex_lock(&smc_create_lgr_pending);
+	local_contact = smc_conn_create(new_smc, peeraddr.sin_addr.s_addr,
+					smcibdev, ibport, &pclc.lcl, 0);
+	if (local_contact == SMC_REUSE_CONTACT)
+		/* lock no longer needed, free it due to following
+		 * smc_clc_wait_msg() call
+		 */
+		mutex_unlock(&smc_create_lgr_pending);
+	if (local_contact < 0) {
+		rc = local_contact;
+		if (rc == -ENOMEM)
+			reason_code = SMC_CLC_DECL_MEM;/* insufficient memory*/
+		else if (rc == -ENOLINK)
+			reason_code = SMC_CLC_DECL_SYNCERR; /* synchr. error */
+		goto decline_rdma;
+	}
+	link = &new_smc->conn.lgr->lnk[SMC_SINGLE_LINK];
 
 	/* tbd in follow-on patch: more steps to setup RDMA communcication,
 	 * create rmbs, map rmbs
 	 */
 
-	rc = smc_clc_send_accept(new_smc);
+	rc = smc_clc_send_accept(new_smc, local_contact);
 	if (rc)
 		goto out_err;
 
@@ -556,6 +624,9 @@ static void smc_listen_work(struct work_struct *work)
 		goto out_err;
 	if (reason_code > 0)
 		goto decline_rdma;
+	smc_conn_save_peer_info(new_smc, &cclc);
+	if (local_contact == SMC_FIRST_CONTACT)
+		smc_link_save_peer_info(link, &cclc);
 
 	/* tbd in follow-on patch: more steps to setup RDMA communcication,
 	 * rtoken_handling, modify_qp
@@ -565,6 +636,8 @@ out_connected:
 	sk_refcnt_debug_inc(newsmcsk);
 	newsmcsk->sk_state = SMC_ACTIVE;
 enqueue:
+	if (local_contact == SMC_FIRST_CONTACT)
+		mutex_unlock(&smc_create_lgr_pending);
 	lock_sock(&lsmc->sk);
 	if (lsmc->sk.sk_state == SMC_LISTEN) {
 		smc_accept_enqueue(&lsmc->sk, newsmcsk);
@@ -580,6 +653,7 @@ enqueue:
 
 decline_rdma:
 	/* RDMA setup failed, switch back to TCP */
+	smc_conn_free(&new_smc->conn);
 	new_smc->use_fallback = 1;
 	if (reason_code && (reason_code != SMC_CLC_DECL_REPLY)) {
 		rc = smc_clc_send_decline(new_smc, reason_code, 0);
@@ -1034,6 +1108,17 @@ out_pnet:
 
 static void __exit smc_exit(void)
 {
+	struct smc_link_group *lgr, *lg;
+	LIST_HEAD(lgr_freeing_list);
+
+	spin_lock_bh(&smc_lgr_list.lock);
+	if (!list_empty(&smc_lgr_list.list))
+		list_splice_init(&smc_lgr_list.list, &lgr_freeing_list);
+	spin_unlock_bh(&smc_lgr_list.lock);
+	list_for_each_entry_safe(lgr, lg, &lgr_freeing_list, list) {
+		list_del_init(&lgr->list);
+		smc_lgr_free(lgr); /* free link group */
+	}
 	smc_ib_unregister_client();
 	sock_unregister(PF_SMC);
 	proto_unregister(&smc_proto);
diff --git a/net/smc/smc.h b/net/smc/smc.h
index 8f8ed98..8736145 100644
--- a/net/smc/smc.h
+++ b/net/smc/smc.h
@@ -14,6 +14,8 @@
 #include <linux/types.h>
 #include <net/sock.h>
 
+#include "smc_ib.h"
+
 #define SMCPROTO_SMC		0	/* SMC protocol */
 
 enum smc_state {		/* possible states of an SMC socket */
@@ -23,9 +25,19 @@ enum smc_state {		/* possible states of an SMC socket */
 	SMC_LISTEN	= 10,
 };
 
+struct smc_link_group;
+
+struct smc_connection {
+	struct rb_node		alert_node;
+	struct smc_link_group	*lgr;		/* link group of connection */
+	u32			alert_token_local; /* unique conn. id */
+	u8			peer_conn_idx;	/* from tcp handshake */
+};
+
 struct smc_sock {				/* smc sock container */
 	struct sock		sk;
 	struct socket		*clcsock;	/* internal tcp socket */
+	struct smc_connection	conn;		/* smc connection */
 	struct sockaddr		*addr;		/* inet connect address */
 	struct smc_sock		*listen_smc;	/* listen parent */
 	struct work_struct	tcp_listen_work;/* handle tcp socket accepts */
@@ -45,6 +57,24 @@ static inline struct smc_sock *smc_sk(const struct sock *sk)
 
 extern u8	local_systemid[SMC_SYSTEMID_LEN]; /* unique system identifier */
 
+/* convert an u32 value into network byte order, store it into a 3 byte field */
+static inline void hton24(u8 *net, u32 host)
+{
+	__be32 t;
+
+	t = cpu_to_be32(host);
+	memcpy(net, ((u8 *)&t) + 1, 3);
+}
+
+/* convert a received 3 byte field into host byte order*/
+static inline u32 ntoh24(u8 *net)
+{
+	__be32 t = 0;
+
+	memcpy(((u8 *)&t) + 1, net, 3);
+	return be32_to_cpu(t);
+}
+
 #ifdef CONFIG_XFRM
 static inline bool using_ipsec(struct smc_sock *smc)
 {
@@ -58,6 +88,11 @@ static inline bool using_ipsec(struct smc_sock *smc)
 }
 #endif
 
+struct smc_clc_msg_local;
+
 int smc_netinfo_by_tcpsk(struct socket *, __be32 *, u8 *);
+void smc_conn_free(struct smc_connection *);
+int smc_conn_create(struct smc_sock *, __be32, struct smc_ib_device *, u8,
+		    struct smc_clc_msg_local *, int);
 
 #endif	/* _SMC_H */
diff --git a/net/smc/smc_clc.c b/net/smc/smc_clc.c
index 95c0dc4..b1d0026 100644
--- a/net/smc/smc_clc.c
+++ b/net/smc/smc_clc.c
@@ -13,6 +13,7 @@
 #include <net/tcp.h>
 
 #include "smc.h"
+#include "smc_core.h"
 #include "smc_clc.h"
 #include "smc_ib.h"
 
@@ -174,12 +175,15 @@ int smc_clc_send_proposal(struct smc_sock *smc,
 /* send CLC CONFIRM message across internal TCP socket */
 int smc_clc_send_confirm(struct smc_sock *smc)
 {
+	struct smc_connection *conn = &smc->conn;
 	struct smc_clc_msg_accept_confirm cclc;
+	struct smc_link *link;
 	int reason_code = 0;
 	struct msghdr msg;
 	struct kvec vec;
 	int len;
 
+	link = &conn->lgr->lnk[SMC_SINGLE_LINK];
 	/* send SMC Confirm CLC msg */
 	memset(&cclc, 0, sizeof(cclc));
 	memcpy(cclc.hdr.eyecatcher, SMC_EYECATCHER, sizeof(SMC_EYECATCHER));
@@ -187,12 +191,18 @@ int smc_clc_send_confirm(struct smc_sock *smc)
 	cclc.hdr.length = htons(sizeof(cclc));
 	cclc.hdr.version = SMC_CLC_V1;		/* SMC version */
 	memcpy(cclc.lcl.id_for_peer, local_systemid, sizeof(local_systemid));
-
-	/* tbd in follow-on patch: fill in link-related values */
+	memcpy(&cclc.lcl.gid, &link->smcibdev->gid[link->ibport - 1],
+	       SMC_GID_SIZE);
+	memcpy(&cclc.lcl.mac, &link->smcibdev->mac[link->ibport - 1],
+	       sizeof(link->smcibdev->mac));
 
 	/* tbd in follow-on patch: fill in rmb-related values */
 
+	hton24(cclc.qpn, link->roce_qp->qp_num);
 	cclc.conn_idx = 1; /* for now: 1 RMB = 1 RMBE */
+	cclc.rmbe_alert_token = htonl(conn->alert_token_local);
+	cclc.qp_mtu = min(link->path_mtu, link->peer_mtu);
+	hton24(cclc.psn, link->psn_initial);
 
 	memcpy(cclc.trl.eyecatcher, SMC_EYECATCHER, sizeof(SMC_EYECATCHER));
 
@@ -213,26 +223,37 @@ int smc_clc_send_confirm(struct smc_sock *smc)
 }
 
 /* send CLC ACCEPT message across internal TCP socket */
-int smc_clc_send_accept(struct smc_sock *new_smc)
+int smc_clc_send_accept(struct smc_sock *new_smc, int srv_first_contact)
 {
+	struct smc_connection *conn = &new_smc->conn;
 	struct smc_clc_msg_accept_confirm aclc;
+	struct smc_link *link;
 	struct msghdr msg;
 	struct kvec vec;
 	int rc = 0;
 	int len;
 
+	link = &conn->lgr->lnk[SMC_SINGLE_LINK];
 	memset(&aclc, 0, sizeof(aclc));
 	memcpy(aclc.hdr.eyecatcher, SMC_EYECATCHER, sizeof(SMC_EYECATCHER));
 	aclc.hdr.type = SMC_CLC_ACCEPT;
 	aclc.hdr.length = htons(sizeof(aclc));
 	aclc.hdr.version = SMC_CLC_V1;		/* SMC version */
+	if (srv_first_contact)
+		aclc.hdr.flag = 1;
 	memcpy(aclc.lcl.id_for_peer, local_systemid, sizeof(local_systemid));
-
-	/* tbd in follow-on patch: fill in link-related values */
+	memcpy(&aclc.lcl.gid, &link->smcibdev->gid[link->ibport - 1],
+	       SMC_GID_SIZE);
+	memcpy(&aclc.lcl.mac, link->smcibdev->mac[link->ibport - 1],
+	       sizeof(link->smcibdev->mac[link->ibport - 1]));
 
 	/* tbd in follow-on patch: fill in rmb-related values */
 
+	hton24(aclc.qpn, link->roce_qp->qp_num);
 	aclc.conn_idx = 1;			/* as long as 1 RMB = 1 RMBE */
+	aclc.rmbe_alert_token = htonl(conn->alert_token_local);
+	aclc.qp_mtu = link->path_mtu;
+	hton24(aclc.psn, link->psn_initial);
 	memcpy(aclc.trl.eyecatcher, SMC_EYECATCHER, sizeof(SMC_EYECATCHER));
 
 	memset(&msg, 0, sizeof(msg));
diff --git a/net/smc/smc_clc.h b/net/smc/smc_clc.h
index 565c62a..ba42f7b 100644
--- a/net/smc/smc_clc.h
+++ b/net/smc/smc_clc.h
@@ -106,6 +106,6 @@ int smc_clc_wait_msg(struct smc_sock *, void *, int, u8);
 int smc_clc_send_decline(struct smc_sock *, u32, u8);
 int smc_clc_send_proposal(struct smc_sock *, struct smc_ib_device *, u8);
 int smc_clc_send_confirm(struct smc_sock *);
-int smc_clc_send_accept(struct smc_sock *);
+int smc_clc_send_accept(struct smc_sock *, int);
 
 #endif
diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c
new file mode 100644
index 0000000..33160ce
--- /dev/null
+++ b/net/smc/smc_core.c
@@ -0,0 +1,358 @@
+/*
+ *  Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ *  Basic Transport Functions exploiting Infiniband API
+ *
+ *  Copyright IBM Corp. 2016
+ *
+ *  Author(s):  Ursula Braun <ubraun@linux.vnet.ibm.com>
+ */
+
+#include <linux/socket.h>
+#include <linux/if_vlan.h>
+#include <linux/random.h>
+#include <linux/workqueue.h>
+#include <net/tcp.h>
+#include <net/sock.h>
+#include <rdma/ib_verbs.h>
+
+#include "smc.h"
+#include "smc_clc.h"
+#include "smc_core.h"
+#include "smc_ib.h"
+
+#define SMC_LGR_FREE_DELAY	(600 * HZ)
+
+/* Register connection's alert token in our lookup structure.
+ * To use rbtrees we have to implement our own insert core.
+ * Requires @conns_lock
+ * @smc		connection to register
+ * Returns 0 on success, != otherwise.
+ */
+static void smc_lgr_add_alert_token(struct smc_connection *conn)
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
+ * Requires @conns_lock
+ * Note that '0' is a reserved value and not assigned.
+ */
+static void smc_lgr_register_conn(struct smc_connection *conn)
+{
+	struct smc_sock *smc = container_of(conn, struct smc_sock, conn);
+	static atomic_t nexttoken = ATOMIC_INIT(0);
+
+	/* find a new alert_token_local value not yet used by some connection
+	 * in this link group
+	 */
+	sock_hold(&smc->sk); /* sock_put in smc_lgr_unregister_conn() */
+	while (!conn->alert_token_local) {
+		conn->alert_token_local = atomic_inc_return(&nexttoken);
+		if (smc_lgr_find_conn(conn->alert_token_local, conn->lgr))
+			conn->alert_token_local = 0;
+	}
+	smc_lgr_add_alert_token(conn);
+	conn->lgr->conns_num++;
+}
+
+/* Unregister connection and reset the alert token of the given connection<
+ */
+static void __smc_lgr_unregister_conn(struct smc_connection *conn)
+{
+	struct smc_sock *smc = container_of(conn, struct smc_sock, conn);
+	struct smc_link_group *lgr = conn->lgr;
+
+	rb_erase(&conn->alert_node, &lgr->conns_all);
+	lgr->conns_num--;
+	conn->alert_token_local = 0;
+	conn->lgr = NULL;
+	sock_put(&smc->sk); /* sock_hold in smc_lgr_register_conn() */
+}
+
+/* Unregister connection and trigger lgr freeing if applicable
+ */
+static void smc_lgr_unregister_conn(struct smc_connection *conn)
+{
+	struct smc_link_group *lgr = conn->lgr;
+
+	if (!conn->alert_token_local)
+		return;
+
+	write_lock_bh(&lgr->conns_lock);
+	__smc_lgr_unregister_conn(conn);
+	write_unlock_bh(&lgr->conns_lock);
+	if (!lgr->conns_num)
+		schedule_delayed_work(&lgr->free_work, SMC_LGR_FREE_DELAY);
+}
+
+static void smc_lgr_free_work(struct work_struct *work)
+{
+	struct smc_link_group *lgr = container_of(to_delayed_work(work),
+						  struct smc_link_group,
+						  free_work);
+	bool conns;
+
+	spin_lock_bh(&smc_lgr_list.lock);
+	read_lock_bh(&lgr->conns_lock);
+	conns = RB_EMPTY_ROOT(&lgr->conns_all);
+	read_unlock_bh(&lgr->conns_lock);
+	if (!conns) { /* number of lgr connections is no longer zero */
+		spin_unlock_bh(&smc_lgr_list.lock);
+		return;
+	}
+	list_del_init(&lgr->list); /* remove from smc_lgr_list */
+	spin_unlock_bh(&smc_lgr_list.lock);
+	smc_lgr_free(lgr);
+}
+
+/* create a new SMC link group */
+static int smc_lgr_create(struct smc_sock *smc, __be32 peer_in_addr,
+			  struct smc_ib_device *smcibdev, u8 ibport,
+			  char *peer_systemid, unsigned short vlan_id)
+{
+	struct smc_link_group *lgr;
+	struct smc_link *lnk;
+	u8 rndvec[3];
+	int rc = 0;
+
+	lgr = kzalloc(sizeof(*lgr), GFP_KERNEL);
+	if (!lgr) {
+		rc = -ENOMEM;
+		goto out;
+	}
+	lgr->role = smc->listen_smc ? SMC_SERV : SMC_CLNT;
+	lgr->daddr = peer_in_addr;
+	memcpy(lgr->peer_systemid, peer_systemid, SMC_SYSTEMID_LEN);
+	lgr->vlan_id = vlan_id;
+	INIT_DELAYED_WORK(&lgr->free_work, smc_lgr_free_work);
+
+	lnk = &lgr->lnk[SMC_SINGLE_LINK];
+	/* initialize link */
+	lnk->smcibdev = smcibdev;
+	lnk->ibport = ibport;
+	lnk->path_mtu = smcibdev->pattr[ibport - 1].active_mtu;
+	get_random_bytes(rndvec, sizeof(rndvec));
+	lnk->psn_initial = rndvec[0] + (rndvec[1] << 8) + (rndvec[2] << 16);
+
+	smc->conn.lgr = lgr;
+	rwlock_init(&lgr->conns_lock);
+	spin_lock_bh(&smc_lgr_list.lock);
+	list_add_tail(&lgr->list, &smc_lgr_list.list);
+	spin_unlock_bh(&smc_lgr_list.lock);
+out:
+	return rc;
+}
+
+/* remove a finished connection from its link group */
+void smc_conn_free(struct smc_connection *conn)
+{
+	struct smc_link_group *lgr = conn->lgr;
+
+	if (!lgr)
+		return;
+	smc_lgr_unregister_conn(conn);
+}
+
+static void smc_link_clear(struct smc_link *lnk)
+{
+	lnk->peer_qpn = 0;
+}
+
+/* remove a link group */
+void smc_lgr_free(struct smc_link_group *lgr)
+{
+	smc_link_clear(&lgr->lnk[SMC_SINGLE_LINK]);
+	kfree(lgr);
+}
+
+/* terminate linkgroup abnormally */
+void smc_lgr_terminate(struct smc_link_group *lgr)
+{
+	struct smc_connection *conn;
+	struct rb_node *node;
+
+	spin_lock_bh(&smc_lgr_list.lock);
+	if (list_empty(&lgr->list)) {
+		/* termination already triggered */
+		spin_unlock_bh(&smc_lgr_list.lock);
+		return;
+	}
+	/* do not use this link group for new connections */
+	list_del_init(&lgr->list);
+	spin_unlock_bh(&smc_lgr_list.lock);
+
+	write_lock_bh(&lgr->conns_lock);
+	node = rb_first(&lgr->conns_all);
+	while (node) {
+		conn = rb_entry(node, struct smc_connection, alert_node);
+		__smc_lgr_unregister_conn(conn);
+		node = rb_first(&lgr->conns_all);
+	}
+	write_unlock_bh(&lgr->conns_lock);
+	schedule_delayed_work(&lgr->free_work, SMC_LGR_FREE_DELAY);
+}
+
+/* Client checks if creation / reuse of a link group happens
+ * synchronously with Server.
+ * Returns true iff client and server disagree.
+ */
+static bool smc_lgr_clt_srv_disagree(struct smc_connection *conn, int new_lgr,
+				     int srv_first_contact)
+{
+	if (!srv_first_contact && new_lgr) {
+		/* Server reuses a link group, but Client wants to start
+		 * a new one
+		 */
+		return true;
+	}
+	if (srv_first_contact && !new_lgr) {
+		/* Server starts a new link group, but Client wants to reuse
+		 * an existing link group
+		 */
+		spin_lock_bh(&smc_lgr_list.lock);
+		list_del_init(&conn->lgr->list);
+		spin_unlock_bh(&smc_lgr_list.lock);
+		smc_lgr_unregister_conn(conn); /* takes conns_lock */
+		/* tbd: terminate existing connections */
+		return true;
+	}
+	return false;
+}
+
+/* Determine vlan of internal TCP socket.
+ * @vlan_id: address to store the determined vlan id into
+ */
+static int smc_vlan_by_tcpsk(struct socket *clcsock, unsigned short *vlan_id)
+{
+	struct dst_entry *dst = sk_dst_get(clcsock->sk);
+	int rc = 0;
+
+	*vlan_id = 0;
+	if (!dst) {
+		rc = -ENOTCONN;
+		goto out;
+	}
+	if (!dst->dev) {
+		rc = -ENODEV;
+		goto out_rel;
+	}
+
+	if (is_vlan_dev(dst->dev))
+		*vlan_id = vlan_dev_vlan_id(dst->dev);
+
+out_rel:
+	dst_release(dst);
+out:
+	return rc;
+}
+
+/* determine the link gid matching the vlan id of the link group */
+static int smc_link_determine_gid(struct smc_link_group *lgr)
+{
+	struct smc_link *lnk = &lgr->lnk[SMC_SINGLE_LINK];
+	struct ib_gid_attr gattr;
+	union ib_gid gid;
+	int i;
+
+	if (!lgr->vlan_id) {
+		lnk->gid = lnk->smcibdev->gid[lnk->ibport - 1];
+		return 0;
+	}
+
+	for (i = 0; i < lnk->smcibdev->pattr[lnk->ibport - 1].gid_tbl_len;
+	     i++) {
+		if (ib_query_gid(lnk->smcibdev->ibdev, lnk->ibport, i, &gid,
+				 &gattr))
+			continue;
+		if (gattr.ndev &&
+		    (vlan_dev_vlan_id(gattr.ndev) == lgr->vlan_id)) {
+			lnk->gid = gid;
+			return 0;
+		}
+	}
+	return -ENODEV;
+}
+
+/* create a new SMC connection (and a new link group if necessary) */
+int smc_conn_create(struct smc_sock *smc, __be32 peer_in_addr,
+		    struct smc_ib_device *smcibdev, u8 ibport,
+		    struct smc_clc_msg_local *lcl, int srv_first_contact)
+{
+	struct smc_connection *conn = &smc->conn;
+	struct smc_link_group *lgr;
+	unsigned short vlan_id;
+	enum smc_lgr_role role;
+	int local_contact = SMC_FIRST_CONTACT;
+	int rc = 0;
+
+	/* wait when another process is already creating a connection
+	 * till either this process can reuse an existing link group or
+	 * till this process has finished creating a new link group
+	 */
+	role = smc->listen_smc ? SMC_SERV : SMC_CLNT;
+	rc = smc_vlan_by_tcpsk(smc->clcsock, &vlan_id);
+	if (rc)
+		return rc;
+
+	/* determine if an existing link group can be reused */
+	spin_lock_bh(&smc_lgr_list.lock);
+	list_for_each_entry(lgr, &smc_lgr_list.list, list) {
+		write_lock_bh(&lgr->conns_lock);
+		if (!memcmp(lgr->peer_systemid, lcl->id_for_peer,
+			    SMC_SYSTEMID_LEN) &&
+		    !memcmp(lgr->lnk[SMC_SINGLE_LINK].peer_gid, &lcl->gid,
+			    SMC_GID_SIZE) &&
+		    !memcmp(lgr->lnk[SMC_SINGLE_LINK].peer_mac, lcl->mac,
+			    sizeof(lcl->mac)) &&
+		    (lgr->role == role) &&
+		    (lgr->vlan_id == vlan_id)) {
+			/* link group found */
+			local_contact = SMC_REUSE_CONTACT;
+			conn->lgr = lgr;
+			smc_lgr_register_conn(conn); /* add smc conn to lgr */
+			write_unlock_bh(&lgr->conns_lock);
+			break;
+		}
+		write_unlock_bh(&lgr->conns_lock);
+	}
+	spin_unlock_bh(&smc_lgr_list.lock);
+
+	if (role == SMC_CLNT) {
+		if (smc_lgr_clt_srv_disagree(conn, local_contact,
+					     srv_first_contact)) {
+			/* send out_of_sync decline, reason synchr. error */
+			smc->sk.sk_err = ENOLINK;
+			return -ENOLINK;
+		}
+	}
+
+	if (local_contact == SMC_FIRST_CONTACT) {
+		rc = smc_lgr_create(smc, peer_in_addr, smcibdev, ibport,
+				    lcl->id_for_peer, vlan_id);
+		if (rc)
+			goto out;
+		smc_lgr_register_conn(conn); /* add smc conn to lgr */
+		rc = smc_link_determine_gid(conn->lgr);
+	}
+
+out:
+	return rc ? rc : local_contact;
+}
diff --git a/net/smc/smc_core.h b/net/smc/smc_core.h
new file mode 100644
index 0000000..c43c6f5
--- /dev/null
+++ b/net/smc/smc_core.h
@@ -0,0 +1,105 @@
+/*
+ * Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ *  Definitions for SMC Connections, Link Groups and Links
+ *
+ *  Copyright IBM Corp. 2016
+ *
+ *  Author(s):  Ursula Braun <ubraun@linux.vnet.ibm.com>
+ */
+
+#ifndef _SMC_CORE_H
+#define _SMC_CORE_H
+
+#include <rdma/ib_verbs.h>
+
+#include "smc.h"
+#include "smc_ib.h"
+
+struct smc_lgr_list {			/* list of link group definition */
+	struct list_head	list;
+	spinlock_t		lock;	/* protects list of link groups */
+};
+
+extern struct smc_lgr_list	smc_lgr_list; /* list of link groups */
+
+enum smc_lgr_role {		/* possible roles of a link group */
+	SMC_CLNT,	/* client */
+	SMC_SERV	/* server */
+};
+
+struct smc_link {
+	struct smc_ib_device	*smcibdev;	/* ib-device */
+	u8			ibport;		/* port - values 1 | 2 */
+	struct ib_qp		*roce_qp;	/* IB queue pair */
+	struct ib_qp_attr	qp_attr;	/* IB queue pair attributes */
+	union ib_gid		gid;		/* gid matching used vlan id */
+	u32			peer_qpn;	/* QP number of peer */
+	enum ib_mtu		path_mtu;	/* used mtu */
+	enum ib_mtu		peer_mtu;	/* mtu size of peer */
+	u32			psn_initial;	/* QP tx initial packet seqno */
+	u32			peer_psn;	/* QP rx initial packet seqno */
+	u8			peer_mac[ETH_ALEN];	/* = gid[8:10||13:15] */
+	u8			peer_gid[sizeof(union ib_gid)];	/* gid of peer*/
+};
+
+/* For now we just allow one parallel link per link group. The SMC protocol
+ * allows more (up to 8).
+ */
+#define SMC_LINKS_PER_LGR_MAX	1
+#define SMC_SINGLE_LINK		0
+
+#define SMC_FIRST_CONTACT	1		/* first contact to a peer */
+#define SMC_REUSE_CONTACT	0		/* follow-on contact to a peer*/
+
+struct smc_link_group {
+	struct list_head	list;
+	enum smc_lgr_role	role;		/* client or server */
+	__be32			daddr;		/* destination ip address */
+	struct smc_link		lnk[SMC_LINKS_PER_LGR_MAX];	/* smc link */
+	char			peer_systemid[SMC_SYSTEMID_LEN];
+						/* unique system_id of peer */
+	struct rb_root		conns_all;	/* connection tree */
+	rwlock_t		conns_lock;	/* protects conns_all */
+	unsigned int		conns_num;	/* current # of connections */
+	unsigned short		vlan_id;	/* vlan id of link group */
+	struct delayed_work	free_work;	/* delayed freeing of an lgr */
+};
+
+/* Find the connection associated with the given alert token in the link group.
+ * To use rbtrees we have to implement our own search core.
+ * Requires @conns_lock
+ * @token	alert token to search for
+ * @lgr		 link group to search in
+ * Returns connection associated with token if found, NULL otherwise.
+ */
+static inline struct smc_connection *smc_lgr_find_conn(
+	u32 token, struct smc_link_group *lgr)
+{
+	struct smc_connection *res = NULL;
+	struct rb_node *node;
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
+void smc_lgr_free(struct smc_link_group *);
+void smc_lgr_terminate(struct smc_link_group *);
+
+#endif
-- 
2.6.6
