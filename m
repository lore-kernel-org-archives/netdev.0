From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] vxlan: fix test which detect duplicate vxlan iface
Date: Thu,  7 Jan 2016 11:26:53 +0100
Message-ID: <1452162413-4227-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:59190 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbcAGK1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 05:27:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a vxlan interface is created, the driver checks that there is not
another vxlan interface with the same properties. To do this, it checks
the existing vxlan udp socket. Since commit 1c51a9159dde, the creation of
the vxlan socket is done only when the interface is set up, thus it breaks
that test.

Example:
$ ip l a vxlan10 type vxlan id 10 group 239.0.0.10 dev eth0 dstport 0
$ ip l a vxlan11 type vxlan id 10 group 239.0.0.10 dev eth0 dstport 0
$ ip -br l | grep vxlan
vxlan10          DOWN           f2:55:1c:6a:fb:00 <BROADCAST,MULTICAST>
vxlan11          DOWN           7a:cb:b9:38:59:0d <BROADCAST,MULTICAST>

Instead of checking sockets, let's loop over the vxlan iface list.

Fixes: 1c51a9159dde ("vxlan: fix race caused by dropping rtnl_unlock")
Reported-by: Thomas Faivre <thomas.faivre@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/vxlan.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ba363cedef80..405a7b6cca25 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2751,7 +2751,7 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 			       struct vxlan_config *conf)
 {
 	struct vxlan_net *vn = net_generic(src_net, vxlan_net_id);
-	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_dev *vxlan = netdev_priv(dev), *tmp;
 	struct vxlan_rdst *dst = &vxlan->default_dst;
 	unsigned short needed_headroom = ETH_HLEN;
 	int err;
@@ -2817,9 +2817,15 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 	if (!vxlan->cfg.age_interval)
 		vxlan->cfg.age_interval = FDB_AGE_DEFAULT;
 
-	if (vxlan_find_vni(src_net, conf->vni, use_ipv6 ? AF_INET6 : AF_INET,
-			   vxlan->cfg.dst_port, vxlan->flags))
+	list_for_each_entry(tmp, &vn->vxlan_list, next) {
+		if (tmp->cfg.vni == conf->vni &&
+		    (tmp->default_dst.remote_ip.sa.sa_family == AF_INET6 ||
+		     tmp->cfg.saddr.sa.sa_family == AF_INET6) == use_ipv6 &&
+		    tmp->cfg.dst_port == vxlan->cfg.dst_port &&
+		    (tmp->flags & VXLAN_F_RCV_FLAGS) ==
+		    (vxlan->flags & VXLAN_F_RCV_FLAGS))
 		return -EEXIST;
+	}
 
 	dev->ethtool_ops = &vxlan_ethtool_ops;
 
-- 
2.4.2
