From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] Software receive packet steering
Date: Thu, 9 Apr 2009 09:43:07 -0700
Message-ID: <65634d660904090943lf273d9cg92be105acef3e6af@mail.gmail.com>
References: <65634d660904081548g7ea3e3bfn858f2336db9a671f@mail.gmail.com>
	 <20090408160948.2257d311@s6510>
	 <20090408.161515.40986410.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:39859 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936384AbZDIQnL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 12:43:11 -0400
Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id n39Gh99V009490
	for <netdev@vger.kernel.org>; Thu, 9 Apr 2009 09:43:10 -0700
Received: from qyk42 (qyk42.prod.google.com [10.241.83.170])
	by zps18.corp.google.com with ESMTP id n39Ggsqx004452
	for <netdev@vger.kernel.org>; Thu, 9 Apr 2009 09:43:08 -0700
Received: by qyk42 with SMTP id 42so1265739qyk.26
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2009 09:43:07 -0700 (PDT)
In-Reply-To: <20090408.161515.40986410.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> -extern int =A0 =A0 =A0 =A0 =A0netif_receive_skb(struct sk_buff *sk=
b);
>>> +extern int =A0 =A0 =A0 =A0 =A0 =A0__netif_receive_skb(struct sk_bu=
ff *skb);
>>> +
>>> +static inline int netif_receive_skb(struct sk_buff *skb)
>>> +{
>>> +#ifdef CONFIG_NET_SOFTRPS
>>> + =A0 =A0return netif_rx(skb);
>>> +#else
>>> + =A0 =A0return __netif_receive_skb(skb);
>>> +#endif
>>> +}
>>
>> Ugh, this forces all devices receiving back into a single backlog
>> queue.
>
> Yes, it basically turns off NAPI.
>

NAPI is still useful, but it does take a higher packet load before
polling kicks in.  I believe this is similarly true for HW multi
queue, and could actually be worse depending on the number of queues
traffic is being split across (in my bnx2x experiment 16 core AMD with
16 queues, I was seeing around 300K interrupts per second, no benefit
from NAPI).

The bimodal behavior between polling and non-polling states does give
us fits.  I looked at the parked mode idea, but the latency hit seems
too high.  We've considered holding the interface in polling state for
longer periods of time, maybe this could trade off CPU cycles (on the
core taking interrupts) for lower latency and higher throughput.
