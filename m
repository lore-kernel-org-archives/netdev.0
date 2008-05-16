From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Top kernel oopses/warnings for the week of May 16th 2008
Date: Fri, 16 May 2008 21:14:07 +0400
Message-ID: <20080516171407.GA1694@2ka.mipt.ru>
References: <482DB93B.2080100@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:41958 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750832AbYEPRXz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2008 13:23:55 -0400
Content-Disposition: inline
In-Reply-To: <482DB93B.2080100@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2008 at 09:41:31AM -0700, Arjan van de Ven (arjan@linux.intel.com) wrote:
> Rank 10: __alloc_pages
> 	Reported 16 times (31 total reports)
> 	Sleeping allocation in interrupt context, some in netlink, some in 
> 	the nv sata driver
> 	This oops was last seen in version 2.6.25.3, and first seen in 
> 	2.6.18-rc1.
> 	More info: 
> 	http://www.kerneloops.org/searchweek.php?search=__alloc_pages

Number of them from via-velocity driver should be fixed by attached
patch (added Francois Romieu <romieu@fr.zoreil.com> to copy), but
frankly that looks really bad. Allocations are protected by lock, which
is used for interrupts, but that is safe, since device is turned off,
but also for suspend (which can free them again, btw), mii register dump
(will break without lock) and something else, which should be fine
though because of rtnl. What we could do better, is to allocate new
rings in advance, and only substitue pointers and write registers under
the lock, Francois?

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 6b8d882..d6b7972 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1251,7 +1251,7 @@ static int velocity_init_rd_ring(struct velocity_info *vptr)
 	vptr->rx_buf_sz = (mtu <= ETH_DATA_LEN) ? PKT_BUF_SZ : mtu + 32;
 
 	vptr->rd_info = kcalloc(vptr->options.numrx,
-				sizeof(struct velocity_rd_info), GFP_KERNEL);
+				sizeof(struct velocity_rd_info), GFP_ATOMIC);
 	if (!vptr->rd_info)
 		return -ENOMEM;
 
@@ -1324,7 +1324,7 @@ static int velocity_init_td_ring(struct velocity_info *vptr)
 
 		vptr->td_infos[j] = kcalloc(vptr->options.numtx,
 					    sizeof(struct velocity_td_info),
-					    GFP_KERNEL);
+					    GFP_ATOMIC);
 		if (!vptr->td_infos[j])	{
 			while(--j >= 0)
 				kfree(vptr->td_infos[j]);


-- 
	Evgeniy Polyakov
