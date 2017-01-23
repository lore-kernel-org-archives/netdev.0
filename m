From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 14/17] gtp: move TEID hash to per socket structure
Date: Mon, 23 Jan 2017 12:57:03 +0100
Message-ID: <20170123115706.4354-15-aschultz@tpip.net>
References: <20170123115706.4354-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:40683 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750999AbdAWMGy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 07:06:54 -0500
In-Reply-To: <20170123115706.4354-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Untangele the TEID information from the network device and move
it into a per socket structure.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 100 ++++++++++++++++++++++++++++++++----------------------
 1 file changed, 60 insertions(+), 40 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 276cc66..019e80f 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -75,10 +75,15 @@ struct gtp_dev {
 	struct net_device	*dev;
 
 	unsigned int		hash_size;
-	struct hlist_head	*tid_hash;
 	struct hlist_head	*addr_hash;
 };
 
+/* One instance of the GTP socket. */
+struct gtp_sock {
+	unsigned int		hash_size;
+	struct hlist_head	tid_hash[];
+};
+
 static unsigned int gtp_net_id __read_mostly;
 
 struct gtp_net {
@@ -106,12 +111,12 @@ static inline u32 ipv4_hashfn(__be32 ip)
 }
 
 /* Resolve a PDP context structure based on the 64bit TID. */
