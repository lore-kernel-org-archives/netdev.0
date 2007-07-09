From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 03/05]: sch_dsmark: act_api support
Date: Mon,  9 Jul 2007 22:46:16 +0200 (MEST)
Message-ID: <20070709204616.1461.15284.sendpatchset@localhost.localdomain>
References: <20070709204611.1461.16465.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41512 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754962AbXGIUqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 16:46:17 -0400
In-Reply-To: <20070709204611.1461.16465.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: sch_dsmark: act_api support

Handle act_api classification results.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 57dbe6717456e774fc1163d801eab312d7c092e5
tree 12daa5c379f9dd30fb59b262a00dafbe6650299f
parent c7c3ff564b59bfb21aadd54cabab9369f120eaba
author Patrick McHardy <kaber@trash.net> Mon, 09 Jul 2007 22:03:51 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 09 Jul 2007 22:03:51 +0200

 net/sched/sch_dsmark.c |   41 +++++++++++++++++++++++++----------------
 1 files changed, 25 insertions(+), 16 deletions(-)

diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 4d2c233..2d7e891 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -237,25 +237,34 @@ static int dsmark_enqueue(struct sk_buff *skb,struct Qdisc *sch)
 		D2PRINTK("result %d class 0x%04x\n", result, res.classid);
 
 		switch (result) {
-#ifdef CONFIG_NET_CLS_POLICE
-			case TC_POLICE_SHOT:
-				kfree_skb(skb);
-				sch->qstats.drops++;
-				return NET_XMIT_POLICED;
+#ifdef CONFIG_NET_CLS_ACT
+		case TC_ACT_QUEUED:
+		case TC_ACT_STOLEN:
+			kfree_skb(skb);
+			return NET_XMIT_SUCCESS;
+		case TC_ACT_SHOT:
+			kfree_skb(skb);
+			sch->qstats.drops++;
+			return NET_XMIT_BYPASS;
+#elif defined(CONFIG_NET_CLS_POLICE)
+		case TC_POLICE_SHOT:
+			kfree_skb(skb);
+			sch->qstats.drops++;
+			return NET_XMIT_POLICED;
 #if 0
-			case TC_POLICE_RECLASSIFY:
-				/* FIXME: what to do here ??? */
+		case TC_POLICE_RECLASSIFY:
+			/* FIXME: what to do here ??? */
 #endif
 #endif
-			case TC_POLICE_OK:
-				skb->tc_index = TC_H_MIN(res.classid);
-				break;
-			case TC_POLICE_UNSPEC:
-				/* fall through */
-			default:
-				if (p->default_index != NO_DEFAULT_INDEX)
-					skb->tc_index = p->default_index;
-				break;
+		case TC_POLICE_OK:
+			skb->tc_index = TC_H_MIN(res.classid);
+			break;
+		case TC_POLICE_UNSPEC:
+			/* fall through */
+		default:
+			if (p->default_index != NO_DEFAULT_INDEX)
+				skb->tc_index = p->default_index;
+			break;
 		}
 	}
 
