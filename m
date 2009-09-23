From: Ben Greear <greearb@candelatech.com>
Subject: ixgbe patch to provide NIC's tx/rx counters via ethtool
Date: Wed, 23 Sep 2009 15:36:00 -0700
Message-ID: <4ABAA2D0.4030608@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050203020704040302000005"
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59225 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbZIWWf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 18:35:56 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n8NMa0pb000506
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 23 Sep 2009 15:36:00 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050203020704040302000005
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

When LRO is enabled, the received packet and byte counters represent the
LRO'd packets, not the packets/bytes on the wire.  The Intel 82599 NIC has
registers that keep count of the physical packets.  Add these counters to
the ethtool stats.  The byte counters are 36-bit, but the high 4 bits were
being ignored in the 2.6.31 ixgbe driver:  Read those as well to allow
longer time between polling the stats to detect wraps.

Signed-off-by: Ben Greear <greearb@candelatech.com>


Please do not apply this until the ixgbe authors ACK it.  There may
have been reasons for not reading the high 4 bits, or they may dislike
this approach entirely.


Here is ethtool stats output with LRO enabled, with patch applied:

#ethtool -S eth20
NIC statistics:
      rx_packets: 15944000
      tx_packets: 12339293
      rx_bytes: 272306022656
      tx_bytes: 940244184
      rx_pkts_nic: 187747191
      tx_pkts_nic: 12340822
      rx_bytes_nic: 284695533402
      tx_bytes_nic: 989725050
      lsc_int: 3
...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------050203020704040302000005
Content-Type: text/plain;
 name="ixgbe_stats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="ixgbe_stats.patch"

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index dff8dfa..da3cba3 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -53,6 +53,10 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"tx_packets", IXGBE_STAT(net_stats.tx_packets)},
 	{"rx_bytes", IXGBE_STAT(net_stats.rx_bytes)},
 	{"tx_bytes", IXGBE_STAT(net_stats.tx_bytes)},
+	{"rx_pkts_nic", IXGBE_STAT(stats.gprc)},
+	{"tx_pkts_nic", IXGBE_STAT(stats.gptc)},
+	{"rx_bytes_nic", IXGBE_STAT(stats.gorc)},
+	{"tx_bytes_nic", IXGBE_STAT(stats.gotc)},
 	{"lsc_int", IXGBE_STAT(lsc_int)},
 	{"tx_busy", IXGBE_STAT(tx_busy)},
 	{"non_eop_descs", IXGBE_STAT(non_eop_descs)},
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 77b0381..929a847 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4377,10 +4377,13 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 
 	/* 82598 hardware only has a 32 bit counter in the high register */
 	if (hw->mac.type == ixgbe_mac_82599EB) {
+		u64 tmp;
 		adapter->stats.gorc += IXGBE_READ_REG(hw, IXGBE_GORCL);
-		IXGBE_READ_REG(hw, IXGBE_GORCH); /* to clear */
+		tmp = IXGBE_READ_REG(hw, IXGBE_GORCH) & 0xF; /* 4 high bits of GORC */
+		adapter->stats.gorc += (tmp << 32);
 		adapter->stats.gotc += IXGBE_READ_REG(hw, IXGBE_GOTCL);
-		IXGBE_READ_REG(hw, IXGBE_GOTCH); /* to clear */
+		tmp = IXGBE_READ_REG(hw, IXGBE_GOTCH) & 0xF; /* 4 high bits of GOTC */
+		adapter->stats.gotc += (tmp << 32);
 		adapter->stats.tor += IXGBE_READ_REG(hw, IXGBE_TORL);
 		IXGBE_READ_REG(hw, IXGBE_TORH); /* to clear */
 		adapter->stats.lxonrxc += IXGBE_READ_REG(hw, IXGBE_LXONRXCNT);

--------------050203020704040302000005--
