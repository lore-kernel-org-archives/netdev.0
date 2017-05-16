From: David Ahern <dsahern@gmail.com>
Subject: [PATCH] net: Improve handling of failures on link and route dumps
Date: Mon, 15 May 2017 23:19:17 -0700
Message-ID: <20170516061917.8128-1-dsahern@gmail.com>
Cc: mq@ucw.cz, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34035 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751349AbdEPGUb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 02:20:31 -0400
Received: by mail-pf0-f195.google.com with SMTP id w69so18747416pfk.1
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 23:20:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In general, rtnetlink dumps do not anticipate failure to dump a single
object (e.g., link or route) on a single pass. As both route and link
objects have grown via more attributes, that is no longer a given.

netlink dumps can handle a failure if the dump function returns an
error; specifically, netlink_dump adds the return code to the response
if it is <= 0 so userspace is notified of the failure. The missing
piece is the rtnetlink dump functions returning the error.

Fix route and link dump functions to return the errors if no object is
added to an skb (detected by skb->len != 0). IPv6 route dumps
(rt6_dump_route) already return the error; this patch updates IPv4 and
link dumps. Other dump functions may need to be ajusted as well.

Reported-by: Jan Moskyto Matejka <mq@ucw.cz>
Signed-off-by: David Ahern <dsahern@gmail.com>
---
The recent IPv6 multipath change brought this to light because of the
ease at which ipv6 route appends can exceed a buffer size, but it seems
to be a day 1 problem.

 net/core/rtnetlink.c    | 36 ++++++++++++++++++++++++------------
 net/ipv4/fib_frontend.c | 15 +++++++++++----
 net/ipv4/fib_trie.c     | 26 ++++++++++++++------------
 3 files changed, 49 insertions(+), 28 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d7f82c3450b1..49a279a7cc15 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1627,13 +1627,13 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 					       cb->nlh->nlmsg_seq, 0,
 					       flags,
 					       ext_filter_mask);
-			/* If we ran out of room on the first message,
-			 * we're in trouble
-			 */
-			WARN_ON((err == -EMSGSIZE) && (skb->len == 0));
 
-			if (err < 0)
-				goto out;
+			if (err < 0) {
+				if (likely(skb->len))
+					goto out;
+
+				goto out_err;
+			}
 
 			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
 cont:
@@ -1641,10 +1641,12 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 		}
 	}
 out:
+	err = skb->len;
+out_err:
 	cb->args[1] = idx;
 	cb->args[0] = h;
 
-	return skb->len;
+	return err;
 }
 
 int rtnl_nla_parse_ifla(struct nlattr **tb, const struct nlattr *head, int len,
@@ -3453,8 +3455,12 @@ static int rtnl_bridge_getlink(struct sk_buff *skb, struct netlink_callback *cb)
 				err = br_dev->netdev_ops->ndo_bridge_getlink(
 						skb, portid, seq, dev,
 						filter_mask, NLM_F_MULTI);
-				if (err < 0 && err != -EOPNOTSUPP)
-					break;
+				if (err < 0 && err != -EOPNOTSUPP) {
+					if (likely(skb->len))
+						break;
+
+					goto out_err;
+				}
 			}
 			idx++;
 		}
@@ -3465,16 +3471,22 @@ static int rtnl_bridge_getlink(struct sk_buff *skb, struct netlink_callback *cb)
 							      seq, dev,
 							      filter_mask,
 							      NLM_F_MULTI);
-				if (err < 0 && err != -EOPNOTSUPP)
-					break;
+				if (err < 0 && err != -EOPNOTSUPP) {
+					if (likely(skb->len))
+						break;
+
+					goto out_err;
+				}
 			}
 			idx++;
 		}
 	}
+	err = skb->len;
+out_err:
 	rcu_read_unlock();
 	cb->args[0] = idx;
 
-	return skb->len;
+	return err;
 }
 
 static inline size_t bridge_nlmsg_size(void)
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 39bd1edee676..83e3ed258467 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -763,7 +763,7 @@ static int inet_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 	unsigned int e = 0, s_e;
 	struct fib_table *tb;
 	struct hlist_head *head;
-	int dumped = 0;
+	int dumped = 0, err;
 
 	if (nlmsg_len(cb->nlh) >= sizeof(struct rtmsg) &&
 	    ((struct rtmsg *) nlmsg_data(cb->nlh))->rtm_flags & RTM_F_CLONED)
@@ -783,20 +783,27 @@ static int inet_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 			if (dumped)
 				memset(&cb->args[2], 0, sizeof(cb->args) -
 						 2 * sizeof(cb->args[0]));
-			if (fib_table_dump(tb, skb, cb) < 0)
-				goto out;
+			err = fib_table_dump(tb, skb, cb);
+			if (err < 0) {
+				if (likely(skb->len))
+					goto out;
+
+				goto out_err;
+			}
 			dumped = 1;
 next:
 			e++;
 		}
 	}
 out:
+	err = skb->len;
+out_err:
 	rcu_read_unlock();
 
 	cb->args[1] = e;
 	cb->args[0] = h;
 
-	return skb->len;
+	return err;
 }
 
 /* Prepare and feed intra-kernel routing request.
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 1201409ba1dc..51182ff2b441 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1983,6 +1983,8 @@ static int fn_trie_dump_leaf(struct key_vector *l, struct fib_table *tb,
 
 	/* rcu_read_lock is hold by caller */
 	hlist_for_each_entry_rcu(fa, &l->leaf, fa_list) {
+		int err;
+
 		if (i < s_i) {
 			i++;
 			continue;
@@ -1993,17 +1995,14 @@ static int fn_trie_dump_leaf(struct key_vector *l, struct fib_table *tb,
 			continue;
 		}
 
-		if (fib_dump_info(skb, NETLINK_CB(cb->skb).portid,
-				  cb->nlh->nlmsg_seq,
-				  RTM_NEWROUTE,
-				  tb->tb_id,
-				  fa->fa_type,
-				  xkey,
-				  KEYLENGTH - fa->fa_slen,
-				  fa->fa_tos,
-				  fa->fa_info, NLM_F_MULTI) < 0) {
+		err = fib_dump_info(skb, NETLINK_CB(cb->skb).portid,
+				    cb->nlh->nlmsg_seq, RTM_NEWROUTE,
+				    tb->tb_id, fa->fa_type,
+				    xkey, KEYLENGTH - fa->fa_slen,
+				    fa->fa_tos, fa->fa_info, NLM_F_MULTI);
+		if (err < 0) {
 			cb->args[4] = i;
-			return -1;
+			return err;
 		}
 		i++;
 	}
@@ -2025,10 +2024,13 @@ int fib_table_dump(struct fib_table *tb, struct sk_buff *skb,
 	t_key key = cb->args[3];
 
 	while ((l = leaf_walk_rcu(&tp, key)) != NULL) {
-		if (fn_trie_dump_leaf(l, tb, skb, cb) < 0) {
+		int err;
+
+		err = fn_trie_dump_leaf(l, tb, skb, cb);
+		if (err < 0) {
 			cb->args[3] = key;
 			cb->args[2] = count;
-			return -1;
+			return err;
 		}
 
 		++count;
-- 
2.11.0 (Apple Git-81)
