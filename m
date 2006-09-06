From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFT] sky2 vs iptables
Date: Wed, 6 Sep 2006 14:16:51 -0700
Message-ID: <20060906141651.116aa758@localhost.localdomain>
References: <44FE2618.3010705@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcclung@nebrwesleyan.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:26334 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751546AbWIFVRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 17:17:02 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <44FE2618.3010705@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 05 Sep 2006 21:36:24 -0400
Daniel Drake <dsd@gentoo.org> wrote:

> Hi,
> 
> There's a strange sky2 bug on the Gentoo bugzilla:
> http://bugs.gentoo.org/show_bug.cgi?id=136508
> 
> sky2 seems to work OK, but breaks as soon as the iptables ruleset is 
> loaded. Nothing can be pinged, etc.
> 
> Can someone try and reproduce this? The iptables rule script has been 
> uploaded here:
> http://bugs.gentoo.org/attachment.cgi?id=95694&action=view
> 
> The very last command in that file is the one which produces an error 
> and stops everything working:
> 
> 	iptables: Unknown error 18446744073709551615
> 
> Apparently a sky2 null deref has also been seen at this point, although 
> I don't have further details on that.
> 
> Thanks!
> Daniel
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

It might be an artifact of the way sky2 was allocating receive buffers.
Bridge-netfilter was assuming header space in the buffer, and would corrupt
other memory, maybe iptables is assuming as well. This makes sky2
use dev_alloc_skb that reserves space.
-----------------------
Subject: sky2: use dev_alloc_skb for receive buffers

Several code paths assume an additional 16 bytes of header padding
on the receive path. Use dev_alloc_skb to get that padding.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6.17.11.orig/drivers/net/sky2.c
+++ linux-2.6.17.11/drivers/net/sky2.c
@@ -949,14 +949,14 @@ static void sky2_vlan_rx_kill_vid(struct
 /*
  * It appears the hardware has a bug in the FIFO logic that
  * cause it to hang if the FIFO gets overrun and the receive buffer
- * is not aligned. ALso alloc_skb() won't align properly if slab
+ * is not aligned. Also dev_alloc_skb() won't align properly if slab
  * debugging is enabled.
  */
 static inline struct sk_buff *sky2_alloc_skb(unsigned int size, gfp_t gfp_mask)
 {
 	struct sk_buff *skb;
 
-	skb = alloc_skb(size + RX_SKB_ALIGN, gfp_mask);
+	skb = __dev_alloc_skb(size + RX_SKB_ALIGN, gfp_mask);
 	if (likely(skb)) {
 		unsigned long p	= (unsigned long) skb->data;
 		skb_reserve(skb, ALIGN(p, RX_SKB_ALIGN) - p);
@@ -1855,7 +1855,7 @@ static struct sk_buff *sky2_receive(stru
 		goto oversize;
 
 	if (length < copybreak) {
-		skb = alloc_skb(length + 2, GFP_ATOMIC);
+		skb = dev_alloc_skb(length + 2);
 		if (!skb)
 			goto resubmit;
 
