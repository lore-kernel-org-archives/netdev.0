From: Steven Barth <cyrus@openwrt.org>
Subject: [PATCH] ipv6: fix backtracking for throw routes
Date: Thu, 19 Mar 2015 16:16:04 +0100
Message-ID: <1426778164-4286-1-git-send-email-cyrus@openwrt.org>
Cc: Steven Barth <cyrus@openwrt.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.core-networks.de ([82.96.72.7]:48001 "EHLO
	mail.core-networks.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756AbbCSPRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 11:17:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

for throw routes to trigger evaluation of other policy rules
EAGAIN needs to be propagated up to fib_rules_lookup
similar to how its done for IPv4

A simple testcase for verification is:

ip -6 rule add lookup 33333 priority 33333
ip -6 route add throw 2001:db8::1
ip -6 route add 2001:db8::1 via fe80::1 dev wlan0 table 33333
ip route get 2001:db8::1

Signed-off-by: Steven Barth <cyrus@openwrt.org>
---
 net/ipv6/fib6_rules.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index b4d5e1d..27ca796 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -104,6 +104,7 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 				goto again;
 			flp6->saddr = saddr;
 		}
+		err = rt->dst.error;
 		goto out;
 	}
 again:
-- 
2.1.4
