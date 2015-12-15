From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net_sched: make qdisc_tree_decrease_qlen() work for non
 mq
Date: Tue, 15 Dec 2015 09:43:12 -0800
Message-ID: <1450201392.8474.37.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stas Nichiporovich <stasn77@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35149 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932211AbbLORnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 12:43:14 -0500
Received: by mail-pf0-f182.google.com with SMTP id 63so8457629pff.2
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 09:43:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Stas Nichiporovich reported a regression in his HFSC qdisc setup
on a non multi queue device.

It turns out I mistakenly added a TCQ_F_NOPARENT flag on all qdisc
allocated in qdisc_create() for non multi queue devices, which was
rather buggy. I was clearly mislead by the TCQ_F_ONETXQUEUE that is
also set here for no good reason, since it only matters for the root
qdisc.

Fixes: 4eaf3b84f288 ("net_sched: fix qdisc_tree_decrease_qlen() races")
Reported-by: Stas Nichiporovich <stasn77@gmail.com>
Tested-by: Stas Nichiporovich <stasn77@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_api.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 7ec667dd4ce1..b5c2cf2aa6d4 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -950,7 +950,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 		}
 		lockdep_set_class(qdisc_lock(sch), &qdisc_tx_lock);
 		if (!netif_is_multiqueue(dev))
-			sch->flags |= TCQ_F_ONETXQUEUE | TCQ_F_NOPARENT;
+			sch->flags |= TCQ_F_ONETXQUEUE;
 	}
 
 	sch->handle = handle;
