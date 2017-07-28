From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH] IP: do not modify ingress packet IP option in ip_options_echo()
Date: Fri, 28 Jul 2017 16:47:42 -0400
Message-ID: <87a83othjl.fsf@stressinduktion.org>
References: <f5758b6b7199d2d2a218b0ad36f1e5ef108eac43.1500642854.git.pabeni@redhat.com>
        <20170724.141253.769254590231937263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: pabeni@redhat.com, netdev@vger.kernel.org, edumazet@google.com,
        kuznet@ms2.inr.ac.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:35771 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752494AbdG1Urn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 16:47:43 -0400
In-Reply-To: <20170724.141253.769254590231937263.davem@davemloft.net> (David
        Miller's message of "Mon, 24 Jul 2017 14:12:53 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

David Miller <davem@davemloft.net> writes:

> From: Paolo Abeni <pabeni@redhat.com>
> Date: Fri, 21 Jul 2017 15:55:18 +0200
>
>> diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
>> index 93157f2..fdda973 100644
>> --- a/net/ipv4/ip_options.c
>> +++ b/net/ipv4/ip_options.c
>> @@ -174,9 +174,6 @@ int __ip_options_echo(struct ip_options *dopt, struct sk_buff *skb,
>>  				doffset -= 4;
>>  		}
>>  		if (doffset > 3) {
>> -			__be32 daddr = fib_compute_spec_dst(skb);
>> -
>> -			memcpy(&start[doffset-1], &daddr, 4);
>>  			dopt->faddr = faddr;
>
> This transformation is required, but in the destination not the source.

We put a lot of effort trying to figure out why this code is needed,
what intend it has and couldn't still figure out why things are how they
are.

Above, I think you are referring to the update in the options header
that directs the packet to the final hosts, such closing the loop and
allowing the packet to reach its final destination.

This update to the header happens in another function, later in the
stack in ip_options_build:

|	if (opt->srr)
|		memcpy(iph+opt->srr+iph[opt->srr+1]-4, &daddr, 4);

Here we correctly copy the destination address into the last option
field.

> The red flag is that we are indexing 'start' with 'doffset' instead of
> 'soffset'.

As Paolo pointed out, we should not put our own source address into the
options array.

Do you have any idea why this code was added in the first place? I read
through 2.0.33 code and even in context of this version, I couldn't
figure that out.

Because it seems the code and update is dead anyways (besides
incorrectly updating the ICMP reflected payload) I don't see any problem
with removing this code. Do you?

Thanks,
Hannes
