From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: fix problem in dequeuing from input_pkt_queue
Date: Wed, 19 May 2010 19:48:33 -0700
Message-ID: <AANLkTimv8YJD61uADUrHoeL4xGfE8wPPUwVpwJNZPFpu@mail.gmail.com>
References: <alpine.DEB.1.00.1005191440440.23271@pokey.mtv.corp.google.com>
	 <AANLkTinvSgc3MTAJZEmhBqmRpYlHdOZ6HQ_j43_m8XX1@mail.gmail.com>
	 <AANLkTilxZdJifPtBANrDNdYWxiAMLY6AwA0KYm1yWjle@mail.gmail.com>
	 <AANLkTinZHzZykWYWu9vOmK5ydtcB6ToVBKG1RKYSuSn4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:5301 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634Ab0ETCsh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 22:48:37 -0400
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id o4K2mZBF023765
	for <netdev@vger.kernel.org>; Wed, 19 May 2010 19:48:35 -0700
Received: from pxi12 (pxi12.prod.google.com [10.243.27.12])
	by hpaq7.eem.corp.google.com with ESMTP id o4K2mXR3028668
	for <netdev@vger.kernel.org>; Wed, 19 May 2010 19:48:34 -0700
Received: by pxi12 with SMTP id 12so8213230pxi.0
        for <netdev@vger.kernel.org>; Wed, 19 May 2010 19:48:33 -0700 (PDT)
In-Reply-To: <AANLkTinZHzZykWYWu9vOmK5ydtcB6ToVBKG1RKYSuSn4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> It should be okay? =C2=A0process_backlog only runs in softirq so bot=
tom
>> halves are already disabled, and I don't think flush_backlog runs ou=
t
>> of an interrupt.
>>
>
> Oh no. It is an IRQ handler.
>
Very well, I will fix that.

Now I'm wondering, though, what the purpose of flush_backlog is...
since __netif_receive_skb is called with interrupts enabled it's
obvious flush_backlog won't catch all the skb's that reference the
device go away.  Is there a reason these packets need to be flushed
and can't just be processed?

> =C2=A0on_each_cpu(flush_backlog, dev, 1);
> ...
> int on_each_cpu(void (*func) (void *info), void *info, int wait)
> {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int ret =3D 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0preempt_disable();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D smp_call_function(func, info, wait=
);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0local_irq_disable();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0func(info);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0local_irq_enable();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0preempt_enable();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> }
>
> --
> Regards=EF=BC=8C
> Changli Gao(xiaosuo@gmail.com)
>
