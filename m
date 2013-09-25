From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] net: introduce support for lazy initialization of
 secret keys
Date: Wed, 25 Sep 2013 15:42:26 -0700
Message-ID: <1380148946.3165.166.camel@edumazet-glaptop>
References: <20130925213403.GF4904@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, edumazet@google.com,
	davem@davemloft.net, ycheng@google.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:52596 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754831Ab3IYWm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 18:42:28 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so289713pdj.18
        for <netdev@vger.kernel.org>; Wed, 25 Sep 2013 15:42:28 -0700 (PDT)
In-Reply-To: <20130925213403.GF4904@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-25 at 23:34 +0200, Hannes Frederic Sowa wrote:
> net_get_random_once is a new macro which handles the initialization of
> secret keys at use-site. It is possible to call it in the fast path. Only
> the initialization depends on the spinlock and is rather slow. Otherwise
> it should get used just before the key is used to delay the entropy
> extration as late as possible to get better randomness. It returns true
> if the key got initialized.

So you don't like cmpxchg() ;)

> +/* BE CAREFUL: this function is not interrupt safe */
> +#define net_get_random_once(buf, nbytes)				\
> +	({								\
> +		static DEFINE_SPINLOCK(__lock);				\
> +		static bool __done = false;				\
> +		bool __ret = false;					\
> +		if (unlikely(!__done))					\
> +			__ret = __net_get_random_once(buf,		\
> +						    nbytes,		\
> +						    &__done,		\
> +						    &__lock);		\
> +		__ret;							\
> +	})
> +
>  

No idea why its needed to have one spinlock per call point.

A single lock should be more than enough.

The spinlock could be private to __net_get_random_once()

+bool __net_get_random_once(void *buf, int nbytes, bool *done,
+                           spinlock_t *lock)
+{
+       spin_lock_bh(lock);
+       if (*done) {
+               spin_unlock_bh(lock);
+               return false;
+       }
+
+       get_random_bytes(buf, nbytes);

I think you might need a memory barrier here.

(smp_wmb();)

+       *done = true;
+       spin_unlock_bh(lock);


BTW, build_ehash_secret() is called like that :

if (unlikely(!inet_ehash_secret))
    if (sock->type != SOCK_RAW && sock->type != SOCK_DGRAM)
        build_ehash_secret();

So it would be better to make sure inet_ehash_secret is not 0 by
accident.
