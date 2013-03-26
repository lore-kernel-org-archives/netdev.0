From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v2 net-next] VXLAN: Precompute vin for VXLAN header.
Date: Tue, 26 Mar 2013 14:33:14 -0700
Message-ID: <1364333594-8809-1-git-send-email-pshelar@nicira.com>
Cc: davem@davemloft.net, jesse@nicira.com,
	Pravin B Shelar <pshelar@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Stevens <dlstevens@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:47336 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751914Ab3CZVd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 17:33:26 -0400
Received: by mail-da0-f72.google.com with SMTP id q27so6073009daj.3
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 14:33:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compute VXLAN vin at time of device create so that there is no need
to translate it on packet send and receive.
This patch do not change userspace interface.

CC: Stephen Hemminger <stephen@networkplumber.org>
CC: David Stevens <dlstevens@us.ibm.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
v1-v2:
  - Fixed fdb vni.
---
 drivers/net/vxlan.c |   54 +++++++++++++++++++++++++++++---------------------
 1 files changed, 31 insertions(+), 23 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 7624ab1..a755da0 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -85,7 +85,7 @@ struct vxlan_rdst {
 	struct rcu_head		 rcu;
 	__be32			 remote_ip;
 	__be16			 remote_port;
-	u32			 remote_vni;
+	__be32			 remote_vni;
 	u32			 remote_ifindex;
 	struct vxlan_rdst	*remote_next;
 };
@@ -105,7 +105,7 @@ struct vxlan_fdb {
 struct vxlan_dev {
 	struct hlist_node hlist;
 	struct net_device *dev;
-	__u32		  vni;		/* virtual network id */
+	__be32		  vni;		/* virtual network id */
 	__be32	          gaddr;	/* multicast group */
 	__be32		  saddr;	/* source address */
 	unsigned int      link;		/* link to multicast over */
@@ -133,15 +133,25 @@ struct vxlan_dev {
 /* salt for hash table */
 static u32 vxlan_salt __read_mostly;
 
-static inline struct hlist_head *vni_head(struct net *net, u32 id)
+static u32 vni_to_vid(__be32 vni)
+{
+	return ntohl(vni) >> 8;
+}
+
+static __be32 vid_to_vni(u32 id)
+{
+	return htonl(id << 8);
+}
+
+static inline struct hlist_head *vni_head(struct net *net, __be32 id)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 
-	return &vn->vni_list[hash_32(id, VNI_HASH_BITS)];
+	return &vn->vni_list[hash_32((__force u32)id, VNI_HASH_BITS)];
 }
 
 /* Look up VNI in a per net namespace table */
-static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id)
+static struct vxlan_dev *vxlan_find_vni(struct net *net, __be32 id)
 {
 	struct vxlan_dev *vxlan;
 
@@ -195,7 +205,7 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 	    nla_put_be16(skb, NDA_PORT, rdst->remote_port))
 		goto nla_put_failure;
 	if (rdst->remote_vni != vxlan->vni &&
-	    nla_put_be32(skb, NDA_VNI, rdst->remote_vni))
+	    nla_put_be32(skb, NDA_VNI, vni_to_vid(rdst->remote_vni)))
 		goto nla_put_failure;
 	if (rdst->remote_ifindex &&
 	    nla_put_u32(skb, NDA_IFINDEX, rdst->remote_ifindex))
@@ -261,7 +271,7 @@ static void vxlan_ip_miss(struct net_device *dev, __be32 ipa)
 	memset(&f, 0, sizeof f);
 	f.state = NUD_STALE;
 	f.remote.remote_ip = ipa; /* goes to NDA_DST */
-	f.remote.remote_vni = VXLAN_N_VID;
+	f.remote.remote_vni = vid_to_vni(VXLAN_N_VID);
 
 	vxlan_fdb_notify(vxlan, &f, RTM_GETNEIGH);
 }
