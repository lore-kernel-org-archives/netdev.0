From: David L Stevens <dlstevens@us.ibm.com>
Subject: [PATCH net-next] generalize VXLAN forwarding tables
Date: Thu, 28 Feb 2013 14:23:07 -0500
Message-ID: <201302281924.r1SJN7u5024149@lab1.dls>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:38505 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759674Ab3B1T2A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2013 14:28:00 -0500
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Thu, 28 Feb 2013 14:27:59 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 6C02EC90025
	for <netdev@vger.kernel.org>; Thu, 28 Feb 2013 14:27:56 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1SJRq37243382
	for <netdev@vger.kernel.org>; Thu, 28 Feb 2013 14:27:52 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1SJRn0W022803
	for <netdev@vger.kernel.org>; Thu, 28 Feb 2013 12:27:49 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch generalizes VXLAN forwarding table entries allowing an administrator
to:
	1) specify multiple destinations for a given MAC
	2) specify alternate vni's in the VXLAN header
	3) specify alternate destination UDP ports
	4) use multicast MAC addresses as fdb lookup keys
	5) specify multicast destinations
	6) specify the outgoing interface for forwarded packets

The combination allows configuration of more complex topologies using VXLAN
encapsulation.

Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 9d70421..bfcdac3 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -80,13 +80,22 @@ struct vxlan_net {
 	struct hlist_head vni_list[VNI_HASH_SIZE];
 };
 
+struct vxlan_rdst {
+	struct rcu_head		 rcu;
+	__be32			 remote_ip;
+	__be16			 remote_port;
+	u32			 remote_vni;
+	u32			 remote_ifindex;
+	struct vxlan_rdst	*remote_next;
+};
+
 /* Forwarding table entry */
 struct vxlan_fdb {
 	struct hlist_node hlist;	/* linked list of entries */
 	struct rcu_head	  rcu;
 	unsigned long	  updated;	/* jiffies */
 	unsigned long	  used;
-	__be32		  remote_ip;
+	struct vxlan_rdst remote;
 	u16		  state;	/* see ndm_state */
 	u8		  eth_addr[ETH_ALEN];
 };
@@ -157,7 +166,8 @@ static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id)
 /* Fill in neighbour message in skbuff. */
 static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 			   const struct vxlan_fdb *fdb,
-			   u32 portid, u32 seq, int type, unsigned int flags)
+			   u32 portid, u32 seq, int type, unsigned int flags,
+			   const struct vxlan_rdst *rdst)
 {
 	unsigned long now = jiffies;
 	struct nda_cacheinfo ci;
@@ -176,7 +186,7 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 
 	if (type == RTM_GETNEIGH) {
 		ndm->ndm_family	= AF_INET;
-		send_ip = fdb->remote_ip != 0;
+		send_ip = rdst->remote_ip != 0;
 		send_eth = !is_zero_ether_addr(fdb->eth_addr);
 	} else
 		ndm->ndm_family	= AF_BRIDGE;
@@ -188,7 +198,17 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 	if (send_eth && nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->eth_addr))
 		goto nla_put_failure;
 
-	if (send_ip && nla_put_be32(skb, NDA_DST, fdb->remote_ip))
+	if (send_ip && nla_put_be32(skb, NDA_DST, rdst->remote_ip))
+		goto nla_put_failure;
+
+	if (rdst->remote_port && rdst->remote_port != vxlan_port &&
+	    nla_put_be16(skb, NDA_PORT, rdst->remote_port))
+		goto nla_put_failure;
+	if (rdst->remote_vni != vxlan->vni &&
+	    nla_put_be32(skb, NDA_VNI, rdst->remote_vni))
+		goto nla_put_failure;
+	if (rdst->remote_ifindex &&
+	    nla_put_u32(skb, NDA_IFINDEX, rdst->remote_ifindex))
 		goto nla_put_failure;
 
 	ci.ndm_used	 = jiffies_to_clock_t(now - fdb->used);
