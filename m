From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: don't use CHECKSUM_PARTIAL on MSG_MORE/UDP_CORK
 sockets
Date: Wed, 21 Oct 2015 11:51:26 +0200
Message-ID: <1445421086.1167705.416135513.62D75196@webmail.messagingengine.com>
References: <1445351922-8463-1-git-send-email-hannes@stressinduktion.org>
 <5626B4A3.6080900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: sd@quesysnail.net, bcodding@redhat.com
To: Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:32851 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753868AbbJUJv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 05:51:26 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 56CFB202B8
	for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 05:51:26 -0400 (EDT)
In-Reply-To: <5626B4A3.6080900@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vlad,

On Tue, Oct 20, 2015, at 23:39, Vlad Yasevich wrote:
> On 10/20/2015 10:38 AM, Hannes Frederic Sowa wrote:
> > MSG_MORE might cause the packet to get fragmented in the end when
> > passed down to the flush function and the transhdrlen check alone is
> > not sufficient to protect against fragmentation. Instead check if the
> > socket user intends to add more data to the socket on the first packet.
> > 
> > This broke checksum calculation for UDPv6 for NFS protocols.
> > 
> > Fixes: 32dce968dd987 ("ipv6: Allow for partial checksums on non-ufo packets")
> > Cc: Vlad Yasevich <vyasevich@gmail.com>
> > Tested-by: Sabrina Dubroca <sd@quesysnail.net>
> > Tested-by: Benjamin Coddington <bcodding@redhat.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> >  net/ipv6/ip6_output.c | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> > index 61d403e..95c5780 100644
> > --- a/net/ipv6/ip6_output.c
> > +++ b/net/ipv6/ip6_output.c
> > @@ -1317,6 +1317,7 @@ emsgsize:
> >  	 * sums only work when transhdrlen is set.
> >  	 */
> >  	if (transhdrlen && sk->sk_protocol == IPPROTO_UDP &&
> > +	    !(flags & MSG_MORE) &&
> >  	    length + fragheaderlen < mtu &&
> >  	    rt->dst.dev->features & NETIF_F_V6_CSUM &&
> >  	    !exthdrlen)
> > 
> 
> Hmm... so while this solves this problem by simply avoiding the
> combination of
> skb #1 having CHECKSUM_PARTIAL and others having CHECKSUM_NONE, I think
> the actual
> problem is a bit deeper.
> The above combination seems to work for me since udp6_hwcsum_outgoing()
> corrects
> the checksum.  However, my testing so far has been on nics that have
> NETIF_F_V6_CSUM,
> but without UFO support.

With nfs tests we never branch into setting up or extending an UDP UFO
packet, also because on the test system UFO is disabled on all
interfaces.

I thought about relaxing this check in future when we simply make sure
we don't do fragmentation based based on the length while taking all
fragments into account.

> On such systems a simple test of using MSG_MORE an IPv6 udp socket
> sending 200 bytes
> followed by 2000 bytes works correctly.

Did you make sure it actually fragmented and the checksums are correct?

> I am now wondering if this might be UFO related instead and looking for a
> nic that
> has UFO support.

So far as I can see it has nothing to do with UFO. I will do more
investigation now. Thanks for bringing this up!

Bye,
Hannes
