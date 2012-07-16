From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: iptables CLAMP MSS to PMTU not working?
Date: Mon, 16 Jul 2012 12:08:44 +0200
Message-ID: <20120716100844.GK1869@secunet.com>
References: <20120712120021.3dc5cd68@vostro>
 <20120712132419.50b4acaf@vostro>
 <20120716084946.67b91a69@vostro>
 <20120716092058.270f6008@vostro>
 <20120716072305.GJ1869@secunet.com>
 <20120716105546.14a6490d@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48953 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751939Ab2GPKIr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2012 06:08:47 -0400
Content-Disposition: inline
In-Reply-To: <20120716105546.14a6490d@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 16, 2012 at 10:55:46AM +0300, Timo Teras wrote:
> On Mon, 16 Jul 2012 09:23:05 +0200 Steffen Klassert
> <steffen.klassert@secunet.com> wrote:
> > 
> > I did this patch to avoid to propagate learned PMTU informations.
> > It restores the behaviour we had before we moved the PMTU informations
> > to the inetpeer. Unfortunately CLAMPMSS really wants to have the PMTU
> > informations of an input route, which is not possible any more after
> > this patch.
> >
> > Anyway, this patch seems to be obsolete in the net-next tree, as
> > the cached pmtu informations are back in the route. So we should
> > remove the check for an output route from ipv4_mtu() in the net-next
> > tree. This should bring CLAMPMSS back to work, at least for upcoming
> > kernel versions.
> 
> Right, saw those commits. But before net-next hits release, I'd really
> need a fix for 3.3/3.4/3.5. Non-working fragmentation with IPsec, and
> this CLAMPMSS thingy are an upgrade stopper for me.
> 
> Would it be safe to just revert this commit, with the side-effect of
> exposing cached pmtu too agressively?

The router that can't send the packet to the next hop network has to
send the ICMP Destination Unreachable message. We never propagated
learned PMTU informations and I would not like to change this, in
particular not in a stable kernel.

Maybe we could fix this for already released kernels within the
netfilter module. Perhaps we could add a function

static unsigned int tcpmss_mtu(const struct dst_entry *dst)
{
        unsigned int mtu = dst_metric_raw(dst, RTAX_MTU); 

        return mtu ? : dst_mtu(dst->path);
}


and use this instead of dst_mtu().

> 
> Or would it be better to try to backport the relevant changes of moving
> pmtu back to route table?

A backport is probaply too invasive for a stable kernel.
