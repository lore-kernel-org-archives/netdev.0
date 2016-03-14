From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] bridge: fix potential use-after-free when hook
 returns QUEUE or STOLEN verdict
Date: Mon, 14 Mar 2016 15:47:09 -0400 (EDT)
Message-ID: <20160314.154709.1101262538579723169.davem@davemloft.net>
References: <1457777682-24689-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	nbd@openwrt.org, zefir.kurtisi@neratec.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49235 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755505AbcCNTrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 15:47:12 -0400
In-Reply-To: <1457777682-24689-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sat, 12 Mar 2016 11:14:42 +0100

> Zefir Kurtisi reported kernel panic with an openwrt specific patch.
> However, it turns out that mainline has a similar bug waiting to happen.
> 
> Once NF_HOOK() returns the skb is in undefined state and must not be
> used.   Moreover, the okfn must consume the skb to support async
> processing (NF_QUEUE).
> 
> Current okfn in this spot doesn't consume it and caller assumes that
> NF_HOOK return value tells us if skb was freed or not, but thats wrong.
> 
> It "works" because no in-tree user registers a NFPROTO_BRIDGE hook at
> LOCAL_IN that returns STOLEN or NF_QUEUE verdicts.
> 
> Once we add NF_QUEUE support for nftables bridge this will break --
> NF_QUEUE holds the skb for async processing, caller will erronoulsy
> return RX_HANDLER_PASS and on reinject netfilter will access free'd skb.
> 
> Fix this by pushing skb up the stack in the okfn instead.
> 
> NB: It also seems dubious to use LOCAL_IN while bypassing PRE_ROUTING
> completely in this case but this is how its been forever so it seems
> preferable to not change this.
> 
> Cc: Felix Fietkau <nbd@openwrt.org>
> Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Technically this is a netfilter change, but I'll apply it directly to my
tree, thanks Florian.
