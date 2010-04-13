From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v2] net: batch skb dequeueing from softnet input_pkt_queue
Date: Tue, 13 Apr 2010 20:53:42 +0800
Message-ID: <n2t412e6f7f1004130553x85452fc0u22e512cad412abd3@mail.gmail.com>
References: <1271173102-2980-1-git-send-email-xiaosuo@gmail.com>
	<1271146112.16881.213.camel@edumazet-laptop> <o2v412e6f7f1004130250rdbe17c5dr5c11c3cbbb2f6dbb@mail.gmail.com>
	<1271153942.16881.233.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:42611 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963Ab0DMMyE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 08:54:04 -0400
Received: by iwn35 with SMTP id 35so1841835iwn.21
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 05:54:02 -0700 (PDT)
In-Reply-To: <1271153942.16881.233.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 13, 2010 at 6:19 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 13 avril 2010 =C3=A0 17:50 +0800, Changli Gao a =C3=A9crit :
>> On Tue, Apr 13, 2010 at 4:08 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0Probably not necessary.
>> >
>> >> + =C2=A0 =C2=A0 volatile bool =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
flush_processing_queue;
>> >
>> > Use of 'volatile' is strongly discouraged, I would say, forbidden.
>> >
>>
>> volatile is used to avoid compiler optimization.
>
> volatile might be used on special macros only, not to guard a variabl=
e.
> volatile was pre SMP days. We need something better defined these day=
s.
>

flush_processing_queue is only accessed on the same CPU, so no
volatile is needed. I'll remove it in the next version.

>> >> @@ -2803,6 +2808,7 @@ static void flush_backlog(void *arg)
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 __skb_unlink(skb, &queue->input_pkt_queue);
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 kfree_skb(skb);
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> >> + =C2=A0 =C2=A0 queue->flush_processing_queue =3D true;
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0Probably not necessary
>> >
>>
>> If flush_backlog() is called when there are still packets in
>> processing_queue, there maybe some packets refer to the netdev gone,
>> if we remove this line.
>
> We dont need this "processing_queue". Once you remove it, there is no
> extra work to perform.

OK. If we make processing_queue is a stack variable. When quota or
jiffies limit is reached, we have to splice processing_queue back to
input_pkt_queue. If flush_backlog() is called before the
processing_queue is spliced, there will still packets which refer to
the NIC going. Then these packets are queued to input_pkt_queue. When
process_backlog() is called again, the dev field of these skbs are
wild...

Oh, my GOD. When RPS is enabled, if flush_backlog(eth0) is called on
CPU1 when a skb0(eth0) is dequeued from CPU0's softnet and isn't
queued to CPU1's softnet, what will happen?

>
>> >
>> >>
>> >
>> > I advise to keep it simple.
>> >
>> > My suggestion would be to limit this patch only to process_backlog=
().
>> >
>> > Really if you touch other areas, there is too much risk.
>> >
>> > Perform sort of skb_queue_splice_tail_init() into a local (stack) =
queue,
>> > but the trick is to not touch input_pkt_queue.qlen, so that we don=
t slow
>> > down enqueue_to_backlog().
>> >
>> > Process at most 'quota' skbs (or jiffies limit).
>> >
>> > relock queue.
>> > input_pkt_queue.qlen -=3D number_of_handled_skbs;
>> >
>>
>> Oh no, in order to let latter packets in as soon as possible, we hav=
e
>> to update qlen immediately.
>>
>
> Absolutely not. You missed something apparently.
>
> You pay the price at each packet enqueue, because you have to compute
> the sum of two lengthes, and guess what, if you do this you have a ca=
che
> line miss in one of the operand. Your patch as is is suboptimal.
>
> Remember : this batch mode should not change packet queueing at all,
> only speed it because of less cache line misses.
>

WoW, is it really so expensive?

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
