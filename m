From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 3/6] flow_dissector: Add hash_extra field to
 flow_keys struct
Date: Sun, 1 Mar 2015 11:17:25 -0800
Message-ID: <CA+mtBx_9SKncJ1hfKj9icJP8bFbSKrHijeJoFOm7dU5MdwejRg@mail.gmail.com>
References: <1425093109-1077-1-git-send-email-therbert@google.com>
	<1425093109-1077-4-git-send-email-therbert@google.com>
	<1425109054.5130.77.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150228203119.GA7687@breakpoint.cc>
	<CA+mtBx8zP0rDG1Dh=KcG0t5dqaqnqS+8---4SBvLD_jGpgue2g@mail.gmail.com>
	<20150301182425.GA23622@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:36429 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbbCATR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 14:17:26 -0500
Received: by igkb16 with SMTP id b16so12226350igk.1
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2015 11:17:25 -0800 (PST)
In-Reply-To: <20150301182425.GA23622@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 1, 2015 at 10:24 AM, Florian Westphal <fw@strlen.de> wrote:
> Tom Herbert <therbert@google.com> wrote:
>> On Sat, Feb 28, 2015 at 12:31 PM, Florian Westphal <fw@strlen.de> wrote:
>> > I've been toying around with reducing skb->cb[] to 44 bytes,
>> > Seems Tom could integrate following patch from my test branch:
>> >
>> > http://git.breakpoint.cc/cgit/fw/net-next.git/commit/?h=skb_cb_44_01&id=29d711e1a71244b71940c2d1e346500bef4d6670
>> >
>> > It makes sfq use a smaller flow key state.
>>
>> Alternatively, I think we might be able to eliminate the use of
>> flow_keys and flow_dissect from the qdisc code altogether. It looks
>> like this is only being used to determine a hash over the addresses,
>> ports, and protocol so I am thinking that we can just call
>> skb_get_hash for that. Will try to post some patches soon.
>
> The problem with this is that you'll lose the secret input to jhash
> in sfq_hash().
>
> assuming you have packets p1 and p2 (from different flows)
> with skb_get_hash(p1) == skb_get_hash(p2) those flows share same
> queue/bin forever as the hash pertubation will no longer work.
>
We still need hash perturbation for the mapping to a small number of
queues which can be done after retrieving skb_get_hash, but the
probability that two different flows match perfectly in skb_get_hash()
should be 1/2^32-- so are hash collisions really a concern here? Note
that we already lose information in the IPv6 address fold in
flow_dissect and don't include VLAN or VNID yet in the flow_keys yet,
so these probably already make a greater probability in a tuple
collision for sfc hash.

> For sfq, hash collisions may exist as well but they'll be resolved
> after some time when q->perturbation (its part of hash input) is reseeded.
