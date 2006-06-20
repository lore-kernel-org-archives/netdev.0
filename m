From: David Miller <davem@davemloft.net>
Subject: Re: [PKT_SCHED]: PSCHED_TADD() and PSCHED_TADD2() can
 result,tv_usec >= 1000000
Date: Mon, 19 Jun 2006 23:51:05 -0700 (PDT)
Message-ID: <20060619.235105.82052619.davem@davemloft.net>
References: <449637EE.4020608@necst.nec.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:29621
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965099AbWFTGvB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 02:51:01 -0400
To: maeda-sxb@necst.nec.co.jp
In-Reply-To: <449637EE.4020608@necst.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shuya MAEDA <maeda-sxb@necst.nec.co.jp>
Date: Mon, 19 Jun 2006 14:36:46 +0900

>  #define PSCHED_TADD2(tv, delta, tv_res) \
>  ({ \
> -          int __delta = (tv).tv_usec + (delta); \
> -          (tv_res).tv_sec = (tv).tv_sec; \
> -          if (__delta > USEC_PER_SEC) { (tv_res).tv_sec++; __delta -= USEC_PER_SEC; } \
> -          (tv_res).tv_usec = __delta; \
> +          int __delta = (delta); \
> +          (tv_res) = (tv); \
> +          if((delta) > USEC_PER_SEC) { \
> +                (tv_res).tv_sec += (delta) / USEC_PER_SEC; \
> +                __delta -= (delta) % USEC_PER_SEC; \
> +          } \
> +          (tv_res).tv_usec += __delta; \
> +          if((tv_res).tv_usec >= USEC_PER_SEC) { \
> +                (tv_res).tv_sec++; \
> +                (tv_res).tv_usec -= USEC_PER_SEC; \
> +          } \
>  })

Divide and modulus can be extremely expensive on some systems, so
let's try to avoid using them.

It is probably sufficient to adjust the passed in delta only once if
it is >= USEC_PER_SEC, but if you feel that is an unsafe assumption
then please use a simply loop like this:

	while (__delta >= USEC_PER_SEC) {
		(tv_res).tv_sec++;
		__delta -= USEC_PER_SEC;
	}

And please provide a proper "Signed-off-by: " line in your next
patch submission.

Thank you very much.
