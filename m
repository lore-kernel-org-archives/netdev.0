From: zhou rui <zhourui.cn@gmail.com>
Subject: Re: RPS will assign different smp_processor_id for the same packet?
Date: Sun, 24 Apr 2011 17:36:51 +0800
Message-ID: <BANLkTintzzpixPi+HDzGUV_agCGr6EX7AQ@mail.gmail.com>
References: <BANLkTimvuGKYuiV_ngTo4wtqhNix4iMfmA@mail.gmail.com>
	<1303402094.3685.54.camel@edumazet-laptop>
	<1303403112.3685.61.camel@edumazet-laptop>
	<BANLkTi=gTNwKX1Tb3mqgWJekRf7n_MHpJQ@mail.gmail.com>
	<BANLkTikY6CAZNkcnU-i7UvPpmSfQuXKtNQ@mail.gmail.com>
	<BANLkTimqkq+2X3=RZ1Qb0e5NpO-yRxuCoQ@mail.gmail.com>
	<BANLkTikyntWG6YPUdVipHvwJ8yGuU_Vi4w@mail.gmail.com>
	<1303632033.2747.51.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:43937 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756303Ab1DXJhD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2011 05:37:03 -0400
Received: by iwn34 with SMTP id 34so1274692iwn.19
        for <netdev@vger.kernel.org>; Sun, 24 Apr 2011 02:37:03 -0700 (PDT)
In-Reply-To: <1303632033.2747.51.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 24, 2011 at 4:00 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le dimanche 24 avril 2011 =E0 10:00 +0800, zhou rui a =E9crit :
>> On Sun, Apr 24, 2011 at 3:56 AM, Tom Herbert <therbert@google.com> w=
rote:
>> > On Sat, Apr 23, 2011 at 8:31 AM, zhou rui <zhourui.cn@gmail.com> w=
rote:
>> >> one more question is:
>> >>
>> >> in the function "int netif_receive_skb(struct sk_buff *skb)"
>> >>
>> >> cpu =3D get_rps_cpu(skb->dev, skb, &rflow);
>> >> if (cpu >=3D 0) {
>> >> =A0ret =3D enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
>> >> ....
>> >>
>> >> probably the cpu is different from the current processor id?(smp_=
processor_id)
>> >> let's say: get_rps_cpu->cpu 0, smp_processor_id->cpu1
>> >> when this happen, does it mean that cpu1 is handling the softirq =
but
>> >> have to divert the packet to cpu0?(via a new softirq?)
>> >>
>> >> so for one packet it involve 2 softirqs?
>> >>
>> >> possible to get_rps_cpu in interrupt,then let the target cpu do o=
nly
>> >> one softirq to hanle the packet?
>> >>
>> > Yes, this is what a non-NAPI driver would do.
>> >
>> > Tom
>> >
>> non-NAPI will get_rps_cpu in irq, but why NAPI will get_rps_cpu in
>> softirq?(if I understand correctly netif_receive_skb executed in
>> softirq?)
>
> Thats hard to understand what your problem or question is.
>
> All heavy Receive networking stuff is handled in softirq.
>
> NAPI allows to reduce number of hardware IRQS in stress/load situatio=
ns,
> fetching several frames at once.
>
>
>
>

my understanding:

non-NAPI scenario:

netif_rx( in irq, get_rps_cpu,enqueue_to_backlog to deliver packet to
cpu queue) ------>net_rx_action(in softirq,deque and process packet)


NAPI:

what does RPS do?(in
irq)------------------------>net_rx_action(softirq)----->netif_receive_=
skb(get_rps_cpu,enque
packet)

so my question is:
for NAPI, get_rps_cpu will be done in softirq?

if the above situation is true,will this happen?
packet_for_cpu_1 --> cpu0(netif_receive_skb,in softirq) --->delivered
to cpu1(softirq)
