From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: fix splat in skb_clone with large messages
Date: Thu, 27 Jun 2013 22:44:49 -0700 (PDT)
Message-ID: <20130627.224449.597576653116367356.davem@davemloft.net>
References: <1372381463-14958-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	artem.savkov@gmail.com, fengguang.wu@intel.com
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36081 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868Ab3F1Fou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 01:44:50 -0400
In-Reply-To: <1372381463-14958-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri, 28 Jun 2013 03:04:23 +0200

> Since (c05cdb1 netlink: allow large data transfers from user-space),
> netlink splats if it invokes skb_clone on large netlink skbs since:
> 
> * skb_shared_info was not correctly initialized.
> * skb->destructor is not set in the cloned skb.
> 
> This was spotted by trinity:
> 
> [  894.990671] BUG: unable to handle kernel paging request at ffffc9000047b001
> [  894.991034] IP: [<ffffffff81a212c4>] skb_clone+0x24/0xc0
> [...]
> [  894.991034] Call Trace:
> [  894.991034]  [<ffffffff81ad299a>] nl_fib_input+0x6a/0x240
> [  894.991034]  [<ffffffff81c3b7e6>] ? _raw_read_unlock+0x26/0x40
> [  894.991034]  [<ffffffff81a5f189>] netlink_unicast+0x169/0x1e0
> [  894.991034]  [<ffffffff81a601e1>] netlink_sendmsg+0x251/0x3d0
> 
> Fix it by:
> 
> 1) introducing a new netlink_skb_clone function that is used in nl_fib_input,
>    that sets our special skb->destructor in the cloned skb. Moreover, handle
>    the release of the large cloned skb head area in the destructor path.
> 
> 2) not allowing large skbuffs in the netlink broadcast path. I cannot find
>    any reasonable use of the large data transfer using netlink in that path,
>    moreover this helps to skip extra skb_clone handling.
> 
> I found two more netlink clients that are cloning the skbs, but they are
> not in the sendmsg path. Therefore, the sole client cloning that I found
> seems to be the fib frontend.
> 
> Thanks to Eric Dumazet for helping to address this issue.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Looks good, applied, thanks!
