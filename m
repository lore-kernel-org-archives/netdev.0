From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net-next 1/4] gtp: move TEID hash to per socket structure
Date: Tue, 14 Mar 2017 12:25:45 +0100
Message-ID: <20170314112548.24027-2-aschultz@tpip.net>
References: <20170314112548.24027-1-aschultz@tpip.net>
Cc: osmocom-net-gprs@lists.osmocom.org,
        netdev <netdev@vger.kernel.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>
To: Harald Welte <laforge@gnumonks.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:33737 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750847AbdCNL1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 07:27:24 -0400
In-Reply-To: <20170314112548.24027-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Untangele the TEID information from the network device and move
it into a per socket structure.

The removeal of the TEID form the netdevice also means that the
gtp genl API for retriving tunnel information and removing tunnels
needs to be adjusted.
Before this change it was possible to change a GTP tunnel using
the gtp netdevice id and the teid. The teid is no longer unique
per gtp netdevice. So after this change it has to be either the
netdevice and MS IP or the GTP socket and teid.

Fortunatly, libgtpnl has always populated the Link Id, TEID,
GSN Peer IP and MS IP. So, the library interface has ensured that
all information that is mandatory after this change is guranteed
to be present. The only project that doesn't use libgtpnl (OpenAir-CN)
is also populating all of those values.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 145 +++++++++++++++++++++++++++++-------------------------
 1 file changed, 78 insertions(+), 67 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 3e1854f..66616f7 100644
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
@@ -215,7 +220,7 @@ static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb, unsigned int hdrlen
 }
 
 /* 1 means pass up to the stack, -1 means drop and 0 means decapsulated. */
-static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
+static int gtp0_udp_encap_recv(struct gtp_sock *gsk, struct sk_buff *skb)
 {
 	unsigned int hdrlen = sizeof(struct udphdr) +
 			      sizeof(struct gtp0_header);
@@ -233,16 +238,16 @@ static int gtp0_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 	if (gtp0->type != GTP_TPDU)
 		return 1;
 
-	pctx = gtp0_pdp_find(gtp, be64_to_cpu(gtp0->tid));
+	pctx = gtp0_pdp_find(gsk, be64_to_cpu(gtp0->tid));
 	if (!pctx) {
-		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
+		pr_debug("No PDP ctx to decap skb=%p\n", skb);
 		return 1;
 	}
 
 	return gtp_rx(pctx, skb, hdrlen);
 }
 
-static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
+static int gtp1u_udp_encap_recv(struct gtp_sock *gsk, struct sk_buff *skb)
 {
 	unsigned int hdrlen = sizeof(struct udphdr) +
 			      sizeof(struct gtp1_header);
@@ -275,9 +280,9 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 
 	gtp1 = (struct gtp1_header *)(skb->data + sizeof(struct udphdr));
 
-	pctx = gtp1_pdp_find(gtp, ntohl(gtp1->tid));
+	pctx = gtp1_pdp_find(gsk, ntohl(gtp1->tid));
 	if (!pctx) {
-		netdev_dbg(gtp->dev, "No PDP ctx to decap skb=%p\n", skb);
+		pr_debug("No PDP ctx to decap skb=%p\n", skb);
 		return 1;
 	}
 
@@ -286,13 +291,21 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb)
 
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
-		sock_put(sk);
+
+		for (i = 0; i < gsk->hash_size; i++)
+			hlist_for_each_entry_rcu(pctx, &gsk->tid_hash[i], hlist_tid)
+				pdp_context_delete(pctx);
+
+		synchronize_rcu();
+		kfree(gsk);
 	}
 }
 
@@ -315,23 +328,23 @@ static void gtp_encap_disable(struct gtp_dev *gtp)
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
 
