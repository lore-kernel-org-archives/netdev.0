From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] mv643xx_eth: fix SMI bus access timeouts
Date: Sat, 1 Nov 2008 06:48:59 +0100
Message-ID: <20081101054859.GB13348@xi.wantstofly.org>
References: <20081101053220.GA13348@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:55041 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbYKAFtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2008 01:49:00 -0400
Content-Disposition: inline
In-Reply-To: <20081101053220.GA13348@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 01, 2008 at 06:32:20AM +0100, Lennert Buytenhek wrote:

> The mv643xx_eth mii bus implementation uses wait_event_timeout() to
> wait for SMI completion interrupts.
> 
> If wait_event_timeout() would return zero, mv643xx_eth would conclude
> that the SMI access timed out, but this is not necessarily true --
> wait_event_timeout() can also return zero in the case where the SMI
> completion interrupt did happen in time but where it took longer than
> the requested timeout for the process performing the SMI access to be
> scheduled again.  This would lead to occasional SMI access timeouts
> when the system would be under heavy load.

FWIW, where I've been seeing this is mostly during heavy softirq
load, e.g. when doing routing when the box can't keep up.

When the system is being hammered like this, simple things like
querying the switch chip for its statistics counters (by doing
"ethtool -S <switch interface>") can take seconds, since querying the
hardware switch stats consists of doing a lot of MII accesses, and
each of those MII accesses takes tens of milliseconds to return because
the issuer of the MII access goes to sleep after issuing the MII access
waiting for an MII done interrupt, but won't get scheduled again to
issue its next MII access until the rx softirq has decided that it has
done enough looping.

This patch makes it a lot more bearable -- but it's still only a bit
of a stopgap:


diff --git a/kernel/softirq.c b/kernel/softirq.c
index c506f26..f7fd630 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -215,7 +215,7 @@ restart:
 	local_irq_disable();
 
 	pending = local_softirq_pending();
-	if (pending && --max_restart)
+	if (pending && !need_resched() && --max_restart)
 		goto restart;
 
 	if (pending)
