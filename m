From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Tue, 15 May 2012 17:00:25 +0200
Message-ID: <1337094025.8512.1095.camel@edumazet-glaptop>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>
	 <1337093776.8512.1089.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kieran Mansley <kmansley@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60876 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932967Ab2EOPAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 11:00:34 -0400
Received: by bkcji2 with SMTP id ji2so4893712bkc.19
        for <netdev@vger.kernel.org>; Tue, 15 May 2012 08:00:33 -0700 (PDT)
In-Reply-To: <1337093776.8512.1089.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-15 at 16:56 +0200, Eric Dumazet wrote:

> Please try latest kernels, this is probably 'fixed'
> 
> What network driver are you using ?
> 
> 

commit b49960a05e32121d29316cfdf653894b88ac9190
Author: Eric Dumazet <edumazet@google.com>
Date:   Wed May 2 02:28:41 2012 +0000

    tcp: change tcp_adv_win_scale and tcp_rmem[2]
    
    tcp_adv_win_scale default value is 2, meaning we expect a good citizen
    skb to have skb->len / skb->truesize ratio of 75% (3/4)
    
    In 2.6 kernels we (mis)accounted for typical MSS=1460 frame :
    1536 + 64 + 256 = 1856 'estimated truesize', and 1856 * 3/4 = 1392.
    So these skbs were considered as not bloated.
    
    With recent truesize fixes, a typical MSS=1460 frame truesize is now the
    more precise :
    2048 + 256 = 2304. But 2304 * 3/4 = 1728.
    So these skb are not good citizen anymore, because 1460 < 1728
    
    (GRO can escape this problem because it build skbs with a too low
    truesize.)
    
    This also means tcp advertises a too optimistic window for a given
    allocated rcvspace : When receiving frames, sk_rmem_alloc can hit
    sk_rcvbuf limit and we call tcp_prune_queue()/tcp_collapse() too often,
    especially when application is slow to drain its receive queue or in
    case of losses (netperf is fast, scp is slow). This is a major latency
    source.
    
    We should adjust the len/truesize ratio to 50% instead of 75%
    
    This patch :
    
    1) changes tcp_adv_win_scale default to 1 instead of 2
    
    2) increase tcp_rmem[2] limit from 4MB to 6MB to take into account
    better truesize tracking and to allow autotuning tcp receive window to
    reach same value than before. Note that same amount of kernel memory is
    consumed compared to 2.6 kernels.
    
    Signed-off-by: Eric Dumazet <edumazet@google.com>
