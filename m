From: ganesh.venkatesan@intel.com
Subject: [PATCH 1/6 2.5] e100 - restore speed/duplex/autoneg settings after
 diagnostic test
Date: Thu, 29 Jul 2004 08:26:22 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407290643410.21929-100000@westville2.jf.intel.com>
Reply-To: ganesh.venkatesan@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--- linux-2.5/drivers/net/e100.c	2004-07-29 00:23:31.781375960 -0700
+++ linux-2.5/drivers/net/e100.c.mod	2004-07-29 00:24:52.375123848 -0700
@@ -1961,18 +1961,27 @@ static int e100_diag_test_count(struct n
 static void e100_diag_test(struct net_device *netdev,
 	struct ethtool_test *test, u64 *data)
 {
+	struct ethtool_cmd cmd;
 	struct nic *nic = netdev_priv(netdev);
-	int i;
+	int i, err;
 
 	memset(data, 0, E100_TEST_LEN * sizeof(u64));
 	data[0] = !mii_link_ok(&nic->mii);
 	data[1] = e100_eeprom_load(nic);
 	if(test->flags & ETH_TEST_FL_OFFLINE) {
+
+		/* save speed, duplex & autoneg settings */
+		err = mii_ethtool_gset(&nic->mii, &cmd);
+
 		if(netif_running(netdev))
 			e100_down(nic);
 		data[2] = e100_self_test(nic);
 		data[3] = e100_loopback_test(nic, lb_mac);
 		data[4] = e100_loopback_test(nic, lb_phy);
+
+		/* restore speed, duplex & autoneg settings */
+		err = mii_ethtool_sset(&nic->mii, &cmd);
+
 		if(netif_running(netdev))
 			e100_up(nic);
 	}
