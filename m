From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tuntap: introduce tx skb ring
Date: Sun, 15 May 2016 20:56:38 -0700
Message-ID: <1463370998.18194.74.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463361421-4397-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32934 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895AbcEPD4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 23:56:42 -0400
In-Reply-To: <1463361421-4397-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-05-16 at 09:17 +0800, Jason Wang wrote:
> We used to queue tx packets in sk_receive_queue, this is less
> efficient since it requires spinlocks to synchronize between producer
> and consumer.

...

>  	struct tun_struct *detached;
> +	/* reader lock */
> +	spinlock_t rlock;
> +	unsigned long tail;
> +	struct tun_desc tx_descs[TUN_RING_SIZE];
> +	/* writer lock */
> +	spinlock_t wlock;
> +	unsigned long head;
>  };
>  

Ok, we had these kind of ideas floating around for many other cases,
like qdisc, UDP or af_packet sockets...

I believe we should have a common set of helpers, not hidden in
drivers/net/tun.c but in net/core/skb_ring.c or something, with more
flexibility (like the number of slots)


BTW, why are you using spin_lock_irqsave() in tun_net_xmit() and
tun_peek() ?

BH should be disabled already (in tun_next_xmit()), and we can not
transmit from hard irq.

Thanks.
