From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2.6 PKT_SCHED] Report qdisc parent to userspace
Date: Fri, 24 Sep 2004 14:37:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924123710.GB3944@postel.suug.ch>
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

Note: This has nothing to do with __parent.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc2-bk7.orig/include/net/pkt_sched.h	2004-09-21 23:26:54.000000000 +0200
+++ linux-2.6.9-rc2-bk7/include/net/pkt_sched.h	2004-09-24 14:15:36.000000000 +0200
@@ -80,6 +80,7 @@
 	int			padded;
 	struct Qdisc_ops	*ops;
 	u32			handle;
+	u32			parent;
 	atomic_t		refcnt;
 	struct sk_buff_head	q;
 	struct net_device	*dev;
--- linux-2.6.9-rc2-bk7.orig/net/sched/sch_api.c	2004-09-21 23:27:31.000000000 +0200
+++ linux-2.6.9-rc2-bk7/net/sched/sch_api.c	2004-09-24 13:56:03.000000000 +0200
@@ -702,10 +702,11 @@
 		return -ENOENT;
 	if (clid == TC_H_INGRESS)
 		q = qdisc_create(dev, tcm->tcm_parent, tca, &err);
-        else
+	else
 		q = qdisc_create(dev, tcm->tcm_handle, tca, &err);
 	if (q == NULL)
 		return err;
+	q->parent = clid;
 
 graft:
 	if (1) {
@@ -821,7 +822,7 @@
 				q_idx++;
 				continue;
 			}
-			if (tc_fill_qdisc(skb, q, 0, NETLINK_CB(cb->skb).pid,
+			if (tc_fill_qdisc(skb, q, q->parent, NETLINK_CB(cb->skb).pid,
 					  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC) <= 0) {
 				read_unlock_bh(&qdisc_tree_lock);
 				goto done;
