From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 4/6] tg3: Use pci_read_vpd() instead of private method
Date: Thu, 3 Dec 2009 10:36:23 -0800
Message-ID: <1259865385-7773-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1204 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756393AbZLCSkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 13:40:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the driver needs to use PCI configuration space to read the VPD data,
the accesses could collide with the pci_read_vpd() function.  This patch
converts the driver to use pci_read_vpd() to avoid any potential
collisions.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   35 ++++++++++++-----------------------
 1 files changed, 12 insertions(+), 23 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5302cf9..49c60f9 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12456,31 +12456,20 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 			memcpy(&vpd_data[i], &tmp, sizeof(tmp));
 		}
 	} else {
-		int vpd_cap;
-
-		vpd_cap = pci_find_capability(tp->pdev, PCI_CAP_ID_VPD);
-		for (i = 0; i < TG3_NVM_VPD_LEN; i += 4) {
-			u32 tmp, j = 0;
-			__le32 v;
-			u16 tmp16;
-
-			pci_write_config_word(tp->pdev, vpd_cap + PCI_VPD_ADDR,
-					      i);
-			while (j++ < 100) {
-				pci_read_config_word(tp->pdev, vpd_cap +
-						     PCI_VPD_ADDR, &tmp16);
-				if (tmp16 & 0x8000)
-					break;
-				msleep(1);
-			}
-			if (!(tmp16 & 0x8000))
+		ssize_t cnt;
+		unsigned int pos = 0, i = 0;
+
+		for (; pos < TG3_NVM_VPD_LEN && i < 3; i++, pos += cnt) {
+			cnt = pci_read_vpd(tp->pdev, pos,
+					   TG3_NVM_VPD_LEN - pos,
+					   &vpd_data[pos]);
+			if (cnt == -ETIMEDOUT || -EINTR)
+				cnt = 0;
+			else if (cnt < 0)
 				goto out_not_found;
-
-			pci_read_config_dword(tp->pdev, vpd_cap + PCI_VPD_DATA,
-					      &tmp);
-			v = cpu_to_le32(tmp);
-			memcpy(&vpd_data[i], &v, sizeof(v));
 		}
+		if (pos != TG3_NVM_VPD_LEN)
+			goto out_not_found;
 	}
 
 	/* Now parse and find the part number. */
-- 
1.6.4.4


