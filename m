From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [RFC] vxlan: convert remote list to list_rcu
Date: Mon, 3 Jun 2013 11:26:16 -0700
Message-ID: <20130603112616.3ad018e2@nehalam.linuxnetplumber.net>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1369821617-29098-3-git-send-email-mike.rapoport@ravellosystems.com>
	<20130530110948.GA10532@casper.infradead.org>
	<CAF1J0HP+Wu9HjEELDaXM2BMREMuKByWr_zz=PwHeNUt=EVbdvw@mail.gmail.com>
	<20130530113739.GB10532@casper.infradead.org>
	<20130531091740.70b3e077@nehalam.linuxnetplumber.net>
	<20130602102942.GA21706@zed>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:63312 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754821Ab3FCS0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 14:26:21 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so1010367pab.36
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 11:26:20 -0700 (PDT)
In-Reply-To: <20130602102942.GA21706@zed>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is based on earlier step from Mike Rapoport

My changes:
 1. eliminate second rcu for rdst free
 2. handle possilble races where fdb notify called but no rdst
 3. only update snooped entries for dynamic entries, shouldn't modify static entries
 4. clean up the multi-dest tx code

This is compile tested only.

#3 is probably a bug that should be fixed differently in -stable


---
 drivers/net/vxlan.c | 75 +++++++++++++++++++++++++++++++++--------------------
 1 file changed, 47 insertions(+), 28 deletions(-)

--- a/drivers/net/vxlan.c	2013-06-03 11:08:39.214230482 -0700
+++ b/drivers/net/vxlan.c	2013-06-03 11:11:37.220114181 -0700
@@ -101,7 +101,7 @@ struct vxlan_rdst {
 	__be16			 remote_port;
 	u32			 remote_vni;
 	u32			 remote_ifindex;
-	struct vxlan_rdst	*remote_next;
+	struct list_head	 list;
 };
 
 /* Forwarding table entry */
@@ -110,7 +110,7 @@ struct vxlan_fdb {
 	struct rcu_head	  rcu;
 	unsigned long	  updated;	/* jiffies */
 	unsigned long	  used;
-	struct vxlan_rdst remote;
+	struct list_head  remotes;
 	u16		  state;	/* see ndm_state */
 	u8		  flags;	/* see ndm_flags */
 	u8		  eth_addr[ETH_ALEN];
@@ -163,6 +163,12 @@ static inline struct hlist_head *vs_head
 	return &vn->sock_list[hash_32(ntohs(port), PORT_HASH_BITS)];
 }
 
