From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 0/3] net: Byte queue limit patch series
Date: Sun, 1 May 2011 19:41:34 -0700
Message-ID: <BANLkTinFmfJbYxvZ+6rrAy+6XsfwF5an5Q@mail.gmail.com>
References: <alpine.DEB.2.00.1104252128001.5889@pokey.mtv.corp.google.com>
	<20110429.115443.28811990.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:6064 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754384Ab1EBClj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2011 22:41:39 -0400
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p422faEV010876
	for <netdev@vger.kernel.org>; Sun, 1 May 2011 19:41:37 -0700
Received: from pzk9 (pzk9.prod.google.com [10.243.19.137])
	by kpbe14.cbf.corp.google.com with ESMTP id p422fYQQ017409
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 1 May 2011 19:41:35 -0700
Received: by pzk9 with SMTP id 9so4065197pzk.33
        for <netdev@vger.kernel.org>; Sun, 01 May 2011 19:41:34 -0700 (PDT)
In-Reply-To: <20110429.115443.28811990.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 29, 2011 at 11:54 AM, David Miller <davem@davemloft.net> wr=
ote:
> From: Tom Herbert <therbert@google.com>
> Date: Mon, 25 Apr 2011 21:38:06 -0700 (PDT)
>
>> This patch series implements byte queue limits (bql) for NIC TX queu=
es.
>
> I like the idea, I don't like how much drivers have to be involved
> in this.
>
> TX queue handling is already too involved for driver writers, so
> having them need to get all of these new hooks right is a non-starter=
=2E
>
> I don't even think it's necessary to be honest, I think you can hide
> to bulk of it.
>
> alloc_etherdev_mq() can initialize the per-txq bql instances.
>
> Add new interface, netdev_free_tx_skb(txq, skb) which can do the
> completion accounting. =A0Actually the 'txq' argument is probably
> superfluous as it can be obtained from the skb itself.
>
Okay, but I think the call at the end of TX completion processing is
still probably needed.  The algorithm is trying to determine the
number of bytes that completed at each interrupt.

> dev_hard_start_xmit() can do the "sent" processing.
>
> Then the only thing you're doing is replacing dev_kfree_skb*()
> in the TX path of the driver with the new netdev_free_tx_skb()
> thing.
>
> Maybe you can add a "netdev_tx_queue_reset()" hook for asynchronous
> device resets. =A0Otherwise the bql reset can occur in generic code
> right at ->ndo_open().
>
Reset probably isn't necessary anyway if all the skb's are properly
completed with netdev_free_tx_skb.

> Finally, you manage the bql limit logic in the existing generic netde=
v
> TX start/stop interfaces. =A0If the user asks for "start" but the bql
> is overlimit, simply ignore the request. =A0The driver will just sign=
al
> another "start" when the next TX packet completes.
>
> Similarly, when the qdisc is queuing up a packet to
> dev_hard_start_xmit() you can, for example, preemptively do a "stop"
> on the queue if you find bql is overlimit.
>
Unfortunately, there is still an additional complexity if we don't
piggy back on the logic in the driver to stop the queue.  I believe
that either this would require another queue state for queue being
stopped for bql which looks pretty cumbersome, so that wrapping this
in a qdisc might be a better possibility.

Tom

> Thanks Tom.
>
>
