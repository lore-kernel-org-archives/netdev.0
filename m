From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6 v4 2/2] hfsc: add link layer overhead adaption
Date: Mon, 14 Jul 2008 16:24:41 +0200
Message-ID: <487B61A9.5090204@trash.net>
References: <20080710193434.19525.83454.stgit@fate.lan> <20080710193440.19525.93085.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47072 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753783AbYGNO0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 10:26:13 -0400
In-Reply-To: <20080710193440.19525.93085.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jussi Kivilinna wrote:
> CBQ and HTB have options for emulating overhead of underlying link layer
> (mpu/overhead/linklayer options). This patch makes sch_hfsc use size table
> to emulate link layer overhead.
> 
> Patch uses size table to convert packet length to emulated link layer packet
> length. Converted packet length is passed to hfsc calculations instead of
> real. If size table isn't passed to kernel, hfsc works as before.
> 
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
> ---
> 
>  include/linux/pkt_sched.h |    5 +
>  net/sched/sch_hfsc.c      |  158 +++++++++++++++++++++++++++++++++++++--------
>  2 files changed, 135 insertions(+), 28 deletions(-)
> 
> diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
> index 5bf1444..46db55d 100644
> --- a/include/linux/pkt_sched.h
> +++ b/include/linux/pkt_sched.h
> @@ -303,6 +303,9 @@ struct tc_htb_xstats
>  struct tc_hfsc_qopt
>  {
>  	__u16	defcls;		/* default class */
> +	__u16	__reserved;
> +	struct tc_sizespec szopts;
> +	__u16	stab[512];
>  };
>  
>  struct tc_service_curve
> @@ -326,6 +329,8 @@ enum
>  	TCA_HFSC_RSC,
>  	TCA_HFSC_FSC,
>  	TCA_HFSC_USC,
> +	TCA_HFSC_SZOPTS,
> +	TCA_HFSC_STAB,

I thought you were going to make this a generic qdisc feature.
Why is configuration still qdisc specific?

I was thinking of something like this:

- add generic attributes for configuring size tables for any
   qdisc, handle those in sch_api

- add qdisc_enqueue() wrapper that calculates the size and
   stores it in skb->cb, convert direct calls of sch->enqueue
   to use it

- change direct uses of skb->len to use the size from the cb

The second step might need a bit more thought to make sure
qdiscs don't get confused when the dequeued packet is larger
than the enqueued one, but I think they usually don't care.

