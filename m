From: Petr Lautrbach <plautrba@redhat.com>
Subject: [PATCH] iproute: fix tc generating ipv6 priority filter
Date: Mon, 14 Jun 2010 15:36:28 +0200
Message-ID: <1276522588-23727-1-git-send-email-plautrba@redhat.com>
Cc: netdev@vger.kernel.org, Petr Lautrbach <plautrba@redhat.com>
To: shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11155 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751097Ab0FNNhB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jun 2010 09:37:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds ipv6 filter priority/traffic class function 
static int parse_ip6_class(int *argc_p, char ***argv_p, struct tc_u32_sel *sel) 
shifting filter value to 5th bit and ignoring "at" as header position 
is exactly given.

Signed-off-by: Petr Lautrbach <plautrba@redhat.com>
---
Hello,

According to [1], tc doesn't generate right filters for IPv6 
"priority".

Priority or Traffic Classes is 8 bits starting at 5th bit 
based on RFC 2460 [2]. There is parse_u8(&argc, &argv, sel, 4, 0)
function used in current version, which shifts filter by 4 bytes 
instead of 4 bits.

[1] https://bugzilla.redhat.com/show_bug.cgi?id=584913
[2] http://www.faqs.org/rfcs/rfc2460.html

 tc/f_u32.c |   39 ++++++++++++++++++++++++++++++++++++++-
 1 files changed, 38 insertions(+), 1 deletions(-)

diff --git a/tc/f_u32.c b/tc/f_u32.c
index 4f5f74e..31e13b5 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -403,6 +403,43 @@ static int parse_ip6_addr(int *argc_p, char ***argv_p,
 	return res;
 }
 
+static int parse_ip6_class(int *argc_p, char ***argv_p, struct tc_u32_sel *sel)
+{
+	int res = -1;
+	int argc = *argc_p;
+	char **argv = *argv_p;
+	__u32 key;
+	__u32 mask;
+	int off = 0;
+	int offmask = 0;
+
+	if (argc < 2)
+		return -1;
+
+	if (get_u32(&key, *argv, 0))
+		return -1;
+	argc--; argv++;
+
+	if (get_u32(&mask, *argv, 16))
+		return -1;
+	argc--; argv++;
+
+	if (key > 0xFF || mask > 0xFF)
+		return -1;
+
+	key <<= 20;
+	mask <<= 20;
+	key = htonl(key);
+	mask = htonl(mask);
+
+	if (res = pack_key(sel, key, mask, off, offmask) < 0)
+		return -1;
+
+	*argc_p = argc;
+	*argv_p = argv;
+	return 0;
+}
+
 static int parse_ether_addr(int *argc_p, char ***argv_p,
 			    struct tc_u32_sel *sel, int off)
 {
@@ -522,7 +559,7 @@ static int parse_ip6(int *argc_p, char ***argv_p, struct tc_u32_sel *sel)
 		res = parse_ip6_addr(&argc, &argv, sel, 24);
 	} else if (strcmp(*argv, "priority") == 0) {
 		NEXT_ARG();
-		res = parse_u8(&argc, &argv, sel, 4, 0);
+		res = parse_ip6_class(&argc, &argv, sel);
 	} else if (strcmp(*argv, "protocol") == 0) {
 		NEXT_ARG();
 		res = parse_u8(&argc, &argv, sel, 6, 0);
-- 
1.7.1

