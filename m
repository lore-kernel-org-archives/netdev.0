From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] vlan: use a valid default mtu value for vlan over macsec
Date: Thu, 14 Jul 2016 18:00:10 +0200
Message-ID: <909348fc51775dc7070b528a7492632e53400412.1468511497.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44744 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751115AbcGNQBG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 12:01:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

macsec can't cope with mtu frames which need vlan tag insertion, and
vlan device set the default mtu equal to the underlying dev's one.
By default vlan over macsec devices use invalid mtu, dropping
all the large packets.
This patch adds a netif helper to check if an upper vlan device
needs mtu reduction. The helper is used during vlan devices
initialization to set a valid default and during mtu updating to
forbid invalid, too bit, mtu values.
The helper currently only check if the lower dev is a macsec device,
if we get more users, we need to update only the helper (possibly
reserving an additional IFF bit).

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/netdevice.h |  7 +++++++
 net/8021q/vlan_dev.c      | 10 ++++++----
 net/8021q/vlan_netlink.c  |  7 +++++--
 3 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 49736a3..8b24952 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4175,6 +4175,13 @@ static inline void netif_keep_dst(struct net_device *dev)
 	dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_XMIT_DST_RELEASE_PERM);
 }
 
+/* return true if dev can't cope with mtu frames that need vlan tag insertion */
+static inline bool netif_reduces_vlan_mtu(struct net_device *dev)
+{
+	/* TODO: reserve and use an additional IFF bit, if we get more users */
+	return dev->priv_flags & IFF_MACSEC;
+}
+
 extern struct pernet_operations __net_initdata loopback_net_ops;
 
 /* Logging, debugging and troubleshooting/diagnostic helpers. */
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index c8f422c..fbfacd5 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -146,10 +146,12 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 
 static int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
 {
-	/* TODO: gotta make sure the underlying layer can handle it,
-	 * maybe an IFF_VLAN_CAPABLE flag for devices?
-	 */
-	if (vlan_dev_priv(dev)->real_dev->mtu < new_mtu)
+	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
+	unsigned int max_mtu = real_dev->mtu;
+
+	if (netif_reduces_vlan_mtu(real_dev))
+		max_mtu -= VLAN_HLEN;
+	if (max_mtu < new_mtu)
 		return -ERANGE;
 
 	dev->mtu = new_mtu;
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index c92b52f..1270207 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -118,6 +118,7 @@ static int vlan_newlink(struct net *src_net, struct net_device *dev,
 {
 	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct net_device *real_dev;
+	unsigned int max_mtu;
 	__be16 proto;
 	int err;
 
@@ -144,9 +145,11 @@ static int vlan_newlink(struct net *src_net, struct net_device *dev,
 	if (err < 0)
 		return err;
 
+	max_mtu = netif_reduces_vlan_mtu(real_dev) ? real_dev->mtu - VLAN_HLEN :
+						     real_dev->mtu;
 	if (!tb[IFLA_MTU])
-		dev->mtu = real_dev->mtu;
-	else if (dev->mtu > real_dev->mtu)
+		dev->mtu = max_mtu;
+	else if (dev->mtu > max_mtu)
 		return -EINVAL;
 
 	err = vlan_changelink(dev, tb, data);
-- 
1.8.3.1
