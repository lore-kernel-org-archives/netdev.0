From: Roland Dreier <roland@kernel.org>
Subject: [PATCH 3.19 and earlier] fib_rules: Fix dump_rules() not to exit early
Date: Mon,  5 Oct 2015 10:29:28 -0700
Message-ID: <1444066168-5566-1-git-send-email-roland@kernel.org>
Cc: Roland Dreier <roland@purestorage.com>
To: netdev@vger.kernel.org, stable@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <roland@purestorage.com>

Backports of 41fc014332d9 ("fib_rules: fix fib rule dumps across
multiple skbs") introduced a regression in "ip rule show" - it ends up
dumping the first rule over and over and never exiting, because 3.19
and earlier are missing commit 053c095a82cf ("netlink: make
nlmsg_end() and genlmsg_end() void"), so fib_nl_fill_rule() ends up
returning skb->len (i.e. > 0) in the success case.

Fix this by checking the return code for < 0 instead of != 0.

Signed-off-by: Roland Dreier <roland@purestorage.com>
---
Hi, this is needed for all stable trees earlier than 4.0 that have
picked up 41fc014332d9; so far looks like at least 3.10.y and 3.14.y
have made such releases.

 net/core/fib_rules.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 627e517077e4..84340a2605ed 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -606,7 +606,7 @@ static int dump_rules(struct sk_buff *skb, struct netlink_callback *cb,
 		err = fib_nl_fill_rule(skb, rule, NETLINK_CB(cb->skb).portid,
 				       cb->nlh->nlmsg_seq, RTM_NEWRULE,
 				       NLM_F_MULTI, ops);
-		if (err)
+		if (err < 0)
 			break;
 skip:
 		idx++;
-- 
2.5.0
