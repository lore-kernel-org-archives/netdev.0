From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: w5300: Use devm_ioremap_resource()
Date: Thu, 27 Feb 2014 17:06:41 -0500 (EST)
Message-ID: <20140227.170641.962779709265574310.davem@davemloft.net>
References: <000001cf33a6$e0a57040$a1f050c0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, msink@permonline.ru
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49804 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710AbaB0WGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 17:06:43 -0500
In-Reply-To: <000001cf33a6$e0a57040$a1f050c0$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Thu, 27 Feb 2014 19:30:04 +0900

> Use devm_ioremap_resource() in order to make the code simpler,
> and remove redundant return value check of platform_get_resource()
> because the value is checked by devm_ioremap_resource().
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

I think the code with the NULL check removed is harder for semantic
checkers to figure out, because of what will look like a blind
dereference via resource_size(mem).

Unless all semantic checkers are going to learn the complete semantics
of devm_ioremap_resource(), in particular that it will signal an error
on a NULL second argument, and then the semantic checker will see
the complete control flow in the call site, I think we should keep
the NULL check.

Maybe recode this as:

	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	if (!mem)
		return -ENXIO;
	mem_size = resource_size(mem);

	priv->base = devm_ioremap_resource(&pdev->dev, mem);
	if (IS_ERR(priv->base))
		return PTR_ERR(priv->base);

Same goes for your other patch.