-static struct pdp_ctx *gtp0_pdp_find(struct gtp_dev *gtp, u64 tid)
+static struct pdp_ctx *gtp0_pdp_find(struct gtp_sock *gsk, u64 tid)
 {
 	struct hlist_head *head;
 	struct pdp_ctx *pdp;
 
-	head = &gtp->tid_hash[gtp0_hashfn(tid) % gtp->hash_size];
+	head = &gsk->tid_hash[gtp0_hashfn(tid) % gsk->hash_size];
 
 	hlist_for_each_entry_rcu(pdp, head, hlist_tid) {
 		if (pdp->gtp_version == GTP_V0 &&
@@ -122,12 +127,12 @@ static struct pdp_ctx *gtp0_pdp_find(struct gtp_dev *gtp, u64 tid)
 }
 
 /* Resolve a PDP context structure based on the 32bit TEI. */
-static struct pdp_ctx *gtp1_pdp_find(struct gtp_dev *gtp, u32 tid)
+static struct pdp_ctx *gtp1_pdp_find(struct gtp_sock *gsk, u32 tid)
 {
 	struct hlist_head *head;
 	struct pdp_ctx *pdp;
 
-	head = &gtp->tid_hash[gtp1u_hashfn(tid) % gtp->hash_size];
+	head = &gsk->tid_hash[gtp1u_hashfn(tid) % gsk->hash_size];
 
 	hlist_for_each_entry_rcu(pdp, head, hlist_tid) {
 		if (pdp->gtp_version == GTP_V1 &&
@@ -215,7 +220,7 @@ static int gtp_rx(struct sk_buff *skb, struct pdp_ctx *pctx, unsigned int hdrlen
 }
 
 /* 1 means pass up to the stack, -1 means drop and 0 means decapsulated. */
-static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
+static int gtp0_udp_encap_recv(struct gtp_sock *gsk, struct sk_buff *skb)
 {
 	unsigned int hdrlen = sizeof(struct udphdr) +
 			      sizeof(struct gtp0_header);
@@ -233,7 +238,7 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 	if (gtp0->type != GTP_TPDU)
 		return 1;
 
-	pctx = gtp0_pdp_find(gtp, be64_to_cpu(gtp0->tid));
+	pctx = gtp0_pdp_find(gsk, be64_to_cpu(gtp0->tid));
 	if (IS_ERR(pctx)) {
 		pr_debug("No PDP ctx to decap skb=%p\n", skb);
 		return 1;
@@ -242,7 +247,7 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 	return gtp_rx(skb, pctx, hdrlen);
 }
 
-static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
+static int gtp1u_udp_encap_recv(struct gtp_sock *gsk, struct sk_buff *skb)
 {
 	unsigned int hdrlen = sizeof(struct udphdr) +
 			      sizeof(struct gtp1_header);
@@ -275,7 +280,7 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 
 	gtp1 = (struct gtp1_header *)(skb->data + sizeof(struct udphdr));
 
-	pctx = gtp1_pdp_find(gtp, ntohl(gtp1->tid));
+	pctx = gtp1_pdp_find(gsk, ntohl(gtp1->tid));
 	if (IS_ERR(pctx)) {
 		pr_debug("No PDP ctx to decap skb=%p\n", skb);
 		return 1;
@@ -289,11 +294,11 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
  */
 static int gtp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
-	struct gtp_dev *gtp;
+	struct gtp_sock *gsk;
 	int ret = 0;
 
-	gtp = rcu_dereference_sk_user_data(sk);
-	if (!gtp)
+	gsk = rcu_dereference_sk_user_data(sk);
+	if (!gsk)
 		return 1;
 
 	pr_debug("encap_recv sk=%p\n", sk);
@@ -301,11 +306,11 @@ static int gtp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	switch (udp_sk(sk)->encap_type) {
 	case UDP_ENCAP_GTP0:
 		pr_debug("received GTP0 packet\n");
-		ret = gtp0_udp_encap_recv(gtp, skb);
+		ret = gtp0_udp_encap_recv(gsk, skb);
 		break;
 	case UDP_ENCAP_GTP1U:
 		pr_debug("received GTP1U packet\n");
-		ret = gtp1u_udp_encap_recv(gtp, skb);
+		ret = gtp1u_udp_encap_recv(gsk, skb);
 		break;
 	default:
 		ret = -1; /* Shouldn't happen. */
@@ -329,12 +334,21 @@ static int gtp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 static void gtp_encap_destroy(struct sock *sk)
 {
-	struct gtp_dev *gtp;
+	struct gtp_sock *gsk;
+	struct pdp_ctx *pctx;
+	int i;
 
-	gtp = rcu_dereference_sk_user_data(sk);
-	if (gtp) {
+	gsk = rcu_dereference_sk_user_data(sk);
+	if (gsk) {
 		udp_sk(sk)->encap_type = 0;
 		rcu_assign_sk_user_data(sk, NULL);
+
+		for (i = 0; i < gsk->hash_size; i++)
+			hlist_for_each_entry_rcu(pctx, &gsk->tid_hash[i], hlist_tid)
+				pdp_context_delete(pctx);
+
+		synchronize_rcu();
+		kfree(gsk);
 	}
 }
 
@@ -607,7 +621,7 @@ static void gtp_link_setup(struct net_device *dev)
 static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize);
 static void gtp_hashtable_free(struct gtp_dev *gtp);
 static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
-			    struct nlattr *data[]);
+			    int hsize, struct nlattr *data[]);
 static void gtp_encap_disable(struct gtp_dev *gtp);
 
 static int gtp_newlink(struct net *src_net, struct net_device *dev,
@@ -625,7 +639,7 @@ static int gtp_newlink(struct net *src_net, struct net_device *dev,
 		hashsize = nla_get_u32(data[IFLA_GTP_PDP_HASHSIZE]);
 
 	if (data[IFLA_GTP_FD0] || data[IFLA_GTP_FD1]) {
-		err = gtp_encap_enable(dev, gtp, data);
+		err = gtp_encap_enable(dev, gtp, hashsize, data);
 		if (err < 0)
 			goto out_err;
 	}
@@ -736,20 +750,12 @@ static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize)
 	if (gtp->addr_hash == NULL)
 		return -ENOMEM;
 
-	gtp->tid_hash = kmalloc(sizeof(struct hlist_head) * hsize, GFP_KERNEL);
-	if (gtp->tid_hash == NULL)
-		goto err1;
-
 	gtp->hash_size = hsize;
 
-	for (i = 0; i < hsize; i++) {
+	for (i = 0; i < hsize; i++)
 		INIT_HLIST_HEAD(&gtp->addr_hash[i]);
-		INIT_HLIST_HEAD(&gtp->tid_hash[i]);
-	}
+
 	return 0;
-err1:
-	kfree(gtp->addr_hash);
-	return -ENOMEM;
 }
 
 static void gtp_hashtable_free(struct gtp_dev *gtp)
@@ -763,15 +769,14 @@ static void gtp_hashtable_free(struct gtp_dev *gtp)
 
 	synchronize_rcu();
 	kfree(gtp->addr_hash);
-	kfree(gtp->tid_hash);
 }
 
-static struct socket *gtp_encap_enable_socket(int fd, int type,
-					      struct gtp_dev *gtp)
+static struct socket *gtp_encap_enable_socket(int fd, int type, int hsize)
 {
 	struct udp_tunnel_sock_cfg tuncfg = {NULL};
+	struct gtp_sock *gsk;
 	struct socket *sock;
-	int err;
+	int err, i;
 
 	pr_debug("enable gtp on %d, %d\n", fd, type);
 
@@ -787,7 +792,17 @@ static struct socket *gtp_encap_enable_socket(int fd, int type,
 		goto out_sock;
 	}
 
-	tuncfg.sk_user_data = gtp;
+	gsk = kzalloc(sizeof(*gsk) + sizeof(struct hlist_head) * hsize, GFP_KERNEL);
+	if (!gsk) {
+		err = -ENOMEM;
+		goto out_sock;
+	}
+
+	gsk->hash_size = hsize;
+	for (i = 0; i < hsize; i++)
+		INIT_HLIST_HEAD(&gsk->tid_hash[i]);
+
+	tuncfg.sk_user_data = gsk;
 	tuncfg.encap_type = type;
 	tuncfg.encap_rcv = gtp_encap_recv;
 	tuncfg.encap_destroy = gtp_encap_destroy;
@@ -801,7 +816,7 @@ static struct socket *gtp_encap_enable_socket(int fd, int type,
 }
 
 static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
-			    struct nlattr *data[])
+			    int hsize, struct nlattr *data[])
 {
 	struct socket *sock0 = NULL;
 	struct socket *sock1u = NULL;
@@ -809,7 +824,7 @@ static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
 	if (data[IFLA_GTP_FD0]) {
 		u32 fd0 = nla_get_u32(data[IFLA_GTP_FD0]);
 
-		sock0 = gtp_encap_enable_socket(fd0, UDP_ENCAP_GTP0, gtp);
+		sock0 = gtp_encap_enable_socket(fd0, UDP_ENCAP_GTP0, hsize);
 		if (IS_ERR(sock0))
 			return PTR_ERR(sock0);
 	}
@@ -817,7 +832,7 @@ static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
 	if (data[IFLA_GTP_FD1]) {
 		u32 fd1 = nla_get_u32(data[IFLA_GTP_FD1]);
 
-		sock1u = gtp_encap_enable_socket(fd1, UDP_ENCAP_GTP1U, gtp);
+		sock1u = gtp_encap_enable_socket(fd1, UDP_ENCAP_GTP1U, hsize);
 		if (IS_ERR(sock1u)) {
 			if (sock0)
 				sockfd_put(sock0);
@@ -890,11 +905,16 @@ static int ipv4_pdp_add(struct net_device *dev, struct sock *sk,
 			struct genl_info *info)
 {
 	struct gtp_dev *gtp = netdev_priv(dev);
+	struct gtp_sock *gsk;
 	u32 hash_ms, hash_tid = 0;
 	struct pdp_ctx *pctx;
 	bool found = false;
 	__be32 ms_addr;
 
+	gsk = rcu_dereference_sk_user_data(sk);
+	if (!gsk)
+		return -ENODEV;
+
 	ms_addr = nla_get_be32(info->attrs[GTPA_MS_ADDRESS]);
 	hash_ms = ipv4_hashfn(ms_addr) % gtp->hash_size;
 
@@ -941,15 +961,15 @@ static int ipv4_pdp_add(struct net_device *dev, struct sock *sk,
 		 * situation in which this doesn't unambiguosly identify the
 		 * PDP context.
 		 */
-		hash_tid = gtp0_hashfn(pctx->u.v0.tid) % gtp->hash_size;
+		hash_tid = gtp0_hashfn(pctx->u.v0.tid) % gsk->hash_size;
 		break;
 	case GTP_V1:
-		hash_tid = gtp1u_hashfn(pctx->u.v1.i_tei) % gtp->hash_size;
+		hash_tid = gtp1u_hashfn(pctx->u.v1.i_tei) % gsk->hash_size;
 		break;
 	}
 
 	hlist_add_head_rcu(&pctx->hlist_addr, &gtp->addr_hash[hash_ms]);
-	hlist_add_head_rcu(&pctx->hlist_tid, &gtp->tid_hash[hash_tid]);
+	hlist_add_head_rcu(&pctx->hlist_tid, &gsk->tid_hash[hash_tid]);
 
 	switch (pctx->gtp_version) {
 	case GTP_V0:
-- 
2.10.2