@@ -316,7 +326,7 @@ static struct vxlan_fdb *vxlan_find_mac(struct vxlan_dev *vxlan,
 
 /* Add/update destinations for multicast */
 static int vxlan_fdb_append(struct vxlan_fdb *f,
-			    __be32 ip, __u32 port, __u32 vni, __u32 ifindex)
+			    __be32 ip, __u32 port, __be32 vni, __u32 ifindex)
 {
 	struct vxlan_rdst *rd_prev, *rd;
 
@@ -345,7 +355,7 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
 static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 			    const u8 *mac, __be32 ip,
 			    __u16 state, __u16 flags,
-			    __u32 port, __u32 vni, __u32 ifindex)
+			    __u32 port, __be32 vni, __u32 ifindex)
 {
 	struct vxlan_fdb *f;
 	int notify = 0;
@@ -436,7 +446,8 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct net *net = dev_net(vxlan->dev);
 	__be32 ip;
-	u32 port, vni, ifindex;
+	u32 port, ifindex;
+	__be32 vni;
 	int err;
 
 	if (!(ndm->ndm_state & (NUD_PERMANENT|NUD_REACHABLE))) {
@@ -463,7 +474,7 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	if (tb[NDA_VNI]) {
 		if (nla_len(tb[NDA_VNI]) != sizeof(u32))
 			return -EINVAL;
-		vni = nla_get_u32(tb[NDA_VNI]);
+		vni = vid_to_vni(nla_get_u32(tb[NDA_VNI]));
 	} else
 		vni = vxlan->vni;
 
@@ -658,7 +669,6 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	struct vxlanhdr *vxh;
 	struct vxlan_dev *vxlan;
 	struct pcpu_tstats *stats;
-	__u32 vni;
 	int err;
 
 	/* pop off outer UDP header */
@@ -673,17 +683,17 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (vxh->vx_flags != htonl(VXLAN_FLAGS) ||
 	    (vxh->vx_vni & htonl(0xff))) {
 		netdev_dbg(skb->dev, "invalid vxlan flags=%#x vni=%#x\n",
-			   ntohl(vxh->vx_flags), ntohl(vxh->vx_vni));
+			   ntohl(vxh->vx_flags), vni_to_vid(vxh->vx_vni));
 		goto error;
 	}
 
 	__skb_pull(skb, sizeof(struct vxlanhdr));
 
 	/* Is this VNI defined? */
-	vni = ntohl(vxh->vx_vni) >> 8;
-	vxlan = vxlan_find_vni(sock_net(sk), vni);
+	vxlan = vxlan_find_vni(sock_net(sk), vxh->vx_vni);
 	if (!vxlan) {
-		netdev_dbg(skb->dev, "unknown vni %d\n", vni);
+		netdev_dbg(skb->dev, "unknown vni %d\n",
+			   vni_to_vid(vxh->vx_vni));
 		goto drop;
 	}
 
@@ -926,12 +936,10 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	unsigned int pkt_len = skb->len;
 	__be32 dst;
 	__u16 src_port, dst_port;
-        u32 vni;
 	__be16 df = 0;
 	__u8 tos, ttl;
 
 	dst_port = rdst->remote_port ? rdst->remote_port : vxlan_port;
-	vni = rdst->remote_vni;
 	dst = rdst->remote_ip;
 
 	if (!dst) {
@@ -1006,7 +1014,7 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
 	vxh->vx_flags = htonl(VXLAN_FLAGS);
-	vxh->vx_vni = htonl(vni << 8);
+	vxh->vx_vni = rdst->remote_vni;
 
 	__skb_push(skb, sizeof(*uh));
 	skb_reset_transport_header(skb);
@@ -1359,15 +1367,15 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	__u32 vni;
+	__be32 vni;
 	int err;
 
 	if (!data[IFLA_VXLAN_ID])
 		return -EINVAL;
 
-	vni = nla_get_u32(data[IFLA_VXLAN_ID]);
+	vni = vid_to_vni(nla_get_u32(data[IFLA_VXLAN_ID]));
 	if (vxlan_find_vni(net, vni)) {
-		pr_info("duplicate VNI %u\n", vni);
+		pr_info("duplicate VNI %u\n", vni_to_vid(vni));
 		return -EEXIST;
 	}
 	vxlan->vni = vni;
@@ -1478,7 +1486,7 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 		.high = htons(vxlan->port_max),
 	};
 
-	if (nla_put_u32(skb, IFLA_VXLAN_ID, vxlan->vni))
+	if (nla_put_u32(skb, IFLA_VXLAN_ID, vni_to_vid(vxlan->vni)))
 		goto nla_put_failure;
 
 	if (vxlan->gaddr && nla_put_be32(skb, IFLA_VXLAN_GROUP, vxlan->gaddr))
-- 
1.7.1
