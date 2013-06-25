From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next] bnx2x: Remove sparse and coccinelle warnings
Date: Tue, 25 Jun 2013 08:50:11 +0300
Message-ID: <1372139411-8250-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1622 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751326Ab3FYFu1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 01:50:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch solves several sparse issues as well as an unneeded semicolon
found via coccinelle.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
Hi Dave,

Please consider applying this patch to `net-next'.

Thanks,
Yuval Mintz
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c     | 9 ++++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 8 +++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c    | 2 +-
 3 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index d342c5a..ea5b2b9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1722,7 +1722,7 @@ static int bnx2x_req_irq(struct bnx2x *bp)
 	return request_irq(irq, bnx2x_interrupt, flags, bp->dev->name, bp->dev);
 }
 
-int bnx2x_setup_irqs(struct bnx2x *bp)
+static int bnx2x_setup_irqs(struct bnx2x *bp)
 {
 	int rc = 0;
 	if (bp->flags & USING_MSIX_FLAG &&
@@ -3543,9 +3543,12 @@ static void bnx2x_update_pbds_gso_enc(struct sk_buff *skb,
 	/* outer IP header info */
 	if (xmit_type & XMIT_CSUM_V4) {
 		struct iphdr *iph = ip_hdr(skb);
+		u16 csum = (__force u16)(~iph->check) -
+			   (__force u16)iph->tot_len -
+			   (__force u16)iph->frag_off;
+
 		pbd2->fw_ip_csum_wo_len_flags_frag =
-			bswab16(csum_fold((~iph->check) -
-					  iph->tot_len - iph->frag_off));
+			bswab16(csum_fold((__force __wsum)csum));
 	} else {
 		pbd2->fw_ip_hdr_to_payload_w =
 			hlen_w - ((sizeof(struct ipv6hdr)) >> 1);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 7c6faeb..b8c067d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1391,7 +1391,7 @@ static bool bnx2x_is_nvm_accessible(struct bnx2x *bp)
 					  bp->pm_cap + PCI_PM_CTRL, &pm);
 
 	if ((rc && !netif_running(dev)) ||
-	    (!rc && ((pm & PCI_PM_CTRL_STATE_MASK) != PCI_D0)))
+	    (!rc && ((pm & PCI_PM_CTRL_STATE_MASK) != (__force u16)PCI_D0)))
 		return false;
 
 	return true;
@@ -1610,8 +1610,10 @@ static int bnx2x_nvram_write1(struct bnx2x *bp, u32 offset, u8 *data_buf,
 		 */
 		val = be32_to_cpu(val_be);
 
-		val &= ~le32_to_cpu(0xff << BYTE_OFFSET(offset));
-		val |= le32_to_cpu(*data_buf << BYTE_OFFSET(offset));
+		val &= ~le32_to_cpu((__force __le32)
+				    (0xff << BYTE_OFFSET(offset)));
+		val |= le32_to_cpu((__force __le32)
+				   (*data_buf << BYTE_OFFSET(offset)));
 
 		rc = bnx2x_nvram_write_dword(bp, align_offset, val,
 					     cmd_flags);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 7318988..740518b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -615,7 +615,7 @@ void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
 	if (rc) {
 		BNX2X_ERR("DMAE returned failure %d\n", rc);
 		bnx2x_panic();
-	};
+	}
 }
 
 static void bnx2x_write_dmae_phys_len(struct bnx2x *bp, dma_addr_t phys_addr,
-- 
1.8.1.227.g44fe835
