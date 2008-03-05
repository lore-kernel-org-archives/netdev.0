From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: E1000:   e1000_update_stats()
Date: Wed, 05 Mar 2008 13:34:44 -0800
Message-ID: <47CF11F4.6030207@intel.com>
References: <67F3071335CB9945A6047FE06957E0240D6D94CE93@exchange.rivulet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Todd Tomaino <ttomaino@rivulet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10654 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753374AbYCEVjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 16:39:18 -0500
In-Reply-To: <67F3071335CB9945A6047FE06957E0240D6D94CE93@exchange.rivulet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[ Adding netdev@vger.kernel.org !]

Todd Tomaino wrote:
> 
> I have been having trouble with interrupt latencies.  While profiling my system, I measured the e1000_update_stats() function disabling interrupts for roughly 100 usec.  For my application, this long of a delay results in data loss.  The e1000_update_stats() function is broken down into 3 main operations:
> 
> 1. acquire spinlock
> 2. read registers & update adapter->stat counters
> 3. update OS adapter->net_stats statistics
> 4. update phy stats.
> 5. release spinlock.
> 
> On my system I measured 57 usec to perform operations #2 and #3, and 52 usec to perform operation #4.
> 
> Reading the comments in the code it appeared that updating adapter->net_stats and adapter->stat required interrupts to be turned off to prevent the e1000_adjust_tbi_stats() function from modifying these structures from interrupt context.  In order to reduce the amount of time spent with interrupts disabled I separated the register reads from updating adapter->stat counters.  The register reads take up the bulk of the 57 usec and shouldn't require protection (I could be wrong).  The new operation looks like this and reduces the amount of time spent with interrupts turned off by 1/2:
> 
> 1. read registers
> 2. acquire spinlock
> 3. update adapter->stat counters
> 4. update OS adapter->net_stats statistics
> 5. update phy stats.
> 6. release spinlock.
> 
> 
> It seemed like a bad idea to attempt to move the phy reads out of the spin locked code area.
> 
> These changes have greatly reduced my interrupt latency, but are there any negative side effects that could be caused??

not per se, I think you did the right thing here. I think it might even be safe to
move the PHY reads outside the spinlock area, and this is certainly something I
would like to try.

would you care to send an RFC patch to netdev@vger.kernel.org?

Also, I notice you are using an old driver/kernel. care to retest against the
latest git trees?

I'll certainly take your suggestion and have it tested.

Auke
