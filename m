From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: Re: Re: [bisected regression] e1000e: "Detected Hardware
 Unit Hang"
Date: Thu, 15 Jan 2015 09:20:37 -0800
Message-ID: <1421342437.11734.79.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1719052.SGOfRAJhfQ@storm> <3089325.gjrPpo2XX1@storm>
	 <1421337658.11734.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1837410.pEGIH05mML@storm>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Linux Netdev List' <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:53312 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753395AbbAORUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 12:20:42 -0500
Received: by mail-ig0-f181.google.com with SMTP id r2so13817193igi.2
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 09:20:42 -0800 (PST)
In-Reply-To: <1837410.pEGIH05mML@storm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-15 at 18:04 +0100, Thomas Jarosch wrote:
> On Thursday, 15. January 2015 08:00:58 Eric Dumazet wrote:
> > Please apply this patch, and try to lower
> > /proc/sys/net/core/gro_max_frags and see if this makes a difference
> > (leaving GRO enabled)
> > 
> > (start with 7 and increase it, limit being 17)
> 
> Patch applied to 3.19-rc4+.
> 
> Results:
>  7: hang
>  8: hang
>  9: hang
> 10: hang
> 11: hang
> 12: hang
> 13: hang
> 14: hang
> 15: hang
> 16: hang
> 17: hang
> 
> for the sake of completeness:
> 1: hang

This is weird : This should have same effect then GRO off (at most one
segment per packet)

> 2: hang
> 3: hang
> 4: hang
> 5: hang
> 6: hang
> 
> Regarding the test procedure: I stopped the download script on the client,
> changed gro_max_frags and started the download again. No cable unplugging / 
> reboot of the box in between. Just mentioning it to make sure it somehow 
> does not affect what we actually wanted to test.
> 
> Additional tests have been done with gro_max_frags 1, 7 and 17:
> - stop networking + unload e1000e -> restart -> download: hang
> 
> One thing I can say from the testing: The more I increase gro_max_frags,
> the longer it takes to trigger it. I tried each setting below three times.
> A value of 17 is really noticeable.
> 
> 1: 3-8 seconds till hang
> 7: 7-10 seconds till hang
> 17: 23-26 seconds till hang

Could you try the following ?

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 38cb586b1bf42fa7a50e19f3e650e8c139788820..6d93facddab78f8db7000fddaa24322651a0eae9 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1264,7 +1264,7 @@ static bool e1000_clean_tx_irq(struct e1000_ring *tx_ring)
 
 	netdev_completed_queue(netdev, pkts_compl, bytes_compl);
 
-#define TX_WAKE_THRESHOLD 32
+#define TX_WAKE_THRESHOLD (MAX_SKB_FRAGS * 3 + 2)
 	if (count && netif_carrier_ok(netdev) &&
 	    e1000_desc_unused(tx_ring) >= TX_WAKE_THRESHOLD) {
 		/* Make sure that anybody stopping the queue after this
@@ -5650,10 +5650,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 		netdev_sent_queue(netdev, skb->len);
 		e1000_tx_queue(tx_ring, tx_flags, count);
 		/* Make sure there is space in the ring for the next send. */
-		e1000_maybe_stop_tx(tx_ring,
-				    (MAX_SKB_FRAGS *
-				     DIV_ROUND_UP(PAGE_SIZE,
-						  adapter->tx_fifo_limit) + 2));
+		e1000_maybe_stop_tx(tx_ring, 3 * MAX_SKB_FRAGS + 2);
 	} else {
 		dev_kfree_skb_any(skb);
 		tx_ring->buffer_info[first].time_stamp = 0;