@@ -211,6 +231,9 @@ static inline size_t vxlan_nlmsg_size(void)
 	return NLMSG_ALIGN(sizeof(struct ndmsg))
 		+ nla_total_size(ETH_ALEN) /* NDA_LLADDR */
 		+ nla_total_size(sizeof(__be32)) /* NDA_DST */
+		+ nla_total_size(sizeof(__be32)) /* NDA_PORT */
+		+ nla_total_size(sizeof(__be32)) /* NDA_VNI */
+		+ nla_total_size(sizeof(__u32)) /* NDA_IFINDEX */
 		+ nla_total_size(sizeof(struct nda_cacheinfo));
 }
 
@@ -225,7 +248,7 @@ static void vxlan_fdb_notify(struct vxlan_dev *vxlan,
 	if (skb == NULL)
 		goto errout;
 
-	err = vxlan_fdb_info(skb, vxlan, fdb, 0, 0, type, 0);
+	err = vxlan_fdb_info(skb, vxlan, fdb, 0, 0, type, 0, &fdb->remote);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in vxlan_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
@@ -247,7 +270,8 @@ static void vxlan_ip_miss(struct net_device *dev, __be32 ipa)
 
 	memset(&f, 0, sizeof f);
 	f.state = NUD_STALE;
-	f.remote_ip = ipa; /* goes to NDA_DST */
+	f.remote.remote_ip = ipa; /* goes to NDA_DST */
+	f.remote.remote_vni = VXLAN_N_VID;
 
 	vxlan_fdb_notify(vxlan, &f, RTM_GETNEIGH);
 }
@@ -301,10 +325,38 @@ static struct vxlan_fdb *vxlan_find_mac(struct vxlan_dev *vxlan,
 	return NULL;
 }
 
+/* Add/update destinations for multicast */
+static int vxlan_fdb_append(struct vxlan_fdb *f,
+			    __be32 ip, __u32 port, __u32 vni, __u32 ifindex)
+{
+	struct vxlan_rdst *rd_prev, *rd;
+
+	rd_prev = NULL;
+	for (rd = &f->remote; rd; rd = rd->remote_next) {
+		if (rd->remote_ip == ip &&
+		    rd->remote_port == port &&
+		    rd->remote_vni == vni &&
+		    rd->remote_ifindex == ifindex)
+			return 0;
+		rd_prev = rd;
+	}
+	rd = kmalloc(sizeof(*rd), GFP_ATOMIC);
+	if (rd == NULL)
+		return -ENOBUFS;
+	rd->remote_ip = ip;
+	rd->remote_port = port;
+	rd->remote_vni = vni;
+	rd->remote_ifindex = ifindex;
+	rd->remote_next = NULL;
+	rd_prev->remote_next = rd;
+	return 1;
+}
+
 /* Add new entry to forwarding table -- assumes lock held */
 static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 			    const u8 *mac, __be32 ip,
-			    __u16 state, __u16 flags)
+			    __u16 state, __u16 flags,
+			    __u32 port, __u32 vni, __u32 ifindex)
 {
 	struct vxlan_fdb *f;
 	int notify = 0;
@@ -321,6 +373,14 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 			f->updated = jiffies;
 			notify = 1;
 		}
+		if ((flags & NLM_F_APPEND) &&
+		    is_multicast_ether_addr(f->eth_addr)) {
+			int rc = vxlan_fdb_append(f, ip, port, vni, ifindex);
+
+			if (rc < 0)
+				return rc;
+			notify |= rc;
+		}
 	} else {
 		if (!(flags & NLM_F_CREATE))
 			return -ENOENT;
@@ -334,7 +394,11 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 			return -ENOMEM;
 
 		notify = 1;
-		f->remote_ip = ip;
+		f->remote.remote_ip = ip;
+		f->remote.remote_port = port;
+		f->remote.remote_vni = vni;
+		f->remote.remote_ifindex = ifindex;
+		f->remote.remote_next = NULL;
 		f->state = state;
 		f->updated = f->used = jiffies;
 		memcpy(f->eth_addr, mac, ETH_ALEN);
@@ -350,6 +414,19 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 	return 0;
 }
 
