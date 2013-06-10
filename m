From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 08/12] vxlan: convert remotes list to list_rcu
Date: Mon, 10 Jun 2013 13:25:23 -0700
Message-ID: <20130610132523.4c1d55ca@nehalam.linuxnetplumber.net>
References: <20130610200524.721617349@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:48339 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753154Ab3FJU0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 16:26:09 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so2633733pbb.19
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 13:26:09 -0700 (PDT)
In-Reply-To: <20130610200524.721617349@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on initial work by Mike Rapoport <mike.rapoport@ravellosystems.com>
Use list macros and RCU for tracking multiple remotes.

Note: this code assumes list always has at least one entry,
because delete is not supported.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vxlan.c |   99 +++++++++++++++++++++++++++++----------------------
 1 file changed, 56 insertions(+), 43 deletions(-)

--- a/drivers/net/vxlan.c	2013-06-10 12:20:01.314071646 -0700
+++ b/drivers/net/vxlan.c	2013-06-10 12:20:02.174061866 -0700
@@ -102,7 +102,7 @@ struct vxlan_rdst {
 	__be16			 remote_port;
 	u32			 remote_vni;
 	u32			 remote_ifindex;
-	struct vxlan_rdst	*remote_next;
+	struct list_head	 list;
 };
 
 /* Forwarding table entry */
@@ -111,7 +111,7 @@ struct vxlan_fdb {
 	struct rcu_head	  rcu;
 	unsigned long	  updated;	/* jiffies */
 	unsigned long	  used;
-	struct vxlan_rdst remote;
+	struct list_head  remotes;
 	u16		  state;	/* see ndm_state */
 	u8		  flags;	/* see ndm_flags */
 	u8		  eth_addr[ETH_ALEN];
@@ -170,6 +170,14 @@ static inline struct hlist_head *vs_head
 	return &vn->sock_list[hash_32(ntohs(port), PORT_HASH_BITS)];
 }
 
