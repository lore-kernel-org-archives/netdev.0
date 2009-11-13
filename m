From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/7] igb: move timesync init into a seperate
	function
Date: Thu, 12 Nov 2009 20:37:00 -0800
Message-ID: <20091113043659.1240.79193.stgit@localhost.localdomain>
References: <20091113043604.1240.80142.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:60015 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755730AbZKMEhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 23:37:12 -0500
In-Reply-To: <20091113043604.1240.80142.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Current code is quite large and making igb_probe difficult to read.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |  115 +++++++++++++++++++++++++-------------------
 1 files changed, 65 insertions(+), 50 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index b044c98..d72d484 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1566,56 +1566,6 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	}
 
 #endif
-	switch (hw->mac.type) {
-	case e1000_82576:
-		/*
-		 * Initialize hardware timer: we keep it running just in case
-		 * that some program needs it later on.
-		 */
-		memset(&adapter->cycles, 0, sizeof(adapter->cycles));
-		adapter->cycles.read = igb_read_clock;
-		adapter->cycles.mask = CLOCKSOURCE_MASK(64);
-		adapter->cycles.mult = 1;
-		/**
-		 * Scale the NIC clock cycle by a large factor so that
-		 * relatively small clock corrections can be added or
-		 * substracted at each clock tick. The drawbacks of a large
-		 * factor are a) that the clock register overflows more quickly
-		 * (not such a big deal) and b) that the increment per tick has
-		 * to fit into 24 bits.  As a result we need to use a shift of
-		 * 19 so we can fit a value of 16 into the TIMINCA register.
-		 */
-		adapter->cycles.shift = IGB_82576_TSYNC_SHIFT;
-		wr32(E1000_TIMINCA,
-		                (1 << E1000_TIMINCA_16NS_SHIFT) |
-		                (16 << IGB_82576_TSYNC_SHIFT));
-
-		/* Set registers so that rollover occurs soon to test this. */
-		wr32(E1000_SYSTIML, 0x00000000);
-		wr32(E1000_SYSTIMH, 0xFF800000);
-		wrfl();
-
-		timecounter_init(&adapter->clock,
-				 &adapter->cycles,
-				 ktime_to_ns(ktime_get_real()));
-		/*
-		 * Synchronize our NIC clock against system wall clock. NIC
-		 * time stamp reading requires ~3us per sample, each sample
-		 * was pretty stable even under load => only require 10
-		 * samples for each offset comparison.
-		 */
-		memset(&adapter->compare, 0, sizeof(adapter->compare));
-		adapter->compare.source = &adapter->clock;
-		adapter->compare.target = ktime_get_real;
-		adapter->compare.num_samples = 10;
-		timecompare_update(&adapter->compare, 0);
-		break;
-	case e1000_82575:
-		/* 82575 does not support timesync */
-	default:
-		break;
-	}
-
 	dev_info(&pdev->dev, "Intel(R) Gigabit Ethernet Network Connection\n");
 	/* print bus type/speed/width info */
 	dev_info(&pdev->dev, "%s: (PCIe:%s:%s) %pM\n",
@@ -1781,6 +1731,70 @@ static void __devinit igb_probe_vfs(struct igb_adapter * adapter)
 #endif /* CONFIG_PCI_IOV */
 }
 
+
+/**
+ * igb_init_hw_timer - Initialize hardware timer used with IEEE 1588 timestamp
+ * @adapter: board private structure to initialize
+ *
+ * igb_init_hw_timer initializes the function pointer and values for the hw
+ * timer found in hardware.
+ **/
+static void igb_init_hw_timer(struct igb_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+
+	switch (hw->mac.type) {
+	case e1000_82576:
+		/*
+		 * Initialize hardware timer: we keep it running just in case
+		 * that some program needs it later on.
+		 */
+		memset(&adapter->cycles, 0, sizeof(adapter->cycles));
+		adapter->cycles.read = igb_read_clock;
+		adapter->cycles.mask = CLOCKSOURCE_MASK(64);
+		adapter->cycles.mult = 1;
+		/**
+		 * Scale the NIC clock cycle by a large factor so that
+		 * relatively small clock corrections can be added or
+		 * substracted at each clock tick. The drawbacks of a large
+		 * factor are a) that the clock register overflows more quickly
+		 * (not such a big deal) and b) that the increment per tick has
+		 * to fit into 24 bits.  As a result we need to use a shift of
+		 * 19 so we can fit a value of 16 into the TIMINCA register.
+		 */
+		adapter->cycles.shift = IGB_82576_TSYNC_SHIFT;
+		wr32(E1000_TIMINCA,
+		                (1 << E1000_TIMINCA_16NS_SHIFT) |
+		                (16 << IGB_82576_TSYNC_SHIFT));
+
+		/* Set registers so that rollover occurs soon to test this. */
+		wr32(E1000_SYSTIML, 0x00000000);
+		wr32(E1000_SYSTIMH, 0xFF800000);
+		wrfl();
+
+		timecounter_init(&adapter->clock,
+				 &adapter->cycles,
+				 ktime_to_ns(ktime_get_real()));
+		/*
+		 * Synchronize our NIC clock against system wall clock. NIC
+		 * time stamp reading requires ~3us per sample, each sample
+		 * was pretty stable even under load => only require 10
+		 * samples for each offset comparison.
+		 */
+		memset(&adapter->compare, 0, sizeof(adapter->compare));
+		adapter->compare.source = &adapter->clock;
+		adapter->compare.target = ktime_get_real;
+		adapter->compare.num_samples = 10;
+		timecompare_update(&adapter->compare, 0);
+		break;
+	case e1000_82575:
+		/* 82575 does not support timesync */
+	default:
+		break;
+	}
+
+}
+
 /**
  * igb_sw_init - Initialize general software structures (struct igb_adapter)
  * @adapter: board private structure to initialize
@@ -1816,6 +1830,7 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 		return -ENOMEM;
 	}
 
+	igb_init_hw_timer(adapter);
 	igb_probe_vfs(adapter);
 
 	/* Explicitly disable IRQ since the NIC can be in any state. */

