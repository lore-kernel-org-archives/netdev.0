From: Patrick McHardy <kaber@trash.net>
Subject: Re: iproute2 update
Date: Tue, 05 Dec 2006 19:43:43 +0100
Message-ID: <4575BDDF.70902@trash.net>
References: <20061205101757.7a35bcbe@freekitty>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000709060505000907050201"
Cc: Jamal <hadi@cyberus.ca>, Masahide NAKAMURA <nakam@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43401 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968616AbWLESns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 13:43:48 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061205101757.7a35bcbe@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000709060505000907050201
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Stephen Hemminger wrote:
> I am about to push out a new version, so if you have any more patches pending
> the window is about to close.

I still have this one I would like to get in.


--------------000709060505000907050201
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[IPROUTE]: Add support for routing rule fwmark masks

Needs kernel >= 2.6.19.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit ba3145833888823f1e1af4ef093d16eea9baed2c
tree 23ef86c81e53c94d3f8d67d5395bcc3183d39e4b
parent 288384f22ffafd2d7d888ee45d8dfcf26d3f2b1c
author Patrick McHardy <kaber@trash.net> Tue, 05 Dec 2006 19:41:36 +0100
committer Patrick McHardy <kaber@trash.net> Tue, 05 Dec 2006 19:41:36 +0100

 include/linux/rtnetlink.h |    1 +
 ip/iprule.c               |   25 +++++++++++++++++++++----
 man/man8/ip.8             |    2 +-
 3 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 1ee3a56..c02470c 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -264,6 +264,7 @@ enum rtattr_type_t
 	RTA_SESSION,
 	RTA_MP_ALGO,
 	RTA_TABLE,
+	RTA_FWMASK,
 	__RTA_MAX
 };
 
diff --git a/ip/iprule.c b/ip/iprule.c
index c584b18..2a4d126 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -37,7 +37,7 @@ static void usage(void) __attribute__((n
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip rule [ list | add | del | flush ] SELECTOR ACTION\n");
-	fprintf(stderr, "SELECTOR := [ not ] [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK ]\n");
+	fprintf(stderr, "SELECTOR := [ not ] [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK[/MASK] ]\n");
 	fprintf(stderr, "            [ dev STRING ] [ pref NUMBER ]\n");
 	fprintf(stderr, "ACTION := [ table TABLE_ID ]\n");
 	fprintf(stderr, "          [ prohibit | reject | unreachable ]\n");
@@ -129,8 +129,17 @@ int print_rule(const struct sockaddr_nl 
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
@@ -252,11 +261,19 @@ static int iprule_modify(int cmd, int ar
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

--------------000709060505000907050201--
