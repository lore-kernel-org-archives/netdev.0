From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 3/4] 8139too: RTNL and flush_scheduled_work deadlock
Date: Fri, 16 Feb 2007 12:36:05 -0800
Message-ID: <20070216123605.56e697ac@freekitty>
References: <20070215223744.GC19840@electric-eye.fr.zoreil.com>
	<20070216075936.GB1599@ff.dom.local>
	<20070216202034.GA10353@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>, jeff@garzik.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	Ben Greear <greearb@candelatech.com>,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34895 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946093AbXBPUnG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 15:43:06 -0500
In-Reply-To: <20070216202034.GA10353@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 16 Feb 2007 21:20:34 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Jarek Poplawski <jarkao2@o2.pl> :
> [...]
> > > diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
> > > index 35ad5cf..99304b2 100644
> > > --- a/drivers/net/8139too.c
> > > +++ b/drivers/net/8139too.c
> > > @@ -1109,6 +1109,8 @@ static void __devexit rtl8139_remove_one (struct pci_dev *pdev)
> > >  
> > >  	assert (dev != NULL);
> > >  
> > > +	flush_scheduled_work();
> > > +
> > 
> > IMHO there should be rather cancel_rearming_delayed_work
> > instead of this.
> 
> The delayed_work is initialized even if tp->have_thread is false,
> so cancel_rearming_delayed_work() will work, yes. Feel free to
> send a patch.
> 
> [...]
> > > @@ -1603,18 +1605,21 @@ static void rtl8139_thread (struct work_struct *work)
> > >  	struct net_device *dev = tp->mii.dev;
> > >  	unsigned long thr_delay = next_tick;
> > >  
> > > +	rtnl_lock();
> > > +
> > > +	if (!netif_running(dev))
> > > +		goto out_unlock;
> > 
> > I wonder, why you don't do netif_running before
> > rtnl_lock ? It's an atomic operation. And I'm not sure if increasing
> > rtnl_lock range is really needed here.
> 
> thread    A: netif_running()
> user task B: rtnl_lock()
> user task B: dev->close()
> user task B: rtnl_unlock()
> thread    A: rtnl_lock()
> thread    A: mess with closed device
> 
> Btw, the thread runs every 3*HZ at most.

You need to hold a dev reference (dev_hold) as well. to keep the device
from disappearing. or do a flush_scheduled_work in the remove routine.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
