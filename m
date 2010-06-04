From: Sonic Zhang <sonic.adi@gmail.com>
Subject: Re: [PATCH v2] netdev:bfin_mac: reclaim and free tx skb as soon as
	possible after transfer
Date: Fri, 4 Jun 2010 12:44:02 +0800
Message-ID: <AANLkTimO47rtvIwYAwpaMYtK5SEnhM0m3AxL5q-8lvA7@mail.gmail.com>
References: <1275536881.18536.5.camel@eight.analog.com>
	<AANLkTik4aWREeblhnbI3DU7a_CE11Rx0GvXi56O2yHzy@mail.gmail.com>
	<1275624354.2533.121.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	uclinux-dist-devel <uclinux-dist-devel@blackfin.uclinux.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:48643 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999Ab0FDEoF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 00:44:05 -0400
Received: by pvg16 with SMTP id 16so401145pvg.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 21:44:02 -0700 (PDT)
In-Reply-To: <1275624354.2533.121.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 4, 2010 at 12:05 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 04 juin 2010 =E0 11:29 +0800, Sonic Zhang a =E9crit :
>> David,
>>
>> Any comments?
>>
>> Thanks
>>
>> Sonic
>>
>> On Thu, Jun 3, 2010 at 11:48 AM, sonic zhang <sonic.adi@gmail.com> w=
rote:
>> > >From 40560ae9e8db42e2d2259b791ace160534c9a0f2 Mon Sep 17 00:00:00=
 2001
>> > From: Sonic Zhang <sonic.zhang@analog.com>
>> > Date: Thu, 3 Jun 2010 11:44:33 +0800
>> > Subject: [PATCH v2] netdev:bfin_mac: reclaim and free tx skb as so=
on as possible after transfer
>> >
>> > SKBs hold onto resources that can't be held indefinitely, such as =
TCP
>> > socket references and netfilter conntrack state. =A0So if a packet=
 is left
>> > in TX ring for a long time, there might be a TCP socket that canno=
t be
>> > closed and freed up.
>> >
>> > Current blackfin EMAC driver always reclaim and free used tx skbs =
in future
>> > transfers. The problem is that future transfer may not come as soo=
n as
>> > possible. This patch start a timer after transfer to reclaim and f=
ree skb.
>> > There is nearly no performance drop with this patch.
>> >
>> > TX interrupt is not enabled for 2 reasons:
>> >
>> > 1) If Blackfin EMAC TX transfer control is turned on, endless TX
>> > interrupts are triggered no matter if TX DMA is enabled. Since DMA=
 walks
>> > down the ring automatically, TX transfer control can't be turned o=
ff in the
>> > middle. The only way is to disable TX interrupt completely.
>> >
>> > 2) skb can not be freed from interrupt context. A work queue or ta=
sklet
>> > has to be created, which introduce more overhead than timer only s=
olution.
>> >
>
> Could you elaborate on this second point ?
>
> skb can be freed from interrupt context using appropriate API :
>
> 1) If from NAPI context, no special care is needed and use
> dev_kfree_skb().
>
> 2) If from hard irq context, use dev_kfree_skb_irq() :
>

Yes, you are right. dev_kfree_skb_irq() queues used skb to the
complete queue. But, it is actually freed in the other soft irq
NET_TX_SOFTIRQ.


> With recent changes, skb is probably already orphaned and can be free=
d
> immediately.
>
> In the unlikely case it is not yet orphaned, skb is queued in
> softnet_data.completion_queue.
>
>
>
>
