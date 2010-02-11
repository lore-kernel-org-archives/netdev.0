From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next-2.6 PATCH v5 0/3] Introduce n-tuple ethtool support
Date: Wed, 10 Feb 2010 20:18:33 -0800
Message-ID: <1265861913.4501.6.camel@localhost>
References: <20100211020310.23436.85885.stgit@localhost.localdomain>
	 <20100210.195445.190157100.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:60326 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755724Ab0BKESc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2010 23:18:32 -0500
In-Reply-To: <20100210.195445.190157100.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-02-10 at 19:54 -0800, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Wed, 10 Feb 2010 18:07:18 -0800
> 
> > One more round of fixes, based on feedback from Patrick McHardy
> > 
> > 1) Change the list count to an unsigned value
> > 2) Fix a memory leak
> > 3) Removed an unnecessary list traversal in the ethtool core
> > 4) Moved all list destruction to a helper function, allowing the driver
> > to control when it clears the list (aside from when free_netdev() kills
> > the cached list).
> 
> All applied, thanks.
> 
> Pj, can you look a shoring up the behavior of one more thing for me?
> 
> When rules get added, it first installs the filter by calling into
> the driver.
> 
> _Then_ is tries to add the software copy of the rule to the device
> list.  This does an allocation which may fail.
> 
> If it does fail, we return -ENOMEM but we left the device configured
> with the new rule.
> 
> Probably better to do it something like:
> 
> 	p = NULL;
> 	if (need_sw_rule_list)
> 		p = alloc_rule();
> 		if (!p)
> 			return -ENOMEM;
> 	}
> 
> 	ret = op->install_rule();
> 	if (ret) {
> 		kfree(p);
> 		return ret;
> 	}
> 	
> 	if (need_sw_rule_list)
> 		sw_rule_insert(dev, p);
> 
> You get the idea, we can do the kfree() unconditonally because kfree(NULL)
> is OK, etc.

No problem.  I'll get a patch together asap for 2.6.34.

Also, probably for 2.6.35, I'm going to try and add a remove capability.

Cheers,
-PJ

