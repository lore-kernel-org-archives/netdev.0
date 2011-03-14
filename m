From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] macb: detect IP version to determin if we are on at91
	or avr32
Date: Mon, 14 Mar 2011 10:15:13 +0000
Message-ID: <20110314101512.GA26085@n2100.arm.linux.org.uk>
References: <1299863585-17263-1-git-send-email-plagnioj@jcrosoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-kernel@vger.kernel.org, Jamie Iles <jamie@jamieiles.com>,
	Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:54245 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993Ab1CNKP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 06:15:28 -0400
Content-Disposition: inline
In-Reply-To: <1299863585-17263-1-git-send-email-plagnioj@jcrosoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 11, 2011 at 06:13:05PM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
> +	if (macb_is_at91(bp)) {
> +		bp->pclk = clk_get(&pdev->dev, "macb_clk");
> +		if (IS_ERR(bp->pclk)) {
> +			dev_err(&pdev->dev, "failed to get macb_clk\n");
> +			goto err_out_free_dev;
> +		}
> +		clk_enable(bp->pclk);
> +	} else {
> +		bp->pclk = clk_get(&pdev->dev, "pclk");
> +		if (IS_ERR(bp->pclk)) {
> +			dev_err(&pdev->dev, "failed to get pclk\n");
> +			goto err_out_free_dev;
> +		}
> +		bp->hclk = clk_get(&pdev->dev, "hclk");
> +		if (IS_ERR(bp->hclk)) {
> +			dev_err(&pdev->dev, "failed to get hclk\n");
> +			goto err_out_put_pclk;
> +		}
> +
> +		clk_enable(bp->pclk);
> +		clk_enable(bp->hclk);
> +	}

This is the same kind of sillyness that started getting OMAP into problems
with the clk API.  Just do this instead:

	bp->pclk = clk_get(&pdev->dev, "pclk");
	if (IS_ERR(bp->pclk)) {
		dev_err(&pdev->dev, "failed to get pclk\n");
		goto err_out_free_dev;
	}
	bp->hclk = clk_get(&pdev->dev, "hclk");
	if (IS_ERR(bp->hclk)) {
		dev_err(&pdev->dev, "failed to get hclk\n");
		goto err_out_put_pclk;
	}

	clk_enable(bp->pclk);
	clk_enable(bp->hclk);

And then require _all_ platforms using this driver to provide a pclk and
a hclk for this device, whether they exist in the SoC or not.  Where they
don't, provide dummy clocks for it.

This probably means you end up with _less_ bloat overall because you're
not having to build the above code.  You've less lines of source code to
maintain.  You have a simplified dirver with consistent requirements
across all platforms.  You don't need to read the version register, and
you don't need macb_is_at91() and macb_is_avr32().

With clkdev it's _cheap_ to provide these dummy clocks once you have one
dummy clock already in place.
