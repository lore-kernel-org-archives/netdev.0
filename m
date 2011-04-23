From: Tom Herbert <therbert@google.com>
Subject: Re: RPS will assign different smp_processor_id for the same packet?
Date: Sat, 23 Apr 2011 12:56:44 -0700
Message-ID: <BANLkTimqkq+2X3=RZ1Qb0e5NpO-yRxuCoQ@mail.gmail.com>
References: <BANLkTimvuGKYuiV_ngTo4wtqhNix4iMfmA@mail.gmail.com>
	<1303402094.3685.54.camel@edumazet-laptop>
	<1303403112.3685.61.camel@edumazet-laptop>
	<BANLkTi=gTNwKX1Tb3mqgWJekRf7n_MHpJQ@mail.gmail.com>
	<BANLkTikY6CAZNkcnU-i7UvPpmSfQuXKtNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: zhou rui <zhourui.cn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:29311 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755343Ab1DWT5A convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2011 15:57:00 -0400
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p3NJuxgp018473
	for <netdev@vger.kernel.org>; Sat, 23 Apr 2011 12:56:59 -0700
Received: from pvg7 (pvg7.prod.google.com [10.241.210.135])
	by wpaz21.hot.corp.google.com with ESMTP id p3NJuvaO015728
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sat, 23 Apr 2011 12:56:58 -0700
Received: by pvg7 with SMTP id 7so1161442pvg.37
        for <netdev@vger.kernel.org>; Sat, 23 Apr 2011 12:56:57 -0700 (PDT)
In-Reply-To: <BANLkTikY6CAZNkcnU-i7UvPpmSfQuXKtNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 23, 2011 at 8:31 AM, zhou rui <zhourui.cn@gmail.com> wrote:
> one more question is:
>
> in the function "int netif_receive_skb(struct sk_buff *skb)"
>
> cpu =3D get_rps_cpu(skb->dev, skb, &rflow);
> if (cpu >=3D 0) {
> =A0ret =3D enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
> ....
>
> probably the cpu is different from the current processor id?(smp_proc=
essor_id)
> let's say: get_rps_cpu->cpu 0, smp_processor_id->cpu1
> when this happen, does it mean that cpu1 is handling the softirq but
> have to divert the packet to cpu0?(via a new softirq?)
>
> so for one packet it involve 2 softirqs?
>
> possible to get_rps_cpu in interrupt,then let the target cpu do only
> one softirq to hanle the packet?
>
Yes, this is what a non-NAPI driver would do.

Tom


> thanks
>
> On Fri, Apr 22, 2011 at 12:29 AM, zhou rui <zhourui.cn@gmail.com> wro=
te:
>> On Friday, April 22, 2011, Eric Dumazet <eric.dumazet@gmail.com> wro=
te:
>>> Le jeudi 21 avril 2011 =E0 18:08 +0200, Eric Dumazet a =E9crit :
>>>> Le jeudi 21 avril 2011 =E0 23:50 +0800, zhou rui a =E9crit :
>>>> > kernel 2.6.36.4
>>>> > CONFIG_RPS=3Dy but not set the cpu mask
>>>> >
>>>> > /sys/class/net/eth1/queues/rx-0 # cat rps_cpus
>>>> > 00
>>>> >
>>>> > register a hook func:
>>>> > =A0 prot_hook.func =3D packet_rcv;
>>>> > =A0 prot_hook.type =3D htons(ETH_P_ALL);
>>>> > =A0 dev_add_pack(&prot_hook);
>>>> >
>>>> >
>>>> > replay the same traffic in very slow speed, printk the
>>>> > smp_processor_id in packet_rcv():
>>>> > first time:
>>>> > cpu=3D4
>>>> > cpu=3D3
>>>> > cpu=3D6
>>>> > cpu=3D7
>>>> >
>>>> > second time:
>>>> > cpu=3D7
>>>> > cpu=3D1
>>>> > cpu=3D5
>>>> > cpu=3D2
>>>> >
>>>> > is it normal?
>>>>
>>>> Yes it is.
>>>>
>>>> What would you expect ?
>>>>
>>>
>>> If rps_cpus contains only '0' bits, it basically means RPS is not a=
ctive
>>> for this input queue.
>>>
>>> CPU is therefore not changed : The cpu handling NAPI on your networ=
k
>>> device directly calls upper linux stack.
>>>
>>> Seeing your traces, it also means your device spreads its interrupt=
s on
>>> many different cpus, this might be not optimal.
>>>
>>> Check /proc/irq/{irq_number}/smp_affinity, it probably contains "ff=
"
>>>
>>>
>>>
>>>
>> Thanks,just saw this email
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
