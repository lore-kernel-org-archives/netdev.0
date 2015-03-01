From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 3/6] flow_dissector: Add hash_extra field to
 flow_keys struct
Date: Sun, 1 Mar 2015 10:16:51 -0800
Message-ID: <CA+mtBx-WwHFToYY9LP=x=SnP5eQy3cmvEDG5d4NJDO5rY0BPsw@mail.gmail.com>
References: <1425093109-1077-1-git-send-email-therbert@google.com>
	<1425093109-1077-4-git-send-email-therbert@google.com>
	<1425109054.5130.77.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150228203119.GA7687@breakpoint.cc>
	<CAA93jw4+RBeZ48-axVZ73SVhxx-CCwSMLvAyUd_m53OtbhkO5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:42125 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752AbbCASQw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 13:16:52 -0500
Received: by igkb16 with SMTP id b16so11973423igk.1
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2015 10:16:51 -0800 (PST)
In-Reply-To: <CAA93jw4+RBeZ48-axVZ73SVhxx-CCwSMLvAyUd_m53OtbhkO5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 28, 2015 at 12:46 PM, Dave Taht <dave.taht@gmail.com> wrote=
:
> On Sat, Feb 28, 2015 at 12:31 PM, Florian Westphal <fw@strlen.de> wro=
te:
>> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> On Fri, 2015-02-27 at 19:11 -0800, Tom Herbert wrote:
>>>
>>> > diff --git a/include/net/sch_generic.h b/include/net/sch_generic.=
h
>>> > index c605d30..d41a034 100644
>>> > --- a/include/net/sch_generic.h
>>> > +++ b/include/net/sch_generic.h
>>> > @@ -252,7 +252,7 @@ struct qdisc_skb_cb {
>>> >     unsigned int            pkt_len;
>>> >     u16                     slave_dev_queue_mapping;
>>> >     u16                     _pad;
>>> > -#define QDISC_CB_PRIV_LEN 20
>>> > +#define QDISC_CB_PRIV_LEN 24
>>> >     unsigned char           data[QDISC_CB_PRIV_LEN];
>>> >  };
>>> >
>>>
>>> This change breaks kernel build : We already are at the cb[] limit.
>>>
>>> Please check commit 257117862634d89de33fec74858b1a0ba5ab444b
>>> ("net: sched: shrink struct qdisc_skb_cb to 28 bytes")
>>
>> I've been toying around with reducing skb->cb[] to 44 bytes,
>> Seems Tom could integrate following patch from my test branch:
>>
>> http://git.breakpoint.cc/cgit/fw/net-next.git/commit/?h=3Dskb_cb_44_=
01&id=3D29d711e1a71244b71940c2d1e346500bef4d6670
>>
>> It makes sfq use a smaller flow key state.
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> My concern with all this work is that you are possibly not looking at
> the quality of the hash
> as the number of queues goes down, or the effects of adding in all
> this extra stuff
> to the hash is, in cases where they don't exist, or are not very rand=
om.
>
> The default, in fq_codel is 1024 queues, and that worked pretty good
> in monty carlo simulations, but I have always felt it could be better
> after we measured more real traffic - there is not a lot of
> information in the proto field in real traffic, and - although it has
> been improved - the ipv6 hash was kind of weak originally and a littl=
e
> odd now.
>
> As some are attempting to deploy these hashes with 64, 32 and even 8
> queues, I would hope that someone (and I can if I get the time) would
> look closely at avalanche effects down to these last few bits.
>
> http://en.wikipedia.org/wiki/Avalanche_effect
>
We are only increasing the input to the hash function by XOR not
reducing, so it seems unlikely this could result in less entropy. In
worse case extra input would might have no effect. As for the
avalanche effect that is more dependent on the hash function itself.
In the kernel we are using Jenkin's hash for such things, and there's
a nice graphical representation for the avalanche effect in the
wikipedia page:

http://en.wikipedia.org/wiki/Jenkins_hash_function


> --
> Dave T=C3=A4ht
> Let's make wifi fast, less jittery and reliable again!
>
> https://plus.google.com/u/0/107942175615993706558/posts/TVX3o84jjmb
