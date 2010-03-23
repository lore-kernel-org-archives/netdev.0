From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Fix locking in flush_backlog
Date: Tue, 23 Mar 2010 17:14:04 +0100
Message-ID: <1269360844.2983.294.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1003222257470.3718@pokey.mtv.corp.google.com>
	 <1269325757.3043.11.camel@edumazet-laptop>
	 <65634d661003230856v3d1737dehf64a883c1e785333@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f184.google.com ([209.85.216.184]:37898 "EHLO
	mail-px0-f184.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754555Ab0CWQOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 12:14:09 -0400
Received: by pxi14 with SMTP id 14so4137339pxi.15
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 09:14:09 -0700 (PDT)
In-Reply-To: <65634d661003230856v3d1737dehf64a883c1e785333@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 mars 2010 =C3=A0 08:56 -0700, Tom Herbert a =C3=A9crit :

> Eric,
>=20
> I'm not sure what you're asking.  Do you just want to add spinlocks i=
n
> the flush_backlog function without changing the mechanism to call the
> function on each CPU, or keep flush_backlog but call it from
> netdev_run_todo for each queue?
>=20

keep flush_backlog() so that its role is obvious and indentation level
not too big.

static void flush_backlog(int cpu)
{
	struct softnet_data *queue =3D &per_cpu(softnet_data, cpu);
	struct sk_buff *skb, *tmp;
	unsigned long flags;

	spin_lock_irqsave(&queue->input_pkt_queue.lock, flags);
	skb_queue_walk_safe(&queue->input_pkt_queue, skb, tmp)
		if (skb->dev =3D=3D dev) {
			__skb_unlink(skb, &queue->input_pkt_queue);
			kfree_skb(skb);
		}
	spin_unlock_irqrestore(&queue->input_pkt_queue.lock, flags);
}

And call it from netdev_run_todo() :

for_each_online_cpu(i)
	flush_backlog(i);

This adds two lines to netdev_run_todo() only.

Thanks