+void vxlan_fdb_free(struct rcu_head *head)
+{
+	struct vxlan_fdb *f = container_of(head, struct vxlan_fdb, rcu);
+
+	while (f->remote.remote_next) {
+		struct vxlan_rdst *rd = f->remote.remote_next;
+
+		f->remote.remote_next = rd->remote_next;
+		kfree(rd);
+	}
+	kfree(f);
+}
+
 static void vxlan_fdb_destroy(struct vxlan_dev *vxlan, struct vxlan_fdb *f)
 {
 	netdev_dbg(vxlan->dev,
@@ -359,7 +436,7 @@ static void vxlan_fdb_destroy(struct vxlan_dev *vxlan, struct vxlan_fdb *f)
 	vxlan_fdb_notify(vxlan, f, RTM_DELNEIGH);
 
 	hlist_del_rcu(&f->hlist);
-	kfree_rcu(f, rcu);
+	call_rcu(&f->rcu, vxlan_fdb_free);
 }
 
 /* Add static entry (via netlink) */
@@ -368,7 +445,9 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 			 const unsigned char *addr, u16 flags)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct net *net = dev_net(vxlan->dev);
 	__be32 ip;
+	u32 port, vni, ifindex;
 	int err;
 
 	if (!(ndm->ndm_state & (NUD_PERMANENT|NUD_REACHABLE))) {
@@ -385,8 +464,36 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 
 	ip = nla_get_be32(tb[NDA_DST]);
 
+	if (tb[NDA_PORT]) {
+		if (nla_len(tb[NDA_PORT]) != sizeof(u32))
+			return -EINVAL;
+		port = nla_get_u32(tb[NDA_PORT]);
+	} else
+		port = vxlan_port;
+
+	if (tb[NDA_VNI]) {
+		if (nla_len(tb[NDA_VNI]) != sizeof(u32))
+			return -EINVAL;
+		vni = nla_get_u32(tb[NDA_VNI]);
+	} else
+		vni = vxlan->vni;
+
+	if (tb[NDA_IFINDEX]) {
+		struct net_device *dev;
+
+		if (nla_len(tb[NDA_IFINDEX]) != sizeof(u32))
+			return -EINVAL;
+		ifindex = nla_get_u32(tb[NDA_IFINDEX]);
+		dev = dev_get_by_index(net, ifindex);
+		if (!dev)
+			return -EADDRNOTAVAIL;
+		dev_put(dev);
+	} else
+		ifindex = 0;
+
 	spin_lock_bh(&vxlan->hash_lock);
-	err = vxlan_fdb_create(vxlan, addr, ip, ndm->ndm_state, flags);
+	err = vxlan_fdb_create(vxlan, addr, ip, ndm->ndm_state, flags, port,
+		vni, ifindex);
 	spin_unlock_bh(&vxlan->hash_lock);
 
 	return err;
@@ -425,18 +532,21 @@ static int vxlan_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 		int err;
 
 		hlist_for_each_entry_rcu(f, n, &vxlan->fdb_head[h], hlist) {
-			if (idx < cb->args[0])
-				goto skip;
-
-			err = vxlan_fdb_info(skb, vxlan, f,
-					     NETLINK_CB(cb->skb).portid,
-					     cb->nlh->nlmsg_seq,
-					     RTM_NEWNEIGH,
-					     NLM_F_MULTI);
-			if (err < 0)
-				break;
+			struct vxlan_rdst *rd;
+			for (rd = &f->remote; rd; rd = rd->remote_next) {
+				if (idx < cb->args[0])
+					goto skip;
+
+				err = vxlan_fdb_info(skb, vxlan, f,
+						     NETLINK_CB(cb->skb).portid,
+						     cb->nlh->nlmsg_seq,
+						     RTM_NEWNEIGH,
+						     NLM_F_MULTI, rd);
+				if (err < 0)
+					break;
 skip:
-			++idx;
+				++idx;
+			}
 		}
 	}
 
