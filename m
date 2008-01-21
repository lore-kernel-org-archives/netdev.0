From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] dsmark: get rid of trivial function
Date: Mon, 21 Jan 2008 02:22:23 -0800 (PST)
Message-ID: <20080121.022223.85874858.davem@davemloft.net>
References: <20080120130542.16720b45@deepthought>
	<20080120132550.056370c0@deepthought>
	<4793E460.5020804@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49243
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763319AbYAUKWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 05:22:18 -0500
In-Reply-To: <4793E460.5020804@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 21 Jan 2008 01:16:32 +0100

> Stephen Hemminger wrote:
> > Replace loop in dsmark_valid_indices with equivalent bit math.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > --- a/net/sched/sch_dsmark.c	2008-01-20 13:07:58.000000000 -0800
> > +++ b/net/sched/sch_dsmark.c	2008-01-20 13:22:54.000000000 -0800
> > @@ -45,13 +45,8 @@ struct dsmark_qdisc_data {
> >  
> >  static inline int dsmark_valid_indices(u16 indices)
> >  {
> > -	while (indices != 1) {
> > -		if (indices & 1)
> > -			return 0;
> > -		indices >>= 1;
> > -	}
> > -
> > -	return 1;
> > +	/* Must have only one bit set */
> > +	return (indices & (indices - 1)) == 0;
> 
> hweight seems easier to understand, it took me a bit
> to realize that the comment matches the code :)

Sounds good.  Here is what I ended up checking in.

[PKT_SCHED] dsmark: Use hweight32() instead of convoluted loop.

Based upon a patch by Stephen Hemminger and suggestions
from Patrick McHardy.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index a9732ae..d96eaf0 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -10,6 +10,7 @@
 #include <linux/errno.h>
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
+#include <linux/bitops.h>
 #include <net/pkt_sched.h>
 #include <net/dsfield.h>
 #include <net/inet_ecn.h>
@@ -43,17 +44,6 @@ struct dsmark_qdisc_data {
 	int			set_tc_index;
 };
 
-static inline int dsmark_valid_indices(u16 indices)
-{
-	while (indices != 1) {
-		if (indices & 1)
-			return 0;
-		indices >>= 1;
-	}
-
-	return 1;
-}
-
 static inline int dsmark_valid_index(struct dsmark_qdisc_data *p, u16 index)
 {
 	return (index <= p->indices && index > 0);
@@ -348,7 +338,8 @@ static int dsmark_init(struct Qdisc *sch, struct rtattr *opt)
 		goto errout;
 
 	indices = RTA_GET_U16(tb[TCA_DSMARK_INDICES-1]);
-	if (!indices || !dsmark_valid_indices(indices))
+
+	if (hweight32(indices) != 1)
 		goto errout;
 
 	if (tb[TCA_DSMARK_DEFAULT_INDEX-1])
