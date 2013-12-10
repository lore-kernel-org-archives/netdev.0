From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] tipc: remove interface state mirroring in
 bearer
Date: Mon, 09 Dec 2013 20:31:24 -0500 (EST)
Message-ID: <20131209.203124.480496339513116139.davem@davemloft.net>
References: <1386342480-2382-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44868 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805Ab3LJBb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 20:31:26 -0500
In-Reply-To: <1386342480-2382-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Fri,  6 Dec 2013 10:08:00 -0500

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> struct 'tipc_bearer' is a generic representation of the underlying
> media type, and exists in a one-to-one relationship to each interface
> TIPC is using. The struct contains a 'blocked' flag that mirrors the
> operational and execution state of the represented interface, and is
> updated through notification calls from the latter. The users of
> tipc_bearer are checking this flag before each attempt to send a
> packet via the interface.
> 
> This state mirroring serves no purpose in the current code base. TIPC
> links will not discover a media failure any faster through this
> mechanism, and in reality the flag only adds overhead at packet
> sending and reception.
> 
> Furthermore, the fact that the flag needs to be protected by a spinlock
> aggregated into tipc_bearer has turned out to cause a serious and
> completely unnecessary deadlock problem.
 ...
> I.e., del_timer_sync() on CPU0 never returns, because the timer handler
> on CPU1 is waiting for the bearer lock.
> 
> We eliminate the 'blocked' flag from struct tipc_bearer, along with all
> tests on this flag. This not only resolves the deadlock, but also
> simplifies and speeds up the data path execution of TIPC. It also fits
> well into our ongoing effort to make the locking policy simpler and
> more manageable.
> 
> An effect of this change is that we can get rid of functions such as
> tipc_bearer_blocked(), tipc_continue() and tipc_block_bearer().
> We replace the latter with a new function, tipc_reset_bearer(), which
> resets all links associated to the bearer immediately after an
> interface goes down.
> 
> A user might notice one slight change in link behaviour after this
> change. When an interface goes down, (e.g. through a NETDEV_DOWN
> event) all attached links will be reset immediately, instead of
> leaving it to each link to detect the failure through a timer-driven
> mechanism. We consider this an improvement, and see no obvious risks
> with the new behavior.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Reviewed-by: Ying Xue <ying.xue@windriver.com>
> Reviewed-by: Paul Gortmaker <Paul.Gortmaker@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks.
