From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH iproute2 net-next] tc: m_mirred: Fix parsing of 'index' optional argument
Date: Fri, 21 Oct 2016 23:01:15 +0300
Message-ID: <1477080075-17146-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36400 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754732AbcJUUBX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 16:01:23 -0400
Received: by mail-wm0-f67.google.com with SMTP id f193so271277wmg.3
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 13:01:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code in parse_mirred() suggests "index" argument can be placed either
after the "egress" clause, or as the first argument (after "action mirred").

However, parse_egress() fails to correctly parse "index" if it's the
first argument.

For example:

 # tc filter add ... action mirred index 5
 RTNETLINK answers: Invalid argument
 (unnecessary RTNETLINK issued, should have been parse error)

 # tc filter add ... action mirred index 5 egress redirect dev eth0
 bad action type egress
 (should have been parsed successfully)

Fix parse_egress as follows:
 - continue parsing after valid "index" is seen
 - don't issue the RTNETLINK unless valid "egress" is seen

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---

 Well, both man and usage suggest "index" comes after the egress clause:
    tc ... action mirred DIRECTION ACTION [ index INDEX ] dev DEVICENAME
 So an alternative would be banning "index" as 1st argument in parse_mirred.

 tc/m_mirred.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/tc/m_mirred.c b/tc/m_mirred.c
index 11f4c9b46f..d3e750b89b 100644
--- a/tc/m_mirred.c
+++ b/tc/m_mirred.c
@@ -91,9 +91,8 @@ parse_egress(struct action_util *a, int *argc_p, char ***argv_p,
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
 				fprintf(stderr, "was expecting egress (%s)\n", *argv);
@@ -134,7 +133,7 @@ parse_egress(struct action_util *a, int *argc_p, char ***argv_p,
 		NEXT_ARG();
 	}
 
-	if (!ok && !iok) {
+	if (!ok) {
 		return -1;
 	}
 
-- 
2.7.4
