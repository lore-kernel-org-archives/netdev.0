From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH][iproute2] tc/q_htb.c: Fix the MPU value output in 'tc
 -d class show dev <device_name> ' command
Date: Wed, 16 Dec 2015 16:15:58 +0100
Message-ID: <20151216161558.265296c7@redhat.com>
References: <5917221449918579@web5j.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org,
	Phil Sutter <psutter@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60469 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932857AbbLPPQD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 10:16:03 -0500
In-Reply-To: <5917221449918579@web5j.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Dmitrii,

On Sat, 12 Dec 2015 14:09:39 +0300 Dmitrii Shcherbakov <fw.dmitrii@yandex.com> wrote:

> I noticed a quite an old change which I have a few questions about so
> maybe somebody could help me out. There are a few lines of code in
> tc/q_htb.c which were committed originally back in 2004 and have not
> changed since related to MPU (Minimum Packet Unit). I asked Stephen -
> this is probably the code that pre-dated git so I am not sure exactly
> who to ask:

AFAIKR I was involved in these overhead changes back in 2004, and also
around 2007 where we introduced a "real" overhead parameter.

We "moved" the overhead parameter to be a "real" struct member (in my commit
e08b09983fe9 ("[NET_SCHED]: Making rate table lookups more flexible."))

Thus, this encoding of overhead in the "mpu" should be obsolete.

struct tc_ratespec {
	unsigned char	cell_log;
	__u8		linklayer; /* lower 4 bits */
	unsigned short	overhead;
	short		cell_align;
	unsigned short	mpu;
	__u32		rate;
};

(sometimes accessed via  struct qdisc_rate_table->rate.overhead)

In newer kernels, this tc_ratespec, is converted and transfered to
struct psched_ratecfg (in functions psched_ratecfg_precompute() and
psched_ratecfg_getrate()).


> I noticed that there is a separate configurable value called
> 'overhead' in q_htb.c now which does not have anything to do with
> 'overhead = hopt->rate.mpu>>8)&0xFF' that is being printed out in the
> above lines:

Looking through both the kernel and iproute2 code, it looks like only
the "real" overhead is used. I cannot find any users of the encoded
overhead into the mpu value.  Thus, your patch should be okay...


> static void explain(void)
> {
>     ...
>         " overhead per-packet size overhead used in rate computations\n"
>     ...
>
 
> In the code fragment from the commit (for some reason I don't
> understand) 'rate.mpu' is sliced into two parts called 'mpu' and
> 'overhead'. So, basically, to retrieve the original MPU value from
> the output of `tc -d class show dev <device_name>` I need to do the
> following: real_mpu = mpu + overhead<<8.
> 

> I also have a hard time understanding whether it is possible to have
> a condition where rate.mpu and ceil.mpu have different values - the
> outputs I have seen always showed the same values for both and I do
> not see anything in the code that sets them to different values (if
> so, maybe the duplicate output should be removed).

Maybe. But do consider backwards compat issues,if you have this output
(e.g. like scripts parsing this output). 

When trying to understand this code, keep in mind that we are trying
to keep backward compatible with older kernels.  Thus, this printing
might be have been left here to keep compat with older kernels, but I
think we can remove it now.


> Please take a look at my patch if you have time for it as this would
> simplify testing in the project I work on and make the output of the
> command less ambiguous for other people who may use HTB.

Reviewed below
 
> Thank you,
> Dmitrii Shcherbakov
> 
> From 26c62f17e1d6ebca9f236000806a63363ab70640 Mon Sep 17 00:00:00 2001
> From: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
> Date: Sat, 12 Dec 2015 02:04:09 +0300
> Subject: [PATCH] tc/q_htb.c: Fix the MPU value output in 'tc -d class show dev
>  <device_name> ' command
> 
> This patch removes slicing of 'rate.mpu' into two parts called 'mpu'
> and 'overhead' alleviating the need to perform calculations to get
> the original MPU value after it is configured as follows: real_mpu =
> mpu + overhead<<8.
> 
> Signed-off-by: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
> ---
>  tc/q_htb.c | 13 +++++--------
>  1 file changed, 5 insertions(+), 8 deletions(-)
> 
> diff --git a/tc/q_htb.c b/tc/q_htb.c
> index 7075a4c..f810329 100644
> --- a/tc/q_htb.c
> +++ b/tc/q_htb.c
> @@ -274,7 +274,6 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
>  	SPRINT_BUF(b1);
>  	SPRINT_BUF(b2);
>  	SPRINT_BUF(b3);
> -	SPRINT_BUF(b4);
>  
>  	if (opt == NULL)
>  		return 0;
> @@ -311,18 +310,16 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
>  		cbuffer = tc_calc_xmitsize(ceil64, hopt->cbuffer);
>  		linklayer = (hopt->rate.linklayer & TC_LINKLAYER_MASK);
>  		if (linklayer > TC_LINKLAYER_ETHERNET || show_details)
> -			fprintf(f, "linklayer %s ", sprint_linklayer(linklayer, b4));
> +			fprintf(f, "linklayer %s ", sprint_linklayer(linklayer, b3));

I don't think your patch should contain this cleanup of "b4".
Submit another patch with that cleanup change, please.


>  		if (show_details) {
> -			fprintf(f, "burst %s/%u mpu %s overhead %s ",
> +			fprintf(f, "burst %s/%u mpu %s ",
>  				sprint_size(buffer, b1),
>  				1<<hopt->rate.cell_log,
> -				sprint_size(hopt->rate.mpu&0xFF, b2),
> -				sprint_size((hopt->rate.mpu>>8)&0xFF, b3));
> -			fprintf(f, "cburst %s/%u mpu %s overhead %s ",
> +				sprint_size(hopt->rate.mpu, b2));
> +			fprintf(f, "cburst %s/%u mpu %s ",
>  				sprint_size(cbuffer, b1),
>  				1<<hopt->ceil.cell_log,
> -				sprint_size(hopt->ceil.mpu&0xFF, b2),
> -				sprint_size((hopt->ceil.mpu>>8)&0xFF, b3));
> +				sprint_size(hopt->ceil.mpu, b2));
>  			fprintf(f, "level %d ", (int)hopt->level);
>  		} else {
>  			fprintf(f, "burst %s ", sprint_size(buffer, b1));

Other part of patch looks good.

Please resubmit patch "officially" and Cc me, then I will review and ACK.
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
