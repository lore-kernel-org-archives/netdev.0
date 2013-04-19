From: David L Stevens <dlstevens@us.ibm.com>
Subject: [PATCH net-next] VXLAN: Allow L2 redirection with L3 switching
Date: Fri, 19 Apr 2013 06:36:26 -0400
Message-ID: <201304191036.r3JAaQ6p005959@lab1.dls>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:44611 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756835Ab3DSKhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 06:37:38 -0400
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Fri, 19 Apr 2013 04:37:37 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id D231619D8043
	for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 04:37:21 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3JAbQKQ364730
	for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 04:37:26 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3JAbQN7013872
	for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 04:37:26 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Allow L2 redirection when VXLAN L3 switching is enabled

This patch restricts L3 switching to destination MAC addresses that are
marked as routers in order to allow virtual IP appliances that do L2
redirection to function with VXLAN L3 switching enabled.

We use L3 switching on VXLAN networks to avoid extra hops when the nominal
router for cross-subnet traffic for a VM is remote and the ultimate
destination may be local, or closer to the local node. Currently, the
destination IP address takes precedence over the MAC address in all cases.
Some network appliances receive packets for a virtualized IP address and
redirect by changing the destination MAC address (only) to be the final
destination for packet processing. VXLAN tunnel endpoints with L3 switching
enabled may then overwrite this destination MAC address based on the packet IP
address, resulting in potential loops and, at least, breaking L2 redirections
that travel through tunnel endpoints.

This patch limits L3 switching to the intended case where the original
destination MAC address is a next-hop router and relies on the destination
MAC address for all other cases, thus allowing L2 redirection and L3 switching
to coexist peacefully.

Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 916a621..a7fd9a0 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -98,6 +98,7 @@ struct vxlan_fdb {
 	unsigned long	  used;
 	struct vxlan_rdst remote;
 	u16		  state;	/* see ndm_state */
+	u8		  flags;	/* see ndm_flags */
 	u8		  eth_addr[ETH_ALEN];
 };
 
@@ -180,7 +181,7 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 		ndm->ndm_family	= AF_BRIDGE;
 	ndm->ndm_state = fdb->state;
 	ndm->ndm_ifindex = vxlan->dev->ifindex;
-	ndm->ndm_flags = NTF_SELF;
+	ndm->ndm_flags = fdb->flags;
 	ndm->ndm_type = NDA_DST;
 
 	if (send_eth && nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->eth_addr))
@@ -343,7 +344,8 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
 static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 			    const u8 *mac, __be32 ip,
 			    __u16 state, __u16 flags,
-			    __u32 port, __u32 vni, __u32 ifindex)
+			    __u32 port, __u32 vni, __u32 ifindex,
+			    __u8 ndm_flags)
 {
 	struct vxlan_fdb *f;
 	int notify = 0;
@@ -360,6 +362,11 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 			f->updated = jiffies;
 			notify = 1;
 		}
+		if (f->flags != ndm_flags) {
+			f->flags = ndm_flags;
+			f->updated = jiffies;
+			notify = 1;
+		}
 		if ((flags & NLM_F_APPEND) &&
 		    is_multicast_ether_addr(f->eth_addr)) {
 			int rc = vxlan_fdb_append(f, ip, port, vni, ifindex);
@@ -387,6 +394,7 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 		f->remote.remote_ifindex = ifindex;
 		f->remote.remote_next = NULL;
 		f->state = state;
+		f->flags = ndm_flags;
 		f->updated = f->used = jiffies;
 		memcpy(f->eth_addr, mac, ETH_ALEN);
 
@@ -480,7 +488,7 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 
 	spin_lock_bh(&vxlan->hash_lock);
 	err = vxlan_fdb_create(vxlan, addr, ip, ndm->ndm_state, flags, port,
-		vni, ifindex);
+		vni, ifindex, ndm->ndm_flags);
 	spin_unlock_bh(&vxlan->hash_lock);
 
 	return err;
@@ -568,7 +576,9 @@ static void vxlan_snoop(struct net_device *dev,
 		err = vxlan_fdb_create(vxlan, src_mac, src_ip,
 				       NUD_REACHABLE,
 				       NLM_F_EXCL|NLM_F_CREATE,
-				       vxlan_port, vxlan->default_dst.remote_vni, 0);
+				       vxlan_port,
+				       vxlan->default_dst.remote_vni,
+				       0, NTF_SELF);
 		spin_unlock(&vxlan->hash_lock);
 	}
 }
@@ -1098,12 +1108,18 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if ((vxlan->flags & VXLAN_F_PROXY) && ntohs(eth->h_proto) == ETH_P_ARP)
 		return arp_reduce(dev, skb);
-	else if ((vxlan->flags&VXLAN_F_RSC) && ntohs(eth->h_proto) == ETH_P_IP)
-		did_rsc = route_shortcircuit(dev, skb);
 
 	f = vxlan_find_mac(vxlan, eth->h_dest);
+	did_rsc = false;
+
+	if (f && (f->flags & NTF_ROUTER) && (vxlan->flags & VXLAN_F_RSC) &&
+	    ntohs(eth->h_proto) == ETH_P_IP) {
+		did_rsc = route_shortcircuit(dev, skb);
+		if (did_rsc)
+			f = vxlan_find_mac(vxlan, eth->h_dest);
+	}
+
 	if (f == NULL) {
-		did_rsc = false;
 		rdst0 = &vxlan->default_dst;
 
 		if (rdst0->remote_ip == htonl(INADDR_ANY) &&
