From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: udp packets following an UFO enqueued packet need also be handled by UFO
Date: Tue, 1 Oct 2013 23:47:21 +0200
Message-ID: <20131001214721.GJ10771@order.stressinduktion.org>
References: <20130921042700.GB8070@order.stressinduktion.org> <20130930114343.GA6356@minipsycho.brq.redhat.com> <20130930172312.GE10771@order.stressinduktion.org> <20131001105837.GA1424@minipsycho.brq.redhat.com> <20131001120907.GH10771@order.stressinduktion.org> <20131001123214.GI10771@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@trash.net, herbert@gondor.apana.org.au,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34936 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575Ab3JAVrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 17:47:23 -0400
Content-Disposition: inline
In-Reply-To: <20131001123214.GI10771@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On Tue, Oct 01, 2013 at 02:32:14PM +0200, Hannes Frederic Sowa wrote:
> On Tue, Oct 01, 2013 at 02:09:07PM +0200, Hannes Frederic Sowa wrote:
> > On Tue, Oct 01, 2013 at 12:58:37PM +0200, Jiri Pirko wrote:
> > > >> 
> > > >> What if non-ufo-path-created skb is peeked?
> > > >
> > > >You mean like:
> > > >first append a frame < mtu
> > > >second frame > mtu so it gets handles by ip6_ufo_append?
> > > >
> > > >Currently I don't see a problem with it but I may be wrong. What is
> > > >your suspicion?
> > > 
> > > Well the skb will have gso_size==0 and ip_summed==CHECKSUM_NONE
> > > Because of that it will be not threated as ufo skb.
> > > 
> > > Following patch fixes it:
> > > 
> > > Subject: [patch net] ip6_output: do skb ufo init for peeked non ufo skb as well
> > > 
> > > Now, if user application does:
> > > sendto len<mtu flag MSG_MORE
> > > sendto len>mtu flag 0
> > > The skb is not treated as fragmented one because it is not initialized
> > > that way. So move the initialization to fix this.
> > > 
> > > Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> > 
> > My understanding is that the frame is only a valid gso frame iff the first skb
> > queued up is setup as an UFO frame. In other cases we only need to make sure
> > we append to the fragment list without updating the gso field and the skb will
> > get linearized (if needed) later in the output path.
> > 
> > This seems not to matter for virtio_net and loopback because we seem to pass
> > the skb as is. But the remaining ethernet card which sets NETIF_F_UFO is
> > neterion and we have to verify if this assumption is correct, there.
> 
> Hm, ip_append_page seems to violate my assumption. I need to read up on the
> code later today.

I still guess my assumption about gso is correct and I will have to review how
the ip_append_page codepath works in detail.

I currently have a tree where I have applied my UFO patch and your dontfrag
patch. When I have an application which does:

socket(PF_INET6, SOCK_DGRAM, IPPROTO_IP) = 3
connect(3, {sa_family=AF_INET6, sin6_port=htons(53), inet_pton(AF_INET6, "::1", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = 0	// UFO is enabled currently
setsockopt(3, SOL_UDP, 1, [1], 4)       = 0		// this sets UDP_CORK active
setsockopt(3, SOL_IPV6, IPV6_MTU, [1280], 4) = 0	// minimal IPV6 mtu
write(3, " ", 1)                        = 1		// generates non-gso head
write(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 3701) = 3701	// generates gso segment in frags but skb_is_gso(skb) == false
write(3, " ", 1						// and boom: null pointer deref and slab corruption

Without your patch this would not been possible and I am not sure your
patch breaks assumptions for hardware UFO. We should wait with that
patch until we sorted out the details.

My current guess is that we need to replace the skb_is_gso() with
something that checks for already appended frags and continue to use
sbk_append_datato_frags in that case.

The strange thing is that if I don't do the IPV6_MTU setsockopt I don't
get an oops.

IPv4 seems to work without problems, too.

Maybe I miss something? :|

Greetings,

  Hannes
