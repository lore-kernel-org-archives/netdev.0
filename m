From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net 1/3] bna: fix firmware loading on big-endian machines
Date: Thu, 28 May 2015 23:10:06 +0200
Message-ID: <1432847408-5066-2-git-send-email-ivecera@redhat.com>
References: <1432847408-5066-1-git-send-email-ivecera@redhat.com>
Cc: Rasesh Mody <rasesh.mody@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55209 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754352AbbE1VKF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 17:10:05 -0400
In-Reply-To: <1432847408-5066-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Firmware required by bna is stored in appropriate files as sequence
of LE32 integers. After loading by request_firmware() they need to be
byte-swapped on big-endian arches. Without this conversion the NIC
is unusable on big-endian machines.

Cc: Rasesh Mody <rasesh.mody@qlogic.com>
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/cna_fwimg.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/brocade/bna/cna_fwimg.c b/drivers/net/ethernet/brocade/bna/cna_fwimg.c
index ebf462d..badea36 100644
--- a/drivers/net/ethernet/brocade/bna/cna_fwimg.c
+++ b/drivers/net/ethernet/brocade/bna/cna_fwimg.c
@@ -30,6 +30,7 @@ cna_read_firmware(struct pci_dev *pdev, u32 **bfi_image,
 			u32 *bfi_image_size, char *fw_name)
 {
 	const struct firmware *fw;
+	u32 n;
 
 	if (request_firmware(&fw, fw_name, &pdev->dev)) {
 		pr_alert("Can't locate firmware %s\n", fw_name);
@@ -40,6 +41,12 @@ cna_read_firmware(struct pci_dev *pdev, u32 **bfi_image,
 	*bfi_image_size = fw->size/sizeof(u32);
 	bfi_fw = fw;
 
+	/* Convert loaded firmware to host order as it is stored in file
+	 * as sequence of LE32 integers.
+	 */
+	for (n = 0; n < *bfi_image_size; n++)
+		le32_to_cpus(*bfi_image + n);
+
 	return *bfi_image;
 error:
 	return NULL;
-- 
2.3.6
