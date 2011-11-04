From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 1/8] tg3: Fix APE mutex init and use
Date: Fri, 4 Nov 2011 12:14:58 -0700
Message-ID: <1320434105-12898-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3456 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755758Ab1KDTN4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 15:13:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

APE mutex register blocks are shared by all ports of multiport devices.
For some mutexing purposes, each function is assigned their own
register.  For other cases, each function is assigned its own request
and grant bits of a single register.  For the latter cases, the tg3
driver is incorrectly allowing each function to use the same set of
grant / request bits.  This patch fixes the code so that each function
uses the appropriate bitset.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   44 ++++++++++++++++++----------------
 drivers/net/ethernet/broadcom/tg3.h |   10 +++++--
 2 files changed, 30 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 161cbbb..3590163 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -628,19 +628,23 @@ static void tg3_ape_lock_init(struct tg3 *tp)
 		regbase = TG3_APE_PER_LOCK_GRANT;
 
 	/* Make sure the driver hasn't any stale locks. */
-	for (i = 0; i < 8; i++) {
-		if (i == TG3_APE_LOCK_GPIO)
-			continue;
-		tg3_ape_write32(tp, regbase + 4 * i, APE_LOCK_GRANT_DRIVER);
+	for (i = TG3_APE_LOCK_PHY0; i <= TG3_APE_LOCK_GPIO; i++) {
+		switch (i) {
+		case TG3_APE_LOCK_PHY0:
+		case TG3_APE_LOCK_PHY1:
+		case TG3_APE_LOCK_PHY2:
+		case TG3_APE_LOCK_PHY3:
+			bit = APE_LOCK_GRANT_DRIVER;
+			break;
+		default:
+			if (!tp->pci_fn)
+				bit = APE_LOCK_GRANT_DRIVER;
+			else
+				bit = 1 << tp->pci_fn;
+		}
+		tg3_ape_write32(tp, regbase + 4 * i, bit);
 	}
 
-	/* Clear the correct bit of the GPIO lock too. */
-	if (!tp->pci_fn)
-		bit = APE_LOCK_GRANT_DRIVER;
-	else
-		bit = 1 << tp->pci_fn;
-
-	tg3_ape_write32(tp, regbase + 4 * TG3_APE_LOCK_GPIO, bit);
 }
 
 static int tg3_ape_lock(struct tg3 *tp, int locknum)
@@ -658,6 +662,10 @@ static int tg3_ape_lock(struct tg3 *tp, int locknum)
 			return 0;
 	case TG3_APE_LOCK_GRC:
 	case TG3_APE_LOCK_MEM:
+		if (!tp->pci_fn)
+			bit = APE_LOCK_REQ_DRIVER;
+		else
+			bit = 1 << tp->pci_fn;
 		break;
 	default:
 		return -EINVAL;
@@ -673,11 +681,6 @@ static int tg3_ape_lock(struct tg3 *tp, int locknum)
 
 	off = 4 * locknum;
 
-	if (locknum != TG3_APE_LOCK_GPIO || !tp->pci_fn)
-		bit = APE_LOCK_REQ_DRIVER;
-	else
-		bit = 1 << tp->pci_fn;
-
 	tg3_ape_write32(tp, req + off, bit);
 
 	/* Wait for up to 1 millisecond to acquire lock. */
@@ -710,6 +713,10 @@ static void tg3_ape_unlock(struct tg3 *tp, int locknum)
 			return;
 	case TG3_APE_LOCK_GRC:
 	case TG3_APE_LOCK_MEM:
+		if (!tp->pci_fn)
+			bit = APE_LOCK_GRANT_DRIVER;
+		else
+			bit = 1 << tp->pci_fn;
 		break;
 	default:
 		return;
@@ -720,11 +727,6 @@ static void tg3_ape_unlock(struct tg3 *tp, int locknum)
 	else
 		gnt = TG3_APE_PER_LOCK_GRANT;
 
-	if (locknum != TG3_APE_LOCK_GPIO || !tp->pci_fn)
-		bit = APE_LOCK_GRANT_DRIVER;
-	else
-		bit = 1 << tp->pci_fn;
-
 	tg3_ape_write32(tp, gnt + 4 * locknum, bit);
 }
 
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index f32f288..03fab8c 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2344,9 +2344,13 @@
 #define  APE_PER_LOCK_GRANT_DRIVER	 0x00001000
 
 /* APE convenience enumerations. */
-#define TG3_APE_LOCK_GRC                1
-#define TG3_APE_LOCK_MEM                4
-#define TG3_APE_LOCK_GPIO               7
+#define TG3_APE_LOCK_PHY0		0
+#define TG3_APE_LOCK_GRC		1
+#define TG3_APE_LOCK_PHY1		2
+#define TG3_APE_LOCK_PHY2		3
+#define TG3_APE_LOCK_MEM		4
+#define TG3_APE_LOCK_PHY3		5
+#define TG3_APE_LOCK_GPIO		7
 
 #define TG3_EEPROM_SB_F1R2_MBA_OFF	0x10
 
-- 
1.7.3.4
