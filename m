From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH iproute2 net-next] tc: m_mirred: Add support for ingress redirect/mirror
Date: Wed, 19 Oct 2016 17:14:09 +0300
Message-ID: <20161019141409.23172-1-shmulik.ladkani@gmail.com>
Cc: netdev@vger.kernel.org, Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34097 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938717AbcJSOOU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 10:14:20 -0400
Received: by mail-qk0-f196.google.com with SMTP id n189so2043389qke.1
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 07:14:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So far, only the 'egress' direction was implemented.

Allow specifying 'ingress' as the direction packet appears on the target
interface.

For example, this takes incoming 802.1q frames on veth0 and redirects
them for input on dummy0:

 # tc filter add dev veth0 parent ffff: pref 1 protocol 802.1q basic \
     action mirred ingress redirect dev dummy0

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
 man/man8/tc-mirred.8 |  4 +---
 tc/m_mirred.c        | 40 ++++++++++++++++++++++++++++------------
 2 files changed, 29 insertions(+), 15 deletions(-)

diff --git a/man/man8/tc-mirred.8 b/man/man8/tc-mirred.8
index bba96e0..38833b4 100644
--- a/man/man8/tc-mirred.8
+++ b/man/man8/tc-mirred.8
@@ -30,9 +30,7 @@ receives. Mirroring is what is sometimes referred to as Switch Port Analyzer
 .TQ
 .B egress
 Specify the direction in which the packet shall appear on the destination
-interface. Currently only
-.B egress
-is implemented.
+interface.
 .TP
 .B mirror
 .TQ
diff --git a/tc/m_mirred.c b/tc/m_mirred.c
index 11f4c9b..01f916d 100644
--- a/tc/m_mirred.c
+++ b/tc/m_mirred.c
@@ -62,13 +62,13 @@ static const char *mirred_n2a(int action)
 }
 
 static int
-parse_egress(struct action_util *a, int *argc_p, char ***argv_p,
-	     int tca_id, struct nlmsghdr *n)
+parse_direction(struct action_util *a, int *argc_p, char ***argv_p,
+		int tca_id, struct nlmsghdr *n)
 {
 
 	int argc = *argc_p;
 	char **argv = *argv_p;
-	int ok = 0, iok = 0, mirror = 0, redir = 0;
+	int ok = 0, iok = 0, mirror = 0, redir = 0, ingress = 0, egress = 0;
 	struct tc_mirred p = {};
 	struct rtattr *tail;
 	char d[16] = {};
@@ -77,7 +77,21 @@ parse_egress(struct action_util *a, int *argc_p, char ***argv_p,
 
 		if (matches(*argv, "action") == 0) {
 			break;
-		} else if (matches(*argv, "egress") == 0) {
+		} else if (!egress && matches(*argv, "egress") == 0) {
+			egress = 1;
+			if (ingress) {
+				fprintf(stderr, "Can't have both egress and ingress\n");
+				return -1;
+			}
+			NEXT_ARG();
+			ok++;
+			continue;
+		} else if (!ingress && matches(*argv, "ingress") == 0) {
+			ingress = 1;
+			if (egress) {
+				fprintf(stderr, "Can't have both ingress and egress\n");
+				return -1;
+			}
 			NEXT_ARG();
 			ok++;
 			continue;
@@ -96,7 +110,7 @@ parse_egress(struct action_util *a, int *argc_p, char ***argv_p,
 					break;
 				}
 			} else if (!ok) {
-				fprintf(stderr, "was expecting egress (%s)\n", *argv);
+				fprintf(stderr, "was expecting egress or ingress (%s)\n", *argv);
 				break;
 
 			} else if (!mirror && matches(*argv, "mirror") == 0) {
@@ -105,7 +119,8 @@ parse_egress(struct action_util *a, int *argc_p, char ***argv_p,
 					fprintf(stderr, "Can't have both mirror and redir\n");
 					return -1;
 				}
-				p.eaction = TCA_EGRESS_MIRROR;
+				p.eaction = egress ? TCA_EGRESS_MIRROR :
+					    TCA_INGRESS_MIRROR;
 				p.action = TC_ACT_PIPE;
 				ok++;
 			} else if (!redir && matches(*argv, "redirect") == 0) {
@@ -114,7 +129,8 @@ parse_egress(struct action_util *a, int *argc_p, char ***argv_p,
 					fprintf(stderr, "Can't have both mirror and redir\n");
 					return -1;
 				}
-				p.eaction = TCA_EGRESS_REDIR;
+				p.eaction = egress ? TCA_EGRESS_REDIR :
+					    TCA_INGRESS_REDIR;
 				p.action = TC_ACT_STOLEN;
 				ok++;
 			} else if ((redir || mirror) && matches(*argv, "dev") == 0) {
@@ -154,7 +170,8 @@ parse_egress(struct action_util *a, int *argc_p, char ***argv_p,
 	}
 
 
-	if (argc && p.eaction == TCA_EGRESS_MIRROR
+	if (argc &&
+	    (p.eaction == TCA_EGRESS_MIRROR || p.eaction == TCA_INGRESS_MIRROR)
 	    && !action_a2n(*argv, &p.action, false))
 		NEXT_ARG();
 
@@ -207,8 +224,9 @@ parse_mirred(struct action_util *a, int *argc_p, char ***argv_p,
 	}
 
 
-	if (matches(*argv, "egress") == 0 || matches(*argv, "index") == 0) {
-		int ret = parse_egress(a, &argc, &argv, tca_id, n);
+	if (matches(*argv, "egress") == 0 || matches(*argv, "ingress") == 0 ||
+	    matches(*argv, "index") == 0) {
+		int ret = parse_direction(a, &argc, &argv, tca_id, n);
 
 		if (ret == 0) {
 			*argc_p = argc;
@@ -216,8 +234,6 @@ parse_mirred(struct action_util *a, int *argc_p, char ***argv_p,
 			return 0;
 		}
 
-	} else if (matches(*argv, "ingress") == 0) {
-		fprintf(stderr, "mirred ingress not supported at the moment\n");
 	} else if (matches(*argv, "help") == 0) {
 		usage();
 	} else {
-- 
2.10.1
