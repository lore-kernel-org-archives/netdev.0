From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [RFC][PATCH 1/2] net: vlan: enable GSO by default
Date: Fri, 24 Jun 2011 11:38:44 +0800
Message-ID: <4E0406C4.6060004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: =?UTF-8?B?5Y2V5Y2r?= <shanwei@cn.fujitsu.com>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCY
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55787 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751304Ab1FXDho (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2011 23:37:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, GSO for vlan device is off, and can't be set to on.
Although underlying device don't support TSO, we still
should use software segments for vlan device.

In vlan_dev_fix_features(), final features is decided by
features of real device and vlan_features of real device.

real_dev->vlan_features is initialized in register_netdevice()
only with NETIF_F_GRO, not NETIF_F_GSO.

So, now GRO is ok, but GSO is broken by default.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/8021q/vlan_dev.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 1c9aa8c..d8f45ba 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -588,9 +588,14 @@ static void vlan_dev_uninit(struct net_device *dev)
 static u32 vlan_dev_fix_features(struct net_device *dev, u32 features)
 {
 	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	u32 old_features = features;
 
 	features &= real_dev->features;
 	features &= real_dev->vlan_features;
+
+	if (old_features & NETIF_F_SOFT_FEATURES)
+		features |= old_features & NETIF_F_SOFT_FEATURES;
+
 	if (dev_ethtool_get_rx_csum(real_dev))
 		features |= NETIF_F_RXCSUM;
 	features |= NETIF_F_LLTX;
-- 
1.7.4.1
