From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] e1000e: write protect ICHx NVM to prevent malicious
 write/erase
Date: Wed, 1 Oct 2008 17:42:02 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0810011731350.3341@nehalem.linux-foundation.org>
References: <20081002001830.5951.3123.stgit@jbrandeb-bw.jf.intel.com> <20081002001835.5951.82533.stgit@jbrandeb-bw.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jeff@garzik.org, davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, arjan@linux.intel.com,
	Bruce Allan <bruce.w.allan@intel.com>, arjan@linux.intel.com
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47613 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751846AbYJBAol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 20:44:41 -0400
In-Reply-To: <20081002001835.5951.82533.stgit@jbrandeb-bw.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 1 Oct 2008, Jesse Brandeburg wrote:
>
> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Set the hardware to ignore all write/erase cycles to the GbE region in
> the ICHx NVM.  This feature can be disabled by the WriteProtectNVM module
> parameter (enabled by default) only after a hardware reset, but
> the machine must be power cycled before trying to enable writes.

Thanks, applied.

One thing that I did notice when I looked at the driver is that I don't 
see any serialization what-so-ever around a lot of the special accesses.

There's all these different routines that do

	ret_val = e1000_acquire_swflag_ich8lan(hw);
	if (ret_val)
		return retval;
	...
	e1000_release_swflag_ich8lan(hw);


but as far as I can tell, there is absolutely _nothing_ that prevents 
these from being done concurrently by software. 

Yeah, yeah, I'm sure most of them end up being single-threaded and only 
called over the probe sequence (well, at least I _hope_ so), but it sure 
isn't obvious. People call e1000_read_nvm() from various different 
contexts, and I'm not seeing what - if anything - protects two concurrent 
ethtool queries, for example.

Imagine that you run ethtool concurrently (even on a UP machine with 
preemption of just a sleeping op), and tell me that having two 
e1000_acquire_swflag_ich8lan/e1000_release_swflag_ich8lan sequences nest 
(or overlap) works. I don't think it does.

That E1000_EXTCNF_CTRL_SWFLAG is _not_ a lock against other threads, it's 
purely a lock against the hardware itself. And maybe I'm missing some 
locking, but I can't see it.

Same goes for the PHY accesses etc afaik. Hmm?

		Linus
