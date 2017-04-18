From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH v4 net-next RFC] net: Generic XDP
Date: Tue, 18 Apr 2017 15:37:02 -0400
Message-ID: <20170418193702.GH4730@C02RW35GFVH8.dhcp.broadcom.net>
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
Received: from mail-wr0-f182.google.com ([209.85.128.182]:36402 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752748AbdDRThP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 15:37:15 -0400
Received: by mail-wr0-f182.google.com with SMTP id c55so1794829wrc.3
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 12:37:14 -0700 (PDT)
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

I completely agree -- I just noted that the offset would be -20 in the
tx_tunnel case and it's easy to get confused since a positive int for
the second arg in skb_pull() does go 'back' with a positive value  and
was just rebuilding and testing just this case with:

-	off = xdp.data - orig_data;
+	/* note that offset is negative */
+	off = orig_data - xdp.data;


> In netif_receive_generic_xdp(), try changing the offset handling code to
> read something like:
> 
> 	off = xdp.data - orig_data;
> 	if (off > 0)
> 		__skb_pull(skb, off);
> 	else if (off < 0)
> 		__skb_push(skb, -off);

This should do it.  I'll give that run, too.

> If that doesn't work try adding:
> 
> 	__skb_cow(skb, XDP_PACKET_HEADROOM, 0);
> 
> right after the skb_linearize() call in that same function.
