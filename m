From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH net-next 3/6] flow_dissector: Add hash_extra field to
 flow_keys struct
Date: Sun, 1 Mar 2015 11:57:35 -0800
Message-ID: <CAA93jw4W4KDTVuHBKZToyNqy8WmSaS6a-FskO-k7McuhYW=VRQ@mail.gmail.com>
References: <1425093109-1077-1-git-send-email-therbert@google.com>
	<1425093109-1077-4-git-send-email-therbert@google.com>
	<1425109054.5130.77.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150228203119.GA7687@breakpoint.cc>
	<CA+mtBx8zP0rDG1Dh=KcG0t5dqaqnqS+8---4SBvLD_jGpgue2g@mail.gmail.com>
	<20150301182425.GA23622@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:39440 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461AbbCAT5g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 14:57:36 -0500
Received: by mail-ob0-f173.google.com with SMTP id uy5so27605427obc.4
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2015 11:57:35 -0800 (PST)
In-Reply-To: <20150301182425.GA23622@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 1, 2015 at 10:24 AM, Florian Westphal <fw@strlen.de> wrote:
> Tom Herbert <therbert@google.com> wrote:
>> On Sat, Feb 28, 2015 at 12:31 PM, Florian Westphal <fw@strlen.de> wr=
ote:
>> > I've been toying around with reducing skb->cb[] to 44 bytes,
>> > Seems Tom could integrate following patch from my test branch:
>> >
>> > http://git.breakpoint.cc/cgit/fw/net-next.git/commit/?h=3Dskb_cb_4=
4_01&id=3D29d711e1a71244b71940c2d1e346500bef4d6670
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

fq_codel relies on a secret input to the hash also, but it is only
created at instantation time. Retaining that secret input is critical
- otherwise an attacker can fairly easily derive the hash and find
ways of flooding the connection at low rates that are almost as
effective as simple attacks against pfifo_fast.

A note on sfq: it is commonly deployed with perturb 10 - which acts as
a "poor man's AQM" scrambling big flows and causing tcp cwnd
reductions - or at least it used to before linux gained much better
resilience in re-ordering. Either behavior - blowing up tcp flows
(then) - or allowing them to overbuffer (now) is pretty undesirable.

I have gone in detail on everything that is wrong with common SFQ
deployments here, commenting extensively on what was once, one of the
most popular shapers in the world:

http://www.bufferbloat.net/projects/cerowrt/wiki/Wondershaper_Must_Die

> assuming you have packets p1 and p2 (from different flows)
> with skb_get_hash(p1) =3D=3D skb_get_hash(p2) those flows share same
> queue/bin forever as the hash pertubation will no longer work.
>
> For sfq, hash collisions may exist as well but they'll be resolved
> after some time when q->perturbation (its part of hash input) is rese=
eded.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
Dave T=C3=A4ht
Let's make wifi fast, less jittery and reliable again!

https://plus.google.com/u/0/107942175615993706558/posts/TVX3o84jjmb
