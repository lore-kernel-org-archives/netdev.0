From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] fib: use atomic_inc_not_zero() in
 fib_rules_lookup
Date: Mon, 27 Sep 2010 16:18:27 +0200
Message-ID: <1285597107.23938.250.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55446 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756026Ab0I0OSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 10:18:33 -0400
Received: by fxm3 with SMTP id 3so1830421fxm.19
        for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 07:18:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems we dont use appropriate refcount increment in an
rcu_read_lock() protected section.

fib_rule_get() might increment a null refcount and bad things could
happen.

While fib_nl_delrule() respects an rcu grace period before calling
fib_rule_put(), fib_rules_cleanup_ops() calls fib_rule_put() without a
grace period.

Note : after this patch, we might avoid the synchronize_rcu() call done
in fib_nl_delrule()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/fib_rules.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 42e84e0..910eac3 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -225,9 +225,11 @@ jumped:
 			err = ops->action(rule, fl, flags, arg);
 
 		if (err != -EAGAIN) {
-			fib_rule_get(rule);
-			arg->rule = rule;
-			goto out;
+			if (likely(atomic_inc_not_zero(&rule->refcnt))) {
+				arg->rule = rule;
+				goto out;
+			}
+			break;
 		}
 	}
 