-	netdev_dbg(gtp->dev, "encap_recv sk=%p\n", sk);
+	pr_debug("encap_recv sk=%p\n", sk);
 
 	switch (udp_sk(sk)->encap_type) {
 	case UDP_ENCAP_GTP0:
-		netdev_dbg(gtp->dev, "received GTP0 packet\n");
-		ret = gtp0_udp_encap_recv(gtp, skb);
+		pr_debug("received GTP0 packet\n");
+		ret = gtp0_udp_encap_recv(gsk, skb);
 		break;
 	case UDP_ENCAP_GTP1U:
-		netdev_dbg(gtp->dev, "received GTP1U packet\n");
-		ret = gtp1u_udp_encap_recv(gtp, skb);
+		pr_debug("received GTP1U packet\n");
+		ret = gtp1u_udp_encap_recv(gsk, skb);
 		break;
 	default:
 		ret = -1; /* Shouldn't happen. */
@@ -339,12 +352,12 @@ static int gtp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	switch (ret) {
 	case 1:
-		netdev_dbg(gtp->dev, "pass up to the process\n");
+		pr_debug("pass up to the process\n");
 		break;
 	case 0:
 		break;
 	case -1:
-		netdev_dbg(gtp->dev, "GTP packet has been dropped\n");
+		pr_debug("GTP packet has been dropped\n");
 		kfree_skb(skb);
 		ret = 0;
 		break;
@@ -624,7 +637,8 @@ static void gtp_link_setup(struct net_device *dev)
 
 static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize);
 static void gtp_hashtable_free(struct gtp_dev *gtp);
-static int gtp_encap_enable(struct gtp_dev *gtp, struct nlattr *data[]);
+static int gtp_encap_enable(struct gtp_dev *gtp, int hsize,
+			    struct nlattr *data[]);
 
 static int gtp_newlink(struct net *src_net, struct net_device *dev,
 			struct nlattr *tb[], struct nlattr *data[])
@@ -638,15 +652,15 @@ static int gtp_newlink(struct net *src_net, struct net_device *dev,
 
 	gtp = netdev_priv(dev);
 
-	err = gtp_encap_enable(gtp, data);
-	if (err < 0)
-		return err;
-
 	if (!data[IFLA_GTP_PDP_HASHSIZE])
 		hashsize = 1024;
 	else
 		hashsize = nla_get_u32(data[IFLA_GTP_PDP_HASHSIZE]);
 
+	err = gtp_encap_enable(gtp, hashsize, data);
+	if (err < 0)
+		return err;
+
 	err = gtp_hashtable_new(gtp, hashsize);
 	if (err < 0)
 		goto out_encap;
@@ -734,20 +748,12 @@ static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize)
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
@@ -756,21 +762,20 @@ static void gtp_hashtable_free(struct gtp_dev *gtp)
 	int i;
 
 	for (i = 0; i < gtp->hash_size; i++)
-		hlist_for_each_entry_rcu(pctx, &gtp->tid_hash[i], hlist_tid)
+		hlist_for_each_entry_rcu(pctx, &gtp->addr_hash[i], hlist_addr)
 			pdp_context_delete(pctx);
 
 	synchronize_rcu();
 	kfree(gtp->addr_hash);
-	kfree(gtp->tid_hash);
 }
 