@@ -456,22 +566,23 @@ static void vxlan_snoop(struct net_device *dev,
 	f = vxlan_find_mac(vxlan, src_mac);
 	if (likely(f)) {
 		f->used = jiffies;
-		if (likely(f->remote_ip == src_ip))
+		if (likely(f->remote.remote_ip == src_ip))
 			return;
 
 		if (net_ratelimit())
 			netdev_info(dev,
 				    "%pM migrated from %pI4 to %pI4\n",
-				    src_mac, &f->remote_ip, &src_ip);
+				    src_mac, &f->remote.remote_ip, &src_ip);
 
-		f->remote_ip = src_ip;
+		f->remote.remote_ip = src_ip;
 		f->updated = jiffies;
 	} else {
 		/* learned new entry */
 		spin_lock(&vxlan->hash_lock);
 		err = vxlan_fdb_create(vxlan, src_mac, src_ip,
 				       NUD_REACHABLE,
-				       NLM_F_EXCL|NLM_F_CREATE);
+				       NLM_F_EXCL|NLM_F_CREATE,
+				       vxlan_port, vxlan->vni, 0);
 		spin_unlock(&vxlan->hash_lock);
 	}
 }
@@ -704,7 +815,7 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
 		}
 
 		f = vxlan_find_mac(vxlan, n->ha);
-		if (f && f->remote_ip == 0) {
+		if (f && f->remote.remote_ip == 0) {
 			/* bridge-local neighbor */
 			neigh_release(n);
 			goto out;
@@ -823,48 +934,27 @@ static u16 vxlan_src_port(const struct vxlan_dev *vxlan, struct sk_buff *skb)
 	return (((u64) hash * range) >> 32) + vxlan->port_min;
 }
 
-/* Transmit local packets over Vxlan
- *
- * Outer IP header inherits ECN and DF from inner header.
- * Outer UDP destination is the VXLAN assigned port.
- *           source port is based on hash of flow
- */
-static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
+				  struct vxlan_rdst *rdst, bool did_rsc)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct rtable *rt;
 	const struct iphdr *old_iph;
-	struct ethhdr *eth;
 	struct iphdr *iph;
 	struct vxlanhdr *vxh;
 	struct udphdr *uh;
 	struct flowi4 fl4;
 	unsigned int pkt_len = skb->len;
 	__be32 dst;
-	__u16 src_port;
+	__u16 src_port, dst_port;
+	u32 vni;
 	__be16 df = 0;
 	__u8 tos, ttl;
 	int err;
-	bool did_rsc = false;
-	const struct vxlan_fdb *f;
-
-	skb_reset_mac_header(skb);
-	eth = eth_hdr(skb);
-
-	if ((vxlan->flags & VXLAN_F_PROXY) && ntohs(eth->h_proto) == ETH_P_ARP)
-		return arp_reduce(dev, skb);
-	else if ((vxlan->flags&VXLAN_F_RSC) && ntohs(eth->h_proto) == ETH_P_IP)
-		did_rsc = route_shortcircuit(dev, skb);
 
