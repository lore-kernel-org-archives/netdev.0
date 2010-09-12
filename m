From: David Miller <davem@davemloft.net>
Subject: Re: sch_atm: null dereference
Date: Sun, 12 Sep 2010 11:57:43 -0700 (PDT)
Message-ID: <20100912.115743.226782545.davem@davemloft.net>
References: <4C823DA0.3050203@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jirislaby@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57455
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753672Ab0ILS5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Sep 2010 14:57:25 -0400
In-Reply-To: <4C823DA0.3050203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jirislaby@gmail.com>
Date: Sat, 04 Sep 2010 14:37:52 +0200

> stanse found a potential null dereference:
> atm_tc_change
>   -> if (flow)
>     -> return -EBUSY;
>   -> flow is NULL now
>   -> if (classid)
>     -> if (!list_empty(&flow->list))
> 
> Introduced probably in
>     sch_atm: Convert to use standard list_head facilities.
> 
> Could you fix that?

Technically it's an unnecessary test that's been there forever.

I've applied the following to net-2.6, thanks!

--------------------
sch_atm: Fix potential NULL deref.

The list_head conversion unearther an unnecessary flow
check.  Since flow is always NULL here we don't need to
see if a matching flow exists already.

Reported-by: Jiri Slaby <jirislaby@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_atm.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 3406627..6318e11 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -255,10 +255,6 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 			error = -EINVAL;
 			goto err_out;
 		}
-		if (!list_empty(&flow->list)) {
-			error = -EEXIST;
-			goto err_out;
-		}
 	} else {
 		int i;
 		unsigned long cl;
-- 
1.7.2.2