-static struct sock *gtp_encap_enable_socket(int fd, int type,
-					    struct gtp_dev *gtp)
+static struct sock *gtp_encap_enable_socket(int fd, int type, int hsize)
 {
 	struct udp_tunnel_sock_cfg tuncfg = {NULL};
+	struct gtp_sock *gsk;
 	struct socket *sock;
 	struct sock *sk;
-	int err;
+	int err, i;
 
 	pr_debug("enable gtp on %d, %d\n", fd, type);
 
@@ -791,10 +796,20 @@ static struct sock *gtp_encap_enable_socket(int fd, int type,
 		goto out_sock;
 	}
 
+	gsk = kzalloc(sizeof(*gsk) + sizeof(struct hlist_head) * hsize, GFP_KERNEL);
+	if (!gsk) {
+		sk = ERR_PTR(-ENOMEM);
+		goto out_sock;
+	}
+
+	gsk->hash_size = hsize;
+	for (i = 0; i < hsize; i++)
+		INIT_HLIST_HEAD(&gsk->tid_hash[i]);
+
 	sk = sock->sk;
 	sock_hold(sk);
 
-	tuncfg.sk_user_data = gtp;
+	tuncfg.sk_user_data = gsk;
 	tuncfg.encap_type = type;
 	tuncfg.encap_rcv = gtp_encap_recv;
 	tuncfg.encap_destroy = gtp_encap_destroy;
@@ -806,7 +821,8 @@ static struct sock *gtp_encap_enable_socket(int fd, int type,
 	return sk;
 }
 
-static int gtp_encap_enable(struct gtp_dev *gtp, struct nlattr *data[])
+static int gtp_encap_enable(struct gtp_dev *gtp, int hsize,
+			    struct nlattr *data[])
 {
 	struct sock *sk1u = NULL;
 	struct sock *sk0 = NULL;
@@ -814,7 +830,7 @@ static int gtp_encap_enable(struct gtp_dev *gtp, struct nlattr *data[])
 	if (data[IFLA_GTP_FD0]) {
 		u32 fd0 = nla_get_u32(data[IFLA_GTP_FD0]);
 
-		sk0 = gtp_encap_enable_socket(fd0, UDP_ENCAP_GTP0, gtp);
+		sk0 = gtp_encap_enable_socket(fd0, UDP_ENCAP_GTP0, hsize);
 		if (IS_ERR(sk0))
 			return PTR_ERR(sk0);
 	}
@@ -822,7 +838,7 @@ static int gtp_encap_enable(struct gtp_dev *gtp, struct nlattr *data[])
 	if (data[IFLA_GTP_FD1]) {
 		u32 fd1 = nla_get_u32(data[IFLA_GTP_FD1]);
 
-		sk1u = gtp_encap_enable_socket(fd1, UDP_ENCAP_GTP1U, gtp);
+		sk1u = gtp_encap_enable_socket(fd1, UDP_ENCAP_GTP1U, hsize);
 		if (IS_ERR(sk1u)) {
 			if (sk0)
 				gtp_encap_disable_sock(sk0);
@@ -895,9 +911,14 @@ static int ipv4_pdp_add(struct gtp_dev *gtp, struct sock *sk,
 	struct net_device *dev = gtp->dev;
 	u32 hash_ms, hash_tid = 0;
 	struct pdp_ctx *pctx;
+	struct gtp_sock *gsk;
 	bool found = false;
 	__be32 ms_addr;
 
+	gsk = rcu_dereference_sk_user_data(sk);
+	if (!gsk)
+		return -ENODEV;
+
 	ms_addr = nla_get_be32(info->attrs[GTPA_MS_ADDRESS]);
 	hash_ms = ipv4_hashfn(ms_addr) % gtp->hash_size;
 
@@ -944,15 +965,15 @@ static int ipv4_pdp_add(struct gtp_dev *gtp, struct sock *sk,
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
@@ -1048,24 +1069,14 @@ static struct pdp_ctx *gtp_find_pdp_by_link(struct net *net,
 {
 	struct gtp_dev *gtp;
 
+	if (!nla[GTPA_MS_ADDRESS])
+		return ERR_PTR(-EINVAL);
+
 	gtp = gtp_find_dev(net, nla);
 	if (!gtp)
 		return ERR_PTR(-ENODEV);
 
-	if (nla[GTPA_MS_ADDRESS]) {
-		__be32 ip = nla_get_be32(nla[GTPA_MS_ADDRESS]);
-
-		return ipv4_pdp_find(gtp, ip);
-	} else if (nla[GTPA_VERSION]) {
-		u32 gtp_version = nla_get_u32(nla[GTPA_VERSION]);
-
-		if (gtp_version == GTP_V0 && nla[GTPA_TID])
-			return gtp0_pdp_find(gtp, nla_get_u64(nla[GTPA_TID]));
-		else if (gtp_version == GTP_V1 && nla[GTPA_I_TEI])
-			return gtp1_pdp_find(gtp, nla_get_u32(nla[GTPA_I_TEI]));
-	}
-
-	return ERR_PTR(-EINVAL);
+	return ipv4_pdp_find(gtp, nla_get_be32(nla[GTPA_MS_ADDRESS]));
 }
 
 static struct pdp_ctx *gtp_find_pdp(struct net *net, struct nlattr *nla[])
@@ -1209,7 +1220,7 @@ static int gtp_genl_dump_pdp(struct sk_buff *skb,
 			last_gtp = NULL;
 
 		for (i = k; i < gtp->hash_size; i++) {
-			hlist_for_each_entry_rcu(pctx, &gtp->tid_hash[i], hlist_tid) {
+			hlist_for_each_entry_rcu(pctx, &gtp->addr_hash[i], hlist_addr) {
 				if (tid && tid != pctx->u.tid)
 					continue;
 				else
-- 
2.10.2
