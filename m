From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 06/13] ipv6: Fix nexthdr for reinjection
Date: Fri, 13 May 2016 07:16:13 +0300
Message-ID: <20160513071613.3749e0c9@halley>
References: <1462985253-2380625-1-git-send-email-tom@herbertland.com>
	<1462985253-2380625-7-git-send-email-tom@herbertland.com>
	<20160512232304.437eb3bc@halley>
	<CALx6S34BHQnxSBAW4n4k+pf0Zey+XaiLAVvU5k_zVVRz=jAJvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34593 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbcEMEQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 00:16:18 -0400
Received: by mail-wm0-f65.google.com with SMTP id n129so1195261wmn.1
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 21:16:17 -0700 (PDT)
In-Reply-To: <CALx6S34BHQnxSBAW4n4k+pf0Zey+XaiLAVvU5k_zVVRz=jAJvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Thu, 12 May 2016 14:45:36 -0700 Tom Herbert <tom@herbertland.com> wrote:
> On Thu, May 12, 2016 at 1:23 PM, Shmulik Ladkani
> <shmulik.ladkani@gmail.com> wrote:
> > On Wed, 11 May 2016 09:47:26 -0700 Tom Herbert <tom@herbertland.com> wrote:  
> >> In ip6_input_finish the protocol handle returns a value greater than
> >> zero the packet needs to be resubmitted using the returned protocol.
> >> The returned protocol is being ignored and each time through resubmit
> >> nexthdr is taken from an offest in the packet. This patch fixes that
> >> so that nexthdr is taken from return value of the protocol handler.
> >>
> >> Signed-off-by: Tom Herbert <tom@herbertland.com>
> >> ---
> >>  net/ipv6/ip6_input.c | 9 ++++++---
> >>  1 file changed, 6 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
> >> index 6ed5601..2a0258a 100644
> >> --- a/net/ipv6/ip6_input.c
> >> +++ b/net/ipv6/ip6_input.c
> >> @@ -222,13 +222,14 @@ static int ip6_input_finish(struct net *net, struct sock *sk, struct sk_buff *sk
> >>        */
> >>
> >>       rcu_read_lock();
> >> -resubmit:
> >> +
> >>       idev = ip6_dst_idev(skb_dst(skb));
> >>       if (!pskb_pull(skb, skb_transport_offset(skb)))
> >>               goto discard;
> >>       nhoff = IP6CB(skb)->nhoff;
> >>       nexthdr = skb_network_header(skb)[nhoff];
> >>
> >> +resubmit:  
> >
> > This has already been attempted in 0243508edd "ipv6: Fix protocol
> > resubmission" and reverted in 1b0ccfe54a.
> >
> > It looks that in some genuine extension header handling cases of ipv6
> > (not related to encapsulation), the original resubmission code REALLY
> > requires one to re-read IP6CB(skb)->nhoff and refetch the nexthdr.
> >  
> Is there any reason why the EH handlers can't read the nexthdr and return
> that?

Unaware of any reason; It does looks like we can simply do so for the EH
handlers (this was my 2nd suggestion).

Note also, that after resubmission, if the new nexthdr proto isn't found
at inet6_protos, there's a later:

				icmpv6_send(skb, ICMPV6_PARAMPROB,
					    ICMPV6_UNK_NEXTHDR, nhoff);

whose purpose is to send icmpv6 "Parameter Problem, Unrecognized Next
Header", with the "Pointer info" field set to value of 'nhoff'.

Thus for the EH handlers case we need to pass the updated
'IP6CB(skb)->nhoff' as the last argument.

OTOH, if the nexthdr proto was due to encapsulation resubmission, I'm
not sure what's the right "pointer info" value to specify :)

Regards,
Shmulik
