From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH for 3.19] rtlwifi: Fix error when accessing unmapped memory
 in skb
Date: Mon, 22 Dec 2014 16:41:22 -0600
Message-ID: <54989E12.6050808@lwfinger.net>
References: <1419269826-12552-1-git-send-email-Larry.Finger@lwfinger.net> <20141222194843.GA7575@zzz>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070702000602040909090600"
Cc: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Biggers <ebiggers3-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141222194843.GA7575@zzz>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070702000602040909090600
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On 12/22/2014 01:48 PM, Eric Biggers wrote:
> Is this really the same behavior as 3.17?  In 3.17, allocating the new skb is
> one of the first things the interrupt handler does, and if that fails it drops
> the packet and keeps using the old skb.  In this proposal, it's only after the
> packet has been received and the old skb has been freed that a new one is
> allocated.  And if that fails --- well, what are you expecting to happen
> exactly?

You are correct. In trying to get a small patch for stable, I missed some 
important points.

Please look at the attached patch. I think it handles the skb allocations 
correctly. The critical point is that _rtl_pci_init_one_rxdesc() cannot be 
allowed to fail to allocate an skb while in the interrupt path. Now, I have 
already allocated the skb before the call and bypassed this routine if the 
allocation fails. After a couple of crashes, this one now works for the case 
when the allocation wouldn't fail anyway. I will likely pull the allocation out 
of _rtl_pci_init_one_rxdesc() in all cases for the final patch.

@Kalle: Please drop the patch I submitted this morning with this subject. It 
would not help the problem. I will resubmit after I am sure of the proper fix.

Thanks,

Larry



--------------070702000602040909090600
Content-Type: text/plain; charset=UTF-8;
 name="fix_skb_alloc_v2"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="fix_skb_alloc_v2"

Index: wireless-drivers/drivers/net/wireless/rtlwifi/pci.c
===================================================================
--- wireless-drivers.orig/drivers/net/wireless/rtlwifi/pci.c
+++ wireless-drivers/drivers/net/wireless/rtlwifi/pci.c
@@ -666,6 +666,7 @@ tx_status_ok:
 }
 
 static int _rtl_pci_init_one_rxdesc(struct ieee80211_hw *hw,
+				    struct sk_buff *new_skb,
 				    u8 *entry, int rxring_idx, int desc_idx)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -674,7 +675,10 @@ static int _rtl_pci_init_one_rxdesc(stru
 	u8 tmp_one = 1;
 	struct sk_buff *skb;
 
-	skb = dev_alloc_skb(rtlpci->rxbuffersize);
+	if (new_skb)
+		skb = new_skb;
+	else
+		skb = dev_alloc_skb(rtlpci->rxbuffersize);
 	if (!skb)
 		return 0;
 	rtlpci->rx_ring[rxring_idx].rx_buf[desc_idx] = skb;
@@ -772,6 +776,7 @@ static void _rtl_pci_rx_interrupt(struct
 	/*RX NORMAL PKT */
 	while (count--) {
 		struct ieee80211_hdr *hdr;
+		struct sk_buff *new_skb = NULL;
 		__le16 fc;
 		u16 len;
 		/*rx buffer descriptor */
@@ -800,6 +805,12 @@ static void _rtl_pci_rx_interrupt(struct
 				return;
 		}
 
+		new_skb = dev_alloc_skb(rtlpci->rxbuffersize);
+		if (unlikely(!new_skb)) {
+			RT_TRACE(rtlpriv, (COMP_INTR | COMP_RECV), DBG_DMESG,
+				 "can't alloc skb for rx\n");
+			goto end;
+		}
 		/* Reaching this point means: data is filled already
 		 * AAAAAAttention !!!
 		 * We can NOT access 'skb' before 'pci_unmap_single'
@@ -845,6 +856,7 @@ static void _rtl_pci_rx_interrupt(struct
 		if (rtlpriv->cfg->ops->rx_command_packet &&
 		    rtlpriv->cfg->ops->rx_command_packet(hw, stats, skb)) {
 				dev_kfree_skb_any(skb);
+				skb = new_skb;
 				goto end;
 		}
 
@@ -895,6 +907,7 @@ static void _rtl_pci_rx_interrupt(struct
 		} else {
 			dev_kfree_skb_any(skb);
 		}
+		skb = new_skb;
 		if (rtlpriv->use_new_trx_flow) {
 			rtlpci->rx_ring[hw_queue].next_rx_rp += 1;
 			rtlpci->rx_ring[hw_queue].next_rx_rp %=
@@ -912,12 +925,13 @@ static void _rtl_pci_rx_interrupt(struct
 		}
 end:
 		if (rtlpriv->use_new_trx_flow) {
-			if (!_rtl_pci_init_one_rxdesc(hw, (u8 *)buffer_desc,
-					     rxring_idx,
-					     rtlpci->rx_ring[rxring_idx].idx))
+			/* TODO: Can the following fail? */
+			if (!_rtl_pci_init_one_rxdesc(hw, skb,
+					 (u8 *)buffer_desc, rxring_idx,
+					 rtlpci->rx_ring[rxring_idx].idx))
 				return;
 		} else {
-			if (!_rtl_pci_init_one_rxdesc(hw, (u8 *)pdesc,
+			if (!_rtl_pci_init_one_rxdesc(hw, skb, (u8 *)pdesc,
 					     rxring_idx,
 					     rtlpci->rx_ring[rxring_idx].idx))
 				return;
@@ -1309,7 +1323,7 @@ static int _rtl_pci_init_rx_ring(struct
 		rtlpci->rx_ring[rxring_idx].idx = 0;
 		for (i = 0; i < rtlpci->rxringcount; i++) {
 			entry = &rtlpci->rx_ring[rxring_idx].buffer_desc[i];
-			if (!_rtl_pci_init_one_rxdesc(hw, (u8 *)entry,
+			if (!_rtl_pci_init_one_rxdesc(hw, NULL, (u8 *)entry,
 						      rxring_idx, i))
 				return -ENOMEM;
 		}
@@ -1334,7 +1348,7 @@ static int _rtl_pci_init_rx_ring(struct
 
 		for (i = 0; i < rtlpci->rxringcount; i++) {
 			entry = &rtlpci->rx_ring[rxring_idx].desc[i];
-			if (!_rtl_pci_init_one_rxdesc(hw, (u8 *)entry,
+			if (!_rtl_pci_init_one_rxdesc(hw, NULL, (u8 *)entry,
 						      rxring_idx, i))
 				return -ENOMEM;
 		}

--------------070702000602040909090600--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
