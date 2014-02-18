From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net] veth: Fix vlan_features so as to be able to use stacked vlan interfaces
Date: Tue, 18 Feb 2014 21:20:08 +0900
Message-ID: <1392726009-8083-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Flavio Leitner <fbl@redhat.com>, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:52160 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753906AbaBRMUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 07:20:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even if we create a stacked vlan interface such as veth0.10.20, it sends
single tagged frames (tagged with only vid 10).
Because vlan_features of a veth interface has the
NETIF_F_HW_VLAN_[CTAG/STAG]_TX bits, veth0.10 also has that feature, so
dev_hard_start_xmit(veth0.10) doesn't call __vlan_put_tag() and
vlan_dev_hard_start_xmit(veth0.10) overwrites vlan_tci.
This prevents us from using a combination of 802.1ad and 802.1Q
in containers, etc.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 drivers/net/veth.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 2ec2041..5b37437 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -285,7 +285,8 @@ static void veth_setup(struct net_device *dev)
 	dev->ethtool_ops = &veth_ethtool_ops;
 	dev->features |= NETIF_F_LLTX;
 	dev->features |= VETH_FEATURES;
-	dev->vlan_features = dev->features;
+	dev->vlan_features = dev->features &
+			     ~(NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX);
 	dev->destructor = veth_dev_free;
 
 	dev->hw_features = VETH_FEATURES;
-- 
1.8.1.2
