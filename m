From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 3/6] net: davinci_emac: Free clock after checking the
 frequency
Date: Tue, 13 Jan 2015 11:54:16 -0800
Message-ID: <20150113195415.GG2419@atomide.com>
References: <1421177368-19756-1-git-send-email-tony@atomide.com>
 <1421177368-19756-4-git-send-email-tony@atomide.com>
 <54B57688.6000908@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-omap@vger.kernel.org,
	Brian Hutchinson <b.hutchman@gmail.com>,
	Felipe Balbi <balbi@ti.com>
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-02-ewr.mailhop.org ([204.13.248.72]:49153 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbbAMT6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 14:58:03 -0500
Content-Disposition: inline
In-Reply-To: <54B57688.6000908@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Tom Lendacky <thomas.lendacky@amd.com> [150113 11:51]:
> On 01/13/2015 01:29 PM, Tony Lindgren wrote:
> >We only use clk_get() to get the frequency, the rest is done by
> >the runtime PM calls. Let's free the clock too.
> >
> >Cc: Brian Hutchinson <b.hutchman@gmail.com>
> >Cc: Felipe Balbi <balbi@ti.com>
> >Signed-off-by: Tony Lindgren <tony@atomide.com>
> >---
> >  drivers/net/ethernet/ti/davinci_emac.c | 1 +
> >  1 file changed, 1 insertion(+)
> >
> >diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
> >index deb43b3..e9efc74 100644
> >--- a/drivers/net/ethernet/ti/davinci_emac.c
> >+++ b/drivers/net/ethernet/ti/davinci_emac.c
> >@@ -1881,6 +1881,7 @@ static int davinci_emac_probe(struct platform_device *pdev)
> >  		return -EBUSY;
> >  	}
> >  	emac_bus_frequency = clk_get_rate(emac_clk);
> >+	clk_put(emac_clk);
> 
> The devm_clk_get call is used to get the clock so either a devm_clk_put
> needs to be used here or just let the devm_ call do its thing and
> automatically do the put when the module is unloaded.

Thanks good catch, updated patch below.

Runtime PM is really managing the clocks here and the driver
just checks the rate so let's devm_clk_put() it here.

Regards,

Tony.

8< ---------------------
From: Tony Lindgren <tony@atomide.com>
Date: Mon, 22 Dec 2014 08:19:06 -0800
Subject: [PATCH] net: davinci_emac: Free clock after checking the frequency

We only use clk_get() to get the frequency, the rest is done by
the runtime PM calls. Let's free the clock too.

Cc: Brian Hutchinson <b.hutchman@gmail.com>
Cc: Felipe Balbi <balbi@ti.com>
Signed-off-by: Tony Lindgren <tony@atomide.com>

--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1881,6 +1881,7 @@ static int davinci_emac_probe(struct platform_device *pdev)
 		return -EBUSY;
 	}
 	emac_bus_frequency = clk_get_rate(emac_clk);
+	devm_clk_put(&pdev->dev, emac_clk);
 
 	/* TODO: Probe PHY here if possible */
 
