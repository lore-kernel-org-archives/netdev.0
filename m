From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Thu, 12 Nov 2009 17:32:13 +0800
Message-ID: <412e6f7f0911120132j5442a1ffp790277597f563953@mail.gmail.com>
References: <412e6f7f0911111912q27f2b0aate56c637349292c3f@mail.gmail.com>
	 <20091112085250.GA7112@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:42453 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbZKLJcH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 04:32:07 -0500
Received: by pwi3 with SMTP id 3so1240700pwi.21
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 01:32:13 -0800 (PST)
In-Reply-To: <20091112085250.GA7112@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 12, 2009 at 4:52 PM, Jarek Poplawski <jarkao2@gmail.com> wr=
ote:
> On 12-11-2009 04:12, Changli Gao wrote:
>> On Wed, Nov 11, 2009 at 11:59 PM, Patrick McHardy <kaber@trash.net> =
wrote:
> ...
>>> What protects the device from disappearing here and below during
>>> dev_queue_xmit() and netif_rx_ni()?
>>
>> For dev_queue_xmit(), dev is holded by skb->_dst, so there is no
>> problem.

Oh, I'm wrong, and not all the skbs using dev_queue_xmit() has a valid
dst, such as AF_PACKET. As skb->dev doesn't own dev, so I think it is
AF_PACKETs fault. Too bad!

>> But for netif_rx_ni(), I don't know how to prevent the device
>> disappearing, and it seems that all the NIC drivers have this proble=
m.
>> Maybe there was the assumption about the execution context of
>> netif_rx() before. Now softirq can't be executed by softirqd, so the
>> packet receiving path maybe interleaved. I don't know how to prevent
>> it happening.
>
> Btw, maybe I miss something, but ifb with act_mirred is for many user=
s
> on the fast path. I'm not sure you proved enough why moving it to the
> process context and additional multiqueue functionality (which seems
> "pretty cool", but probably mostly for testing purposes) don't harm
> its main use?

Because process is more flexible than other activities, and you can
specify its priority and bind it to some CPU, and so on. If you have a
SMP system, and a NIC which doesn't support MQ. When you use it as a
firewall, you'll find all the work is nearly on a CPU. As throughput
increase, that CPU will be full and no more throughput can gain,
though the other CPUs are still idle. With IFB-MQ, you can distribute
the packets among all the CPUs, and archive good throughput.

I know you worry about the latency. From my experiments, It just OK.
No much explicit latency is added.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
