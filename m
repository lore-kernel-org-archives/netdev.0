From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH net 1/7] net: ethernet: ti: cpsw: fix bad register access
 in probe error path
Date: Thu, 17 Nov 2016 10:41:03 +0100
Message-ID: <20161117094103.GB21237@localhost>
References: <1479306916-27673-1-git-send-email-johan@kernel.org>
 <1479306916-27673-2-git-send-email-johan@kernel.org>
 <664c1f10-dd31-8566-852f-ee5ca0b5c46e@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johan Hovold <johan@kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <664c1f10-dd31-8566-852f-ee5ca0b5c46e@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 16, 2016 at 02:33:18PM -0600, Grygorii Strashko wrote:
> On 11/16/2016 08:35 AM, Johan Hovold wrote:
> > Make sure to resume the platform device to enable clocks before
> > accessing the CPSW registers in the probe error path (e.g. for deferred
> > probe).
> > 
> > Unhandled fault: external abort on non-linefetch (0x1008) at 0xd0872d08
> > ...
> > [<c04fabcc>] (cpsw_ale_control_set) from [<c04fb8b4>] (cpsw_ale_destroy+0x2c/0x44)
> > [<c04fb8b4>] (cpsw_ale_destroy) from [<c04fea58>] (cpsw_probe+0xbd0/0x10c4)
> > [<c04fea58>] (cpsw_probe) from [<c047b2a0>] (platform_drv_probe+0x5c/0xc0)
> > 
> > Note that in the unlikely event of a runtime-resume failure, we'll leak
> > the ale struct.
> > 
> > Fixes: df828598a755 ("netdev: driver: ethernet: Add TI CPSW driver")
> > Signed-off-by: Johan Hovold <johan@kernel.org>
> > ---
> >  drivers/net/ethernet/ti/cpsw.c | 7 ++++++-
> >  1 file changed, 6 insertions(+), 1 deletion(-)
> > 
> > diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> > index c6cff3d2ff05..5bc5e6189661 100644
> > --- a/drivers/net/ethernet/ti/cpsw.c
> > +++ b/drivers/net/ethernet/ti/cpsw.c
> > @@ -2818,7 +2818,12 @@ static int cpsw_probe(struct platform_device *pdev)
> >  	return 0;
> >  
> >  clean_ale_ret:
> > -	cpsw_ale_destroy(cpsw->ale);
> > +	if (pm_runtime_get_sync(&pdev->dev) < 0) {
> > +		pm_runtime_put_noidle(&pdev->dev);
> > +	} else {
> > +		cpsw_ale_destroy(cpsw->ale);
> > +		pm_runtime_put_sync(&pdev->dev);
> > +	}
> >  clean_dma_ret:
> >  	cpdma_ctlr_destroy(cpsw->dma);
> >  clean_runtime_disable_ret:
> > 
> 
> I think, wouldn't it be logically more simple to just keep CPSW PM
> runtime enabled during probe?

Indeed it would. I'll do that in a v2.

Thanks,
Johan
