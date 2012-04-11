From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: avoid order-1 allocations on wifi and tx path
Date: Wed, 11 Apr 2012 10:11:46 -0400 (EDT)
Message-ID: <20120411.101146.1779004013194245072.davem@davemloft.net>
References: <20120411052733.GA17352@merlins.org>
	<1334122980.5300.2154.camel@edumazet-glaptop>
	<1334125848.5300.2330.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marc@merlins.org, Larry.Finger@lwfinger.net,
	bhutchings@solarflare.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754054Ab2DKOMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 10:12:05 -0400
In-Reply-To: <1334125848.5300.2330.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 11 Apr 2012 08:30:48 +0200

> Marc Merlin reported many order-1 allocations failures in TX path on its
> wireless setup, that dont make any sense with MTU=1500 network, and non
> SG capable hardware.
> 
> After investigation, it turns out TCP uses sk_stream_alloc_skb() and
> used as a convention skb_tailroom(skb) to know how many bytes of data
> payload could be put in this skb (for non SG capable devices)
> 
> Note : these skb used kmalloc-4096 (MTU=1500 + MAX_HEADER +
> sizeof(struct skb_shared_info) being above 2048)
> 
> Later, mac80211 layer need to add some bytes at the tail of skb
> (IEEE80211_ENCRYPT_TAILROOM = 18 bytes) and since no more tailroom is
> available has to call pskb_expand_head() and request order-1
> allocations.
> 
> This patch changes sk_stream_alloc_skb() so that only
> sk->sk_prot->max_header bytes of headroom are reserved, and use a new
> skb field, avail_size to hold the data payload limit.
> 
> This way, order-0 allocations done by TCP stack can leave more than 2 KB
> of tailroom and no more allocation is performed in mac80211 layer (or
> any layer needing some tailroom)
> 
> avail_size is unioned with mark/dropcount, since mark will be set later
> in IP stack for output packets. Therefore, skb size is unchanged.
> 
> Reported-by: Marc MERLIN <marc@merlins.org>
> Tested-by: Marc MERLIN <marc@merlins.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks Eric.
