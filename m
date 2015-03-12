From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] rtlwifi: get buffer_desc before trying to alloc new skb
Date: Thu, 12 Mar 2015 12:29:31 -0500
Message-ID: <5501CCFB.3040203@lwfinger.net>
References: <1426160036-1542-1-git-send-email-hamo.by@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070009050401090900020200"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Yang Bai <hamo.by-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1426160036-1542-1-git-send-email-hamo.by-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070009050401090900020200
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On 03/12/2015 06:33 AM, Yang Bai wrote:
> if rtlpriv->use_new_trx_flow == true and we run out of memory
> to alloc a new skb, we will directly jump to no_new tag with
> buffer_desc == NULL. Then we will dereference this NULL pointer
> in function _rtl_pci_init_one_rxdesc.
>
> Signed-off-by: Yang Bai <hamo.by-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Is the attached patch OK? I have tested it, but it is unlikely that I have hit 
any memory failures, thus that part needs to be checked by eye.

Larry



--------------070009050401090900020200
Content-Type: text/x-patch;
 name="0001-rtlwifi-get-buffer_desc-before-trying-to-alloc-new-s.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-rtlwifi-get-buffer_desc-before-trying-to-alloc-new-s.pa";
 filename*1="tch"

>From 74e20cf2bdb8312252363362495b9e517b3637d9 Mon Sep 17 00:00:00 2001
From: Yang Bai <hamo.by-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 12 Mar 2015 11:56:40 -0500
Subject: [PATCH V2 4.0] rtlwifi: get buffer_desc before trying to alloc new skb

If rtlpriv->use_new_trx_flow == true and we run out of memory
to alloc a new skb, we will directly jump to no_new tag with
buffer_desc == NULL. Then we will dereference this NULL pointer
in function _rtl_pci_init_one_rxdesc.

Signed-off-by: Yang Bai <hamo.by-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> [3.18+]
---

V2 - Refactor to reduce the number of tests of use_new_trx_flow.


 drivers/net/wireless/rtlwifi/pci.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index a62170e..7069778 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -801,7 +801,10 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 								      hw_queue);
 			if (rx_remained_cnt == 0)
 				return;
-
+			buffer_desc =
+			  &rtlpci->rx_ring[rxring_idx].buffer_desc
+				[rtlpci->rx_ring[rxring_idx].idx];
+			pdesc = (struct rtl_rx_desc *)skb->data;
 		} else {	/* rx descriptor */
 			pdesc = &rtlpci->rx_ring[rxring_idx].desc[
 				rtlpci->rx_ring[rxring_idx].idx];
@@ -824,13 +827,6 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 		new_skb = dev_alloc_skb(rtlpci->rxbuffersize);
 		if (unlikely(!new_skb))
 			goto no_new;
-		if (rtlpriv->use_new_trx_flow) {
-			buffer_desc =
-			  &rtlpci->rx_ring[rxring_idx].buffer_desc
-				[rtlpci->rx_ring[rxring_idx].idx];
-			/*means rx wifi info*/
-			pdesc = (struct rtl_rx_desc *)skb->data;
-		}
 		memset(&rx_status , 0 , sizeof(rx_status));
 		rtlpriv->cfg->ops->query_rx_desc(hw, &stats,
 						 &rx_status, (u8 *)pdesc, skb);
-- 
2.1.4


--------------070009050401090900020200--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
