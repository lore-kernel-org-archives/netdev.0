From: subashab@codeaurora.org
Subject: Re: [PATCH] net: rps: fix data stall after hotplug
Date: Mon, 30 Mar 2015 23:49:39 -0000
Message-ID: <6ef597cb521f6c9adf48562c72677415.squirrel@www.codeaurora.org>
References: <b3ecb218932daa656a796cfa6e9e62b9.squirrel@www.codeaurora.org>
    <1426801839.25985.15.camel@edumazet-glaptop2.roam.corp.google.com>
    <1426852239.25985.33.camel@edumazet-glaptop2.roam.corp.google.com>
    <b25a45de2cb43bbcfcaa84634d74533e.squirrel@www.codeaurora.org>
    <744bbefe8859bf667eafc0de02729078.squirrel@www.codeaurora.org>
    <1427149742.25985.84.camel@edumazet-glaptop2.roam.corp.google.com>
    <49d5ac3130df29059f167a0401754c67.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:36718 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932093AbbC3Xtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 19:49:40 -0400
In-Reply-To: <49d5ac3130df29059f167a0401754c67.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> >> Please try instead this patch :
>>> >>
>>> >> diff --git a/net/core/dev.c b/net/core/dev.c
>>> >> index
>>> >> 5d43e010ef870a6ab92895297fe18d6e6a03593a..baa4bff9a6fbe0d77d7921865c038060cb5efffd
>>> >> 100644
>>> >> --- a/net/core/dev.c
>>> >> +++ b/net/core/dev.c
>>> >> @@ -4320,9 +4320,8 @@ static void
>>> net_rps_action_and_irq_enable(struct
>>> >> softnet_data *sd)
>>> >>  		while (remsd) {
>>> >>  			struct softnet_data *next = remsd->rps_ipi_next;
>>> >>
>>> >> -			if (cpu_online(remsd->cpu))
>>> >> -				smp_call_function_single_async(remsd->cpu,
>>> >> -							   &remsd->csd);
>>> >> +			smp_call_function_single_async(remsd->cpu,
>>> >> +						       &remsd->csd);
>>> >>  			remsd = next;
>>> >>  		}
>>> >>  	} else
>>> >>
>>> >>

Hi Eric

While the original issue of data stall due to missing IPI is no longer
seen with netif_rx_ni(), the scenario of rps cpu online in [1 -
get_rps_cpus] but offline in [2 - net_rps_action_and_irq_enable] could
still occur. Using your patch, triggering an IPI on an offline cpu in [2]
leads to a crash on my arch.

I would like to know your thoughts on how to fix this race. Could the
patch which I had initially proposed help here. Alternatively, is it
correct to reset NAPI state and increment dropped sd count if an offline
CPU is detected in [2].

--
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux
Foundation Collaborative Project
