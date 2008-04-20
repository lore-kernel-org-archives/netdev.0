From: jamal <hadi@cyberus.ca>
Subject: [PATCH 3/3] [TC/U32] Infrastructure for pretty printing
Date: Sun, 20 Apr 2008 10:49:24 -0400
Message-ID: <1208702964.12249.57.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-2tTEBBY0108quZrDuJ47"
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:56348 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753587AbYDTOt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 10:49:27 -0400
Received: by an-out-0708.google.com with SMTP id d31so383968and.103
        for <netdev@vger.kernel.org>; Sun, 20 Apr 2008 07:49:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2tTEBBY0108quZrDuJ47
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

And last for now ..

cheers,
jamal

--=-2tTEBBY0108quZrDuJ47
Content-Disposition: attachment; filename=0003-TC-U32-Infrastructure-for-pretty-printing.txt
Content-Type: text/plain; name=0003-TC-U32-Infrastructure-for-pretty-printing.txt; charset=us-ascii
Content-Transfer-Encoding: 7bit

[PATCH 3/3] [TC/U32] Infrastructure for pretty printing

This patch makes it easy to add pretty printers of different protocols.
For starters it makes use of ipv4 and raw printers.
Add more later ...

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 tc/f_u32.c |   57 +++++++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 43 insertions(+), 14 deletions(-)

diff --git a/tc/f_u32.c b/tc/f_u32.c
index db492fe..7ead576 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -21,6 +21,7 @@
 #include <arpa/inet.h>
 #include <string.h>
 #include <linux/if.h>
+#include <linux/if_ether.h>
 
 #include "utils.h"
 #include "tc_util.h"
@@ -789,27 +790,24 @@ static int parse_hashkey(int *argc_p, char ***argv_p, struct tc_u32_sel *sel)
 	return 0;
 }
 
-static void show_key(FILE *f, const struct tc_u32_key *key)
+static void print_ipv4(FILE *f, const struct tc_u32_key *key)
 {
 	char abuf[256];
 
-	if (!show_cooked)
-		goto raw;
-
 	switch (key->off) {
 	case 0:
 		switch (ntohl(key->mask)) {
 		case 0x0f000000:
-			fprintf(f, "\n ihl %u", ntohl(key->val) >> 24);
+			fprintf(f, "\n  match IP ihl %u", ntohl(key->val) >> 24);
 			return;
 		case 0x00ff0000:
-			fprintf(f, "\n dsfield %#x", ntohl(key->val) >> 16);
+			fprintf(f, "\n  match IP dsfield %#x", ntohl(key->val) >> 16);
 			return;
 		}
 		break;
 	case 8:
 		if (ntohl(key->mask) == 0x00ff0000) {
-			fprintf(f, "\n protocol %u", ntohl(key->val) >> 16);
+			fprintf(f, "\n  match IP protocol %d", ntohl(key->val) >> 16);
 			return;
 		}
 		break;
@@ -818,7 +816,7 @@ static void show_key(FILE *f, const struct tc_u32_key *key)
 			int bits = mask2bits(key->mask);
 			if (bits >= 0) {
 				fprintf(f, "\n  %s %s/%d", 
-					key->off == 12 ? "src" : "dst",
+					key->off == 12 ? "match IP src" : "match IP dst",
 					inet_ntop(AF_INET, &key->val,
 						  abuf, sizeof(abuf)),
 					bits);
@@ -830,23 +828,26 @@ static void show_key(FILE *f, const struct tc_u32_key *key)
 	case 20:
 		switch (ntohl(key->mask)) {
 		case 0x0000ffff:
-			fprintf(f, "\n  sport %u", 
+			fprintf(f, "\n  match sport %u",
 				ntohl(key->val) & 0xffff);
 			return;
 		case 0xffff0000:
-			fprintf(f, "\n  dport %u", 
+			fprintf(f, "\n  match dport %u",
 				ntohl(key->val) >> 16);
 			return;
 		case 0xffffffff:
-			fprintf(f, "\n  sport %u, dport %u", 
+			fprintf(f, "\n  match sport %u, match dport %u",
 				ntohl(key->val) & 0xffff,
 				ntohl(key->val) >> 16);
 
 			return;
 		}
+		/* XXX: Default print_raw */
 	}
+}
 
-raw:
+static void print_raw(FILE *f, const struct tc_u32_key *key)
+{
 	fprintf(f, "\n  match %08x/%08x at %s%d",
 		(unsigned int)ntohl(key->val),
 		(unsigned int)ntohl(key->mask),
@@ -854,7 +855,35 @@ raw:
 		key->off);
 }
 
-static int u32_parse_opt(struct filter_util *qu, char *handle, 
+static struct {
+	__u16 proto;
+	__u16 pad;
+	void (*pprinter)(FILE *f, const struct tc_u32_key *key);
+	} u32_pprinters[] = {
+		{0, 0, print_raw},
+		{ETH_P_IP, 0, print_ipv4},
+};
+
+static void show_keys(FILE *f, const struct tc_u32_key *key)
+{
+	int i = 0;
+
+	if (!show_cooked)
+		goto show_k;
+
+	for (i = 0; i < sizeof(u32_pprinters) / sizeof(u32_pprinters[0]); i++) {
+		if (u32_pprinters[i].proto == ntohs(f_proto)) {
+show_k:
+			u32_pprinters[i].pprinter(f, key);
+			return;
+		}
+	}
+
+	i = 0;
+	goto show_k;
+}
+
+static int u32_parse_opt(struct filter_util *qu, char *handle,
 			 int argc, char **argv, struct nlmsghdr *n)
 {
 	struct {
@@ -1129,7 +1158,7 @@ static int u32_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt,
 		if (sel->nkeys) {
 			int i;
 			for (i=0; i<sel->nkeys; i++) {
-				show_key(f, sel->keys + i);
+				show_keys(f, sel->keys + i);
 				if (show_stats && NULL != pf)
 					fprintf(f, " (success %llu ) ",
 						(unsigned long long) pf->kcnts[i]);
-- 
1.4.4.1.gaed4


--=-2tTEBBY0108quZrDuJ47--

