From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v5 0/3] Introduce n-tuple ethtool support
Date: Wed, 10 Feb 2010 19:54:45 -0800 (PST)
Message-ID: <20100210.195445.190157100.davem@davemloft.net>
References: <20100211020310.23436.85885.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42182
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752327Ab0BKDye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 22:54:34 -0500
In-Reply-To: <20100211020310.23436.85885.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 10 Feb 2010 18:07:18 -0800

> One more round of fixes, based on feedback from Patrick McHardy
> 
> 1) Change the list count to an unsigned value
> 2) Fix a memory leak
> 3) Removed an unnecessary list traversal in the ethtool core
> 4) Moved all list destruction to a helper function, allowing the driver
> to control when it clears the list (aside from when free_netdev() kills
> the cached list).

All applied, thanks.

Pj, can you look a shoring up the behavior of one more thing for me?

When rules get added, it first installs the filter by calling into
the driver.

_Then_ is tries to add the software copy of the rule to the device
list.  This does an allocation which may fail.

If it does fail, we return -ENOMEM but we left the device configured
with the new rule.

Probably better to do it something like:

	p = NULL;
	if (need_sw_rule_list)
		p = alloc_rule();
		if (!p)
			return -ENOMEM;
	}

	ret = op->install_rule();
	if (ret) {
		kfree(p);
		return ret;
	}
	
	if (need_sw_rule_list)
		sw_rule_insert(dev, p);

You get the idea, we can do the kfree() unconditonally because kfree(NULL)
is OK, etc.

