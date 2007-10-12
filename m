From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnl: Simplify ASSERT_RTNL
Date: Thu, 11 Oct 2007 17:30:46 -0700 (PDT)
Message-ID: <20071011.173046.66166737.davem@davemloft.net>
References: <m1hckyf4ag.fsf@ebiederm.dsl.xmission.com>
	<20071011082845.GA16527@gondor.apana.org.au>
	<m1tzoxehlo.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53326
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750827AbXJLAao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 20:30:44 -0400
In-Reply-To: <m1tzoxehlo.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 11 Oct 2007 10:33:39 -0600

> Having ASSERT_RTNL warn if you were sleeping does not seem
> intuitive from the name.
> 
> This instance of convoluted locking seems like a complete
> one off to me, and if it will warn about other constructs
> currently in the kernel it seems wrong.

RTNL is a semaphore, therefore it sleeps.

Therefore anything that requires RTNL is held can also assume that it
can do things like GFP_KERNEL allocations and other sleeping actions.

This is why any code path that runs with spinlocks held or interrupts
disabled, and hits an RTNL assertion, is buggy.  It is the chain of
dependencies of what is allowed in such contexts.

	ASSERT_RTNL();
	page = alloc_page(GFP_KERNEL);

That sequence above is absolutely always legal.

The might_sleep() check is just letting us know the problem exists.

If spinlocks or interrupt disabling is needed to implement something
deeper in the call chain, that's fine, it just cannot call back into
the RTNL asserted domain with those spinlocks held or interrupts
disabled.

If the mac_vlan driver, or whichever one has the problem, does things
like this it must be fixed and putting or not putting a proper
might_sleep() check here doesn't change that.
