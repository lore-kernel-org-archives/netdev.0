From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v1 1/4] net-e1000e: fix ethtool set_features taking new features into account too late
Date: Mon, 21 Nov 2011 15:19:57 -0800
Message-ID: <22b29c09790d922f6e84ec623b8a691a7c3cd0a3.1321917278.git.david.decotigny@google.com>
References: <cover.1321917278.git.david.decotigny@google.com>
Cc: David Decotigny <david.decotigny@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1321917278.git.david.decotigny@google.com>
In-Reply-To: <cover.1321917278.git.david.decotigny@google.com>
References: <cover.1321917278.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Before this patch, the set_features() ethtool callback would not take
the new specified features into account when configuring the NIC. It
would only consider the current features, ie. the ones after previous
set_features(). A second ethtool set_features() with the same
specified features cannot work around that issue because it would boil
down to a nop (code checks wether specified features changed or not).

This patch solves this by propagating the requested features.

Tested:
  printk in code + custom ethtool (based on
  http://patchwork.ozlabs.org/patch/95836/)



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index a5bd7a3..b63f316 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5901,24 +5901,28 @@ static void e1000_eeprom_checks(struct e1000_adapter *adapter)
 }
 
 static int e1000_set_features(struct net_device *netdev,
-	netdev_features_t features)
+			      netdev_features_t features)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	netdev_features_t changed = features ^ netdev->features;
+	int retval = 1;  /* telling netdev that we are updating
+			  * netdev->features by ourselves */
+
+	netdev->features = features;
 
 	if (changed & (NETIF_F_TSO | NETIF_F_TSO6))
 		adapter->flags |= FLAG_TSO_FORCE;
 
 	if (!(changed & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX |
 			 NETIF_F_RXCSUM)))
-		return 0;
+		return retval;
 
 	if (netif_running(netdev))
 		e1000e_reinit_locked(adapter);
 	else
 		e1000e_reset(adapter);
 
-	return 0;
+	return retval;
 }
 
 static const struct net_device_ops e1000e_netdev_ops = {
-- 
1.7.3.1
