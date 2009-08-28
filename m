From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-08-28
Date: Fri, 28 Aug 2009 15:10:39 -0400
Message-ID: <20090828191039.GC32694@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42407 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752233AbZH1TPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 15:15:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

One more late-breaker for 2.6.31...

This patch is rather large for this stage of the cycle, but it
corrects a regression disussed recently on LKML, documented in bug
14016 at bugzilla.kernel.org.  This jist of it is that the ipw2200
firmware loading routine was using an order 6 memory allocation that was
failing with newer allocators under some circumstances.

Please let me know if there are problems!

Thanks,

John

---

Individual patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 8ff499e43c537648399fca8ba39d24c0768b3fab:
  Dongdong Deng (1):
        smc91x: let smc91x work well under netpoll

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Zhu Yi (1):
      ipw2200: firmware DMA loading rework

 drivers/net/wireless/ipw2x00/ipw2200.c |  120 ++++++++++++++++++--------------
 1 files changed, 67 insertions(+), 53 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 6dcac73..f593fbb 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -2874,45 +2874,27 @@ static int ipw_fw_dma_add_command_block(struct ipw_priv *priv,
 	return 0;
 }
 
-static int ipw_fw_dma_add_buffer(struct ipw_priv *priv,
-				 u32 src_phys, u32 dest_address, u32 length)
+static int ipw_fw_dma_add_buffer(struct ipw_priv *priv, dma_addr_t *src_address,
+				 int nr, u32 dest_address, u32 len)
 {
-	u32 bytes_left = length;
-	u32 src_offset = 0;
-	u32 dest_offset = 0;
-	int status = 0;
+	int ret, i;
+	u32 size;
+
 	IPW_DEBUG_FW(">> \n");
-	IPW_DEBUG_FW_INFO("src_phys=0x%x dest_address=0x%x length=0x%x\n",
-			  src_phys, dest_address, length);
-	while (bytes_left > CB_MAX_LENGTH) {
-		status = ipw_fw_dma_add_command_block(priv,
-						      src_phys + src_offset,
-						      dest_address +
-						      dest_offset,
-						      CB_MAX_LENGTH, 0, 0);
-		if (status) {
+	IPW_DEBUG_FW_INFO("nr=%d dest_address=0x%x len=0x%x\n",
+			  nr, dest_address, len);
+
+	for (i = 0; i < nr; i++) {
+		size = min_t(u32, len - i * CB_MAX_LENGTH, CB_MAX_LENGTH);
+		ret = ipw_fw_dma_add_command_block(priv, src_address[i],
+						   dest_address +
+						   i * CB_MAX_LENGTH, size,
+						   0, 0);
+		if (ret) {
 			IPW_DEBUG_FW_INFO(": Failed\n");
 			return -1;
 		} else
 			IPW_DEBUG_FW_INFO(": Added new cb\n");
-
-		src_offset += CB_MAX_LENGTH;
-		dest_offset += CB_MAX_LENGTH;
-		bytes_left -= CB_MAX_LENGTH;
-	}
-
-	/* add the buffer tail */
-	if (bytes_left > 0) {
-		status =
-		    ipw_fw_dma_add_command_block(priv, src_phys + src_offset,
-						 dest_address + dest_offset,
-						 bytes_left, 0, 0);
-		if (status) {
-			IPW_DEBUG_FW_INFO(": Failed on the buffer tail\n");
-			return -1;
-		} else
-			IPW_DEBUG_FW_INFO
-			    (": Adding new cb - the buffer tail\n");
 	}
 
 	IPW_DEBUG_FW("<< \n");
@@ -3160,59 +3142,91 @@ static int ipw_load_ucode(struct ipw_priv *priv, u8 * data, size_t len)
 
 static int ipw_load_firmware(struct ipw_priv *priv, u8 * data, size_t len)
 {
-	int rc = -1;
+	int ret = -1;
 	int offset = 0;
 	struct fw_chunk *chunk;
-	dma_addr_t shared_phys;
-	u8 *shared_virt;
+	int total_nr = 0;
+	int i;
+	struct pci_pool *pool;
+	u32 *virts[CB_NUMBER_OF_ELEMENTS_SMALL];
+	dma_addr_t phys[CB_NUMBER_OF_ELEMENTS_SMALL];
 
 	IPW_DEBUG_TRACE("<< : \n");
-	shared_virt = pci_alloc_consistent(priv->pci_dev, len, &shared_phys);
 
-	if (!shared_virt)
+	pool = pci_pool_create("ipw2200", priv->pci_dev, CB_MAX_LENGTH, 0, 0);
+	if (!pool) {
+		IPW_ERROR("pci_pool_create failed\n");
 		return -ENOMEM;
-
-	memmove(shared_virt, data, len);
+	}
 
 	/* Start the Dma */
-	rc = ipw_fw_dma_enable(priv);
+	ret = ipw_fw_dma_enable(priv);
 
 	/* the DMA is already ready this would be a bug. */
 	BUG_ON(priv->sram_desc.last_cb_index > 0);
 
 	do {
+		u32 chunk_len;
+		u8 *start;
+		int size;
+		int nr = 0;
+
 		chunk = (struct fw_chunk *)(data + offset);
 		offset += sizeof(struct fw_chunk);
+		chunk_len = le32_to_cpu(chunk->length);
+		start = data + offset;
+
+		nr = (chunk_len + CB_MAX_LENGTH - 1) / CB_MAX_LENGTH;
+		for (i = 0; i < nr; i++) {
+			virts[total_nr] = pci_pool_alloc(pool, GFP_KERNEL,
+							 &phys[total_nr]);
+			if (!virts[total_nr]) {
+				ret = -ENOMEM;
+				goto out;
+			}
+			size = min_t(u32, chunk_len - i * CB_MAX_LENGTH,
+				     CB_MAX_LENGTH);
+			memcpy(virts[total_nr], start, size);
+			start += size;
+			total_nr++;
+			/* We don't support fw chunk larger than 64*8K */
+			BUG_ON(total_nr > CB_NUMBER_OF_ELEMENTS_SMALL);
+		}
+
 		/* build DMA packet and queue up for sending */
 		/* dma to chunk->address, the chunk->length bytes from data +
 		 * offeset*/
 		/* Dma loading */
-		rc = ipw_fw_dma_add_buffer(priv, shared_phys + offset,
-					   le32_to_cpu(chunk->address),
-					   le32_to_cpu(chunk->length));
-		if (rc) {
+		ret = ipw_fw_dma_add_buffer(priv, &phys[total_nr - nr],
+					    nr, le32_to_cpu(chunk->address),
+					    chunk_len);
+		if (ret) {
 			IPW_DEBUG_INFO("dmaAddBuffer Failed\n");
 			goto out;
 		}
 
-		offset += le32_to_cpu(chunk->length);
+		offset += chunk_len;
 	} while (offset < len);
 
 	/* Run the DMA and wait for the answer */
-	rc = ipw_fw_dma_kick(priv);
-	if (rc) {
+	ret = ipw_fw_dma_kick(priv);
+	if (ret) {
 		IPW_ERROR("dmaKick Failed\n");
 		goto out;
 	}
 
-	rc = ipw_fw_dma_wait(priv);
-	if (rc) {
+	ret = ipw_fw_dma_wait(priv);
+	if (ret) {
 		IPW_ERROR("dmaWaitSync Failed\n");
 		goto out;
 	}
-      out:
-	pci_free_consistent(priv->pci_dev, len, shared_virt, shared_phys);
-	return rc;
+ out:
+	for (i = 0; i < total_nr; i++)
+		pci_pool_free(pool, virts[i], phys[i]);
+
+	pci_pool_destroy(pool);
+
+	return ret;
 }
 
 /* stop nic */
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
