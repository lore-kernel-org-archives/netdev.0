From: Andrea Shepard <andrea@persephoneslair.org>
Subject: [PATCH] Fix corruption of skb csum field in pskb_expand_head() of net/core/skbuff.c
Date: Thu, 22 Jul 2010 12:12:35 -0700
Message-ID: <20100722191234.GA832@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cronus.persephoneslair.org ([216.254.15.24]:45140 "EHLO
	cronus.persephoneslair.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750776Ab0GVTXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 15:23:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make pskb_expand_head() check ip_summed to make sure csum_start is really
csum_start and not csum before adjusting it.

This fixes a bug I encountered using a Sun Quad-Fast Ethernet card and VLANs.
On my configuration, the sunhme driver produces skbs with differing amounts
of headroom on receive depending on the packet size.  See line 2030 of
drivers/net/sunhme.c; packets smaller than RX_COPY_THRESHOLD have 52 bytes
of headroom but packets larger than that cutoff have only 20 bytes.

When these packets reach the VLAN driver, vlan_check_reorder_header()
calls skb_cow(), which, if the packet has less than NET_SKB_PAD (== 32) bytes
of headroom, uses pskb_expand_head() to make more.

Then, pskb_expand_head() needs to adjust a lot of offsets into the skb,
including csum_start.  Since csum_start is a union with csum, if the packet
has a valid csum value this will corrupt it, which was the effect I observed.
The sunhme hardware computes receive checksums, so the skbs would be created
by the driver with ip_summed == CHECKSUM_COMPLETE and a valid csum field, and
then pskb_expand_head() would corrupt the csum field, leading to an "hw csum
error" message later on, for example in icmp_rcv() for pings larger than the
sunhme RX_COPY_THRESHOLD.

On the basis of the comment at the beginning of include/linux/skbuff.h,
I believe that the csum_start skb field is only meaningful if ip_csummed is
CSUM_PARTIAL, so this patch makes pskb_expand_head() adjust it only in that
case to avoid corrupting a valid csum value.

Please see my more in-depth disucssion of tracking down this bug for
more details if you like:

http://puellavulnerata.livejournal.com/112186.html
http://puellavulnerata.livejournal.com/112567.html
http://puellavulnerata.livejournal.com/112891.html
http://puellavulnerata.livejournal.com/113096.html
http://puellavulnerata.livejournal.com/113591.html

I am not subscribed to this list, so please CC me on replies.

Signed-off-by: Andrea Shepard <andrea@persephoneslair.org>

diff -Nau linux-2.6.34.1/net/core/skbuff.c linux-2.6.34.1-skb-csum/net/core/skbuff.c
--- linux-2.6.34.1/net/core/skbuff.c    2010-07-05 11:24:10.000000000 -0700
+++ linux-2.6.34.1-skb-csum/net/core/skbuff.c   2010-07-21 18:42:33.000000000 -0700
@@ -854,7 +854,9 @@
        skb->network_header   += off;
        if (skb_mac_header_was_set(skb))
                skb->mac_header += off;
-       skb->csum_start       += nhead;
+       /* Only adjust this if it actually is csum_start rather than csum */
+       if (skb->ip_summed == CHECKSUM_PARTIAL)
+               skb->csum_start += nhead;
        skb->cloned   = 0;
        skb->hdr_len  = 0;
        skb->nohdr    = 0;

-- 
Andrea Shepard
