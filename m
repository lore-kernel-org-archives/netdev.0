From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 3/6] vxlan: fix byte order issues with NDA_PORT
Date: Sat, 27 Apr 2013 14:31:54 -0700
Message-ID: <20130427213258.279619123@vyatta.com>
References: <20130427213151.255971631@vyatta.com>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:52171 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753544Ab3D0Vqg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Apr 2013 17:46:36 -0400
Content-Disposition: inline; filename=vxlan-nda-port-be16.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NDA_PORT attribute was added, but the author wasn't careful
about width (port is 16 bits), or byte order.  The attribute was
being dumped as 16 bits, but only 32 bit value would be accepted
when setting up a device. Also, the remote port is in network
byte order and was being compared with default port in host byte
order.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/vxlan.c	2013-04-27 13:38:57.232338603 -0700
+++ b/drivers/net/vxlan.c	2013-04-27 13:56:54.050412049 -0700
@@ -192,7 +192,7 @@ static int vxlan_fdb_info(struct sk_buff
 	if (send_ip && nla_put_be32(skb, NDA_DST, rdst->remote_ip))
 		goto nla_put_failure;
 
-	if (rdst->remote_port && rdst->remote_port != vxlan_port &&
+	if (rdst->remote_port && rdst->remote_port != htons(vxlan_port) &&
 	    nla_put_be16(skb, NDA_PORT, rdst->remote_port))
 		goto nla_put_failure;
 	if (rdst->remote_vni != vxlan->default_dst.remote_vni &&
@@ -222,7 +222,7 @@ static inline size_t vxlan_nlmsg_size(vo
 	return NLMSG_ALIGN(sizeof(struct ndmsg))
 		+ nla_total_size(ETH_ALEN) /* NDA_LLADDR */
 		+ nla_total_size(sizeof(__be32)) /* NDA_DST */
-		+ nla_total_size(sizeof(__be32)) /* NDA_PORT */
+		+ nla_total_size(sizeof(__be16)) /* NDA_PORT */
 		+ nla_total_size(sizeof(__be32)) /* NDA_VNI */
 		+ nla_total_size(sizeof(__u32)) /* NDA_IFINDEX */
 		+ nla_total_size(sizeof(struct nda_cacheinfo));
@@ -317,7 +317,7 @@ static struct vxlan_fdb *vxlan_find_mac(
 
 /* Add/update destinations for multicast */
 static int vxlan_fdb_append(struct vxlan_fdb *f,
-			    __be32 ip, __u32 port, __u32 vni, __u32 ifindex)
+			    __be32 ip, __be16 port, __u32 vni, __u32 ifindex)
 {
 	struct vxlan_rdst *rd_prev, *rd;
 
@@ -346,7 +346,7 @@ static int vxlan_fdb_append(struct vxlan
 static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 			    const u8 *mac, __be32 ip,
 			    __u16 state, __u16 flags,
-			    __u32 port, __u32 vni, __u32 ifindex,
+			    __be16 port, __u32 vni, __u32 ifindex,
 			    __u8 ndm_flags)
 {
 	struct vxlan_fdb *f;
@@ -444,7 +444,8 @@ static int vxlan_fdb_add(struct ndmsg *n
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct net *net = dev_net(vxlan->dev);
 	__be32 ip;
-	u32 port, vni, ifindex;
+	__be16 port;
+	u32 vni, ifindex;
 	int err;
 
 	if (!(ndm->ndm_state & (NUD_PERMANENT|NUD_REACHABLE))) {
@@ -462,11 +463,11 @@ static int vxlan_fdb_add(struct ndmsg *n
 	ip = nla_get_be32(tb[NDA_DST]);
 
 	if (tb[NDA_PORT]) {
-		if (nla_len(tb[NDA_PORT]) != sizeof(u32))
+		if (nla_len(tb[NDA_PORT]) != sizeof(__be16))
 			return -EINVAL;
-		port = nla_get_u32(tb[NDA_PORT]);
+		port = nla_get_be16(tb[NDA_PORT]);
 	} else
-		port = vxlan_port;
+		port = htons(vxlan_port);
 
 	if (tb[NDA_VNI]) {
 		if (nla_len(tb[NDA_VNI]) != sizeof(u32))
@@ -489,8 +490,8 @@ static int vxlan_fdb_add(struct ndmsg *n
 		ifindex = 0;
 
 	spin_lock_bh(&vxlan->hash_lock);
-	err = vxlan_fdb_create(vxlan, addr, ip, ndm->ndm_state, flags, port,
-		vni, ifindex, ndm->ndm_flags);
+	err = vxlan_fdb_create(vxlan, addr, ip, ndm->ndm_state, flags,
+			       port, vni, ifindex, ndm->ndm_flags);
 	spin_unlock_bh(&vxlan->hash_lock);
 
 	return err;
@@ -964,12 +965,13 @@ static netdev_tx_t vxlan_xmit_one(struct
 	struct udphdr *uh;
 	struct flowi4 fl4;
 	__be32 dst;
-	__u16 src_port, dst_port;
+	__u16 src_port;
+	__be16 dst_port;
         u32 vni;
 	__be16 df = 0;
 	__u8 tos, ttl;
 
-	dst_port = rdst->remote_port ? rdst->remote_port : vxlan_port;
+	dst_port = rdst->remote_port ? rdst->remote_port : htons(vxlan_port);
 	vni = rdst->remote_vni;
 	dst = rdst->remote_ip;
 
@@ -1050,7 +1052,7 @@ static netdev_tx_t vxlan_xmit_one(struct
 	skb_reset_transport_header(skb);
 	uh = udp_hdr(skb);
 
-	uh->dest = htons(dst_port);
+	uh->dest = dst_port;
 	uh->source = htons(src_port);
 
 	uh->len = htons(skb->len);
