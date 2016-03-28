From: Neil Horman <nhorman@redhat.com>
Subject: Re: [PATCH v2] netpoll: Fix extra refcount release in
 netpoll_cleanup()
Date: Mon, 28 Mar 2016 09:18:34 -0400
Message-ID: <20160328131834.GA8419@hmsreliant.think-freely.org>
References: <20160325025621.32476.93348.stgit@bhelgaas-glaptop2.roam.corp.google.com>
 <20160325113342.GA21579@hmsreliant.think-freely.org>
 <20160325164639.GA29822@localhost>
 <20160325.151636.590435237623997861.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: helgaas@kernel.org, bhelgaas@google.com,
	nikolay@cumulusnetworks.com, netdev@vger.kernel.org,
	aduyck@mirantis.com, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55147 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752306AbcC1NSh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2016 09:18:37 -0400
Content-Disposition: inline
In-Reply-To: <20160325.151636.590435237623997861.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 25, 2016 at 03:16:36PM -0400, David Miller wrote:
> From: Bjorn Helgaas <helgaas@kernel.org>
> Date: Fri, 25 Mar 2016 11:46:39 -0500
> 
> > You're right, there is an issue here.  I reproduced a problem with a
> > bond device.  bond_netpoll_setup() calls __netpoll_setup() directly
> > (not netpoll_setup()).  I'll debug it more; just wanted to let you
> > know there *is* a problem with this patch.
> 
> I bet that's why the assignment to np->dev and the reference counting
> were separated in the first place :-/
> 
> Indeed, commit 30fdd8a082a00126a6feec994e43e8dc12f5bccb:
> 
> commit 30fdd8a082a00126a6feec994e43e8dc12f5bccb
> Author: Jiri Pirko <jiri@resnulli.us>
> Date:   Tue Jul 17 05:22:35 2012 +0000
> 
>     netpoll: move np->dev and np->dev_name init into __netpoll_setup()
>     
>     Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

We probably just want to balance the setting/clearing of np->dev in
__netpoll_setup, so that any error return (that would result in a drop of the
refcount in netpoll_setup) correlates to a setting of np->dev to NULL in
__netpoll_setup. That leaves us with the problem of having to watch for future
imbalances as you mentioned previously Dave, but it seems a potential problem
tomorrow is preferable to an actual problem today.

Another option would be to move the dev_hold/put into __netpoll_setup, but doing
so would I think require some additional refactoring in netpoll_setup.  Namely
that we would still need a dev_hold/put in netpoll_setup to prevent the device
from being removed during the period where we release the rtnl lock in the if
(!netif_running(ndev)) clause. We would have to hold the device, unlock rtnl,
then put the device after re-aquiring rtnl at the end of that if block.

Neil
