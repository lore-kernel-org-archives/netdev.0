From: Timo Teras <timo.teras@iki.fi>
Subject: Re: iptables CLAMP MSS to PMTU not working?
Date: Mon, 16 Jul 2012 13:53:18 +0300
Message-ID: <20120716135318.134d7f63@vostro>
References: <20120712120021.3dc5cd68@vostro>
	<20120712132419.50b4acaf@vostro>
	<20120716084946.67b91a69@vostro>
	<20120716092058.270f6008@vostro>
	<20120716072305.GJ1869@secunet.com>
	<20120716105546.14a6490d@vostro>
	<20120716100844.GK1869@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:51729 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542Ab2GPKxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 06:53:37 -0400
Received: by eaak11 with SMTP id k11so1601887eaa.19
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 03:53:36 -0700 (PDT)
In-Reply-To: <20120716100844.GK1869@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Jul 2012 12:08:44 +0200 Steffen Klassert
<steffen.klassert@secunet.com> wrote:

> On Mon, Jul 16, 2012 at 10:55:46AM +0300, Timo Teras wrote:
> > On Mon, 16 Jul 2012 09:23:05 +0200 Steffen Klassert
> > <steffen.klassert@secunet.com> wrote:
> > > 
> > > I did this patch to avoid to propagate learned PMTU informations.
> > > It restores the behaviour we had before we moved the PMTU
> > > informations to the inetpeer. Unfortunately CLAMPMSS really wants
> > > to have the PMTU informations of an input route, which is not
> > > possible any more after this patch.
> > >
> > > Anyway, this patch seems to be obsolete in the net-next tree, as
> > > the cached pmtu informations are back in the route. So we should
> > > remove the check for an output route from ipv4_mtu() in the
> > > net-next tree. This should bring CLAMPMSS back to work, at least
> > > for upcoming kernel versions.
> > 
> > Right, saw those commits. But before net-next hits release, I'd
> > really need a fix for 3.3/3.4/3.5. Non-working fragmentation with
> > IPsec, and this CLAMPMSS thingy are an upgrade stopper for me.
> > 
> > Would it be safe to just revert this commit, with the side-effect of
> > exposing cached pmtu too agressively?
> 
> The router that can't send the packet to the next hop network has to
> send the ICMP Destination Unreachable message. We never propagated
> learned PMTU informations and I would not like to change this, in
> particular not in a stable kernel.

Ah, now I understand what you mean with "propagation". Leaking out the
PMTU of locally originating traffic to the forward path.

Makes sense. I'll probably just revert the change locally, as for my
use this should not be a problem.

> Maybe we could fix this for already released kernels within the
> netfilter module. Perhaps we could add a function
> 
> static unsigned int tcpmss_mtu(const struct dst_entry *dst)
> {
>         unsigned int mtu = dst_metric_raw(dst, RTAX_MTU); 
> 
>         return mtu ? : dst_mtu(dst->path);
> }
> 
> and use this instead of dst_mtu().

Yes, of course this fixes TCPMSS; but not IPsec fragmentation which is
even more critical.

On forward path, if I send large IP-packets (e.g. ping -s 1500) with
DF-bit not set to a destination that is XFRMed, I get now blackholed.

This is because the large packet is fragmented according to the forward
route MTU which now does not account the XFRM headers and the fragments
are too large to be sent out. This causes the packets to get dropped
to floor; and since DF was not set, there's no ICMP error sent out.
With fragmentation the originator is not and does not want to be aware
of the PMTU.

Basically the MTU needs to be accurate for fragmentation to work.

Just using the "device MTU" or "route MTU" is not enough. This is
because XFRMed target MTU is currently learned dynamically. The
per-packet overhead can depend on destination IP (e.g. per-IP SA can
have different hash or encapsulation which affects the header size and
thus the overall MTU).

I guess it would be better if the XFRMed MTUs were calculated properly.
This would avoid one lost packet -- the one that gets sent out using
the device/route MTU, then triggers route pmtu to get updated, and
dropped. Then further packets get fragmented according to the cached
pmtu properly. Would be nice if this "learning" packet was not needed.
