From: Marc MERLIN <marc@merlins.org>
Subject: Re: kernel 3.5.2/amd64: iwlwifi 0000:03:00.0: failed to allocate pci memory
Date: Wed, 12 Sep 2012 21:52:51 -0700
Message-ID: <20120913045251.GA30915@merlins.org>
References: <20120908161038.GF3347@merlins.org> <1347122927.1234.849.camel@edumazet-glaptop> <20120904003014.GB6287@merlins.org> <20120908170128.GK3347@merlins.org> <1347130641.11167.0.camel@jlt4.sipsolutions.net> <1347272641.4272.1.camel@jlt4.sipsolutions.net> <20120910153431.GD5053@merlins.org> <20120910154402.GF5053@merlins.org> <1347292023.4272.28.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="x+6KMIRAuhnl3hBn"
Cc: wey-yi.w.guy@intel.com, ilw@linux.intel.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from magic.merlins.org ([209.81.13.136]:54649 "EHLO
	mail1.merlins.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749Ab2IMEw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 00:52:57 -0400
Content-Disposition: inline
In-Reply-To: <1347292023.4272.28.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Sep 10, 2012 at 05:47:03PM +0200, Johannes Berg wrote:
> > but http://p.sipsolutions.net/11ea33b376a5bac5.txt
> > refers to drivers/net/wireless/iwlwifi/dvm/ucode.c
> > 
> > Obviously I can fix pathnames by hand, but jus wanted to make sure I'm doing
> > the right thing before doing that.
> 
> That'll probably just work. I may also erroneously have included
> dvm16/... changes that are internal only, so you won't have to worry
> about that file.

I had to port the patch back to my 3.5.3 kernel and since then I haven't
hany firmware loading failures, thanks much.

I'll attach the patch below in case it helps others.

Thanks for your help,
Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/  

--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="iwlwifi-firmware.patch"

diff -urN .iwlwifi/iwl-drv.c iwlwifi/iwl-drv.c
--- .iwlwifi/iwl-drv.c	2012-07-21 13:58:29.000000000 -0700
+++ iwlwifi/iwl-drv.c	2012-09-12 16:30:28.997944875 -0700
@@ -116,10 +116,8 @@
 
 static void iwl_free_fw_desc(struct iwl_drv *drv, struct fw_desc *desc)
 {
-	if (desc->v_addr)
-		dma_free_coherent(drv->trans->dev, desc->len,
-				  desc->v_addr, desc->p_addr);
-	desc->v_addr = NULL;
+	vfree(desc->data);
+	desc->data = NULL;
 	desc->len = 0;
 }
 
@@ -138,21 +136,24 @@
 }
 
 static int iwl_alloc_fw_desc(struct iwl_drv *drv, struct fw_desc *desc,
-		      struct fw_sec *sec)
+			     struct fw_sec *sec)
 {
-	if (!sec || !sec->size) {
-		desc->v_addr = NULL;
+	void *data;
+
+	desc->data = NULL;
+
+	if (!sec || !sec->size)
 		return -EINVAL;
-	}
 
-	desc->v_addr = dma_alloc_coherent(drv->trans->dev, sec->size,
-					  &desc->p_addr, GFP_KERNEL);
-	if (!desc->v_addr)
+	data = vmalloc(sec->size);
+	if (!data)
 		return -ENOMEM;
 
 	desc->len = sec->size;
 	desc->offset = sec->offset;
-	memcpy(desc->v_addr, sec->data, sec->size);
+	memcpy(data, sec->data, desc->len);
+	desc->data = data;
+
 	return 0;
 }
 
diff -urN .iwlwifi/iwl-fw.h iwlwifi/iwl-fw.h
--- .iwlwifi/iwl-fw.h	2012-07-21 13:58:29.000000000 -0700
+++ iwlwifi/iwl-fw.h	2012-09-12 16:30:28.997944875 -0700
@@ -124,8 +124,7 @@
 
 /* one for each uCode image (inst/data, init/runtime/wowlan) */
 struct fw_desc {
-	dma_addr_t p_addr;	/* hardware address */
-	void *v_addr;		/* software address */
+	const void *data;	/* vmalloc'ed data */
 	u32 len;		/* size in bytes */
 	u32 offset;		/* offset in the device */
 };
diff -urN .iwlwifi/iwl-trans-pcie.c iwlwifi/iwl-trans-pcie.c
--- .iwlwifi/iwl-trans-pcie.c	2012-07-21 13:58:29.000000000 -0700
+++ iwlwifi/iwl-trans-pcie.c	2012-09-12 16:32:48.190750091 -0700
@@ -896,13 +896,10 @@
 /*
  * ucode
  */
