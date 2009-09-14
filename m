From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: Fix qdisc_graft WRT ingress qdisc
Date: Mon, 14 Sep 2009 08:35:44 +0000
Message-ID: <20090914083544.GA10444@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:49180 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754471AbZINIfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 04:35:48 -0400
Received: by fxm17 with SMTP id 17so669851fxm.37
        for <netdev@vger.kernel.org>; Mon, 14 Sep 2009 01:35:51 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the recent mq change using ingress qdisc overwrites dev->qdisc;
there is also a wrong old qdisc pointer passed to notify_and_destroy.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_api.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 3af1061..c5a6d62 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -693,13 +693,18 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 			if (new && i > 0)
 				atomic_inc(&new->refcnt);
 
-			qdisc_destroy(old);
+			if (!ingress)
+				qdisc_destroy(old);
 		}
 
-		notify_and_destroy(skb, n, classid, dev->qdisc, new);
-		if (new && !new->ops->attach)
-			atomic_inc(&new->refcnt);
-		dev->qdisc = new ? : &noop_qdisc;
+		if (!ingress) {
+			notify_and_destroy(skb, n, classid, dev->qdisc, new);
+			if (new && !new->ops->attach)
+				atomic_inc(&new->refcnt);
+			dev->qdisc = new ? : &noop_qdisc;
+		} else {
+			notify_and_destroy(skb, n, classid, old, new);
+		}
 
 		if (dev->flags & IFF_UP)
 			dev_activate(dev);
