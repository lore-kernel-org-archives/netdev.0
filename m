From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3 1/3] ipv4: introduce ip_dst_mtu_secure and protect forwarding path against pmtu spoofing
Date: Wed, 8 Jan 2014 07:13:20 +0100
Message-ID: <20140108061320.GA9007@order.stressinduktion.org>
References: <20140106084827.GA5766@order.stressinduktion.org> <20140107.191314.881648861654097224.davem@davemloft.net> <20140108050225.GO30393@order.stressinduktion.org> <20140108.010213.884915830982848289.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	johnwheffner@gmail.com, steffen.klassert@secunet.com,
	fweimer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47273 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbaAHGNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 01:13:21 -0500
Content-Disposition: inline
In-Reply-To: <20140108.010213.884915830982848289.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 08, 2014 at 01:02:13AM -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 8 Jan 2014 06:02:25 +0100
> 
> > Hi David!
> > 
> > On Tue, Jan 07, 2014 at 07:13:14PM -0500, David Miller wrote:
> >> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> >> Date: Mon, 6 Jan 2014 09:48:27 +0100
> >> 
> >> > +ip_forward_use_pmtu - BOOLEAN
> >> > +	By default we don't trust protocol path MTUs while forwarding
> >> > +	because they could be easily forged and can lead to unwanted
> >> > +	fragmentation by the router.
> >> > +	You only need to enable this if you have user-space software
> >> > +	which tries to discover path mtus by itself and depends on the
> >> > +	kernel honoring this information. This is normally not the
> >> > +	case.
> >> > +	Default: 0 (disabled)
> >> > +	Possible values:
> >> > +	0 - disabled
> >> > +	1 - enabled
> >> 
> >> You made this default to off, great, but the description text still says
> >> that we don't trust PMTU information by default :-)
> > 
> > Hm, sorry, but I don't see the contradiction.
> 
> You say "By default we don't trust protocol path MTUs", but if the
> default value of ip_forward_use_pmtu is zero, we in fact do.

I am sorry..  maybe I am just stupid?

static inline unsigned int ip_dst_mtu_secure(const struct dst_entry *dst,
                                            bool forwarding)
{
       struct net *net = dev_net(dst->dev);

       if (net->ipv4.sysctl_ip_fwd_use_pmtu ||
           dst_metric_locked(dst, RTAX_MTU) ||
           !forwarding)
               return dst_mtu(dst);

       return min(dst->dev->mtu, IP_MAX_MTU);
}

The path with dst_mtu is the patch where I want to use the path
mtu information. It only gets reached either by locked route,
sysctl_ip_fwd_use_pmtu not zero or we are not forwarding the packet.

So, if fwd_use_pmtu is zero, either the mtu must be locked or we are
not forwarding the packet to use the path mtu.

Sorry for the confusion,

  Hannes
