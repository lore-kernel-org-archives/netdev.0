From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV4] ROUTE: ip_rt_dump() is unecessary slow
Date: Wed, 09 Jan 2008 17:02:28 +1100
Message-ID: <E1JCU1E-00076z-00@gondolin.me.apana.org.au>
References: <47831A37.5000607@cosmosbay.com>
Cc: davem@davemloft.net, dipankar@in.ibm.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com (Eric Dumazet)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2534 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751943AbYAIGDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 01:03:04 -0500
In-Reply-To: <47831A37.5000607@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <dada1@cosmosbay.com> wrote:
> 
> Very good question, but honestly I really dont see why it was there at the 
> first place :

It was there because someone went through this file and robotically
replaced all conditional read barriers with rcu_dereference, even when
it made zero sense.

Basically you can add a conditional barrier either at the point where
the pointer gets read, or where it gets derferenced.  Previously we
did the latter (except that the show function didn't have a barrier
at all which is technically a bug though harmless in pratice).  This
patch moves it to the spot where it gets read which is also OK.

> static struct rtable *rt_cache_get_next(struct seq_file *seq, struct rtable *r)
> {
> -       struct rt_cache_iter_state *st = rcu_dereference(seq->private);
> +       struct rt_cache_iter_state *st = seq->private;
> 
> -       r = r->u.dst.rt_next;
> +       r = rcu_dereference(r->u.dst.rt_next);
>        while (!r) {
>                rcu_read_unlock_bh();
>                if (--st->bucket < 0)
>                        break;
>                rcu_read_lock_bh();
> -               r = rt_hash_table[st->bucket].chain;
> +               r = rcu_dereference(rt_hash_table[st->bucket].chain);
>        }
>        return r;

Slight optimisation: please move both barriers onto the return statement,
i.e.,

	return rcu_dereference(r);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
