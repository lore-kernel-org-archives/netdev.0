From: ericnetdev dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH net] ipv6: sr: fix BUG in HMAC init when preemption is enabled
Date: Tue, 10 Jan 2017 10:16:29 -0800
Message-ID: <CAHTyZGxoCV=fUjbUq2r5vtH2rDqGScrf=ty2HYOL8KLhdf4R4w@mail.gmail.com>
References: <1484055562-6414-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36126 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755547AbdAJSQa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 13:16:30 -0500
Received: by mail-it0-f65.google.com with SMTP id o138so191914ito.3
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 10:16:30 -0800 (PST)
In-Reply-To: <1484055562-6414-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-01-10 5:39 GMT-08:00 David Lebrun <david.lebrun@uclouvain.be>:
> When CONFIG_PREEMPT=y, CONFIG_IPV6=m and CONFIG_SEG6_HMAC=y,
> seg6_hmac_init() is called during the initialization of the ipv6 module.
> This causes a subsequent call to smp_processor_id() with preemption
> enabled, resulting in the following trace.

I disagree with  your fix.  Keeping GFP_KERNEL for all these per cpu
allocations is needed.

What about the simpler :

Rationale : we only need to get the size of the allocation, we do not
care of migration here, all cpus having the same allocation.

Another issue with this is code is that in case of an allocation
error, no cleanup is performed to free prior allocations.

diff --git a/net/ipv6/seg6_hmac.c b/net/ipv6/seg6_hmac.c
index ef1c8a46e7aceee45b2044d4b4338dc3aed88807..b31d682816503129e12d3eae5b70a8cbce8525a7
100644
--- a/net/ipv6/seg6_hmac.c
+++ b/net/ipv6/seg6_hmac.c
@@ -400,7 +400,7 @@ static int seg6_hmac_init_algo(void)
                        *p_tfm = tfm;
                }

-               p_tfm = this_cpu_ptr(algo->tfms);
+               p_tfm = __this_cpu_ptr(algo->tfms);
                tfm = *p_tfm;

                shsize = sizeof(*shash) + crypto_shash_descsize(tfm);
