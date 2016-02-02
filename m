From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net] net: Allow flow dissector to handle non 4-byte
 aligned headers
Date: Tue, 2 Feb 2016 13:35:09 -0500
Message-ID: <20160202183509.GA26588@oracle.com>
References: <1454276221-3543907-1-git-send-email-tom@herbertland.com>
 <20160202003127.GA25154@oracle.com>
 <CAKgT0UfjLEBUeiV3WS2BC=yRkxi9JBF4mqJ=niXOUQnhkiMhvA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18625 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754796AbcBBSf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 13:35:26 -0500
Content-Disposition: inline
In-Reply-To: <CAKgT0UfjLEBUeiV3WS2BC=yRkxi9JBF4mqJ=niXOUQnhkiMhvA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (02/01/16 19:56), Alexander Duyck wrote:
> > @@ -394,7 +407,7 @@ ip_proto_again:
> >                                                    data, hlen, &_eth);
> >                         if (!eth)
> >                                 goto out_bad;
> > -                       proto = eth->h_proto;
> > +                       proto = get_unaligned_be16(&eth->h_proto);
> >                         nhoff += sizeof(*eth);
> >                 }
> 
> This piece doesn't make any sense to me.  It is already only 2 bytes
> wide.  I'm not sure why we should be seeing this trigger an unaligned
> access.  Are you sure it wasn't something like the keyid causing the
> issue?  I'd be interested in seeing what the compiler did here that it
> is triggering the problem.

You're right- I was getting blinded by all the unaligned-access
messages swimming by and making a mistake. It was actually the 

                memcpy(&key_addrs->v4addrs, &iph->saddr,
                       sizeof(key_addrs->v4addrs));

The assembler code is this:

   0x8d3298 <__skb_flow_dissect+500>:   ld  [ %l5 + 0xc ], %g3
   0x8d329c <__skb_flow_dissect+504>:   add  %i2, %g1, %g2
   0x8d32a0 <__skb_flow_dissect+508>:   st  %g3, [ %i2 + %g1 ]
   0x8d32a4 <__skb_flow_dissect+512>:   ld  [ %l5 + 0x10 ], %g1
   0x8d32a8 <__skb_flow_dissect+516>:   st  %g1, [ %g2 + 4 ]
   0x8d32ac <__skb_flow_dissect+520>:   mov  2, %g1

I get unaligned access traps at __skb_flow_dissect+500 and
__skb_flow_dissect+512 (corresponding to saddr and daddr), once for
each interface (gretap/eth0 and eth1). 

--Sowmini
