From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: Re: [PATCH -next] bridge: fix potential use-after-free when hook
 returns QUEUE or STOLEN verdict
Date: Mon, 14 Mar 2016 16:28:27 +0100
Message-ID: <56E6D89B.6030608@neratec.com>
References: <1457777682-24689-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, Felix Fietkau <nbd@openwrt.org>
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:3726 "EHLO mail.neratec.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965348AbcCNP2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2016 11:28:31 -0400
In-Reply-To: <1457777682-24689-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/2016 11:14 AM, Florian Westphal wrote:
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
> ---
>  
Looks good: applying the same fix-pattern to OpenWRT private patches solved the
oops previously observed.

Thanks for the quick resolution.

Tested-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>
