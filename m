From: "Michael Chan" <mchan@broadcom.com>
Subject: [TG3]: Fix performance regression on 5705.
Date: Fri, 12 Oct 2007 12:39:07 -0700
Message-ID: <1192217947.6987.2.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3760 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751873AbXJLSnB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2007 14:43:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Fix performance regression on 5705.

A performance regression was introduced by the following commit:

    commit ee6a99b539a50b4e9398938a0a6d37f8bf911550
    Author: Michael Chan <mchan@broadcom.com>
    Date:   Wed Jul 18 21:49:10 2007 -0700

    [TG3]: Fix msi issue with kexec/kdump.

In making that change, the PCI latency timer and cache line size
registers were not restored after chip reset.  On the 5705, the
latency timer gets reset to 0 during chip reset and this causes
very poor performance.

Update version to 3.84.

Signed-off-by: Michael Chan <mchan@broadcom.com>
    
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 30b1cca..b9e1dc6 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -64,8 +64,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.83"
-#define DRV_MODULE_RELDATE	"October 10, 2007"
+#define DRV_MODULE_VERSION	"3.84"
+#define DRV_MODULE_RELDATE	"October 12, 2007"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
@@ -5056,6 +5056,12 @@ static void tg3_restore_pci_state(struct tg3 *tp)
 
 	pci_write_config_dword(tp->pdev, TG3PCI_COMMAND, tp->pci_cmd);
 
+	if (!(tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS)) {
+		pci_write_config_byte(tp->pdev, PCI_CACHE_LINE_SIZE,
+				      tp->pci_cacheline_sz);
+		pci_write_config_byte(tp->pdev, PCI_LATENCY_TIMER,
+				      tp->pci_lat_timer);
+	}
 	/* Make sure PCI-X relaxed ordering bit is clear. */
 	if (tp->pcix_cap) {
 		u16 pcix_cmd;


