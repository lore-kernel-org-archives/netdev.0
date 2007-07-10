From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e100: Fix Tyan motherboard e100 not receiving IPMI commands
Date: Tue, 10 Jul 2007 08:45:11 -0700
Message-ID: <20070710154511.8419.38789.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: david.graham@intel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40378 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755496AbXGJPpO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 11:45:14 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Graham <david.graham@intel.com>

The 82550 & 51 parts have an extended configuration block that
includes a bit "GMRC", required to enable the expected TCO behavior,
in config byte offset 22d.  The config block sent by the failing driver
does include the extension area, but this bit is not initialised,
and the downlaod only specifies 0x16 bytes to be sent to the NIC
(thaht's bytes 00..21d). By initializing the GMRC bit, and extending
the download size for D102+ MACs, the problem is resolved.

Signed-off-by: David Graham <david.graham@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e100.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 763810c..74ea637 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -159,7 +159,7 @@
 
 #define DRV_NAME		"e100"
 #define DRV_EXT			"-NAPI"
-#define DRV_VERSION		"3.5.17-k4"DRV_EXT
+#define DRV_VERSION		"3.5.23-k4"DRV_EXT
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network Driver"
 #define DRV_COPYRIGHT		"Copyright(c) 1999-2006 Intel Corporation"
 #define PFX			DRV_NAME ": "
@@ -1024,10 +1024,16 @@ static void e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 		config->mwi_enable = 0x1;	/* 1=enable, 0=disable */
 		config->standard_tcb = 0x0;	/* 1=standard, 0=extended */
 		config->rx_long_ok = 0x1;	/* 1=VLANs ok, 0=standard */
-		if(nic->mac >= mac_82559_D101M)
+		if (nic->mac >= mac_82559_D101M) {
 			config->tno_intr = 0x1;		/* TCO stats enable */
-		else
+			/* Enable TCO in extended config */
+			if (nic->mac >= mac_82551_10) {
+				config->byte_count = 0x20; /* extended bytes */
+				config->rx_d102_mode = 0x1; /* GMRC for TCO */
+			}
+		} else {
 			config->standard_stat_counter = 0x0;
+		}
 	}
 
 	DPRINTK(HW, DEBUG, "[00-07]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
