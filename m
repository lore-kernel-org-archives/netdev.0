From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: introduce dev_consume_skb_any()
Date: Thu, 05 Dec 2013 08:38:05 -0800
Message-ID: <1386261485.30495.203.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com>
	 <20131203.165034.1085515763685633822.davem@davemloft.net>
	 <1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com>
	 <1386115199.30495.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1386247508.30495.180.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131205141346.GB14095@order.stressinduktion.org>
	 <1386254734.30495.186.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1386255952.30495.192.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131205154438.GA21745@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:43586 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756857Ab3LEQiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 11:38:07 -0500
Received: by mail-pb0-f44.google.com with SMTP id rq2so26210502pbb.31
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 08:38:06 -0800 (PST)
In-Reply-To: <20131205154438.GA21745@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-05 at 16:44 +0100, Hannes Frederic Sowa wrote:

> It makes some sense but I did not grasp the whole ->users dependency
> picture, yet. I guess the barrier is only needed when refcount drops
> down to 0 and we don't necessarily need one when incrementing ->users.

If you are the only user of this skb, really no smp barrier is needed at
all.

The problem comes when another cpu is working on the skb, and finally
releases its reference on it.

Before releasing its reference, it must commit all changes it might have
done onto skb. Otherwise another cpu might read stale data.

The smp_wmb() is done by the atomic_dec_and_test(), as it contains a
full barrier.

So the smp_rmb() pairs with the barrier done in atomic_dec_and_test()
