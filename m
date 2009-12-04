From: Patrick McHardy <kaber@trash.net>
Subject: Re: iprule: add oif classification support
Date: Fri, 04 Dec 2009 07:07:14 +0100
Message-ID: <4B18A712.20701@trash.net>
References: <4B14082E.208@trash.net> <20091203.154957.131929849.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080203020600000909020704"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45929 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbZLDGHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 01:07:10 -0500
In-Reply-To: <20091203.154957.131929849.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080203020600000909020704
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 30 Nov 2009 19:00:14 +0100
> 
>> This patch contains iproute support for iprule oif classification
>> for the send-to-self RFC I just sent out.
> 
> Patrick, you need to submit a new version of this patch with
> the FIB_RULE_* macro fixed, just like the kernel version got
> fixed.

Thanks for reminind me of this. New patch attached.




--------------080203020600000909020704
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 0fe5164cbaa1d65dda341075710be71bf1f32d10
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Dec 4 07:06:18 2009 +0100

    iprule: add oif classification support
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
index 87b606b..42c4c2c 100644
--- a/include/linux/fib_rules.h
+++ b/include/linux/fib_rules.h
@@ -8,7 +8,9 @@
 #define FIB_RULE_PERMANENT	0x00000001
 #define FIB_RULE_INVERT		0x00000002
 #define FIB_RULE_UNRESOLVED	0x00000004
-#define FIB_RULE_DEV_DETACHED	0x00000008
+#define FIB_RULE_IIF_DETACHED	0x00000008
+#define FIB_RULE_DEV_DETACHED	FIB_RULE_IIF_DETACHED
+#define FIB_RULE_OIF_DETACHED	0x00000010
 
 /* try to find source address in routing lookups */
 #define FIB_RULE_FIND_SADDR	0x00010000
@@ -33,7 +35,8 @@ enum
 	FRA_UNSPEC,
 	FRA_DST,	/* destination address */
 	FRA_SRC,	/* source address */
-	FRA_IFNAME,	/* interface name */
+	FRA_IIFNAME,	/* interface name */
+#define FRA_IFNAME	FRA_IIFNAME
 	FRA_GOTO,	/* target to jump to (FR_ACT_GOTO) */
 	FRA_UNUSED2,
 	FRA_PRIORITY,	/* priority/preference */
@@ -47,6 +50,7 @@ enum
 	FRA_UNUSED8,
 	FRA_TABLE,	/* Extended table id */
 	FRA_FWMASK,	/* mask for netfilter mark */
+	FRA_OIFNAME,
 	__FRA_MAX
 };
 
diff --git a/ip/iprule.c b/ip/iprule.c
index e1a943a..9d4c9ae 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -38,7 +38,7 @@ static void usage(void)
 {
 	fprintf(stderr, "Usage: ip rule [ list | add | del | flush ] SELECTOR ACTION\n");
 	fprintf(stderr, "SELECTOR := [ not ] [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK[/MASK] ]\n");
-	fprintf(stderr, "            [ dev STRING ] [ pref NUMBER ]\n");
+	fprintf(stderr, "            [ iif STRING ] [ oif STRING ] [ pref NUMBER ]\n");
 	fprintf(stderr, "ACTION := [ table TABLE_ID ]\n");
 	fprintf(stderr, "          [ prohibit | reject | unreachable ]\n");
 	fprintf(stderr, "          [ realms [SRCREALM/]DSTREALM ]\n");
@@ -146,7 +146,13 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 	if (tb[FRA_IFNAME]) {
 		fprintf(fp, "iif %s ", (char*)RTA_DATA(tb[FRA_IFNAME]));
-		if (r->rtm_flags & FIB_RULE_DEV_DETACHED)
+		if (r->rtm_flags & FIB_RULE_IIF_DETACHED)
+			fprintf(fp, "[detached] ");
+	}
+
+	if (tb[FRA_OIFNAME]) {
+		fprintf(fp, "oif %s ", (char*)RTA_DATA(tb[FRA_OIFNAME]));
+		if (r->rtm_flags & FIB_RULE_OIF_DETACHED)
 			fprintf(fp, "[detached] ");
 	}
 
@@ -311,6 +317,9 @@ static int iprule_modify(int cmd, int argc, char **argv)
 			   strcmp(*argv, "iif") == 0) {
 			NEXT_ARG();
 			addattr_l(&req.n, sizeof(req), FRA_IFNAME, *argv, strlen(*argv)+1);
+		} else if (strcmp(*argv, "oif") == 0) {
+			NEXT_ARG();
+			addattr_l(&req.n, sizeof(req), FRA_OIFNAME, *argv, strlen(*argv)+1);
 		} else if (strcmp(*argv, "nat") == 0 ||
 			   matches(*argv, "map-to") == 0) {
 			NEXT_ARG();
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index a8fccc4..fab337d 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -240,7 +240,9 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 .IR TOS " ] [ "
 .B  fwmark
 .IR FWMARK[/MASK] " ] [ "
-.B  dev
+.B  iif
+.IR STRING " ] [ "
+.B  oif
 .IR STRING " ] [ "
 .B  pref
 .IR NUMBER " ]"
@@ -1936,6 +1938,12 @@ that you may create separate routing tables for forwarded and local
 packets and, hence, completely segregate them.
 
 .TP
+.BI oif " NAME"
+select the outgoing device to match.  The outgoing interface is only
+available for packets originating from local sockets that are bound to
+a device.
+
+.TP
 .BI tos " TOS"
 .TP
 .BI dsfield " TOS"

--------------080203020600000909020704--
