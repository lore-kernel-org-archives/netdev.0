From: Mike Galbraith <efault@gmx.de>
Subject: Re: net/sched: latent livelock in dev_deactivate_many() due to
 yield() usage
Date: Wed, 05 Apr 2017 05:20:29 +0200
Message-ID: <1491362429.4536.77.camel@gmx.de>
References: <1491107321.13631.33.camel@gmx.de>
         <CAM_iQpWGMkDaoV2k0DEghqeqb9k=MbpBtT8zH3tvENxLUCefkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Peter Zijlstra <peterz@infradead.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:51505 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751692AbdDEDU7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 23:20:59 -0400
In-Reply-To: <CAM_iQpWGMkDaoV2k0DEghqeqb9k=MbpBtT8zH3tvENxLUCefkQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-04 at 15:39 -0700, Cong Wang wrote:

> Thanks for the report! Looks like a quick solution here is to replace
> this yield() with cond_resched(), it is harder to really wait for
> all qdisc's to transmit all packets.

No, cond_resched() won't help.  What I did is below, but I suspect net
wizards will do something better.

---
 net/sched/sch_generic.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -16,6 +16,7 @@
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
+#include <linux/swait.h>
 #include <linux/string.h>
 #include <linux/errno.h>
 #include <linux/netdevice.h>
@@ -901,6 +902,7 @@ static bool some_qdisc_is_busy(struct ne
  */
 void dev_deactivate_many(struct list_head *head)
 {
+	DECLARE_SWAIT_QUEUE_HEAD_ONSTACK(swait);
 	struct net_device *dev;
 	bool sync_needed = false;
 
@@ -924,8 +926,7 @@ void dev_deactivate_many(struct list_hea
 
 	/* Wait for outstanding qdisc_run calls. */
 	list_for_each_entry(dev, head, close_list)
-		while (some_qdisc_is_busy(dev))
-			yield();
+		swait_event_timeout(swait, !some_qdisc_is_busy(dev), 1);
 }
 
 void dev_deactivate(struct net_device *dev)
