From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 4/5] ixgbe patch to provide NIC's tx/rx counters via
	ethtool
Date: Wed, 30 Sep 2009 15:08:16 -0700
Message-ID: <20090930220815.27479.2145.stgit@localhost.localdomain>
References: <20090930220705.27479.62694.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Ben Greear <greearb@candelatech.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:35753
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754749AbZI3WJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 18:09:19 -0400
In-Reply-To: <20090930220705.27479.62694.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

When LRO is enabled, the received packet and byte counters represent the
LRO'd packets, not the packets/bytes on the wire.  The Intel 82599 NIC has
registers that keep count of the physical packets.  Add these counters to
the ethtool stats.  The byte counters are 36-bit, but the high 4 bits were
being ignored in the 2.6.31 ixgbe driver:  Read those as well to allow
longer time between polling the stats to detect wraps.

Signed-off-by: Ben Greear <greearb@candelatech.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |    4 ++++
 drivers/net/ixgbe/ixgbe_main.c    |    7 +++++--
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 53b0a66..fa314cb 100644
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
index c198183..9609673 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4449,10 +4449,13 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 
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

