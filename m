From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RCU PATCH 13/14] net: sched: make bstats per cpu and estimator
 RCU safe
Date: Mon, 10 Mar 2014 11:06:14 -0700
Message-ID: <1394474774.3607.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32>
	 <20140310170837.3011.21600.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:59767 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121AbaCJSGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 14:06:23 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so7312802pdi.5
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 11:06:17 -0700 (PDT)
In-Reply-To: <20140310170837.3011.21600.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 10:08 -0700, John Fastabend wrote:

> +void
> +__gnet_stats_copy_basic_cpu(struct gnet_stats_basic_packed *bstats,
> +			    struct gnet_stats_basic_cpu *b)
> +{
> +	int i;
> +
> +	for_each_possible_cpu(i) {
> +		struct gnet_stats_basic_cpu *bcpu = per_cpu_ptr(b, i);
> +		unsigned int start;
> +
> +		do {
> +			start = u64_stats_fetch_begin_bh(&bcpu->syncp);
> +			bstats->bytes += bcpu->bstats.bytes;
> +			bstats->packets += bcpu->bstats.packets;
> +		} while (u64_stats_fetch_retry_bh(&bcpu->syncp, start));
> +	}
> +}

This is buggy. You need to use temporary variables, otherwise if the
retry is done, you add bcpu->bstats.bytes/packets multiple times.
