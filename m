From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 2/2] bonding: use l4 hash if available
Date: Tue, 15 Sep 2015 17:15:34 -0700
Message-ID: <CALx6S37WgoNp-mgSHFmDc0dW1ozKt-5kNV4+j4oPekebVz8JVQ@mail.gmail.com>
References: <1442355868.4116.14.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S36gs8qC5UXjowoDShZif=81BMJQjUyR_mn4JTaH6xE43w@mail.gmail.com>
	<1442361832.4116.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:36095 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbbIPAPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 20:15:34 -0400
Received: by ioii196 with SMTP id i196so215909279ioi.3
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 17:15:34 -0700 (PDT)
In-Reply-To: <1442361832.4116.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 15, 2015 at 5:03 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-09-15 at 16:45 -0700, Tom Herbert wrote:
>> > +       if (bond->params.xmit_policy == BOND_XMIT_POLICY_ENCAP34 &&
>> > +           skb->l4_hash)
>> > +                       return skb->hash;
>> > +
>> >         if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER2 ||
>> >             !bond_flow_dissect(bond, skb, &flow))
>> >                 return bond_eth_hash(skb);
>> >
>> >
>> Ugh, bond_flow_dissect is yet another instance of customized flow
>> dissection! We should really clean this up. I suggest that in cases
>> were we want L4 hash a call to skb_get_hash should suffice. We can
>> create skb_get_l3hash when caller explicitly wants an L3 hash-- this
>> would return skb->hash if it's valid and skb->l4_hash is not set, else
>> call flow dissector with FLOW_DISSECTOR_F_STOP_AT_L3 and then do the
>> normal hash over flow keys (don't save result in skb->hash in this
>> case).
>
> This code predates all the change you did recently ;)
>
A more fundamental question is whether we can eliminate some of these
hashing types (I see five of them in if_bonding.h). Is there any
substantial difference between this and IPv4/v6 ECMP routing such that
they shouldn't all have the same path selection modes?

Tom

> BTW, the simple xor weakness is showing up after
> our change favoring even ports at connect() time, for a bonding device
> with 2 or 4 slaves.
>
> (commit 07f4c90062f8fc7c8c26f8f95324cbe8fa3145a5
> "tcp/dccp: try to not exhaust ip_local_port_range in connect()")
>
>
>
>
