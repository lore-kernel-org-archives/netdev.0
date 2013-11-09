From: Loganaden Velvindron <loganaden@gmail.com>
Subject: Re: [RFC] tcp: randomize TCP source ports
Date: Sat, 9 Nov 2013 19:26:57 +0400
Message-ID: <CAOp4FwTEJ1FkQaQNG9_h464oF3SKTrc3r4=AvTjGapXZwd+8eg@mail.gmail.com>
References: <1383872049.9412.124.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131108130244.GE5876@order.stressinduktion.org>
	<1383919418.9412.234.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131108142856.GA28330@order.stressinduktion.org>
	<1383923478.9412.240.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131109044724.GB1963@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:39149 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753256Ab3KIP06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Nov 2013 10:26:58 -0500
Received: by mail-wg0-f43.google.com with SMTP id n12so202969wgh.22
        for <netdev@vger.kernel.org>; Sat, 09 Nov 2013 07:26:57 -0800 (PST)
In-Reply-To: <20131109044724.GB1963@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 9, 2013 at 8:47 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Fri, Nov 08, 2013 at 07:11:18AM -0800, Eric Dumazet wrote:
>> On Fri, 2013-11-08 at 15:28 +0100, Hannes Frederic Sowa wrote:
>>
>> > What do you think about using a timer to keep the reseed out of fast-path
>> > and switch to the non-arch get_random_bytes instead?
>>
>> Well, the initial seed value is get_random_bytes(). I felt that using a
>> xor with the _arch() version would be safe enough.
>>
>> For the timer, I do not think its worth the pain : Do you want a per cpu
>> timer, or a global one ?
>
> This untested diff came to my mind (it is based on the random tree). I
> actually consider to propose something like this for 3.13. UDP port
> randomization is really critical.

I'll try to test the diff, as the idea seems interesting.

I guess that it would help for DNS.

>
> In 3.14 timeframe I suggest abandon net_random and use prandom_u32
> directly so code gets easier to audit.
>
> Would it hurt to use "proper" get_random_byte calls for port randomization?
>
> diff --git a/drivers/char/random.c b/drivers/char/random.c
> index cdf4cfb..e9d0136 100644
> --- a/drivers/char/random.c
> +++ b/drivers/char/random.c
> @@ -657,9 +657,11 @@ retry:
>         r->entropy_total += nbits;
>         if (!r->initialized && nbits > 0) {
>                 if (r->entropy_total > 128) {
> -                       if (r == &nonblocking_pool)
> +                       if (r == &nonblocking_pool) {
>                                 pr_notice("random: %s pool is initialized\n",
>                                           r->name);
> +                               prandom_reseed();
> +                       }
>                         r->initialized = 1;
>                         r->entropy_total = 0;
>                 }
> diff --git a/include/linux/random.h b/include/linux/random.h
> index 6312dd9..4f878c0 100644
> --- a/include/linux/random.h
> +++ b/include/linux/random.h
> @@ -29,6 +29,7 @@ unsigned long randomize_range(unsigned long start, unsigned long end, unsigned l
>  u32 prandom_u32(void);
>  void prandom_bytes(void *buf, int nbytes);
>  void prandom_seed(u32 seed);
> +void prandom_reseed(void);
>
>  u32 prandom_u32_state(struct rnd_state *);
>  void prandom_bytes_state(struct rnd_state *state, void *buf, int nbytes);
> diff --git a/lib/random32.c b/lib/random32.c
> index 52280d5..1ee611f 100644
> --- a/lib/random32.c
> +++ b/lib/random32.c
> @@ -174,11 +174,31 @@ static int __init prandom_init(void)
>  }
>  core_initcall(prandom_init);
>
> +static void __prandom_timer(unsigned long dontcare);
> +static DEFINE_TIMER(seed_timer, __prandom_timer, 0, 0);
> +
> +static void __prandom_timer(unsigned long dontcare)
> +{
> +       u32 entropy;
> +       get_random_bytes(&entropy, sizeof(entropy));
> +       prandom_seed(entropy);
> +       seed_timer.expires = jiffies + 60 * HZ;
> +       add_timer(&seed_timer);
> +}
> +
> +static int prandom_start_seed_timer(void)
> +{
> +       seed_timer.expires = jiffies + 60 * HZ;
> +       add_timer(&seed_timer);
> +       return 0;
> +}
> +late_initcall(prandom_start_seed_timer);
> +
>  /*
>   *     Generate better values after random number generator
>   *     is fully initialized.
>   */
> -static int __init prandom_reseed(void)
> +void prandom_reseed(void)
>  {
>         int i;
>
> @@ -196,4 +216,3 @@ static int __init prandom_reseed(void)
>         }
>         return 0;
>  }
> -late_initcall(prandom_reseed);
>
> Greetings,
>
>   Hannes
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
This message is strictly personal and the opinions expressed do not
represent those of my employers, either past or present.