-static int iwl_load_section(struct iwl_trans *trans, u8 section_num,
-			    const struct fw_desc *section)
+static int iwl_load_firmware_chunk(struct iwl_trans *trans, u32 dst_addr,
+				   dma_addr_t phy_addr, u32 byte_cnt)
 {
 	struct iwl_trans_pcie *trans_pcie = IWL_TRANS_GET_PCIE_TRANS(trans);
-	dma_addr_t phy_addr = section->p_addr;
-	u32 byte_cnt = section->len;
-	u32 dst_addr = section->offset;
 	int ret;
 
 	trans_pcie->ucode_write_complete = false;
@@ -915,8 +912,8 @@
 		FH_SRVC_CHNL_SRAM_ADDR_REG(FH_SRVC_CHNL), dst_addr);
 
 	iwl_write_direct32(trans,
-		FH_TFDIB_CTRL0_REG(FH_SRVC_CHNL),
-		phy_addr & FH_MEM_TFDIB_DRAM_ADDR_LSB_MSK);
+			   FH_TFDIB_CTRL0_REG(FH_SRVC_CHNL),
+			   phy_addr & FH_MEM_TFDIB_DRAM_ADDR_LSB_MSK);
 
 	iwl_write_direct32(trans,
 		FH_TFDIB_CTRL1_REG(FH_SRVC_CHNL),
@@ -935,19 +932,51 @@
 		FH_TCSR_TX_CONFIG_REG_VAL_DMA_CREDIT_DISABLE	|
 		FH_TCSR_TX_CONFIG_REG_VAL_CIRQ_HOST_ENDTFD);
 
-	IWL_DEBUG_FW(trans, "[%d] uCode section being loaded...\n",
-		     section_num);
 	ret = wait_event_timeout(trans_pcie->ucode_write_waitq,
 				 trans_pcie->ucode_write_complete, 5 * HZ);
 	if (!ret) {
-		IWL_ERR(trans, "Could not load the [%d] uCode section\n",
-			section_num);
+		IWL_ERR(trans, "Failed to load firmware chunk!\n");
 		return -ETIMEDOUT;
 	}
 
 	return 0;
 }
 
+static int iwl_load_section(struct iwl_trans *trans, u8 section_num,
+			    const struct fw_desc *section)
+{
+	u8 *v_addr;
+	dma_addr_t p_addr;
+	u32 offset;
+	int ret = 0;
+
+	IWL_DEBUG_FW(trans, "[%d] uCode section being loaded...\n",
+		     section_num);
+
+	v_addr = dma_alloc_coherent(trans->dev, PAGE_SIZE, &p_addr, GFP_KERNEL);
+	if (!v_addr)
+		return -ENOMEM;
+
+	for (offset = 0; offset < section->len; offset += PAGE_SIZE) {
+		u32 copy_size;
+
+		copy_size = min_t(u32, PAGE_SIZE, section->len - offset);
+
+		memcpy(v_addr, (u8 *)section->data + offset, copy_size);
+		ret = iwl_load_firmware_chunk(trans, section->offset + offset,
+					      p_addr, copy_size);
+		if (ret) {
+			IWL_ERR(trans,
+				"Could not load the [%d] uCode section\n",
+				section_num);
+			break;
+		}
+	}
+
+	dma_free_coherent(trans->dev, PAGE_SIZE, v_addr, p_addr);
+	return ret;
+}
+
 static int iwl_load_given_ucode(struct iwl_trans *trans,
 				const struct fw_img *image)
 {
@@ -955,7 +984,7 @@
 		int i;
 
 		for (i = 0; i < IWL_UCODE_SECTION_MAX; i++) {
-			if (!image->sec[i].p_addr)
+			if (!image->sec[i].data)
 				break;
 
 			ret = iwl_load_section(trans, i, &image->sec[i]);
diff -urN .iwlwifi/iwl-ucode.c iwlwifi/iwl-ucode.c
--- .iwlwifi/iwl-ucode.c	2012-07-21 13:58:29.000000000 -0700
+++ iwlwifi/iwl-ucode.c	2012-09-12 17:10:18.151765877 -0700
@@ -270,7 +270,7 @@
 static int iwl_verify_sec_sparse(struct iwl_priv *priv,
 				  const struct fw_desc *fw_desc)
 {
-	__le32 *image = (__le32 *)fw_desc->v_addr;
+	__le32 *image = (__le32 *)fw_desc->data;
 	u32 len = fw_desc->len;
 	u32 val;
 	u32 i;
@@ -294,7 +294,7 @@
 static void iwl_print_mismatch_sec(struct iwl_priv *priv,
 				    const struct fw_desc *fw_desc)
 {
-	__le32 *image = (__le32 *)fw_desc->v_addr;
+	__le32 *image = (__le32 *)fw_desc->data;
 	u32 len = fw_desc->len;
 	u32 val;
 	u32 offs;

--x+6KMIRAuhnl3hBn--
