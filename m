From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next v2] rocker: move netevent neigh update to
 processes context
Date: Thu, 4 Jun 2015 18:07:52 +0900
Message-ID: <20150604090749.GA18460@verge.net.au>
References: <1433303008-32656-1-git-send-email-sfeldma@gmail.com>
 <20150603.233829.1362177764562847830.davem@davemloft.net>
 <20150604082045.GA7709@vergenet.net>
 <20150604.013409.228829580818256337.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, jiri@resnulli.us,
	makita.toshiaki@lab.ntt.co.jp
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:50545 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685AbbFDJH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 05:07:57 -0400
Content-Disposition: inline
In-Reply-To: <20150604.013409.228829580818256337.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On Thu, Jun 04, 2015 at 01:34:09AM -0700, David Miller wrote:
> From: Simon Horman <simon.horman@netronome.com>
> Date: Thu, 4 Jun 2015 17:20:48 +0900
> 
> > What I was seeing is as follows:
> > 
> > 1. rocker_port_ipv4_nh() is called via switchdev_port_obj_add()
> >    with trans = SWITCHDEV_TRANS_PREPARE
> > 
> > 2. rocker_port_ipv4_neigh() is called by rocker_neigh_update()
> >    with trans = SWITCHDEV_TRANS_NONE.
> > 
> >    The call chain goes up to arp_process() via neigh_update().
> > 
> > 3. rocker_port_ipv4_nh() is called via switchdev_port_obj_add()
> >    with trans = SWITCHDEV_TRANS_COMMIT
> > 
> > #1 and #2 are guarded by rtl across those calls but
> > #2 is not guarded by rtnl.
> > 
> > Inside both rocker_port_ipv4_nh() and rocker_port_ipv4_neigh()
> > neigh_tbl_lock lock is taken but it is not held across the
> > two calls to rocker_port_ipv4_nh within a single prepare->commit transaction.
> > 
> > I can double check that the above still occurs, but I'm not aware of any
> > recent changes that would cause it not to occur any more.
> 
> Ok, thanks for explaining.
> 
> I still don't want this to be moved asynchronosly from the ARP neigh
> update event code path.
> 
> And therefore I'd like folks to look into another mechanism to fix
> this.
> 
> If that means the prepare/commit engine is given a spinlock by the
> driver to be held across the two calls, so be it.

I'm not opposed to such a scheme. But I'd like to note that it seems to me
that for it to resolve the problem above the lock would be need be held
both for "none" and "prepare->commit" transactions.  I think the former may
be a little tricky as it may occur in IRQ context but perhaps I am missing
something obvious.
