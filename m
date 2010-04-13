From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v2] net: batch skb dequeueing from softnet input_pkt_queue
Date: Tue, 13 Apr 2010 17:50:29 +0800
Message-ID: <o2v412e6f7f1004130250rdbe17c5dr5c11c3cbbb2f6dbb@mail.gmail.com>
References: <1271173102-2980-1-git-send-email-xiaosuo@gmail.com>
	<1271146112.16881.213.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:36229 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059Ab0DMJuu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 05:50:50 -0400
Received: by iwn35 with SMTP id 35so1769513iwn.21
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 02:50:49 -0700 (PDT)
In-Reply-To: <1271146112.16881.213.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 13, 2010 at 4:08 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Probably not necessary.
>
>> + =C2=A0 =C2=A0 volatile bool =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 flu=
sh_processing_queue;
>
> Use of 'volatile' is strongly discouraged, I would say, forbidden.
>

volatile is used to avoid compiler optimization.

> Its usually a sign of 'I dont exactly what memory ordering I need, so=
 I
> throw a volatile just in case'. We live in a world full of RCU, read =
,
> write, full barriers. And these apis are well documented.
>

There isn't memory accessing order problem.

>> @@ -2803,6 +2808,7 @@ static void flush_backlog(void *arg)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 __skb_unlink(skb, &queue->input_pkt_queue);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 kfree_skb(skb);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 queue->flush_processing_queue =3D true;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Probably not necessary
>

If flush_backlog() is called when there are still packets in
processing_queue, there maybe some packets refer to the netdev gone,
if we remove this line.

>> =C2=A0 =C2=A0 =C2=A0 rps_unlock(queue);
>> =C2=A0}
>>
>> @@ -3112,14 +3118,23 @@ static int process_backlog(struct napi_struc=
t *napi, int quota)
>> =C2=A0 =C2=A0 =C2=A0 struct softnet_data *queue =3D &__get_cpu_var(s=
oftnet_data);
>> =C2=A0 =C2=A0 =C2=A0 unsigned long start_time =3D jiffies;
>>
>> + =C2=A0 =C2=A0 if (queue->flush_processing_queue) {
>
> Really... this is bloat IMHO


Any better idea?

>
>>
>
> I advise to keep it simple.
>
> My suggestion would be to limit this patch only to process_backlog().
>
> Really if you touch other areas, there is too much risk.
>
> Perform sort of skb_queue_splice_tail_init() into a local (stack) que=
ue,
> but the trick is to not touch input_pkt_queue.qlen, so that we dont s=
low
> down enqueue_to_backlog().
>
> Process at most 'quota' skbs (or jiffies limit).
>
> relock queue.
> input_pkt_queue.qlen -=3D number_of_handled_skbs;
>

Oh no, in order to let latter packets in as soon as possible, we have
to update qlen immediately.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
