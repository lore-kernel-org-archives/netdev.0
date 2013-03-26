From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] VXLAN: Precompute vin for VXLAN header.
Date: Tue, 26 Mar 2013 11:28:59 -0700
Message-ID: <1364322539-27141-1-git-send-email-pshelar@nicira.com>
Cc: davem@davemloft.net, jesse@nicira.com,
	Pravin B Shelar <pshelar@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:39982 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1760058Ab3CZS3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 14:29:18 -0400
Received: by mail-pd0-f200.google.com with SMTP id w10so6798033pde.3
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 11:29:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compute VXLAN vin at time of device create so that there is no need
to translate it on packet send and receive.
This patch do not change userspace interface.

CC: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 7624ab1..8faebf7 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -105,7 +105,7 @@ struct vxlan_fdb {
 struct vxlan_dev {
 	struct hlist_node hlist;
 	struct net_device *dev;
-	__u32		  vni;		/* virtual network id */
+	__be32		  vni;		/* virtual network id */
 	__be32	          gaddr;	/* multicast group */
 	__be32		  saddr;	/* source address */
 	unsigned int      link;		/* link to multicast over */
@@ -133,15 +133,15 @@ struct vxlan_dev {
 /* salt for hash table */
 static u32 vxlan_salt __read_mostly;
 
-static inline struct hlist_head *vni_head(struct net *net, u32 id)
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
 
@@ -658,7 +658,6 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	struct vxlanhdr *vxh;
 	struct vxlan_dev *vxlan;
 	struct pcpu_tstats *stats;
-	__u32 vni;
 	int err;
 
 	/* pop off outer UDP header */
@@ -680,10 +679,10 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	__skb_pull(skb, sizeof(struct vxlanhdr));
 
 	/* Is this VNI defined? */
-	vni = ntohl(vxh->vx_vni) >> 8;
-	vxlan = vxlan_find_vni(sock_net(sk), vni);
+	vxlan = vxlan_find_vni(sock_net(sk), vxh->vx_vni);
 	if (!vxlan) {
-		netdev_dbg(skb->dev, "unknown vni %d\n", vni);
+		netdev_dbg(skb->dev, "unknown vni %d\n",
+			   (ntohl(vxh->vx_vni) >> 8));
 		goto drop;
 	}
 
@@ -1006,7 +1004,7 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
 	vxh->vx_flags = htonl(VXLAN_FLAGS);
-	vxh->vx_vni = htonl(vni << 8);
+	vxh->vx_vni = vxlan->vni;
 
 	__skb_push(skb, sizeof(*uh));
 	skb_reset_transport_header(skb);
@@ -1359,15 +1357,17 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	__u32 vni;
+	__u32 id;
+	__be32 vni;
 	int err;
 
 	if (!data[IFLA_VXLAN_ID])
 		return -EINVAL;
 
-	vni = nla_get_u32(data[IFLA_VXLAN_ID]);
+	id = nla_get_u32(data[IFLA_VXLAN_ID]);
+	vni = htonl(id << 8);
 	if (vxlan_find_vni(net, vni)) {
-		pr_info("duplicate VNI %u\n", vni);
+		pr_info("duplicate VNI %u\n", id);
 		return -EEXIST;
 	}
 	vxlan->vni = vni;
@@ -1478,7 +1478,7 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 		.high = htons(vxlan->port_max),
 	};
 
-	if (nla_put_u32(skb, IFLA_VXLAN_ID, vxlan->vni))
+	if (nla_put_u32(skb, IFLA_VXLAN_ID, (ntohl(vxlan->vni) >> 8)))
 		goto nla_put_failure;
 
 	if (vxlan->gaddr && nla_put_be32(skb, IFLA_VXLAN_GROUP, vxlan->gaddr))
-- 
1.7.1
