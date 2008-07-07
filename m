From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v3 2/2] hfsc: add link layer overhead adaption
Date: Mon, 07 Jul 2008 13:53:24 +0200
Message-ID: <487203B4.4030701@trash.net>
References: <20080703220311.30053.63477.stgit@fate.lan> <20080703220317.30053.87947.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58054 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753507AbYGGLx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 07:53:28 -0400
In-Reply-To: <20080703220317.30053.87947.stgit@fate.lan>
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
> +/* convert packet length to link layer packet length */
> +static unsigned int get_linklayer_len(struct hfsc_class *cl, unsigned int len)
> +{
> +	if (unlikely(!len) || likely(!cl->stab))
> +		return len;
> +	return qdisc_linklayer_sz(cl->stab, len);
> +}

This means HFSC will use other packet sizes as inner qdiscs, policers,
statistics etc, which I don't like very much. My original patch used
the size tables to calculate the size when enqueing to the root qdisc
and stored it in the cb, so all qdiscs in the hierarchy can use the
same size.

> @@ -987,9 +997,11 @@ hfsc_change_usc(struct hfsc_class *cl, struct tc_service_curve *usc,
>  }
>  
>  static const struct nla_policy hfsc_policy[TCA_HFSC_MAX + 1] = {
> -	[TCA_HFSC_RSC]	= { .len = sizeof(struct tc_service_curve) },
> -	[TCA_HFSC_FSC]	= { .len = sizeof(struct tc_service_curve) },
> -	[TCA_HFSC_USC]	= { .len = sizeof(struct tc_service_curve) },
> +	[TCA_HFSC_RSC]		= { .len = sizeof(struct tc_service_curve) },
> +	[TCA_HFSC_FSC]		= { .len = sizeof(struct tc_service_curve) },
> +	[TCA_HFSC_USC]		= { .len = sizeof(struct tc_service_curve) },
> +	[TCA_HFSC_SZOPTS]	= { .len = sizeof(struct tc_sizespec) },
> +	[TCA_HFSC_STAB]		= { .type = NLA_BINARY, .len = TC_STAB_SIZE },

Why are these two separate attributes?
