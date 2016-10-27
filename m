From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCHv2 iproute2 net-next] tc: m_mirred: Fix parsing of 'index' optional argument
Date: Thu, 27 Oct 2016 10:36:06 +0300
Message-ID: <20161027073606.6112-1-shmulik.ladkani@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35124 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933572AbcJ0HgQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 03:36:16 -0400
Received: by mail-wm0-f65.google.com with SMTP id b80so1236863wme.2
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 00:36:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code in parse_mirred() suggests "index" argument can be placed either
after the egress/ingress clause, or as the first argument (after
"action mirred").

However, parse_direction() fails to correctly parse "index" if it's the
first argument.

For example:

 # tc filter add ... action mirred index 5
 RTNETLINK answers: Invalid argument
 (unnecessary RTNETLINK issued, should have been parse error)

 # tc filter add ... action mirred index 5 egress redirect dev eth0
 bad action type egress
 (should have been parsed successfully)

Fix parse_direction as follows:
 - continue parsing after valid "index" is seen
 - don't issue the RTNETLINK unless valid "egress"/"ingress" is seen

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
 v2: rebased to recent tip of net-next, amended log message

 An alternative solution: banning "index" as 1st argument in parse_mirred

 tc/m_mirred.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/tc/m_mirred.c b/tc/m_mirred.c
index 01f916d..64d870a 100644
--- a/tc/m_mirred.c
+++ b/tc/m_mirred.c
@@ -105,9 +105,8 @@ parse_direction(struct action_util *a, int *argc_p, char ***argv_p,
 				}
 				iok++;
 				if (!ok) {
-					argc--;
-					argv++;
-					break;
+					NEXT_ARG();
+					continue;
 				}
 			} else if (!ok) {
 				fprintf(stderr, "was expecting egress or ingress (%s)\n", *argv);
@@ -150,7 +149,7 @@ parse_direction(struct action_util *a, int *argc_p, char ***argv_p,
 		NEXT_ARG();
 	}
 
-	if (!ok && !iok) {
+	if (!ok) {
 		return -1;
 	}
 
-- 
2.10.1
