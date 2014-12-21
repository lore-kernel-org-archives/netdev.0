From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [BUG] rtl8192se: panic accessing unmapped memory in skb
Date: Sun, 21 Dec 2014 17:02:02 -0600
Message-ID: <5497516A.2020400@lwfinger.net>
References: <20141221172516.GA12784@zzz>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080701040609070407000102"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Biggers <ebiggers3@gmail.com>, linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141221172516.GA12784@zzz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080701040609070407000102
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On 12/21/2014 11:25 AM, Eric Biggers wrote:
> Hi,
>
> I have a RTL8192SE wireless card, attached via PCI.  Usually it works with no
> issues, but I recently had a kernel panic occur in the rtl8192se driver.  The
> kernel version is 3.18.  Based on my analysis of the panic dump, the panic was
> caused by a memory access violation in this block of code in
> rtl92se_rx_query_desc():
>
>          if (stats->decrypted) {
>                  hdr = (struct ieee80211_hdr *)(skb->data +
>                         stats->rx_drvinfo_size + stats->rx_bufshift);
>
>                  if ((_ieee80211_is_robust_mgmt_frame(hdr)) &&
>                          (ieee80211_has_protected(hdr->frame_control)))
>                          rx_status->flag &= ~RX_FLAG_DECRYPTED;
>                  else
>                          rx_status->flag |= RX_FLAG_DECRYPTED;
>          }
>
> Specifically, the violation occurred the first time hdr->frame_control was
> accessed, as part of _ieee80211_is_robust_mgmt_frame().
>
> The panic occurred when the system was under heavy filesystem load but seemingly
> is not easily reproducible.
>
> There was recently a NULL check that was removed from this exact place in the
> code, but it was certainly useless.  Instead, what's much more suspect to me is
> that inside _rtl_pci_rx_interrupt(), there is no error checking of the return
> value of _rtl_pci_init_one_rxdesc(), which might fail if the skb couldn't be
> allocated.  I am wondering if this could be causing the problem.

Your analysis is probably correct; however, I'm not sure what to do if the 
allocate of an skb fails. As the name says, this routine is entered through an 
interrupt, and I'm not sure what to do other than to exit.

The attached patch will implement the exit after logging an error. Please patch 
your system and report back.

How much RAM does your system have? That info might be useful in trying to 
reproduce the problem, which might indeed be difficult. Although pci.c was 
extensively reworked in the 3.17 => 3.18 transition, most of the changes were 
added to implement the changed descriptor structure for the RTL8192EE, and I do 
not remember any changes that would affect any of the other drivers. As a 
result, the current structure has been in place for some time, and this problem 
has not been reported before.

Larry


--------------080701040609070407000102
Content-Type: text/plain; charset=UTF-8;
 name="rtlwifi_report_add_new_rxdesc_failure"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="rtlwifi_report_add_new_rxdesc_failure"

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 846a2e6..c576c71 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -676,7 +676,7 @@ static int _rtl_pci_init_one_rxdesc(struct ieee80211_hw *hw,
 
 	skb = dev_alloc_skb(rtlpci->rxbuffersize);
 	if (!skb)
-		return 0;
+		return -ENOMEM;;
 	rtlpci->rx_ring[rxring_idx].rx_buf[desc_idx] = skb;
 
 	/* just set skb->cb to mapping addr for pci_unmap_single use */
@@ -685,7 +685,7 @@ static int _rtl_pci_init_one_rxdesc(struct ieee80211_hw *hw,
 			       rtlpci->rxbuffersize, PCI_DMA_FROMDEVICE);
 	bufferaddress = *((dma_addr_t *)skb->cb);
 	if (pci_dma_mapping_error(rtlpci->pdev, bufferaddress))
-		return 0;
+		return -EFAULT;
 	if (rtlpriv->use_new_trx_flow) {
 		rtlpriv->cfg->ops->set_desc(hw, (u8 *)entry, false,
 					    HW_DESC_RX_PREPARE,
@@ -701,7 +701,7 @@ static int _rtl_pci_init_one_rxdesc(struct ieee80211_hw *hw,
 					    HW_DESC_RXOWN,
 					    (u8 *)&tmp_one);
 	}
-	return 1;
+	return 0;
 }
 
 /* inorder to receive 8K AMSDU we have set skb to
@@ -768,6 +768,7 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 		.signal = 0,
 		.rate = 0,
 	};
+	int err;
 
 	/*RX NORMAL PKT */
 	while (count--) {
@@ -912,13 +913,21 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 		}
 end:
 		if (rtlpriv->use_new_trx_flow) {
-			_rtl_pci_init_one_rxdesc(hw, (u8 *)buffer_desc,
-						 rxring_idx,
-					       rtlpci->rx_ring[rxring_idx].idx);
+			err = _rtl_pci_init_one_rxdesc(hw, (u8 *)buffer_desc,
+						       rxring_idx,
+						       rtlpci->rx_ring[rxring_idx].idx);
+			if (err) {
+				pr_err("%s Failed to init RX descriptor\n");
+				return;
+			}
 		} else {
-			_rtl_pci_init_one_rxdesc(hw, (u8 *)pdesc, rxring_idx,
-						 rtlpci->rx_ring[rxring_idx].idx);
-
+			err = _rtl_pci_init_one_rxdesc(hw, (u8 *)pdesc,
+						       rxring_idx,
+						       rtlpci->rx_ring[rxring_idx].idx);
+			if (err) {
+				pr_err("%s Failed to init RX descriptor\n");
+				return;
+			}
 			if (rtlpci->rx_ring[rxring_idx].idx ==
 			    rtlpci->rxringcount - 1)
 				rtlpriv->cfg->ops->set_desc(hw, (u8 *)pdesc,


--------------080701040609070407000102--
