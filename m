From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 1/2][RFC] vlan: use pskb_copy() when inserting a vlan tag by hand
Date: Tue, 8 Jul 2008 20:52:26 +0200
Message-ID: <20080708185226.GD14330@xi.wantstofly.org>
References: <20080707205646.GB12997@xi.wantstofly.org> <4872841E.1030609@trash.net> <20080707210701.GD12997@xi.wantstofly.org> <48728784.2030202@trash.net> <487394CC.7050107@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@cam.org>,
	Dale Farnsworth <dale@farnsworth.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:37107 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbYGHSw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 14:52:28 -0400
Content-Disposition: inline
In-Reply-To: <487394CC.7050107@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 08, 2008 at 06:24:44PM +0200, Patrick McHardy wrote:

> >>>>When inserting a vlan tag into an skb by hand (in the case the
> >>>>target network device hardware does not support inserting a vlan
> >>>>tag by passing it in via the TX descriptor), making a copy of the
> >>>>skb to be modified by calling skb_copy() is overkill, since
> >>>>skb_copy() will needlessly linearize the skb, copying of all of
> >>>>the fragmented data around, and checksumming the paket in software
> >>>>even if the hardware is perfectly capable of doing that by itself.
> >>>>
> >>>>For this case, pskb_copy() does exactly what is needed and no more,
> >>>>so use that instead.
> >>>>
> >>>>Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> >>>This looks fine to me.
> >>
> >>OK.  Since the mv643xx_eth patch (2/2) depends on both this patch
> >>and the one you/I sent previously, could you merge the mv643xx_eth
> >>patch (2/2) via your tree as well?
> >
> >I already sent the network_header fix to Dave, so its probably
> >easiest to have it go through him directly. Your patch applies
> >cleanly on top of my VLAN update from this morning. 
> 
> Actually, are you sure this patch is helping for the case
> you describe? The function you changed is only called on
> the RX path.

You're right, I got confused with setting ->vlan_features, which is
the actual thing that controls whether ->hard_start_xmit() gets send
fragmented skbs or not.

skb_copy() shows high in the profiles, but it's not the skb_copy() in
vlan_check_reorder_header() (my bad), it's the skb_copy() call in
skb_unshare() called via include/linux/if_vlan.h:__vlan_put_tag().

I've gathered some numbers for zero-copy (sendfile) sending a 1 GiB
file filled with zeroes from the box that has the mv643xx_eth to a
random x86 box:

- 2.6.26-rc9, no VLAN tagging: ~71 sec, 14.4 MiB/s
- 2.6.29-rc9, VLAN tagging: ~107 sec, 9.57 MiB/s
- 2.6.29-rc9, VLAN tagging with [1] + [2]: ~94 sec: 10.9 MiB/s
- 2.6.29-rc9, VLAN tagging with [1] + [2] + [3]: ~81 sec: 12.6 MiB/s

I'm wondering whether lying to the stack about HW VLAN accel
capability and adding the VLAN tag to the ethernet header in a
private buffer in the driver will give me the performance back.



[1] "vlan 01/07: fix network_header/mac_header adjustments",
    http://marc.info/?l=linux-netdev&m=121543468509250&w=2


[2] "mv643xx_eth: enable hardware TX checksumming with vlan tags",
    http://marc.info/?l=linux-netdev&m=121546423330743&w=2


[3]

(If I'd have to guess, I'd say that the existence of a frag list
shouldn't matter for the shareability of an skb, but there's probably
a good reason why skb_unshare() calls skb_copy() and not pskb_copy().)

Index: linux-2.6.26-rc9/include/linux/skbuff.h
===================================================================
--- linux-2.6.26-rc9.orig/include/linux/skbuff.h
+++ linux-2.6.26-rc9/include/linux/skbuff.h
@@ -581,7 +581,7 @@ static inline struct sk_buff *skb_unshar
 {
 	might_sleep_if(pri & __GFP_WAIT);
 	if (skb_cloned(skb)) {
-		struct sk_buff *nskb = skb_copy(skb, pri);
+		struct sk_buff *nskb = pskb_copy(skb, pri);
 		kfree_skb(skb);	/* Free our shared copy */
 		skb = nskb;
 	}
