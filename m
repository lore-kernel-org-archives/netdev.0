From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/9] e1000e: fix buffer overrun while the I219 is processing DMA transactions
Date: Tue, 10 Oct 2017 10:21:36 -0700
Message-ID: <20171010172139.77914-7-jeffrey.t.kirsher@intel.com>
References: <20171010172139.77914-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Sasha Neftin <sasha.neftin@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:6195 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932562AbdJJRWC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 13:22:02 -0400
In-Reply-To: <20171010172139.77914-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sasha Neftin <sasha.neftin@intel.com>

Intel® 100/200 Series Chipset platforms reduced the round-trip
latency for the LAN Controller DMA accesses, causing in some high
performance cases a buffer overrun while the I219 LAN Connected
Device is processing the DMA transactions. I219LM and I219V devices
can fall into unrecovered Tx hang under very stressfully UDP traffic
and multiple reconnection of Ethernet cable. This Tx hang of the LAN
Controller is only recovered if the system is rebooted. Slightly slow
down DMA access by reducing the number of outstanding requests.
This workaround could have an impact on TCP traffic performance
on the platform. Disabling TSO eliminates performance loss for TCP
traffic without a noticeable impact on CPU performance.

Please, refer to I218/I219 specification update:
https://www.intel.com/content/www/us/en/embedded/products/networking/
ethernet-connection-i218-family-documentation.html

Signed-off-by: Sasha Neftin <sasha.neftin@intel.com>
Reviewed-by: Dima Ruinskiy <dima.ruinskiy@intel.com>
Reviewed-by: Raanan Avargil <raanan.avargil@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index ee9de3500331..14b096f3d1da 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3021,8 +3021,8 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 
 	hw->mac.ops.config_collision_dist(hw);
 
-	/* SPT and CNP Si errata workaround to avoid data corruption */
-	if (hw->mac.type >= e1000_pch_spt) {
+	/* SPT and KBL Si errata workaround to avoid data corruption */
+	if (hw->mac.type == e1000_pch_spt) {
 		u32 reg_val;
 
 		reg_val = er32(IOSFPC);
@@ -3030,7 +3030,9 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 		ew32(IOSFPC, reg_val);
 
 		reg_val = er32(TARC(0));
-		reg_val |= E1000_TARC0_CB_MULTIQ_3_REQ;
+		/* SPT and KBL Si errata workaround to avoid Tx hang */
+		reg_val &= ~BIT(28);
+		reg_val |= BIT(29);
 		ew32(TARC(0), reg_val);
 	}
 }
-- 
2.14.2
