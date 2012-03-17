From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/irda: add clk_prepare/clk_unprepare to pxaficp_ir
Date: Fri, 16 Mar 2012 23:10:47 -0700 (PDT)
Message-ID: <20120316.231047.1919840752101978309.davem@davemloft.net>
References: <1331835569.14662.11.camel@flow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.y.miao@gmail.com,
	haojian.zhuang@marvell.com, samuel@sortiz.org
To: philipp.zabel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39896 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826Ab2CQGL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 02:11:57 -0400
In-Reply-To: <1331835569.14662.11.camel@flow>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philipp Zabel <philipp.zabel@gmail.com>
Date: Thu, 15 Mar 2012 19:19:29 +0100

> This patch adds clk_prepare/clk_unprepare calls to the pxaficp_ir
> driver by using the helper functions clk_prepare_enable and
> clk_disable_unprepare.
> 
> Signed-off-by: Philipp Zabel <philipp.zabel@gmail.com>

This is terrible.

So the problem was that clk_enable can't be invoked from atomic
context, because it wants to take a mutex for some implementation.

Therefore an existing routine with well defined semantics,
clk_enable(), was turned into a NOP.

And this silently breaks drivers.

Instead of silently breaking things, make direct
clk_enable()/clk_disable() invocations either result in a compile
error or a run-time BUG_ON().

There are other ways this could have been handled as well.

But just making clk_{enable,disable}() essentially stop working
was not a very good one at all.

I'll apply this patch to net-next, but I just wanted to point out
what an absolutely brain-dead way this was handled.
