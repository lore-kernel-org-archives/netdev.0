From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] pkt_sched: Fix gen_estimator locks
Date: Tue, 26 Aug 2008 22:57:38 +1000
Message-ID: <E1KXy78-0000mY-00@gondolin.me.apana.org.au>
References: <20080825230848.GB12082@ami.dom.local>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: jarkao2@gmail.com (Jarek Poplawski)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58232 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755325AbYHZM5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 08:57:43 -0400
In-Reply-To: <20080825230848.GB12082@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski <jarkao2@gmail.com> wrote:
> pkt_sched: Fix gen_estimator locks
> 
> While passing a qdisc root lock to gen_new_estimator() and
> gen_replace_estimator() dev could be deactivated or even before
> grafting proper root qdisc as qdisc_sleeping (e.g. qdisc_create),
> so using qdisc_root_lock() is not enough. This patch adds
> qdisc_root_sleeping_lock() for this, plus additional checks, where
> necessary.
> 
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Looks good.

> @@ -830,9 +830,16 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
>                        sch->stab = stab;
>                }
>                if (tca[TCA_RATE]) {
> +                       spinlock_t *root_lock;
> +
> +                       if ((sch->parent != TC_H_ROOT) &&
> +                           !(sch->flags & TCQ_F_INGRESS))
> +                               root_lock = qdisc_root_sleeping_lock(sch);
> +                       else
> +                               root_lock = qdisc_lock(sch);

Another reason why we should just have pointers to the root.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
