From: Patrick McHardy <kaber@trash.net>
Subject: Re: HFSC classes going out of bounds, regression in recent kernels?
Date: Tue, 06 Apr 2010 17:37:39 +0200
Message-ID: <4BBB5543.40607@trash.net>
References: <201004061822.21735.nuclearcat@nuclearcat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000908060106030506020305"
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Denys Fedorysychenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60333 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754413Ab0DFPhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 11:37:40 -0400
In-Reply-To: <201004061822.21735.nuclearcat@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000908060106030506020305
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Denys Fedorysychenko wrote:
> I notice on one of my QoS machines that HFSC start going out of bandwidth 
> limits. The most terrible thing - it happens suddenly, and if i just relaunch 
> QoS script - everything will work fine.

That sounds like there's an overflow somewhere.

> I'm not sure it is not my mistake, but most probably it is a bug.
> I can't tell for sure when it is happened, last kernel was on this machine 
> 2.6.28 i guess, or maybe even older.

Looking through the recent patches in this area, my prime suspect
is the attached patch. Does reverting it make any difference?


--------------000908060106030506020305
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit a4a710c4a7490587406462bf1d54504b7783d7d7
Author: Jarek Poplawski <jarkao2@gmail.com>
Date:   Mon Jun 8 22:05:13 2009 +0000

    pkt_sched: Change PSCHED_SHIFT from 10 to 6
    
    Change PSCHED_SHIFT from 10 to 6 to increase schedulers time
    resolution. This will increase 16x a number of (internal) ticks per
    nanosecond, and is needed to improve accuracy of schedulers based on
    rate tables, like HTB, TBF or CBQ, with rates above 100Mbit. It is
    assumed this change is safe for 32bit accounting of time diffs up
    to 2 minutes, which should be enough for common use (extremely low
    rate values may overflow, so get inaccurate instead). To make full
    use of this change an updated iproute2 will be needed. (But using
    older iproute2 should be safe too.)
    
    This change breaks ticks - microseconds similarity, so some minor code
    fixes might be needed. It is also planned to change naming adequately
    eg. to PSCHED_TICKS2NS() etc. in the near future.
    
    Reported-by: Antonio Almeida <vexwek@gmail.com>
    Tested-by: Antonio Almeida <vexwek@gmail.com>
    Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index cd0e026..120935b 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -41,8 +41,8 @@ static inline void *qdisc_priv(struct Qdisc *q)
 typedef u64	psched_time_t;
 typedef long	psched_tdiff_t;
 
-/* Avoid doing 64 bit divide by 1000 */
-#define PSCHED_SHIFT			10
+/* Avoid doing 64 bit divide */
+#define PSCHED_SHIFT			6
 #define PSCHED_US2NS(x)			((s64)(x) << PSCHED_SHIFT)
 #define PSCHED_NS2US(x)			((x) >> PSCHED_SHIFT)
 

--------------000908060106030506020305--
