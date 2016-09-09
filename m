From: Lorenzo Colitti <lorenzo@google.com>
Subject: [RFC net-next] net: diag: Make inet_diag bytecode match consistent with ip rules
Date: Fri,  9 Sep 2016 16:53:08 +0900
Message-ID: <1473407588-135334-1-git-send-email-lorenzo@google.com>
Cc: eric.dumazet@gmail.com, davem@davemloft.net, ek@google.com,
        Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35192 "EHLO
        mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752436AbcIIHxS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 03:53:18 -0400
Received: by mail-pa0-f43.google.com with SMTP id b2so25993494pat.2
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 00:53:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recently-added socket mark matching in inet_diag_bc_run is
inconsistent with the fwmark matching in fib_rule_match:

inet_diag_bc_run:
	if ((entry->mark & cond->mask) != cond->mark)
		yes = 0;

fib_rule_match:
	if ((rule->mark ^ fl->flowi_mark) & rule->mark_mask)
		goto out;

The two behave differently if the filter mark has bits set that
are not also set in the filter mask. For example, given a filter
of 0x1111/0x1101, and a socket mark of 0x1111, inet_diag_bc_run
will not match the socket, but fib_rule_match will.

This behaviour is not incorrect, and in fact it is consistent
with the mark iptables module, which does:

mark_mt:
	return ((skb->mark & info->mask) == info->mark) ^ info->invert;

In both cases the expressive power of the filter is the same.
Userspace would probably be well advised to specify a filter of
0x1101/0x1101, which will behave the same in both implementations.
However, of the two, the behaviour of fib_rule_match seems more
intuitive, and as mark matching in inet bytecode filters was only
recently added, it seems safe to change.

Fixes: a52e95abf772 ("net: diag: allow socket bytecode filters to match socket marks")
Tested: https://android-review.googlesource.com/271795
Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 net/ipv4/inet_diag.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index e4d16fc..1683bf5 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -598,7 +598,7 @@ static int inet_diag_bc_run(const struct nlattr *_bc,
 			struct inet_diag_markcond *cond;
 
 			cond = (struct inet_diag_markcond *)(op + 1);
-			if ((entry->mark & cond->mask) != cond->mark)
+			if ((entry->mark ^ cond->mark) & cond->mask)
 				yes = 0;
 			break;
 		}
-- 
2.8.0.rc3.226.g39d4020
