From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH 4/6] [NET-NEXT]qlge: Cleanup chip reset path.
Date: Tue, 14 Oct 2008 13:31:36 -0700
Message-ID: <20081014203136.GB27393@susedev.qlogic.org>
References: <20081011171614.GA26384@susedev.qlogic.org> <1223745433-26440-4-git-send-email-ron.mercer@qlogic.com> <20081011213000.GB29496@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-driver@qlogic.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:49240 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716AbYJNUbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 16:31:46 -0400
Content-Disposition: inline
In-Reply-To: <20081011213000.GB29496@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 11, 2008 at 11:30:00PM +0200, Francois Romieu wrote:
> Ron Mercer <ron.mercer@qlogic.com> :
> [...]
> > diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
> > index c257546..1788e5c 100755
> > --- a/drivers/net/qlge/qlge_main.c
> > +++ b/drivers/net/qlge/qlge_main.c
> [...]
> > @@ -3471,14 +3449,29 @@ static int qlge_set_mac_address(struct net_device *ndev, void *p)
> >  static void qlge_tx_timeout(struct net_device *ndev)
> >  {
> >  	struct ql_adapter *qdev = (struct ql_adapter *)netdev_priv(ndev);
> > -	queue_delayed_work(qdev->workqueue, &qdev->asic_reset_work, 0);
> > +	ql_queue_asic_error(qdev);
> >  }
> >  
> >  static void ql_asic_reset_work(struct work_struct *work)
> >  {
> >  	struct ql_adapter *qdev =
> >  	    container_of(work, struct ql_adapter, asic_reset_work.work);
> > -	ql_cycle_adapter(qdev);
> > +	int status;
> > +
> > +	status = ql_adapter_down(qdev);
> > +	if (status)
> > +		goto error;
> > +
> > +	status = ql_adapter_up(qdev);
> > +	if (status)
> > +		goto error;
> > +	return;
> > +error:
> > +	QPRINTK(qdev, IFUP, ALERT,
> > +		"Driver up/down cycle failed, closing device\n");
> > +	rtnl_lock();
> > +	dev_close(qdev->ndev);
> > +	rtnl_unlock();
> 
> ql_asic_reset_work
> -> dev_close
>    -> qlge_close
>       -> ql_adapter_down
>          -> cancel_delayed_work_sync(&qdev->asic_reset_work);
>             -> __cancel_work_timer
>                -> wait_on_work
>                   -> wait_on_cpu_work
>                      -> wait_for_completion
> 
> Imho it will wait forever.

Francois,
Thanks for your input.  I think you are correct and believe I've fixed this though I need to
test the scenario you've pointed out.
Cheers,
Ron


> 
> -- 
> Ueimor
