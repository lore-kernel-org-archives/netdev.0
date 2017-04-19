From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH v4 net-next RFC] net: Generic XDP
Date: Wed, 19 Apr 2017 10:29:03 -0400
Message-ID: <20170419142903.GJ4730@C02RW35GFVH8.dhcp.broadcom.net>
References: <20170415005949.GB73685@ast-mbp.thefacebook.com>
 <20170418190535.GG4730@C02RW35GFVH8.dhcp.broadcom.net>
 <20170418.150708.1605529107204449972.davem@davemloft.net>
 <20170418.152916.1361453741909754079.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, michael.chan@broadcom.com,
        netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:32837 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934148AbdDSO3N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 10:29:13 -0400
Received: by mail-oi0-f66.google.com with SMTP id a189so4886459oib.0
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 07:29:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170418.152916.1361453741909754079.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 18, 2017 at 03:29:16PM -0400, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 18 Apr 2017 15:07:08 -0400 (EDT)
> 
> > From: Andy Gospodarek <andy@greyhouse.net>
> > Date: Tue, 18 Apr 2017 15:05:35 -0400
> > 
> >> On Fri, Apr 14, 2017 at 05:59:51PM -0700, Alexei Starovoitov wrote:
> >>> On Thu, Apr 13, 2017 at 04:23:15PM -0400, David Miller wrote:
> >>> > +
> >>> > +	switch (act) {
> >>> > +	case XDP_TX:
> >>> > +		__skb_push(skb, skb->mac_len);
> >>> 
> >>> s/skb->mac_len/mac_len/
> >>> 
> >> 
> >> I was away from my keyboard for a few days, but was able to get some
> >> time to test this today.
> >> 
> >> When using this change above suggested by Alexei, XDP_DROP and XDP_TX
> >> actions appear to work well with xdp1 and xdp2.
> >> 
> >> I'm seeing some rather odd behavior with xdp_tx_tunnel so it might be
> >> good to hold off on committing this just yet.
> >> 
> >> At first glance, it looks like there is enough headroom for the new
> >> frame, but the resulting packet data do not look right and I'm actually
> >> seeing some data that may be left on the stack from a previous caller.
> > 
> > Thanks for testing Andy, I'll take a look and see if I can figure it out.
> 
> Andy, I think we might be getting burnt by signedness issues in the
> offset handling when the XDP program adjusts the packet data pointer.
> 
> In netif_receive_generic_xdp(), try changing the offset handling code to
> read something like:
> 
> 	off = xdp.data - orig_data;
> 	if (off > 0)
> 		__skb_pull(skb, off);
> 	else if (off < 0)
> 		__skb_push(skb, -off);
> 
> If that doesn't work try adding:
> 
> 	__skb_cow(skb, XDP_PACKET_HEADROOM, 0);
> 
> right after the skb_linearize() call in that same function.

So I tried a variety of things and the simplest change on top of yours that
works well for xdp1, xdp2, and xdp_tx_iptunnel. 

diff --git a/net/core/dev.c b/net/core/dev.c
index b3d3a6e..1bab3dc 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4316,11 +4316,11 @@ static u32 netif_receive_generic_xdp(struct sk_buff *skb,
 
 	off = xdp.data - orig_data;
 	if (off)
-		__skb_push(skb, off);
+		__skb_push(skb, -off);
 
 	switch (act) {
 	case XDP_TX:
-		__skb_push(skb, skb->mac_len);
+		__skb_push(skb, mac_len);
 		/* fall through */
 	case XDP_PASS:
 		break;

I ran this on top of a card that uses the bnxt_en driver on a desktop
class system with an i7-6700 CPU @ 3.40GHz, sending a single stream of
UDP traffic with flow control disabled and saw the following (all stats
in Million PPS).

                xdp1                xdp2            xdp_tx_tunnel
Generic XDP      7.8    5.5 (1.3 actual)         4.6 (1.1 actual)
Optimized XDP   11.7		     9.7                      4.6

One thing to note is that the Generic XDP case shows some different
results for reported by the application vs actual (seen on the wire).  I
did not debug where the drops are happening and what counter needs to be
incremented to note this -- I'll add that to my TODO list.  The
Optimized XDP case does not have a difference in reported vs actual
frames on the wire.

I agree with all those who have asserted that this is great tool for
those that want to get started with XDP but do not have hardware, so I'd
say it's ready to have the 'RFC' tag dropped.  Thanks for pushing this
forward, Dave!  :-)
