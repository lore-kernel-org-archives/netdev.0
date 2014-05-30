From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] cnic: don't take the rtnl_read_lock in cnic_rcv_netevent
Date: Fri, 30 May 2014 16:38:23 -0400
Message-ID: <20140530203823.GH3144@hmsreliant.think-freely.org>
References: <1401462019-7958-1-git-send-email-nhorman@tuxdriver.com>
 <1401472691.9728.145.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <20140530200311.GG3144@hmsreliant.think-freely.org>
 <1401480820.9728.148.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	fcoe-devel@open-fcoe.org, Robert Love <robert.w.love@intel.com>,
	Vasu Dev <vasu.dev@intel.com>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38757 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754611AbaE3Uib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 16:38:31 -0400
Content-Disposition: inline
In-Reply-To: <1401480820.9728.148.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 30, 2014 at 01:13:40PM -0700, Michael Chan wrote:
> On Fri, 2014-05-30 at 16:03 -0400, Neil Horman wrote: 
> > On Fri, May 30, 2014 at 10:58:11AM -0700, Michael Chan wrote:
> > > On Fri, 2014-05-30 at 11:00 -0400, Neil Horman wrote: 
> > > > The Cnic driver handles lots of ulp operations in its netdevice event hanlder.
> > > > To do this, it accesses the ulp_ops array, which is an rcu protected array.
> > > > However, some ulp operations (like bnx2fc_indicate_netevent) try to lock
> > > > mutexes, which might sleep (somthing that you can't do while holding rcu read
> > > > side locks if you've configured non-preemptive rcu.
> > > > 
> > > > Fix this by changing the dereference method.  All accesses to the ulp_ops array
> > > > for a cnic dev are modified under the protection of the rtnl lock, and so we can
> > > > safely just use rcu_dereference_rtnl, and remove the rcu_read_lock here
> > > 
> > > Because the bnx2fc function can sleep, we need a more complete fix to
> > > prevent the ulp_ops from going away when the device is unregistered.
> > > synchronize_rcu() won't be able to protect it.  I'll post the patch
> > > later today.  Thanks.
> > > 
> > The device can't be unregistered while we hold rtnl, can it?  Since we hold it
> > in this path it seems safe to me, even if we sleep, or am I missing something?
> > Neil
> > 
> The netdev cannot be unregistered of course, but I am talking about
> bnx2fc unregistering the cnic device.  For example if someone does
> fcoeadm -d or bnx2fc gets unloaded.

I don't think the latter can happen, as creating an fcoe transport places a hold
on the bnx2fc module (see bnx2fc_create), and the former operation (fcoeadm -d)
will block in bnx2fc_destroy as it requires holding the rtnl_lock, which will
already be held by the netevent notifer, and confirmed by the
rcu_dereference_rtnl in my patch.

I really think we're safe here
Neil

> > 
> 
> 
