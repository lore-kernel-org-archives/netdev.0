From: Liang Li <liang.li@windriver.com>
Subject: Re: [v1 PATCH] ucc_geth: fix ethtool set ring param bug
Date: Thu, 2 Sep 2010 23:48:18 +0800
Message-ID: <20100902154818.GA30293@localhost>
References: <1283179677-21262-1-git-send-email-liang.li@windriver.com>
 <1283305429-8426-1-git-send-email-liang.li@windriver.com>
 <1283348550.2268.7.camel@achroite.uk.solarflarecom.com>
 <20100902005034.GA9901@localhost>
 <1283425907.2272.0.camel@achroite.uk.solarflarecom.com>
Reply-To: Liang Li <liang.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: leoli@freescale.com, davem@davemloft.net, avorontsov@ru.mvista.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:56169 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752433Ab0IBPqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 11:46:37 -0400
Content-Disposition: inline
In-Reply-To: <1283425907.2272.0.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 02, 2010 at 12:11:47PM +0100, Ben Hutchings wrote:
> On Thu, 2010-09-02 at 08:50 +0800, Liang Li wrote:
> > On Wed, Sep 01, 2010 at 02:42:30PM +0100, Ben Hutchings wrote:
> > > On Wed, 2010-09-01 at 09:43 +0800, Liang Li wrote:
> > > > It's common sense that when we should do change to driver ring
> > > > desc/buffer etc only after 'stop/shutdown' the device. When we
> > > > do change while devices/driver is running, kernel oops occur:
> > > [...]
> > > > -	ug_info->bdRingLenRx[queue] = ring->rx_pending;
> > > > -	ug_info->bdRingLenTx[queue] = ring->tx_pending;
> > > > -
> > > >  	if (netif_running(netdev)) {
> > > > -		/* FIXME: restart automatically */
> > > > -		printk(KERN_INFO
> > > > -			"Please re-open the interface.\n");
> > > > +		u16 rx_t;
> > > > +		u16 tx_t;
> > > > +		printk(KERN_INFO "Stopping interface %s.\n", netdev->name);
> > > > +		ucc_geth_close(netdev);
> > > > +
> > > > +		rx_t = ug_info->bdRingLenRx[queue];
> > > > +		tx_t = ug_info->bdRingLenTx[queue];
> > > > +
> > > > +		ug_info->bdRingLenRx[queue] = ring->rx_pending;
> > > > +		ug_info->bdRingLenTx[queue] = ring->tx_pending;
> > > > +
> > > > +		printk(KERN_INFO "Reactivating interface %s.\n", netdev->name);
> > > > +		ret = ucc_geth_open(netdev);
> > > > +		if (ret) {
> > > > +			printk(KERN_WARNING "uec_set_ringparam: set ring param for running"
> > > > +					" interface %s failed. Please try to make the interface "
> > > > +					" down, then try again.\n", netdev->name);
> > > > +			ug_info->bdRingLenRx[queue] = rx_t;
> > > > +			ug_info->bdRingLenTx[queue] = tx_t;
> > > > +		}
> > > [...]
> > > 
> > > Bringing the interface down will call ucc_geth_close(), which will try
> > > to free resources that have not been allocated!
> > 
> > Sorry, I did not understand you on this point. There is no
> > ucc_geth_close when 'open fail'. What you mean here exactly?
> [...]
> 
> Read your own warning.

So the warning is mis-leading... We may not need it... Still, let's talk
about the rare case that 'fail of open', may you please show me what is
the right thing to do 'clean up work' when ever the open fail. Maybe
dev_close(net_dev)?

Thanks,
				-Liang Li

> 
> Ben.
> 
> -- 
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
