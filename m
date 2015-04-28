From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net 4/4] netlink: add a flags field in the cb structure
Date: Tue, 28 Apr 2015 18:33:51 +0200
Message-ID: <1430238831-29966-5-git-send-email-nicolas.dichtel@6wind.com>
References: <1430238831-29966-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, dmitry.tarnyaginuug.ch@6wind.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:35204 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030529AbbD1QeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 12:34:12 -0400
In-Reply-To: <1430238831-29966-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this patch is to minimize copy and paste error. The flag
NLM_F_MULTI is often set in wrong cases because people copy and paste code
that uses this flag. When this flag is set, it means that it is a
multi-part netlink message which ends with a NLMSG_DONE.

In most of the cases, only a dump sends this NLMSG_DONE message. Let's set
this flag directly into the dump, hence people won't copy and paste
NLM_F_MULTI.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/netlink.h  | 1 +
 net/core/rtnetlink.c     | 9 ++++-----
 net/netlink/af_netlink.c | 1 +
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 6835c1279df7..0a29bd255639 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -129,6 +129,7 @@ struct netlink_callback {
 	u16			family;
 	u16			min_dump_alloc;
 	unsigned int		prev_seq, seq;
+	int			flags;
 	long			args[6];
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 666e0928ba40..837d30b5ffed 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1357,8 +1357,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 			err = rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
 					       NETLINK_CB(cb->skb).portid,
 					       cb->nlh->nlmsg_seq, 0,
-					       NLM_F_MULTI,
-					       ext_filter_mask);
+					       cb->flags, ext_filter_mask);
 			/* If we ran out of room on the first message,
 			 * we're in trouble
 			 */
@@ -2738,7 +2737,7 @@ static int nlmsg_populate_fdb(struct sk_buff *skb,
 		err = nlmsg_populate_fdb_fill(skb, dev, ha->addr, 0,
 					      portid, seq,
 					      RTM_NEWNEIGH, NTF_SELF,
-					      NLM_F_MULTI);
+					      cb->flags);
 		if (err < 0)
 			return err;
 skip:
@@ -2970,7 +2969,7 @@ static int rtnl_bridge_getlink(struct sk_buff *skb, struct netlink_callback *cb)
 			if (idx >= cb->args[0] &&
 			    br_dev->netdev_ops->ndo_bridge_getlink(
 				    skb, portid, seq, dev, filter_mask,
-				    NLM_F_MULTI) < 0)
+				    cb->flags) < 0)
 				break;
 			idx++;
 		}
@@ -2979,7 +2978,7 @@ static int rtnl_bridge_getlink(struct sk_buff *skb, struct netlink_callback *cb)
 			if (idx >= cb->args[0] &&
 			    ops->ndo_bridge_getlink(skb, portid, seq, dev,
 						    filter_mask,
-						    NLM_F_MULTI) < 0)
+						    cb->flags) < 0)
 				break;
 			idx++;
 		}
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ec4adbdcb9b4..3e2d29703499 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2755,6 +2755,7 @@ int __netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	cb->module = control->module;
 	cb->min_dump_alloc = control->min_dump_alloc;
 	cb->skb = skb;
+	cb->flags = NLM_F_MULTI;
 
 	nlk->cb_running = true;
 
-- 
2.2.2
