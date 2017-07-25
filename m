From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [RFC PATCH] IP: do not modify ingress packet IP option in
 ip_options_echo()
Date: Tue, 25 Jul 2017 17:26:16 +0200
Message-ID: <1500996376.13149.10.camel@redhat.com>
References: <f5758b6b7199d2d2a218b0ad36f1e5ef108eac43.1500642854.git.pabeni@redhat.com>
         <20170724.141253.769254590231937263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
        hannes@stressinduktion.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54416 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752089AbdGYP0T (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Jul 2017 11:26:19 -0400
In-Reply-To: <20170724.141253.769254590231937263.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-07-24 at 14:12 -0700, David Miller wrote:
> From: Paolo Abeni <pabeni@redhat.com>
> Date: Fri, 21 Jul 2017 15:55:18 +0200
> 
> > diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
> > index 93157f2..fdda973 100644
> > --- a/net/ipv4/ip_options.c
> > +++ b/net/ipv4/ip_options.c
> > @@ -174,9 +174,6 @@ int __ip_options_echo(struct ip_options *dopt, struct sk_buff *skb,
> >                               doffset -= 4;
> >               }
> >               if (doffset > 3) {
> > -                     __be32 daddr = fib_compute_spec_dst(skb);
> > -
> > -                     memcpy(&start[doffset-1], &daddr, 4);
> >                       dopt->faddr = faddr;
> 
> This transformation is required, but in the destination not the source.
> 
> The red flag is that we are indexing 'start' with 'doffset' instead of
> 'soffset'.

Thank you for your reply. I spent some time trying to understand the
reasoning behind the code above, but still it baffles me. 

I have a reproducer sending TCP syns to a closed port using LSRR
routing towards different namespaces without any explicit route for the
server address nor for the way back.
With the vanilla kernel, the ICMP port unreachable replyes contain a
corrupted version of the ingress packet, with the last item of LSRR IP
option addresses list changed to the TCP server endpoint's IP.
With the patched kernel, ICMP port unreachable packets look correct.
The LSRR addresses list used for the backward path is unchanged and
looks correct in both cases (replies are correctly received from the
sender).

Please allow me to articulate a bit more longer.

In the above context 'start' is:

     unsigned char *start = sptr+sopt->srr; // ip_options.c line 156

and sptr is:

     sptr = skb_network_header(skb); // ip_options.c line 94

The patche code is effectively updating the ingress packet source
routing option list. Specifically it's overwriting the last item
('doffset') with the preferred local address used to reach ip_hdr-
>saddr - that is, with the source host address for the backward path.

Updating the last item of the return/echoed source route option list
looks doubtful: at this stage such item should contain the last hop to
be used to reach ip_hdr->saddr on the backward path. The destination
address will be added to LSRR list later by ip_options_build().

According to RFC 1812, section 4.2.2.1:

"The option as received (the recorded route) MUST be passed up to the
transport layer (or to ICMP message processing)."

The ingress packet source route list must not be modified.

"A router MUST provide a means whereby transport protocols and
applications can reverse the source route in a received datagram.  This
reversed source route MUST be inserted into datagrams they originate
(see [INTRO:2] for details) when the router is unaware of policy
constraints"

The return/echoed source route list must be the reverse of the ingress
one, plus:

"When a source route option is created (which would happen when
the router is originating a source routed datagram or is
inserting a source route option as a result of a special
filter), it MUST be correctly formed even if it is being
created by reversing a recorded route that erroneously includes
the source host"

AFACS this is exactly what the code is currently doing in lines 166-
174 of ip_options.c. We must not include the source host address in the
source route address list, as replacing 'start' with 'dptr' would do.

According to all the above I think we should just drop the lines
reported in the patch, am I missing something?

Thanks!

Paolo
