From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 2/2] vxlan: setup the right link netns in newlink hdlr
Date: Mon, 26 Jan 2015 22:28:14 +0100
Message-ID: <1422307694-10079-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1422307694-10079-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, dmitry.tarnyagin@lockless.no,
	arvid.brodin@alten.se, alex.aring@gmail.com,
	linux-wpan@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:41144 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958AbbAZV2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 16:28:42 -0500
In-Reply-To: <1422307694-10079-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename the netns to src_net to avoid confusion with the netns where the
interface stands. The user may specify IFLA_NET_NS_[PID|FD] to create
a x-netns netndevice: IFLA_NET_NS_[PID|FD] points to the netns where the
netdevice stands and src_net to the link netns.

Note that before commit f01ec1c017de ("vxlan: add x-netns support"), it was
possible to create a x-netns vxlan netdevice, but the netdevice was not
operational.

Fixes: f01ec1c017de ("vxlan: add x-netns support")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/vxlan.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 7fbd89fbe107..a8c755dcab14 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2432,10 +2432,10 @@ static void vxlan_sock_work(struct work_struct *work)
 	dev_put(vxlan->dev);
 }
 
-static int vxlan_newlink(struct net *net, struct net_device *dev,
+static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
-	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
+	struct vxlan_net *vn = net_generic(src_net, vxlan_net_id);
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_rdst *dst = &vxlan->default_dst;
 	__u32 vni;
@@ -2445,7 +2445,7 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 	if (!data[IFLA_VXLAN_ID])
 		return -EINVAL;
 
-	vxlan->net = dev_net(dev);
+	vxlan->net = src_net;
 
 	vni = nla_get_u32(data[IFLA_VXLAN_ID]);
 	dst->remote_vni = vni;
@@ -2481,7 +2481,7 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 	if (data[IFLA_VXLAN_LINK] &&
 	    (dst->remote_ifindex = nla_get_u32(data[IFLA_VXLAN_LINK]))) {
 		struct net_device *lowerdev
-			 = __dev_get_by_index(net, dst->remote_ifindex);
+			 = __dev_get_by_index(src_net, dst->remote_ifindex);
 
 		if (!lowerdev) {
 			pr_info("ifindex %d does not exist\n", dst->remote_ifindex);
@@ -2557,7 +2557,7 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 	    nla_get_u8(data[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]))
 		vxlan->flags |= VXLAN_F_UDP_ZERO_CSUM6_RX;
 
-	if (vxlan_find_vni(net, vni, use_ipv6 ? AF_INET6 : AF_INET,
+	if (vxlan_find_vni(src_net, vni, use_ipv6 ? AF_INET6 : AF_INET,
 			   vxlan->dst_port)) {
 		pr_info("duplicate VNI %u\n", vni);
 		return -EEXIST;
-- 
2.2.2
