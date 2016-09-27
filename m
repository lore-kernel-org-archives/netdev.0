From: Liping Zhang <zlpnobody@gmail.com>
Subject: Re: [PATCH] Fix link error in 32bit arch because of 64bit division
Date: Tue, 27 Sep 2016 18:23:50 +0800
Message-ID: <CAML_gOcy1DcNom+19xr26_4326511B64+S_od11gBGbLfNk1qg@mail.gmail.com>
References: <20160927074203.GA3968@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, johunt@akamai.com,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Vishwanath Pai <pai.vishwain@gmail.com>
To: Vishwanath Pai <vpai@akamai.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160927074203.GA3968@akamai.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi  Vishwanath Pai,

2016-09-27 15:42 GMT+08:00 Vishwanath Pai <vpai@akamai.com>:
> Fix link error in 32bit arch because of 64bit division

This should be "netfilter: xt_hashlimit: fix ... "

>
> --- a/net/netfilter/xt_hashlimit.c
> +++ b/net/netfilter/xt_hashlimit.c
> @@ -465,19 +465,20 @@ static u64 user2credits(u64 user, int revision)
>  {
>         if (revision == 1) {
>                 /* If multiplying would overflow... */
> -               if (user > 0xFFFFFFFF / (HZ*CREDITS_PER_JIFFY_v1))
> +               if (user > div64_u64(0xFFFFFFFF, (HZ*CREDITS_PER_JIFFY_v1)))

Here divisor and dividend are all 32-bit integer, so covert "/" to div64_u64
seems unnecessary.

>                         /* Divide first. */
> -                       return (user / XT_HASHLIMIT_SCALE) *\
> +                       return div64_u64(user, XT_HASHLIMIT_SCALE) *\
>                                                 HZ * CREDITS_PER_JIFFY_v1;
>
> -               return (user * HZ * CREDITS_PER_JIFFY_v1) \
> -                                               / XT_HASHLIMIT_SCALE;
> +               return div64_u64((user * HZ * CREDITS_PER_JIFFY_v1),
> +                                 XT_HASHLIMIT_SCALE);
>         } else {
> -               if (user > 0xFFFFFFFFFFFFFFFF / (HZ*CREDITS_PER_JIFFY))
> -                       return (user / XT_HASHLIMIT_SCALE_v2) *\
> +               if (user > div64_u64(0xFFFFFFFFFFFFFFFF, (HZ*CREDITS_PER_JIFFY)))

0xFFFFFFFFFFFFFFFF and "HZ*CREDITS_PER_JIFFY" are both
constant, and GCC will do constant folding optimization, so I think
convert "/" to div64_u64 here is also unnecessary.

> +                       return div64_u64(user, XT_HASHLIMIT_SCALE_v2) *\
>                                                 HZ * CREDITS_PER_JIFFY;
>
> -               return (user * HZ * CREDITS_PER_JIFFY) / XT_HASHLIMIT_SCALE_v2;
> +               return div64_u64((user * HZ * CREDITS_PER_JIFFY),
> +                                XT_HASHLIMIT_SCALE_v2);
>         }
>  }
>
