From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.6 1/11] ixgb: Fix multi-cast packet
 count in statistics
Date: Thu, 28 Apr 2005 18:45:50 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281844080.28003-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix multi-cast packet count in statistics

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2005-04-05 23:06:36.332229456 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2005-04-05 23:06:38.283932752 -0700
@@ -1526,14 +1526,33 @@ ixgb_change_mtu(struct net_device *netde
 void
 ixgb_update_stats(struct ixgb_adapter *adapter)
 {
+	struct net_device *netdev = adapter->netdev;
+
+	if((netdev->flags & IFF_PROMISC) || (netdev->flags & IFF_ALLMULTI) ||
+	   (netdev->mc_count > IXGB_MAX_NUM_MULTICAST_ADDRESSES)) {
+		u64 multi = IXGB_READ_REG(&adapter->hw, MPRCL);
+		u32 bcast_l = IXGB_READ_REG(&adapter->hw, BPRCL);
+		u32 bcast_h = IXGB_READ_REG(&adapter->hw, BPRCH);
+		u64 bcast = ((u64)bcast_h << 32) | bcast_l; 
+
+		multi |= ((u64)IXGB_READ_REG(&adapter->hw, MPRCH) << 32);
+		/* fix up multicast stats by removing broadcasts */
+		multi -= bcast;
+		
+		adapter->stats.mprcl += (multi & 0xFFFFFFFF);
+		adapter->stats.mprch += (multi >> 32);
+		adapter->stats.bprcl += bcast_l; 
+		adapter->stats.bprch += bcast_h;
+	} else {
+		adapter->stats.mprcl += IXGB_READ_REG(&adapter->hw, MPRCL);
+		adapter->stats.mprch += IXGB_READ_REG(&adapter->hw, MPRCH);
+		adapter->stats.bprcl += IXGB_READ_REG(&adapter->hw, BPRCL);
+		adapter->stats.bprch += IXGB_READ_REG(&adapter->hw, BPRCH);
+	}
 	adapter->stats.tprl += IXGB_READ_REG(&adapter->hw, TPRL);
 	adapter->stats.tprh += IXGB_READ_REG(&adapter->hw, TPRH);
 	adapter->stats.gprcl += IXGB_READ_REG(&adapter->hw, GPRCL);
 	adapter->stats.gprch += IXGB_READ_REG(&adapter->hw, GPRCH);
-	adapter->stats.bprcl += IXGB_READ_REG(&adapter->hw, BPRCL);
-	adapter->stats.bprch += IXGB_READ_REG(&adapter->hw, BPRCH);
-	adapter->stats.mprcl += IXGB_READ_REG(&adapter->hw, MPRCL);
-	adapter->stats.mprch += IXGB_READ_REG(&adapter->hw, MPRCH);
 	adapter->stats.uprcl += IXGB_READ_REG(&adapter->hw, UPRCL);
 	adapter->stats.uprch += IXGB_READ_REG(&adapter->hw, UPRCH);
 	adapter->stats.vprcl += IXGB_READ_REG(&adapter->hw, VPRCL);
