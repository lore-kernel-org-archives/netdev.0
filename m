From: "Hiremath, Vaibhav" <hvaibhav@ti.com>
Subject: RE: [PATCH 1/2] net: davinci_mdio: enable and disable clock
Date: Fri, 3 Aug 2012 05:53:37 +0000
Message-ID: <79CD15C6BA57404B839C016229A409A83EA7F04C@DBDE01.ent.ti.com>
References: <1343936616-29318-1-git-send-email-zonque@gmail.com>
 <501B5EC1.7010304@ti.com> <501B6020.7090502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"koen@dominion.thruhere.net" <koen@dominion.thruhere.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:58154 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750794Ab2HCFxw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 01:53:52 -0400
In-Reply-To: <501B6020.7090502@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 03, 2012 at 10:52:40, Daniel Mack wrote:
> On 03.08.2012 07:16, Vaibhav Hiremath wrote:
> > 
> > 
> > On 8/3/2012 1:13 AM, Daniel Mack wrote:
> >> Make the driver control the device clocks. Appearantly, the Davinci
> >> platform probes this driver with the clock all powered up, but on OMAP,
> >> this isn't the case.
> >>
> >> Signed-off-by: Daniel Mack <zonque@gmail.com>
> >> ---
> >>  drivers/net/ethernet/ti/davinci_mdio.c | 16 ++++++++++++++--
> >>  1 file changed, 14 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
> >> index cd7ee20..b4b6015 100644
> >> --- a/drivers/net/ethernet/ti/davinci_mdio.c
> >> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
> >> @@ -332,6 +332,8 @@ static int __devinit davinci_mdio_probe(struct platform_device *pdev)
> >>  		goto bail_out;
> >>  	}
> >>  
> >> +	clk_enable(data->clk);
> >> +
> >>  	dev_set_drvdata(dev, data);
> >>  	data->dev = dev;
> >>  	spin_lock_init(&data->lock);
> >> @@ -379,8 +381,11 @@ bail_out:
> >>  	if (data->bus)
> >>  		mdiobus_free(data->bus);
> >>  
> >> -	if (data->clk)
> >> +	if (data->clk) {
> >> +		clk_disable(data->clk);
> >>  		clk_put(data->clk);
> >> +	}
> >> +
> >>  	pm_runtime_put_sync(&pdev->dev);
> >>  	pm_runtime_disable(&pdev->dev);
> >>  
> >> @@ -397,8 +402,11 @@ static int __devexit davinci_mdio_remove(struct platform_device *pdev)
> >>  	if (data->bus)
> >>  		mdiobus_free(data->bus);
> >>  
> >> -	if (data->clk)
> >> +	if (data->clk) {
> >> +		clk_disable(data->clk);
> >>  		clk_put(data->clk);
> >> +	}
> >> +
> >>  	pm_runtime_put_sync(&pdev->dev);
> >>  	pm_runtime_disable(&pdev->dev);
> >>  
> >> @@ -427,6 +435,8 @@ static int davinci_mdio_suspend(struct device *dev)
> >>  	data->suspended = true;
> >>  	spin_unlock(&data->lock);
> >>  
> >> +	clk_disable(data->clk);
> >> +
> >>  	return 0;
> >>  }
> >>  
> >> @@ -435,6 +445,8 @@ static int davinci_mdio_resume(struct device *dev)
> >>  	struct davinci_mdio_data *data = dev_get_drvdata(dev);
> >>  	u32 ctrl;
> >>  
> >> +	clk_enable(data->clk);
> >> +
> > 
> > Danial,
> > 
> > I would request you to wait for this, its not that simple and straight.
> > And once you migrate to runtime PM you don't need clk_enable/disable,
> > this should get handled under runtime PM api's.
> 
> As I said, it can be dropped.
> 
> > Also have you read my another email post -
> > 
> > http://comments.gmane.org/gmane.linux.ports.arm.omap/80796
> > 
> > Certainly, with respect to CPSW & MDIO, this patch is not enough and
> > requires further investigation. I have started looking at this and
> > hopefully will have some solution soon...
> 
> Ok, no problem. We certainly need the DT bindings for davinci_mdio. With
> that applied, and the hwmod added (in the patch I posted yesterday), I
> can at least mount the rootfs via NFS, which is all I currently need.
> 
> 

I certainly understand your requirement here.

Actually this is not the only device we have, the same issue is applicable 
to PWM subsystem available in AM335x. Hopefully I should have something soon 
on this.


Thanks,
Vaibhav