+/* First remote destination for a forwarding entry (or NULL) */
+static inline struct vxlan_rdst *first_remote(struct vxlan_fdb *fdb)
+{
+	return list_first_or_null_rcu(&fdb->remotes, struct vxlan_rdst, list);
+}
+
 /* Find VXLAN socket based on network namespace and UDP port */
 static struct vxlan_sock *vxlan_find_port(struct net *net, __be16 port)
 {
@@ -216,10 +222,11 @@ static int vxlan_fdb_info(struct sk_buff
 
 	if (type == RTM_GETNEIGH) {
 		ndm->ndm_family	= AF_INET;
-		send_ip = rdst->remote_ip != htonl(INADDR_ANY);
+		send_ip = rdst && rdst->remote_ip != htonl(INADDR_ANY);
 		send_eth = !is_zero_ether_addr(fdb->eth_addr);
 	} else
 		ndm->ndm_family	= AF_BRIDGE;
+
 	ndm->ndm_state = fdb->state;
 	ndm->ndm_ifindex = vxlan->dev->ifindex;
 	ndm->ndm_flags = fdb->flags;
@@ -228,18 +235,20 @@ static int vxlan_fdb_info(struct sk_buff
 	if (send_eth && nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->eth_addr))
 		goto nla_put_failure;
 
-	if (send_ip && nla_put_be32(skb, NDA_DST, rdst->remote_ip))
-		goto nla_put_failure;
-
-	if (rdst->remote_port && rdst->remote_port != vxlan->dst_port &&
-	    nla_put_be16(skb, NDA_PORT, rdst->remote_port))
-		goto nla_put_failure;
-	if (rdst->remote_vni != vxlan->default_dst.remote_vni &&
-	    nla_put_be32(skb, NDA_VNI, rdst->remote_vni))
-		goto nla_put_failure;
-	if (rdst->remote_ifindex &&
-	    nla_put_u32(skb, NDA_IFINDEX, rdst->remote_ifindex))
-		goto nla_put_failure;
+	if (rdst) {
+		if (send_ip && nla_put_be32(skb, NDA_DST, rdst->remote_ip))
+			goto nla_put_failure;
+
+		if (rdst->remote_port && rdst->remote_port != vxlan->dst_port &&
+		    nla_put_be16(skb, NDA_PORT, rdst->remote_port))
+			goto nla_put_failure;
+		if (rdst->remote_vni != vxlan->default_dst.remote_vni &&
+		    nla_put_be32(skb, NDA_VNI, rdst->remote_vni))
+			goto nla_put_failure;
+		if (rdst->remote_ifindex &&
+		    nla_put_u32(skb, NDA_IFINDEX, rdst->remote_ifindex))
+			goto nla_put_failure;
+	}
 
 	ci.ndm_used	 = jiffies_to_clock_t(now - fdb->used);
 	ci.ndm_confirmed = 0;
@@ -268,7 +277,7 @@ static inline size_t vxlan_nlmsg_size(vo
 }
 
 static void vxlan_fdb_notify(struct vxlan_dev *vxlan,
-			     const struct vxlan_fdb *fdb, int type)
+			     struct vxlan_fdb *fdb, int type)
 {
 	struct net *net = dev_net(vxlan->dev);
 	struct sk_buff *skb;
@@ -278,7 +287,7 @@ static void vxlan_fdb_notify(struct vxla
 	if (skb == NULL)
 		goto errout;
 
-	err = vxlan_fdb_info(skb, vxlan, fdb, 0, 0, type, 0, &fdb->remote);
+	err = vxlan_fdb_info(skb, vxlan, fdb, 0, 0, type, 0, first_remote(fdb));
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in vxlan_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
@@ -297,11 +306,16 @@ static void vxlan_ip_miss(struct net_dev
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
@@ -370,17 +384,17 @@ static struct vxlan_fdb *vxlan_find_mac(
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
@@ -388,8 +402,9 @@ static int vxlan_fdb_append(struct vxlan
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
 
@@ -441,16 +456,14 @@ static int vxlan_fdb_create(struct vxlan
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
@@ -465,13 +478,10 @@ static int vxlan_fdb_create(struct vxlan
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
 
@@ -577,26 +587,25 @@ static int vxlan_fdb_dump(struct sk_buff
 
 	for (h = 0; h < FDB_HASH_SIZE; ++h) {
 		struct vxlan_fdb *f;
-		int err;
 
 		hlist_for_each_entry_rcu(f, &vxlan->fdb_head[h], hlist) {
-			struct vxlan_rdst *rd;
-			for (rd = &f->remote; rd; rd = rd->remote_next) {
-				if (idx < cb->args[0])
-					goto skip;
+			struct vxlan_rdst *rdst;
 
+			list_for_each_entry_rcu(rdst, &f->remotes, list) {
+				int err;
 				err = vxlan_fdb_info(skb, vxlan, f,
 						     NETLINK_CB(cb->skb).portid,
 						     cb->nlh->nlmsg_seq,
 						     RTM_NEWNEIGH,
-						     NLM_F_MULTI, rd);
+						     NLM_F_MULTI, rdst);
 				if (err < 0)
-					break;
-skip:
+					goto errout;
+
 				++idx;
 			}
 		}
 	}
+ errout:
 
 	return idx;
 }
@@ -613,16 +622,24 @@ static void vxlan_snoop(struct net_devic
 
 	f = vxlan_find_mac(vxlan, src_mac);
 	if (likely(f)) {
-		if (likely(f->remote.remote_ip == src_ip))
+		struct vxlan_rdst *remote;
+
+		/* is this a static entry, ignore snooping */
+		if (!(f->flags & NTF_SELF))
+			return;
+
+		remote = first_remote(f);
+		if (!remote || remote->remote_ip == src_ip)
 			return;
 
 		if (net_ratelimit())
 			netdev_info(dev,
 				    "%pM migrated from %pI4 to %pI4\n",
-				    src_mac, &f->remote.remote_ip, &src_ip);
+				    src_mac, &remote->remote_ip, &src_ip);
 
-		f->remote.remote_ip = src_ip;
+		remote->remote_ip = src_ip;
 		f->updated = jiffies;
+		vxlan_fdb_notify(vxlan, f, RTM_NEWNEIGH);
 	} else {
 		/* learned new entry */
 		spin_lock(&vxlan->hash_lock);
@@ -856,6 +873,7 @@ static int arp_reduce(struct net_device
 	if (n) {
 		struct vxlan_fdb *f;
 		struct sk_buff	*reply;
+		struct vxlan_rdst *remote;
 
 		if (!(n->nud_state & NUD_CONNECTED)) {
 			neigh_release(n);
@@ -863,7 +881,9 @@ static int arp_reduce(struct net_device
 		}
 
 		f = vxlan_find_mac(vxlan, n->ha);
-		if (f && f->remote.remote_ip == htonl(INADDR_ANY)) {
+		if (f &&
+		    (remote = first_remote(f)) &&
+		    remote->remote_ip == htonl(INADDR_ANY)) {
 			/* bridge-local neighbor */
 			neigh_release(n);
 			goto out;
@@ -1153,9 +1173,8 @@ static netdev_tx_t vxlan_xmit(struct sk_
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct ethhdr *eth;
 	bool did_rsc = false;
-	struct vxlan_rdst *rdst0, *rdst;
+	struct vxlan_rdst *rdst0;
 	struct vxlan_fdb *f;
-	int rc1, rc;
 
 	skb_reset_mac_header(skb);
 	eth = eth_hdr(skb);
@@ -1173,32 +1192,40 @@ static netdev_tx_t vxlan_xmit(struct sk_
 			f = vxlan_find_mac(vxlan, eth->h_dest);
 	}
 
-	if (f == NULL) {
+	if (f) {
+		struct vxlan_rdst *rdst;
+
+		rdst0 = NULL;
+		list_for_each_entry_rcu(rdst, &f->remotes, list) {
+			if (rdst0) {
+				struct sk_buff *skb1;
+				skb1 = skb_clone(skb, GFP_ATOMIC);
+				if (skb1)
+					vxlan_xmit_one(skb1, dev,
+						       rdst0, did_rsc);
+				else
+					++dev->stats.tx_dropped;
+			}
+			rdst0 = rdst;
+		}
+
+		if (!rdst0) {
+			/* forwarding entry but destination list empty */
+			++dev->stats.tx_dropped;
+			kfree_skb(skb);
+			return NETDEV_TX_OK;
+		}
+
+	} else {
 		rdst0 = &vxlan->default_dst;
 
 		if (rdst0->remote_ip == htonl(INADDR_ANY) &&
 		    (vxlan->flags & VXLAN_F_L2MISS) &&
 		    !is_multicast_ether_addr(eth->h_dest))
 			vxlan_fdb_miss(vxlan, eth->h_dest);
-	} else
-		rdst0 = &f->remote;
-
-	rc = NETDEV_TX_OK;
-
-	/* if there are multiple destinations, send copies */
-	for (rdst = rdst0->remote_next; rdst; rdst = rdst->remote_next) {
-		struct sk_buff *skb1;
-
-		skb1 = skb_clone(skb, GFP_ATOMIC);
-		rc1 = vxlan_xmit_one(skb1, dev, rdst, did_rsc);
-		if (rc == NETDEV_TX_OK)
-			rc = rc1;
 	}
 
-	rc1 = vxlan_xmit_one(skb, dev, rdst0, did_rsc);
-	if (rc == NETDEV_TX_OK)
-		rc = rc1;
-	return rc;
+	return vxlan_xmit_one(skb, dev, rdst0, did_rsc);
 }
 
 /* Walk the forwarding table and purge stale entries */