+/* First remote destination for a forwarding entry.
+ * Guaranteed to be non-NULL because remotes are never deleted.
+ */
+static inline struct vxlan_rdst *first_remote(struct vxlan_fdb *fdb)
+{
+	return list_first_or_null_rcu(&fdb->remotes, struct vxlan_rdst, list);
+}
+
 /* Find VXLAN socket based on network namespace and UDP port */
 static struct vxlan_sock *vxlan_find_port(struct net *net, __be16 port)
 {
@@ -275,7 +283,7 @@ static inline size_t vxlan_nlmsg_size(vo
 }
 
 static void vxlan_fdb_notify(struct vxlan_dev *vxlan,
-			     const struct vxlan_fdb *fdb, int type)
+			     struct vxlan_fdb *fdb, int type)
 {
 	struct net *net = dev_net(vxlan->dev);
 	struct sk_buff *skb;
@@ -285,7 +293,7 @@ static void vxlan_fdb_notify(struct vxla
 	if (skb == NULL)
 		goto errout;
 
-	err = vxlan_fdb_info(skb, vxlan, fdb, 0, 0, type, 0, &fdb->remote);
+	err = vxlan_fdb_info(skb, vxlan, fdb, 0, 0, type, 0, first_remote(fdb));
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in vxlan_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
@@ -304,11 +312,16 @@ static void vxlan_ip_miss(struct net_dev
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_fdb f;
+	struct vxlan_rdst remote;
 
 	memset(&f, 0, sizeof f);
 	f.state = NUD_STALE;
-	f.remote.remote_ip = ipa; /* goes to NDA_DST */
-	f.remote.remote_vni = VXLAN_N_VID;
+
+	remote.remote_ip = ipa; /* goes to NDA_DST */
+	remote.remote_vni = VXLAN_N_VID;
+
+	INIT_LIST_HEAD(&f.remotes);
+	list_add_rcu(&remote.list, &f.remotes);
 
 	vxlan_fdb_notify(vxlan, &f, RTM_GETNEIGH);
 }
@@ -318,6 +331,7 @@ static void vxlan_fdb_miss(struct vxlan_
 	struct vxlan_fdb	f;
 
 	memset(&f, 0, sizeof f);
+	INIT_LIST_HEAD(&f.remotes);
 	f.state = NUD_STALE;
 	memcpy(f.eth_addr, eth_addr, ETH_ALEN);
 
@@ -377,17 +391,17 @@ static struct vxlan_fdb *vxlan_find_mac(
 static int vxlan_fdb_append(struct vxlan_fdb *f,
 			    __be32 ip, __be16 port, __u32 vni, __u32 ifindex)
 {
-	struct vxlan_rdst *rd_prev, *rd;
+	struct vxlan_rdst *rd;
 
-	rd_prev = NULL;
-	for (rd = &f->remote; rd; rd = rd->remote_next) {
+	/* protected by vxlan->hash_lock */
+	list_for_each_entry(rd, &f->remotes, list) {
 		if (rd->remote_ip == ip &&
 		    rd->remote_port == port &&
 		    rd->remote_vni == vni &&
 		    rd->remote_ifindex == ifindex)
 			return 0;
-		rd_prev = rd;
 	}
+
 	rd = kmalloc(sizeof(*rd), GFP_ATOMIC);
 	if (rd == NULL)
 		return -ENOBUFS;
@@ -395,8 +409,9 @@ static int vxlan_fdb_append(struct vxlan
 	rd->remote_port = port;
 	rd->remote_vni = vni;
 	rd->remote_ifindex = ifindex;
-	rd->remote_next = NULL;
-	rd_prev->remote_next = rd;
+
+	list_add_tail_rcu(&rd->list, &f->remotes);
+
 	return 1;
 }
 
@@ -448,16 +463,14 @@ static int vxlan_fdb_create(struct vxlan
 			return -ENOMEM;
 
 		notify = 1;
-		f->remote.remote_ip = ip;
-		f->remote.remote_port = port;
-		f->remote.remote_vni = vni;
-		f->remote.remote_ifindex = ifindex;
-		f->remote.remote_next = NULL;
 		f->state = state;
 		f->flags = ndm_flags;
 		f->updated = f->used = jiffies;
+		INIT_LIST_HEAD(&f->remotes);
 		memcpy(f->eth_addr, mac, ETH_ALEN);
 
+		vxlan_fdb_append(f, ip, port, vni, ifindex);
+
 		++vxlan->addrcnt;
 		hlist_add_head_rcu(&f->hlist,
 				   vxlan_fdb_head(vxlan, mac));
@@ -472,13 +485,10 @@ static int vxlan_fdb_create(struct vxlan
 static void vxlan_fdb_free(struct rcu_head *head)
 {
 	struct vxlan_fdb *f = container_of(head, struct vxlan_fdb, rcu);
+	struct vxlan_rdst *rd, *nd;
 
-	while (f->remote.remote_next) {
-		struct vxlan_rdst *rd = f->remote.remote_next;
-
-		f->remote.remote_next = rd->remote_next;
+	list_for_each_entry_safe(rd, nd, &f->remotes, list)
 		kfree(rd);
-	}
 	kfree(f);
 }
 
@@ -588,23 +598,24 @@ static int vxlan_fdb_dump(struct sk_buff
 
 		hlist_for_each_entry_rcu(f, &vxlan->fdb_head[h], hlist) {
 			struct vxlan_rdst *rd;
-			for (rd = &f->remote; rd; rd = rd->remote_next) {
-				if (idx < cb->args[0])
-					goto skip;
 
+			if (idx < cb->args[0])
+				goto skip;
+
+			list_for_each_entry_rcu(rd, &f->remotes, list) {
 				err = vxlan_fdb_info(skb, vxlan, f,
 						     NETLINK_CB(cb->skb).portid,
 						     cb->nlh->nlmsg_seq,
 						     RTM_NEWNEIGH,
 						     NLM_F_MULTI, rd);
 				if (err < 0)
-					break;
-skip:
-				++idx;
+					goto out;
 			}
+skip:
+			++idx;
 		}
 	}
-
+out:
 	return idx;
 }
 
@@ -620,19 +631,21 @@ static bool vxlan_snoop(struct net_devic
 
 	f = vxlan_find_mac(vxlan, src_mac);
 	if (likely(f)) {
-		if (likely(f->remote.remote_ip == src_ip))
-			return false;
+		struct vxlan_rdst *rdst = first_remote(f);
 
 		/* Don't migrate static entries, drop packets */
 		if (!(f->flags & NTF_SELF))
 			return true;
 
+		if (likely(rdst->remote_ip == src_ip))
+			return false;
+
 		if (net_ratelimit())
 			netdev_info(dev,
 				    "%pM migrated from %pI4 to %pI4\n",
-				    src_mac, &f->remote.remote_ip, &src_ip);
+				    src_mac, &rdst->remote_ip, &src_ip);
 
-		f->remote.remote_ip = src_ip;
+		rdst->remote_ip = src_ip;
 		f->updated = jiffies;
 		vxlan_fdb_notify(vxlan, f, RTM_NEWNEIGH);
 	} else {
@@ -866,7 +879,7 @@ static int arp_reduce(struct net_device
 		}
 
 		f = vxlan_find_mac(vxlan, n->ha);
-		if (f && f->remote.remote_ip == htonl(INADDR_ANY)) {
+		if (f && first_remote(f)->remote_ip == htonl(INADDR_ANY)) {
 			/* bridge-local neighbor */
 			neigh_release(n);
 			goto out;
@@ -1181,17 +1194,17 @@ static netdev_tx_t vxlan_xmit(struct sk_
 		    (vxlan->flags & VXLAN_F_L2MISS) &&
 		    !is_multicast_ether_addr(eth->h_dest))
 			vxlan_fdb_miss(vxlan, eth->h_dest);
-	} else
-		rdst0 = &f->remote;
-
-
-	/* if there are multiple destinations, send copies */
-	for (rdst = rdst0->remote_next; rdst; rdst = rdst->remote_next) {
-		struct sk_buff *skb1;
+	} else {
+		rdst = rdst0 = first_remote(f);
 
-		skb1 = skb_clone(skb, GFP_ATOMIC);
-		if (skb1)
-			vxlan_xmit_one(skb1, dev, rdst, did_rsc);
+		/* if there are multiple destinations, send copies */
+		list_for_each_entry_continue_rcu(rdst, &f->remotes, list) {
+			struct sk_buff *skb1;
+
+			skb1 = skb_clone(skb, GFP_ATOMIC);
+			if (skb1)
+				vxlan_xmit_one(skb1, dev, rdst, did_rsc);
+		}
 	}
 
 	vxlan_xmit_one(skb, dev, rdst0, did_rsc);
