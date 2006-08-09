From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2]: [IPV4] route: Locking infrastructure for dynamic routing cache sizing.
Date: Wed, 09 Aug 2006 21:31:45 +1000
Message-ID: <E1GAmHp-0006RS-00@gondolin.me.apana.org.au>
References: <20060809.005310.108740577.davem@davemloft.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47122 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030457AbWHILbw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 07:31:52 -0400
To: davem@davemloft.net (David Miller)
In-Reply-To: <20060809.005310.108740577.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
>
> +static struct rt_hash_bucket *rt_get_bucket(u32 daddr, u32 saddr, unsigned int *hp)
> +{
> +       struct rt_hash_bucket *r;
> +       unsigned long seq;
> +
> +       do {
> +               unsigned int hash;
> +
> +               seq = read_seqbegin(&rt_hash_seq);
> +               *hp = hash = __rt_hash_code(daddr, saddr, __rt_hash_mask);
> +               r = &__rt_hash_table[hash];
> +       } while (read_seqretry(&rt_hash_seq, seq));

If we hit a writer just as they begin resizing, we could be here for
quite a while.

In fact because we expect each writer to stick around for a relatively
long time, we could use a new seqlock primitive that just spun until
the LSB becomes zero again.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
