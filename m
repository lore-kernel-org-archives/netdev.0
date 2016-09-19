From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH] ip: (ipvlan) introduce L3s mode
Date: Mon, 19 Sep 2016 14:39:40 -0700
Message-ID: <1474321180-31717-1-git-send-email-mahesh@bandewar.net>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36387 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932199AbcISVjy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 17:39:54 -0400
Received: by mail-pf0-f193.google.com with SMTP id n24so7755410pfb.3
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 14:39:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

The new mode 'l3s' can be set like -

  ip link add link <master> dev <IPvlan-slave> type ipvlan mode l3s

  e.g. ip link add link eth0 dev ipvl0 type ipvlan mode l3s

Also did some trivial code restructuring.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 include/linux/if_link.h |  1 +
 ip/iplink_ipvlan.c      | 32 +++++++++++++-------------------
 2 files changed, 14 insertions(+), 19 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 1feb708902ac..78ef2c6ae04e 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -461,6 +461,7 @@ enum {
 enum ipvlan_mode {
 	IPVLAN_MODE_L2 = 0,
 	IPVLAN_MODE_L3,
+	IPVLAN_MODE_L3S,
 	IPVLAN_MODE_MAX
 };
 
diff --git a/ip/iplink_ipvlan.c b/ip/iplink_ipvlan.c
index a6273be88a2a..f7735f3a13ef 100644
--- a/ip/iplink_ipvlan.c
+++ b/ip/iplink_ipvlan.c
@@ -20,18 +20,7 @@
 
 static void ipvlan_explain(FILE *f)
 {
-	fprintf(f, "Usage: ... ipvlan [ mode { l2 | l3 } ]\n");
-}
-
-static void explain(void)
-{
-	ipvlan_explain(stderr);
-}
-
-static int mode_arg(void)
-{
-	fprintf(stderr, "Error: argument of \"mode\" must be either \"l2\", or \"l3\"\n");
-	return -1;
+	fprintf(f, "Usage: ... ipvlan [ mode { l2 | l3  | l3s } ]\n");
 }
 
 static int ipvlan_parse_opt(struct link_util *lu, int argc, char **argv,
@@ -47,20 +36,24 @@ static int ipvlan_parse_opt(struct link_util *lu, int argc, char **argv,
 				mode = IPVLAN_MODE_L2;
 			else if (strcmp(*argv, "l3") == 0)
 				mode = IPVLAN_MODE_L3;
-			else
-				return mode_arg();
-
+			else if (strcmp(*argv, "l3s") == 0)
+				mode = IPVLAN_MODE_L3S;
+			else {
+				fprintf(stderr, "Error: argument of \"mode\" must be either \"l2\", \"l3\" or \"l3s\"\n");
+				return -1;
+			}
 			addattr16(n, 1024, IFLA_IPVLAN_MODE, mode);
 		} else if (matches(*argv, "help") == 0) {
-			explain();
+			ipvlan_explain(stderr);
 			return -1;
 		} else {
 			fprintf(stderr, "ipvlan: unknown option \"%s\"?\n",
 				*argv);
-			explain();
+			ipvlan_explain(stderr);
 			return -1;
 		}
-		argc--, argv++;
+		argc--;
+		argv++;
 	}
 
 	return 0;
@@ -78,7 +71,8 @@ static void ipvlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 
 			fprintf(f, " mode %s ",
 				mode == IPVLAN_MODE_L2 ? "l2" :
-				mode == IPVLAN_MODE_L3 ? "l3" : "unknown");
+				mode == IPVLAN_MODE_L3 ? "l3" :
+				mode == IPVLAN_MODE_L3S ? "l3s" : "unknown");
 		}
 	}
 }
-- 
2.8.0.rc3.226.g39d4020
