From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ethernet: call __skb_pull() in eth_type_trans()
Date: Mon, 03 May 2010 23:16:18 -0700 (PDT)
Message-ID: <20100503.231618.237360885.davem@davemloft.net>
References: <1272895972-13799-1-git-send-email-xiaosuo@gmail.com>
	<20100503.125404.134122628.davem@davemloft.net>
	<h2h412e6f7f1005031934m971342dw965e046d40485ec7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42820
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754782Ab0EDGQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 02:16:11 -0400
In-Reply-To: <h2h412e6f7f1005031934m971342dw965e046d40485ec7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Tue, 4 May 2010 10:34:07 +0800

> It seems no callers pass eth_type_trans() a packet, whose length is
> less than ETH_HLEN. It means that skb_pull() always returns non-NULL.
> And if skb_pull() returns NULL, the later memory dereferences must be
> invalid.

In your opinion.  As I explained in the reply to your latest
eth_type_trans() patch, we can defererence several bytes past
the end of skb->data's valid packet data area without faulting.

We'll just read in garbage, because it's things like skb_shared_info()
and friends might be there.

But it's completely safe, and frankly I'm fine with the kernel doing
this when runts make it into this code if that allows us to avoid
stupid checks.

> As Eric mentioned above, GRE only assures the length of the packets
> passed to eth_type_trans() isn't less than ETH_HLEN, we should check
> skb->len before we dereference skb->data.

The code needs only ETH_HLEN, but valid ethernet packets must be at
least ETH_ZLEN.

> For performance, how about inlining eth_type_trans(). Because its main
> users are NIC drivers, and there aren't likely many kinds of NICs at
> the same time, inlining it won't increases the size of the kernel
> image much.

No, that's unnecessary bloat, plus I want to make ->ndo_type_trans()
a netdev operation so it can possibly be deferred.

Changli, please go hack elsewhere and on some other piece of code,
all your ideas here in eth_type_trans() are not well founded.

I see from your struct dst union removal patch that you don't even
build test your changes, so why don't you spend your excess energy on
making sure your code at least compiles successfully?

Thanks.
