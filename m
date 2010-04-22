From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] rps: immediate send IPI in
 process_backlog()
Date: Thu, 22 Apr 2010 09:28:23 +0200
Message-ID: <1271921303.7895.4778.camel@edumazet-laptop>
References: <1271883898.7895.3379.camel@edumazet-laptop>
	 <20100422.002118.107274505.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, xiaosuo@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:61633 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782Ab0DVH2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 03:28:33 -0400
Received: by bwz25 with SMTP id 25so9178460bwz.28
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 00:28:32 -0700 (PDT)
In-Reply-To: <20100422.002118.107274505.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 avril 2010 =C3=A0 00:21 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 21 Apr 2010 23:04:58 +0200
>=20
> > If some skb are queued to our backlog, we are delaying IPI sending =
at
> > the end of net_rx_action(), increasing latencies. This defeats the
> > queueing, since we want to quickly dispatch packets to the pool of
> > worker cpus, then eventually deeply process our packets.
> >=20
> > It's better to send IPI before processing our packets in upper laye=
rs,
> > from process_backlog().
> >=20
> > Change the _and_disable_irq suffix to _and_enable_irq(), since we e=
nable
> > local irq in net_rps_action(), sorry for the confusion.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Eric, irqs are enabled in process_backlog(), so I don't know how lega=
l
> it is to invoke net_rps_action_and_irq_enable() from there.
>=20
> At least, if you are depending upon a later action to pick up the
> pieces if the rps_ipi_list test races, you need to update the comment
> above net_rps_action_and_irq_enable() since it states that it is
> always invoked with IRQs disabled :-)
> --

But I do disable irqs berfore calling this function from
process_backlog, only if current pointer is non null.

Pointer is then re-fetched inside net_rps_action_and_irq_enable()

I thought using xchg(), but this adds an atomic op, so I think its
better to use local_irq_disable()/enable() pairs.


About the comment, it says :

/*
 * net_rps_action sends any pending IPI's for rps.
 * Note: called with local irq disabled, but exits with local irq
enabled.
 */


So it documents this function is called with irq disabled, and re-enabl=
e
them before return ?


