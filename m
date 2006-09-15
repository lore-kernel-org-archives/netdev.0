From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE]: Add support for routing rule fwmark masks
Date: Fri, 15 Sep 2006 02:41:24 +0200
Message-ID: <4509F6B4.5020108@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040709010103020802030207"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:27107 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751384AbWIOAoj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 20:44:39 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040709010103020802030207
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Kernel support for this is in net-2.6.19. The output format
of rule listing is unchanged when no masks are used.




--------------040709010103020802030207
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[IPROUTE]: Add support for routing rule fwmark masks

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit e733fab0168bd659cef3158113c762c3c080471f
tree 011f330145c58c61dc8e47bbe71b6075a3727a76
parent af1b6a41d4c7ed8aab98cfdcdafd55ec6c638b07
author Patrick McHardy <kaber@trash.net> Fri, 15 Sep 2006 02:29:47 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 15 Sep 2006 02:29:47 +0200

 include/linux/rtnetlink.h |    1 +
 ip/iprule.c               |   25 +++++++++++++++++++++----
 man/man8/ip.8             |    2 +-
 3 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index d63578c..2e38a9f 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -263,6 +263,7 @@ enum rtattr_type_t
 	RTA_SESSION,
 	RTA_MP_ALGO,
 	RTA_TABLE,
+	RTA_FWMASK,
 	__RTA_MAX
 };
 
diff --git a/ip/iprule.c b/ip/iprule.c
index 6caf573..f59df0b 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -36,7 +36,7 @@ static void usage(void) __attribute__((n
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip rule [ list | add | del | flush ] SELECTOR ACTION\n");
-	fprintf(stderr, "SELECTOR := [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK ]\n");
+	fprintf(stderr, "SELECTOR := [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK[/MASK] ]\n");
 	fprintf(stderr, "            [ dev STRING ] [ pref NUMBER ]\n");
 	fprintf(stderr, "ACTION := [ table TABLE_ID ]\n");
 	fprintf(stderr, "          [ prohibit | reject | unreachable ]\n");
@@ -123,8 +123,17 @@ static int print_rule(const struct socka
 		SPRINT_BUF(b1);
 		fprintf(fp, "tos %s ", rtnl_dsfield_n2a(r->rtm_tos, b1, sizeof(b1)));
 	}
-	if (tb[RTA_PROTOINFO]) {
-		fprintf(fp, "fwmark %#x ", *(__u32*)RTA_DATA(tb[RTA_PROTOINFO]));
+	if (tb[RTA_PROTOINFO] || tb[RTA_FWMASK]) {
+		__u32 mark = 0, mask = 0;
+
+		if (tb[RTA_PROTOINFO])
+			mark = *(__u32*)RTA_DATA(tb[RTA_PROTOINFO]);
+
+		if (tb[RTA_FWMASK] &&
+		    (mask = *(__u32*)RTA_DATA(tb[RTA_FWMASK])) != 0xFFFFFFFF)
+			fprintf(fp, "fwmark 0x%x/0x%x ", mark, mask);
+		else 
+			fprintf(fp, "fwmark 0x%x ", mark);
 	}
 
 	if (tb[RTA_IIF]) {
@@ -243,11 +252,19 @@ static int iprule_modify(int cmd, int ar
 				invarg("TOS value is invalid\n", *argv);
 			req.r.rtm_tos = tos;
 		} else if (strcmp(*argv, "fwmark") == 0) {
-			__u32 fwmark;
+			char *slash;
+			__u32 fwmark, fwmask;
 			NEXT_ARG();
+			if ((slash = strchr(*argv, '/')) != NULL)
+				*slash = '\0';
 			if (get_u32(&fwmark, *argv, 0))
 				invarg("fwmark value is invalid\n", *argv);
 			addattr32(&req.n, sizeof(req), RTA_PROTOINFO, fwmark);
+			if (slash) {
+				if (get_u32(&fwmask, slash+1, 0))
+					invarg("fwmask value is invalid\n", slash+1);
+				addattr32(&req.n, sizeof(req), RTA_FWMASK, fwmask);
+			}
 		} else if (matches(*argv, "realms") == 0) {
 			__u32 realm;
 			NEXT_ARG();
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 12da6d5..a9132da 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -223,7 +223,7 @@ throw " | " unreachable " | " prohibit "
 .B  tos
 .IR TOS " ] [ "
 .B  fwmark
-.IR FWMARK " ] [ "
+.IR FWMARK[/MASK] " ] [ "
 .B  dev
 .IR STRING " ] [ "
 .B  pref


--------------040709010103020802030207--
