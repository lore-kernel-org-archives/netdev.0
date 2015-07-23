From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next] ipv4: be more aggressive when probing alternative gateways
Date: Thu, 23 Jul 2015 10:39:35 +0300
Message-ID: <1437637175-8052-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:44074 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751392AbbGWHkO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 03:40:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we do not notice if new alternative gateways
are added. We can do it by checking for present neigh
entry. Also, gateways that are currently probed (NUD_INCOMPLETE)
can be skipped from round-robin probing.

Suggested-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/fib_semantics.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 6754c64..d4c6732 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -438,13 +438,15 @@ static int fib_detect_death(struct fib_info *fi, int order,
 	if (n) {
 		state = n->nud_state;
 		neigh_release(n);
+	} else {
+		return 0;
 	}
 	if (state == NUD_REACHABLE)
 		return 0;
 	if ((state & NUD_VALID) && order != dflt)
 		return 0;
 	if ((state & NUD_VALID) ||
-	    (*last_idx < 0 && order > dflt)) {
+	    (*last_idx < 0 && order > dflt && state != NUD_INCOMPLETE)) {
 		*last_resort = fi;
 		*last_idx = order;
 	}
-- 
1.9.3
