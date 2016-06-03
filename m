From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 07/15] smc: remote memory buffers (RMBs)
Date: Fri,  3 Jun 2016 17:27:06 +0200
Message-ID: <201606031527.u53FQ73m045290@mx0a-001b2d01.pphosted.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:7216 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752290AbcFCP1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 11:27:46 -0400
Received: from pps.filterd (m0082756.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u53FQ73m045290
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2016 11:27:46 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23b4m8q6bb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 11:27:45 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 3 Jun 2016 16:27:42 +0100
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* allocate data RMB memory for sending and receiving
* size depends on the maximum socket send and receive buffers
* allocated RMBs are kept during life time of the owning link group
* map the allocated RMBs to DMA

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/af_smc.c   |  29 ++++++-
 net/smc/smc.h      |  45 +++++++++++
 net/smc/smc_clc.c  |   6 +-
 net/smc/smc_core.c | 223 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 net/smc/smc_core.h |  20 +++++
 net/smc/smc_ib.c   |  19 +++++
 net/smc/smc_ib.h   |   5 ++
 7 files changed, 340 insertions(+), 7 deletions(-)

diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index d1e9098..3481eea 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -256,6 +256,8 @@ static void smc_conn_save_peer_info(struct smc_sock *smc,
 				    struct smc_clc_msg_accept_confirm *clc)
 {
 	smc->conn.peer_conn_idx = clc->conn_idx;
+	smc->conn.peer_rmbe_len = smc_uncompress_bufsize(clc->rmbe_size);
+	atomic_set(&smc->conn.peer_rmbe_space, smc->conn.peer_rmbe_len);
 }
 
 static void smc_link_save_peer_info(struct smc_link *link,
@@ -334,6 +336,18 @@ static int smc_connect_rdma(struct smc_sock *smc)
 	link = &smc->conn.lgr->lnk[SMC_SINGLE_LINK];
 
 	smc_conn_save_peer_info(smc, &aclc);
+
+	rc = smc_sndbuf_create(smc);
+	if (rc) {
+		reason_code = SMC_CLC_DECL_MEM;
+		goto decline_rdma_unlock;
+	}
+	rc = smc_rmb_create(smc);
+	if (rc) {
+		reason_code = SMC_CLC_DECL_MEM;
+		goto decline_rdma_unlock;
+	}
+
 	if (local_contact == SMC_FIRST_CONTACT)
 		smc_link_save_peer_info(link, &aclc);
 	/* tbd in follow-on patch: more steps to setup RDMA communcication,
@@ -609,9 +623,16 @@ static void smc_listen_work(struct work_struct *work)
 	}
 	link = &new_smc->conn.lgr->lnk[SMC_SINGLE_LINK];
 
-	/* tbd in follow-on patch: more steps to setup RDMA communcication,
-	 * create rmbs, map rmbs
-	 */
+	rc = smc_sndbuf_create(new_smc);
+	if (rc) {
+		reason_code = SMC_CLC_DECL_MEM;
+		goto decline_rdma;
+	}
+	rc = smc_rmb_create(new_smc);
+	if (rc) {
+		reason_code = SMC_CLC_DECL_MEM;
+		goto decline_rdma;
+	}
 
 	rc = smc_clc_send_accept(new_smc, local_contact);
 	if (rc)
@@ -1058,6 +1079,8 @@ static int smc_create(struct net *net, struct socket *sock, int protocol,
 			      IPPROTO_TCP, &smc->clcsock);
 	if (rc)
 		sk_common_release(sk);
+	smc->sk.sk_sndbuf = max(smc->clcsock->sk->sk_sndbuf, SMC_BUF_MIN_SIZE);
+	smc->sk.sk_rcvbuf = max(smc->clcsock->sk->sk_rcvbuf, SMC_BUF_MIN_SIZE);
 
 out:
 	return rc;
diff --git a/net/smc/smc.h b/net/smc/smc.h
index 8736145..914f3da 100644
--- a/net/smc/smc.h
+++ b/net/smc/smc.h
@@ -32,6 +32,16 @@ struct smc_connection {
 	struct smc_link_group	*lgr;		/* link group of connection */
 	u32			alert_token_local; /* unique conn. id */
 	u8			peer_conn_idx;	/* from tcp handshake */
+	int			peer_rmbe_len;	/* size of peer rx buffer */
+	atomic_t		peer_rmbe_space;/* remaining free bytes in peer
+						 * rmbe
+						 */
+
+	struct smc_buf_desc	*sndbuf_desc;	/* send buffer descriptor */
+	int			sndbuf_size;	/* sndbuf size <== sock wmem */
+	struct smc_buf_desc	*rmb_desc;	/* RMBE descriptor */
+	int			rmbe_size;	/* RMBE size <== sock rmem */
+	int			rmbe_size_short;/* compressed notation */
 };
 
 struct smc_sock {				/* smc sock container */
@@ -75,6 +85,41 @@ static inline u32 ntoh24(u8 *net)
 	return be32_to_cpu(t);
 }
 
+#define SMC_BUF_MIN_SIZE 16384		/* minimum size of an RMB */
+
+#define SMC_RMBE_SIZES	16	/* number of distinct sizes for an RMBE */
+/* theoretically, the RFC states that largest size would be 512K,
+ * i.e. compressed 5 and thus 6 sizes (0..5), despite
+ * struct smc_clc_msg_accept_confirm.rmbe_size being a 4 bit value (0..15)
+ */
+
+/* convert the RMB size into the compressed notation - minimum 16K.
+ * In contrast to plain ilog2, this rounds towards the next power of 2,
+ * so the socket application gets at least its desired sndbuf / rcvbuf size.
+ */
+static inline u8 smc_compress_bufsize(int size)
+{
+	u8 compressed;
+
+	if (size <= SMC_BUF_MIN_SIZE)
+		return 0;
+
+	size = (size - 1) >> 14;
+	compressed = ilog2(size) + 1;
+	if (compressed >= SMC_RMBE_SIZES)
+		compressed = SMC_RMBE_SIZES - 1;
+	return compressed;
+}
+
+/* convert the RMB size from compressed notation into integer */
+static inline int smc_uncompress_bufsize(u8 compressed)
+{
+	u32 size;
+
+	size = 0x00000001 << (((int)compressed) + 14);
+	return (int)size;
+}
+
 #ifdef CONFIG_XFRM
 static inline bool using_ipsec(struct smc_sock *smc)
 {
diff --git a/net/smc/smc_clc.c b/net/smc/smc_clc.c
index b1d0026..2360b8d 100644
--- a/net/smc/smc_clc.c
+++ b/net/smc/smc_clc.c
@@ -246,13 +246,13 @@ int smc_clc_send_accept(struct smc_sock *new_smc, int srv_first_contact)
 	       SMC_GID_SIZE);
 	memcpy(&aclc.lcl.mac, link->smcibdev->mac[link->ibport - 1],
 	       sizeof(link->smcibdev->mac[link->ibport - 1]));
-
-	/* tbd in follow-on patch: fill in rmb-related values */
-
 	hton24(aclc.qpn, link->roce_qp->qp_num);
 	aclc.conn_idx = 1;			/* as long as 1 RMB = 1 RMBE */
 	aclc.rmbe_alert_token = htonl(conn->alert_token_local);
 	aclc.qp_mtu = link->path_mtu;
+	aclc.rmbe_size = conn->rmbe_size_short,
+	aclc.rmb_dma_addr =
+		cpu_to_be64((u64)conn->rmb_desc->dma_addr[SMC_SINGLE_LINK]);
 	hton24(aclc.psn, link->psn_initial);
 	memcpy(aclc.trl.eyecatcher, SMC_EYECATCHER, sizeof(SMC_EYECATCHER));
 
diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c
index 33160ce..53d7fd9 100644
--- a/net/smc/smc_core.c
+++ b/net/smc/smc_core.c
@@ -132,6 +132,7 @@ static int smc_lgr_create(struct smc_sock *smc, __be32 peer_in_addr,
 	struct smc_link *lnk;
 	u8 rndvec[3];
 	int rc = 0;
+	int i;
 
 	lgr = kzalloc(sizeof(*lgr), GFP_KERNEL);
 	if (!lgr) {
@@ -142,6 +143,12 @@ static int smc_lgr_create(struct smc_sock *smc, __be32 peer_in_addr,
 	lgr->daddr = peer_in_addr;
 	memcpy(lgr->peer_systemid, peer_systemid, SMC_SYSTEMID_LEN);
 	lgr->vlan_id = vlan_id;
+	rwlock_init(&lgr->sndbufs_lock);
+	rwlock_init(&lgr->rmbs_lock);
+	for (i = 0; i < SMC_RMBE_SIZES; i++) {
+		INIT_LIST_HEAD(&lgr->sndbufs[i]);
+		INIT_LIST_HEAD(&lgr->rmbs[i]);
+	}
 	INIT_DELAYED_WORK(&lgr->free_work, smc_lgr_free_work);
 
 	lnk = &lgr->lnk[SMC_SINGLE_LINK];
@@ -161,6 +168,22 @@ out:
 	return rc;
 }
 
+static void smc_sndbuf_unuse(struct smc_connection *conn)
+{
+	if (conn->sndbuf_desc) {
+		xchg(&conn->sndbuf_desc->used, 0);
+		conn->sndbuf_size = 0;
+	}
+}
+
+static void smc_rmb_unuse(struct smc_connection *conn)
+{
+	if (conn->rmb_desc) {
+		xchg(&conn->rmb_desc->used, 0);
+		conn->rmbe_size = 0;
+	}
+}
+
 /* remove a finished connection from its link group */
 void smc_conn_free(struct smc_connection *conn)
 {
@@ -169,6 +192,8 @@ void smc_conn_free(struct smc_connection *conn)
 	if (!lgr)
 		return;
 	smc_lgr_unregister_conn(conn);
+	smc_rmb_unuse(conn);
+	smc_sndbuf_unuse(conn);
 }
 
 static void smc_link_clear(struct smc_link *lnk)
@@ -176,9 +201,39 @@ static void smc_link_clear(struct smc_link *lnk)
 	lnk->peer_qpn = 0;
 }
 
+static void smc_lgr_free_sndbufs(struct smc_link_group *lgr)
+{
+	struct smc_buf_desc *sndbuf_desc, *bf_desc;
+	int i;
+
+	for (i = 0; i < SMC_RMBE_SIZES; i++) {
+		list_for_each_entry_safe(sndbuf_desc, bf_desc, &lgr->sndbufs[i],
+					 list) {
+			kfree(sndbuf_desc->cpu_addr);
+			kfree(sndbuf_desc);
+		}
+	}
+}
+
+static void smc_lgr_free_rmbs(struct smc_link_group *lgr)
+{
+	struct smc_buf_desc *rmb_desc, *bf_desc;
+	int i;
+
+	for (i = 0; i < SMC_RMBE_SIZES; i++) {
+		list_for_each_entry_safe(rmb_desc, bf_desc, &lgr->rmbs[i],
+					 list) {
+			kfree(rmb_desc->cpu_addr);
+			kfree(rmb_desc);
+		}
+	}
+}
+
 /* remove a link group */
 void smc_lgr_free(struct smc_link_group *lgr)
 {
+	smc_lgr_free_rmbs(lgr);
+	smc_lgr_free_sndbufs(lgr);
 	smc_link_clear(&lgr->lnk[SMC_SINGLE_LINK]);
 	kfree(lgr);
 }
@@ -323,7 +378,8 @@ int smc_conn_create(struct smc_sock *smc, __be32 peer_in_addr,
 		    !memcmp(lgr->lnk[SMC_SINGLE_LINK].peer_mac, lcl->mac,
 			    sizeof(lcl->mac)) &&
 		    (lgr->role == role) &&
-		    (lgr->vlan_id == vlan_id)) {
+		    (lgr->vlan_id == vlan_id) &&
+		    (lgr->conns_num < SMC_RMBS_PER_LGR_MAX)) {
 			/* link group found */
 			local_contact = SMC_REUSE_CONTACT;
 			conn->lgr = lgr;
@@ -356,3 +412,168 @@ int smc_conn_create(struct smc_sock *smc, __be32 peer_in_addr,
 out:
 	return rc ? rc : local_contact;
 }
+
+/* try to reuse a sndbuf description slot of the sndbufs list for a certain
+ * buf_size; if not available, return NULL
+ */
+static inline
+struct smc_buf_desc *smc_sndbuf_get_slot(struct smc_link_group *lgr,
+					 int compressed_bufsize)
+{
+	struct smc_buf_desc *sndbuf_slot;
+
+	read_lock_bh(&lgr->sndbufs_lock);
+	list_for_each_entry(sndbuf_slot, &lgr->sndbufs[compressed_bufsize],
+			    list) {
+		if (cmpxchg(&sndbuf_slot->used, 0, 1) == 0) {
+			read_unlock_bh(&lgr->sndbufs_lock);
+			return sndbuf_slot;
+		}
+	}
+	read_unlock_bh(&lgr->sndbufs_lock);
+	return NULL;
+}
+
+/* try to reuse an rmb description slot of the rmbs list for a certain
+ * rmbe_size; if not available, return NULL
+ */
+static inline
+struct smc_buf_desc *smc_rmb_get_slot(struct smc_link_group *lgr,
+				      int compressed_bufsize)
+{
+	struct smc_buf_desc *rmb_slot;
+
+	read_lock_bh(&lgr->rmbs_lock);
+	list_for_each_entry(rmb_slot, &lgr->rmbs[compressed_bufsize],
+			    list) {
+		if (cmpxchg(&rmb_slot->used, 0, 1) == 0) {
+			read_unlock_bh(&lgr->rmbs_lock);
+			return rmb_slot;
+		}
+	}
+	read_unlock_bh(&lgr->rmbs_lock);
+	return NULL;
+}
+
+/* create the tx buffer for an SMC socket */
+int smc_sndbuf_create(struct smc_sock *smc)
+{
+	struct smc_connection *conn = &smc->conn;
+	struct smc_link_group *lgr = conn->lgr;
+	int tmp_bufsize, tmp_bufsize_short;
+	struct smc_buf_desc *sndbuf_desc;
+	int rc;
+
+	/* use socket send buffer size (w/o overhead) as start value */
+	for (tmp_bufsize_short = smc_compress_bufsize(smc->sk.sk_sndbuf / 2);
+	     tmp_bufsize_short >= 0; tmp_bufsize_short--) {
+		tmp_bufsize = smc_uncompress_bufsize(tmp_bufsize_short);
+		/* check for reusable sndbuf_slot in the link group */
+		sndbuf_desc = smc_sndbuf_get_slot(lgr, tmp_bufsize_short);
+		if (sndbuf_desc) {
+			memset(sndbuf_desc->cpu_addr, 0, tmp_bufsize);
+			break; /* found reusable slot */
+		}
+		/* try to alloc a new send buffer */
+		sndbuf_desc = kzalloc(sizeof(*sndbuf_desc), GFP_KERNEL);
+		if (!sndbuf_desc)
+			break; /* give up with -ENOMEM */
+		sndbuf_desc->cpu_addr = kzalloc(tmp_bufsize,
+						GFP_KERNEL | __GFP_NOWARN |
+						__GFP_NOMEMALLOC |
+						__GFP_NORETRY);
+		if (!sndbuf_desc->cpu_addr) {
+			kfree(sndbuf_desc);
+			/* if send buffer allocation has failed,
+			 * try a smaller one
+			 */
+			continue;
+		}
+		rc = smc_ib_buf_map(lgr->lnk[SMC_SINGLE_LINK].smcibdev,
+				    tmp_bufsize, sndbuf_desc,
+				    DMA_TO_DEVICE);
+		if (rc) {
+			kfree(sndbuf_desc->cpu_addr);
+			kfree(sndbuf_desc);
+			continue; /* if mapping failed, try smaller one */
+		}
+		sndbuf_desc->used = 1;
+		write_lock_bh(&lgr->sndbufs_lock);
+		list_add(&sndbuf_desc->list,
+			 &lgr->sndbufs[tmp_bufsize_short]);
+		write_unlock_bh(&lgr->sndbufs_lock);
+		break;
+	}
+	if (sndbuf_desc && sndbuf_desc->cpu_addr) {
+		conn->sndbuf_desc = sndbuf_desc;
+		conn->sndbuf_size = tmp_bufsize;
+		smc->sk.sk_sndbuf = tmp_bufsize * 2;
+		return 0;
+	} else {
+		return -ENOMEM;
+	}
+}
+
+/* create the RMB for an SMC socket (even though the SMC protocol
+ * allows more than one RMB-element per RMB, the Linux implementation
+ * uses just one RMB-element per RMB, i.e. uses an extra RMB for every
+ * connection in a link group
+ */
+int smc_rmb_create(struct smc_sock *smc)
+{
+	struct smc_connection *conn = &smc->conn;
+	struct smc_link_group *lgr = conn->lgr;
+	int tmp_bufsize, tmp_bufsize_short;
+	struct smc_buf_desc *rmb_desc;
+	int rc;
+
+	/* use socket recv buffer size (w/o overhead) as start value */
+	for (tmp_bufsize_short = smc_compress_bufsize(smc->sk.sk_rcvbuf / 2);
+	     tmp_bufsize_short >= 0; tmp_bufsize_short--) {
+		tmp_bufsize = smc_uncompress_bufsize(tmp_bufsize_short);
+		/* check for reusable rmb_slot in the link group */
+		rmb_desc = smc_rmb_get_slot(lgr, tmp_bufsize_short);
+		if (rmb_desc) {
+			memset(rmb_desc->cpu_addr, 0, tmp_bufsize);
+			break; /* found reusable slot */
+		}
+		/* try to alloc a new RMB */
+		rmb_desc = kzalloc(sizeof(*rmb_desc), GFP_KERNEL);
+		if (!rmb_desc)
+			break; /* give up with -ENOMEM */
+		rmb_desc->cpu_addr = kzalloc(tmp_bufsize,
+					     GFP_KERNEL | __GFP_NOWARN |
+					     __GFP_NOMEMALLOC |
+					     __GFP_NORETRY);
+		if (!rmb_desc->cpu_addr) {
+			kfree(rmb_desc);
+			/* if RMB allocation has failed,
+			 * try a smaller one
+			 */
+			continue;
+		}
+		rc = smc_ib_buf_map(lgr->lnk[SMC_SINGLE_LINK].smcibdev,
+				    tmp_bufsize, rmb_desc,
+				    DMA_FROM_DEVICE);
+		if (rc) {
+			kfree(rmb_desc->cpu_addr);
+			kfree(rmb_desc);
+			continue; /* if mapping failed, try smaller one */
+		}
+		rmb_desc->used = 1;
+		write_lock_bh(&lgr->rmbs_lock);
+		list_add(&rmb_desc->list,
+			 &lgr->rmbs[tmp_bufsize_short]);
+		write_unlock_bh(&lgr->rmbs_lock);
+		break;
+	}
+	if (rmb_desc && rmb_desc->cpu_addr) {
+		conn->rmb_desc = rmb_desc;
+		conn->rmbe_size = tmp_bufsize;
+		conn->rmbe_size_short = tmp_bufsize_short;
+		smc->sk.sk_rcvbuf = tmp_bufsize * 2;
+		return 0;
+	} else {
+		return -ENOMEM;
+	}
+}
diff --git a/net/smc/smc_core.h b/net/smc/smc_core.h
index c43c6f5..ad9b16d 100644
--- a/net/smc/smc_core.h
+++ b/net/smc/smc_core.h
@@ -16,6 +16,8 @@
 #include "smc.h"
 #include "smc_ib.h"
 
+#define SMC_RMBS_PER_LGR_MAX	255	/* max. # of RMBs per link group */
+
 struct smc_lgr_list {			/* list of link group definition */
 	struct list_head	list;
 	spinlock_t		lock;	/* protects list of link groups */
@@ -52,6 +54,15 @@ struct smc_link {
 #define SMC_FIRST_CONTACT	1		/* first contact to a peer */
 #define SMC_REUSE_CONTACT	0		/* follow-on contact to a peer*/
 
+/* tx/rx buffer list element for sndbufs list and rmbs list of a lgr */
+struct smc_buf_desc {
+	struct list_head	list;
+	u64			dma_addr[SMC_LINKS_PER_LGR_MAX];
+						/* mapped address of buffer */
+	void			*cpu_addr;	/* virtual address of buffer */
+	u32			used;		/* currently used / unused */
+};
+
 struct smc_link_group {
 	struct list_head	list;
 	enum smc_lgr_role	role;		/* client or server */
@@ -63,6 +74,11 @@ struct smc_link_group {
 	rwlock_t		conns_lock;	/* protects conns_all */
 	unsigned int		conns_num;	/* current # of connections */
 	unsigned short		vlan_id;	/* vlan id of link group */
+
+	struct list_head	sndbufs[SMC_RMBE_SIZES];/* tx buffers */
+	rwlock_t		sndbufs_lock;	/* protects tx buffers */
+	struct list_head	rmbs[SMC_RMBE_SIZES];	/* rx buffers */
+	rwlock_t		rmbs_lock;	/* protects rx buffers */
 	struct delayed_work	free_work;	/* delayed freeing of an lgr */
 };
 
@@ -99,7 +115,11 @@ static inline struct smc_connection *smc_lgr_find_conn(
 	return res;
 }
 
+struct smc_clc_msg_accept_confirm;
+
 void smc_lgr_free(struct smc_link_group *);
 void smc_lgr_terminate(struct smc_link_group *);
+int smc_sndbuf_create(struct smc_sock *);
+int smc_rmb_create(struct smc_sock *);
 
 #endif
diff --git a/net/smc/smc_ib.c b/net/smc/smc_ib.c
index 8b6bb50..9ca1412 100644
--- a/net/smc/smc_ib.c
+++ b/net/smc/smc_ib.c
@@ -16,6 +16,7 @@
 
 #include "smc_pnet.h"
 #include "smc_ib.h"
+#include "smc_core.h"
 #include "smc.h"
 
 struct smc_ib_devices smc_ib_devices = {	/* smc-registered ib devices */
@@ -29,6 +30,24 @@ u8 local_systemid[SMC_SYSTEMID_LEN] = SMC_LOCAL_SYSTEMID_RESET;	/* unique system
 								 * identifier
 								 */
 
+/* map a new TX or RX buffer to DMA */
+int smc_ib_buf_map(struct smc_ib_device *smcibdev, int buf_size,
+		   struct smc_buf_desc *buf_slot,
+		   enum dma_data_direction data_direction)
+{
+	int rc = 0;
+
+	if (buf_slot->dma_addr[SMC_SINGLE_LINK])
+		return rc; /* already mapped */
+	buf_slot->dma_addr[SMC_SINGLE_LINK] =
+		ib_dma_map_single(smcibdev->ibdev, buf_slot->cpu_addr,
+				  buf_size, data_direction);
+	if (ib_dma_mapping_error(smcibdev->ibdev,
+				 buf_slot->dma_addr[SMC_SINGLE_LINK]))
+		rc = -EIO;
+	return rc;
+}
+
 static int smc_ib_fill_gid_and_mac(struct smc_ib_device *smcibdev, u8 ibport)
 {
 	struct net_device *ndev;
diff --git a/net/smc/smc_ib.h b/net/smc/smc_ib.h
index a1ca04f..57167af 100644
--- a/net/smc/smc_ib.h
+++ b/net/smc/smc_ib.h
@@ -32,9 +32,14 @@ struct smc_ib_device {				/* ib-device infos for smc */
 	u8			initialized : 1; /* ib dev CQ, evthdl done */
 };
 
+struct smc_sock;
+struct smc_buf_desc;
+
 int smc_ib_register_client(void) __init;
 void smc_ib_unregister_client(void);
 bool smc_ib_port_active(struct smc_ib_device *, u8);
 int smc_ib_remember_port_attr(struct smc_ib_device *, u8);
+int smc_ib_buf_map(struct smc_ib_device *, int, struct smc_buf_desc *,
+		   enum dma_data_direction);
 
 #endif
-- 
2.6.6
