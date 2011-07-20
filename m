From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 7/8] tg3: Return size from tg3_vpd_readblock()
Date: Wed, 20 Jul 2011 13:20:56 -0700
Message-ID: <1311193257-20531-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2272 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751713Ab1GTUTf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 16:19:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Newer VPD datablocks can exceed the size the tg3 driver is traditionally
used to.  This can cause some of the routines that operate on the VPD
data to fail when in-fact they could have succeeded had they known the
correct size.  This patch fixes the problem.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index f2b0839..bce0f226 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10573,7 +10573,7 @@ static void tg3_get_ethtool_stats(struct net_device *dev,
 	memcpy(tmp_stats, tg3_get_estats(tp), sizeof(tp->estats));
 }
 
-static __be32 * tg3_vpd_readblock(struct tg3 *tp)
+static __be32 *tg3_vpd_readblock(struct tg3 *tp, u32 *vpdlen)
 {
 	int i;
 	__be32 *buf;
@@ -10640,6 +10640,8 @@ static __be32 * tg3_vpd_readblock(struct tg3 *tp)
 			goto error;
 	}
 
+	*vpdlen = len;
+
 	return buf;
 
 error:
@@ -10659,7 +10661,7 @@ error:
 
 static int tg3_test_nvram(struct tg3 *tp)
 {
-	u32 csum, magic;
+	u32 csum, magic, len;
 	__be32 *buf;
 	int i, j, k, err = 0, size;
 
@@ -10800,18 +10802,17 @@ static int tg3_test_nvram(struct tg3 *tp)
 
 	kfree(buf);
 
-	buf = tg3_vpd_readblock(tp);
+	buf = tg3_vpd_readblock(tp, &len);
 	if (!buf)
 		return -ENOMEM;
 
-	i = pci_vpd_find_tag((u8 *)buf, 0, TG3_NVM_VPD_LEN,
-			     PCI_VPD_LRDT_RO_DATA);
+	i = pci_vpd_find_tag((u8 *)buf, 0, len, PCI_VPD_LRDT_RO_DATA);
 	if (i > 0) {
 		j = pci_vpd_lrdt_size(&((u8 *)buf)[i]);
 		if (j < 0)
 			goto out;
 
-		if (i + PCI_VPD_LRDT_TAG_SIZE + j > TG3_NVM_VPD_LEN)
+		if (i + PCI_VPD_LRDT_TAG_SIZE + j > len)
 			goto out;
 
 		i += PCI_VPD_LRDT_TAG_SIZE;
@@ -13209,14 +13210,14 @@ static void __devinit tg3_read_vpd(struct tg3 *tp)
 {
 	u8 *vpd_data;
 	unsigned int block_end, rosize, len;
+	u32 vpdlen;
 	int j, i = 0;
 
-	vpd_data = (u8 *)tg3_vpd_readblock(tp);
+	vpd_data = (u8 *)tg3_vpd_readblock(tp, &vpdlen);
 	if (!vpd_data)
 		goto out_no_vpd;
 
-	i = pci_vpd_find_tag(vpd_data, 0, TG3_NVM_VPD_LEN,
-			     PCI_VPD_LRDT_RO_DATA);
+	i = pci_vpd_find_tag(vpd_data, 0, vpdlen, PCI_VPD_LRDT_RO_DATA);
 	if (i < 0)
 		goto out_not_found;
 
@@ -13224,7 +13225,7 @@ static void __devinit tg3_read_vpd(struct tg3 *tp)
 	block_end = i + PCI_VPD_LRDT_TAG_SIZE + rosize;
 	i += PCI_VPD_LRDT_TAG_SIZE;
 
-	if (block_end > TG3_NVM_VPD_LEN)
+	if (block_end > vpdlen)
 		goto out_not_found;
 
 	j = pci_vpd_find_info_keyword(vpd_data, i, rosize,
@@ -13249,7 +13250,7 @@ static void __devinit tg3_read_vpd(struct tg3 *tp)
 			goto partno;
 
 		memcpy(tp->fw_ver, &vpd_data[j], len);
-		strncat(tp->fw_ver, " bc ", TG3_NVM_VPD_LEN - len - 1);
+		strncat(tp->fw_ver, " bc ", vpdlen - len - 1);
 	}
 
 partno:
@@ -13262,7 +13263,7 @@ partno:
 
 	i += PCI_VPD_INFO_FLD_HDR_SIZE;
 	if (len > TG3_BPN_SIZE ||
-	    (len + i) > TG3_NVM_VPD_LEN)
+	    (len + i) > vpdlen)
 		goto out_not_found;
 
 	memcpy(tp->board_part_number, &vpd_data[i], len);
-- 
1.7.3.4


