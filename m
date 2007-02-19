From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH 3/4] 8139too: RTNL and flush_scheduled_work deadlock
Date: Mon, 19 Feb 2007 13:05:00 +0100
Message-ID: <20070219120500.GB2190@ff.dom.local>
References: <20070215223744.GC19840@electric-eye.fr.zoreil.com> <20070216075936.GB1599@ff.dom.local> <20070216202034.GA10353@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	Ben Greear <greearb@candelatech.com>,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:52882 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932180AbXBSMBl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 07:01:41 -0500
Content-Disposition: inline
In-Reply-To: <20070216202034.GA10353@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 16, 2007 at 09:20:34PM +0100, Francois Romieu wrote:
> Jarek Poplawski <jarkao2@o2.pl> :
...
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

You are right (mostly)! But I think rtnl_lock is special
and should be spared (even this 3*HZ) and here it's used
for some mainly internal purpose (close synchronization).
And it looks like mainly for this internal reason holding
of rtnl_lock is increased. And because rtnl_lock is quite
popular you have to take into consideration that after
this 3*HZ it could spend some time waiting for the lock.
So, maybe it would be nicer to check this netif_running
twice (after rtnl_lock where needed), but maybe it's a
mater of taste only, and yours is better, as well.
(Btw. I didn't verify this, but I hope you checked that
places not under rtnl_lock before the patch are safe from
some locking problems now.)

Jarek P.
