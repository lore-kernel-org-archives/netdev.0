From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2.4 PKT_SCHED] Report qdisc parent to userspace
Date: Wed, 29 Sep 2004 02:01:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929000150.GA9113@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Report parent classid of a qdisc back to userspace. Without this there
is no way for userspace to see if the qdisc is attached to a class
other than parsing all class trees of the link and check all tcm_info
fields in the leaf classes.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.4.28-pre3-bk4.orig/include/net/pkt_sched.h	2004-09-29 00:42:01.000000000 +0200
+++ linux-2.4.28-pre3-bk4/include/net/pkt_sched.h	2004-09-29 00:54:46.000000000 +0200
@@ -81,6 +81,7 @@
 #define TCQ_F_INGRES	4
 	struct Qdisc_ops	*ops;
 	u32			handle;
+	u32			parent;
 	atomic_t		refcnt;
 	struct sk_buff_head	q;
 	struct net_device	*dev;
--- linux-2.4.28-pre3-bk4.orig/net/sched/sch_api.c	2004-09-29 00:42:03.000000000 +0200
+++ linux-2.4.28-pre3-bk4/net/sched/sch_api.c	2004-09-29 00:59:36.000000000 +0200
@@ -371,6 +371,8 @@
 			unsigned long cl = cops->get(parent, classid);
 			if (cl) {
 				err = cops->graft(parent, cl, new, old);
+				if (new)
+					new->parent = classid;
 				cops->put(parent, cl);
 			}
 		}
@@ -812,7 +814,7 @@
 				q_idx++;
 				continue;
 			}
-			if (tc_fill_qdisc(skb, q, 0, NETLINK_CB(cb->skb).pid,
+			if (tc_fill_qdisc(skb, q, q->parent, NETLINK_CB(cb->skb).pid,
 					  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC) <= 0) {
 				read_unlock(&qdisc_tree_lock);
 				goto done;