-	f = vxlan_find_mac(vxlan, eth->h_dest);
-	if (f == NULL) {
-		did_rsc = false;
-		dst = vxlan->gaddr;
-		if (!dst && (vxlan->flags & VXLAN_F_L2MISS) &&
-		    !is_multicast_ether_addr(eth->h_dest))
-			vxlan_fdb_miss(vxlan, eth->h_dest);
-	} else
-		dst = f->remote_ip;
+	dst_port = rdst->remote_port ? rdst->remote_port : vxlan_port;
+	vni = rdst->remote_vni;
+	dst = rdst->remote_ip;
 
 	if (!dst) {
 		if (did_rsc) {
@@ -912,7 +1002,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	src_port = vxlan_src_port(vxlan, skb);
 
 	memset(&fl4, 0, sizeof(fl4));
-	fl4.flowi4_oif = vxlan->link;
+	fl4.flowi4_oif = rdst->remote_ifindex;
 	fl4.flowi4_tos = RT_TOS(tos);
 	fl4.daddr = dst;
 	fl4.saddr = vxlan->saddr;
@@ -939,13 +1029,13 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
 	vxh->vx_flags = htonl(VXLAN_FLAGS);
-	vxh->vx_vni = htonl(vxlan->vni << 8);
+	vxh->vx_vni = htonl(vni << 8);
 
 	__skb_push(skb, sizeof(*uh));
 	skb_reset_transport_header(skb);
 	uh = udp_hdr(skb);
 
-	uh->dest = htons(vxlan_port);
+	uh->dest = htons(dst_port);
 	uh->source = htons(src_port);
 
 	uh->len = htons(skb->len);
@@ -995,6 +1085,64 @@ tx_free:
 	return NETDEV_TX_OK;
 }
 
+/* Transmit local packets over Vxlan
+ *
+ * Outer IP header inherits ECN and DF from inner header.
+ * Outer UDP destination is the VXLAN assigned port.
+ *           source port is based on hash of flow
+ */
+static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct ethhdr *eth;
+	bool did_rsc = false;
+	struct vxlan_rdst group, *rdst0, *rdst;
+	struct vxlan_fdb *f;
+	int rc1, rc;
+
+	skb_reset_mac_header(skb);
+	eth = eth_hdr(skb);
+
+	if ((vxlan->flags & VXLAN_F_PROXY) && ntohs(eth->h_proto) == ETH_P_ARP)
+		return arp_reduce(dev, skb);
+	else if ((vxlan->flags&VXLAN_F_RSC) && ntohs(eth->h_proto) == ETH_P_IP)
+		did_rsc = route_shortcircuit(dev, skb);
+
+	f = vxlan_find_mac(vxlan, eth->h_dest);
+	if (f == NULL) {
+		did_rsc = false;
+		group.remote_port = vxlan_port;
+		group.remote_vni = vxlan->vni;
+		group.remote_ip = vxlan->gaddr;
+		group.remote_ifindex = vxlan->link;
+		group.remote_next = 0;
+		rdst0 = &group;
+
+		if (group.remote_ip == htonl(INADDR_ANY) &&
+		    (vxlan->flags & VXLAN_F_L2MISS) &&
+		    !is_multicast_ether_addr(eth->h_dest))
+			vxlan_fdb_miss(vxlan, eth->h_dest);
+	} else
+		rdst0 = &f->remote;
+
+	rc = NETDEV_TX_OK;
+
+	/* if there are multiple destinations, send copies */
+	for (rdst = rdst0->remote_next; rdst; rdst = rdst->remote_next) {
+		struct sk_buff *skb1;
+
+		skb1 = skb_clone(skb, GFP_ATOMIC);
+		rc1 = vxlan_xmit_one(skb1, dev, rdst, did_rsc);
+		if (rc == NETDEV_TX_OK)
+			rc = rc1;
+	}
+
+	rc1 = vxlan_xmit_one(skb, dev, rdst0, did_rsc);
+	if (rc == NETDEV_TX_OK)
+		rc = rc1;
+	return rc;
+}
+
 /* Walk the forwarding table and purge stale entries */
 static void vxlan_cleanup(unsigned long arg)
 {
@@ -1548,6 +1696,7 @@ static void __exit vxlan_cleanup_module(void)
 {
 	rtnl_link_unregister(&vxlan_link_ops);
 	unregister_pernet_device(&vxlan_net_ops);
+	rcu_barrier();
 }
 module_exit(vxlan_cleanup_module);
 
diff --git a/include/uapi/linux/neighbour.h b/include/uapi/linux/neighbour.h
index adb068c..f175212 100644
--- a/include/uapi/linux/neighbour.h
+++ b/include/uapi/linux/neighbour.h
@@ -21,6 +21,9 @@ enum {
 	NDA_CACHEINFO,
 	NDA_PROBES,
 	NDA_VLAN,
+	NDA_PORT,
+	NDA_VNI,
+	NDA_IFINDEX,
 	__NDA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d8aa20f..75bc33c 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2080,7 +2080,7 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	}
 
 	addr = nla_data(tb[NDA_LLADDR]);
-	if (!is_valid_ether_addr(addr)) {
+	if (is_zero_ether_addr(addr)) {
 		pr_info("PF_BRIDGE: RTM_NEWNEIGH with invalid ether address\n");
 		return -EINVAL;
 	}
