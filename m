From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH 1/5] be2net: fix BE3-R FW download compatibility check
Date: Mon, 12 Oct 2015 03:47:17 -0400
Message-ID: <1444636041-4727-2-git-send-email-sathya.perla@avagotech.com>
References: <1444636041-4727-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:50637 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751779AbbJLH5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 03:57:22 -0400
In-Reply-To: <1444636041-4727-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@avagotech.com>

In the BE3 FW image, unlike Skyhawk's, the "asic_type_rev" field doesn't
track the asic_rev of chip it is compatible with. When asic_type_rev
is 0 the image is compatible only with pre-BE3-R chips (asic_rev < 0x10).
Fix the current compatibility check to take care of this.
We hit this issue when we try to flash old BE3 images (used prior to the
release of BE3-R) on pre-BE3-R adapters.

Fixes: a6e6ff6eee12f3e ("be2net: simplify UFI compatibility checking")
Signed-off-by: Kalesh AP <kalesh.purayil@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 7bf51a1..86eed47 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4999,7 +4999,15 @@ static bool be_check_ufi_compatibility(struct be_adapter *adapter,
 		return false;
 	}
 
-	return (fhdr->asic_type_rev >= adapter->asic_rev);
+	/* In BE3 FW images the "asic_type_rev" field doesn't track the
+	 * asic_rev of the chips it is compatible with.
+	 * When asic_type_rev is 0 the image is compatible only with
+	 * pre-BE3-R chips (asic_rev < 0x10)
+	 */
+	if (BEx_chip(adapter) && fhdr->asic_type_rev == 0)
+		return adapter->asic_rev < 0x10;
+	else
+		return (fhdr->asic_type_rev >= adapter->asic_rev);
 }
 
 static int be_fw_download(struct be_adapter *adapter, const struct firmware* fw)
-- 
2.4.1
