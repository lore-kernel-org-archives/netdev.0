From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: fix problem in dequeuing from input_pkt_queue
Date: Thu, 20 May 2010 08:09:50 +0800
Message-ID: <AANLkTinZHzZykWYWu9vOmK5ydtcB6ToVBKG1RKYSuSn4@mail.gmail.com>
References: <alpine.DEB.1.00.1005191440440.23271@pokey.mtv.corp.google.com>
	<AANLkTinvSgc3MTAJZEmhBqmRpYlHdOZ6HQ_j43_m8XX1@mail.gmail.com>
	<AANLkTilxZdJifPtBANrDNdYWxiAMLY6AwA0KYm1yWjle@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:42572 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752912Ab0ETAKP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 20:10:15 -0400
Received: by pxi18 with SMTP id 18so1030846pxi.19
        for <netdev@vger.kernel.org>; Wed, 19 May 2010 17:10:14 -0700 (PDT)
In-Reply-To: <AANLkTilxZdJifPtBANrDNdYWxiAMLY6AwA0KYm1yWjle@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 20, 2010 at 7:58 AM, Tom Herbert <therbert@google.com> wrot=
e:
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0napi->weight =3D weight_p;
>>> - =C2=A0 =C2=A0 =C2=A0 local_irq_disable();
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0while (work < quota) {
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct sk_bu=
ff *skb;
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int=
 qlen;
>>>
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0while ((skb =
=3D __skb_dequeue(&sd->process_queue))) {
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 local_irq_enable();
>>
>> we need to keep local irq disabled. If not, flush_backlog may be
>> called, and it will access sd->process_queue.
>>
>
> It should be okay? =C2=A0process_backlog only runs in softirq so bott=
om
> halves are already disabled, and I don't think flush_backlog runs out
> of an interrupt.
>

Oh no. It is an IRQ handler.

  on_each_cpu(flush_backlog, dev, 1);
=2E..
int on_each_cpu(void (*func) (void *info), void *info, int wait)
{
        int ret =3D 0;

        preempt_disable();
        ret =3D smp_call_function(func, info, wait);
        local_irq_disable();
        func(info);
        local_irq_enable();
        preempt_enable();
        return ret;
}

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
