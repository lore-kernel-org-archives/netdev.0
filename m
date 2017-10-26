From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/6] e1000: fix race condition between e1000_down() and e1000_watchdog
Date: Thu, 26 Oct 2017 09:19:50 -0700
Message-ID: <20171026161955.4407-2-jeffrey.t.kirsher@intel.com>
References: <20171026161955.4407-1-jeffrey.t.kirsher@intel.com>
Cc: Vincenzo Maffione <v.maffione@gmail.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30235 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932433AbdJZQUS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 12:20:18 -0400
In-Reply-To: <20171026161955.4407-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincenzo Maffione <v.maffione@gmail.com>

This patch fixes a race condition that can result into the interface being
up and carrier on, but with transmits disabled in the hardware.
The bug may show up by repeatedly IFF_DOWN+IFF_UP the interface, which
allows e1000_watchdog() interleave with e1000_down().

    CPU x                           CPU y
    --------------------------------------------------------------------
    e1000_down():
        netif_carrier_off()
                                    e1000_watchdog():
                                        if (carrier == off) {
                                            netif_carrier_on();
                                            enable_hw_transmit();
                                        }
        disable_hw_transmit();
                                    e1000_watchdog():
                                        /* carrier on, do nothing */

Signed-off-by: Vincenzo Maffione <v.maffione@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 98375e1e1185..1982f7917a8d 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -520,8 +520,6 @@ void e1000_down(struct e1000_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	u32 rctl, tctl;
 
-	netif_carrier_off(netdev);
-
 	/* disable receives in the hardware */
 	rctl = er32(RCTL);
 	ew32(RCTL, rctl & ~E1000_RCTL_EN);
@@ -537,6 +535,15 @@ void e1000_down(struct e1000_adapter *adapter)
 	E1000_WRITE_FLUSH();
 	msleep(10);
 
+	/* Set the carrier off after transmits have been disabled in the
+	 * hardware, to avoid race conditions with e1000_watchdog() (which
+	 * may be running concurrently to us, checking for the carrier
+	 * bit to decide whether it should enable transmits again). Such
+	 * a race condition would result into transmission being disabled
+	 * in the hardware until the next IFF_DOWN+IFF_UP cycle.
+	 */
+	netif_carrier_off(netdev);
+
 	napi_disable(&adapter->napi);
 
 	e1000_irq_disable(adapter);
-- 
2.14.2
