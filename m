From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH iproute2] ip: add support for multicast rules
Date: Wed, 09 Jun 2010 17:41:10 +0200
Message-ID: <4C0FB616.3000303@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010605090000040301080808"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36716 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757374Ab0FIPlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 11:41:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010605090000040301080808
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit



--------------010605090000040301080808
Content-Type: text/x-diff;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 44a5293c1c47b8c32d9bb0756660ea5d4802acf2
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Apr 13 17:03:47 2010 +0200

    ip: add support for multicast rules
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index e94981d..0d8ef9e 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -7,6 +7,13 @@
 #include <linux/if_addr.h>
 #include <linux/neighbour.h>
 
+/* rtnetlink families. Values up to 127 are reserved for real address
+ * families, values above 128 may be used arbitrarily.
+ */
+#define RTNL_FAMILY_IPMR		128
+#define RTNL_FAMILY_IP6MR		129
+#define RTNL_FAMILY_MAX			129
+
 /****
  *		Routing/neighbour discovery messages.
  ****/
diff --git a/ip/ip.c b/ip/ip.c
index e0cf175..9f29533 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -42,7 +42,7 @@ static void usage(void)
 "Usage: ip [ OPTIONS ] OBJECT { COMMAND | help }\n"
 "       ip [ -force ] -batch filename\n"
 "where  OBJECT := { link | addr | addrlabel | route | rule | neigh | ntable |\n"
-"                   tunnel | tuntap | maddr | mroute | monitor | xfrm }\n"
+"                   tunnel | tuntap | maddr | mroute | mrule | monitor | xfrm }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | link } |\n"
 "                    -o[neline] | -t[imestamp] | -b[atch] [filename] |\n"
@@ -76,6 +76,7 @@ static const struct cmd {
 	{ "monitor",	do_ipmonitor },
 	{ "xfrm",	do_xfrm },
 	{ "mroute",	do_multiroute },
+	{ "mrule",	do_multirule },
 	{ "help",	do_help },
 	{ 0 }
 };
diff --git a/ip/ip_common.h b/ip/ip_common.h
index c857667..a114186 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -37,6 +37,7 @@ extern int do_iplink(int argc, char **argv);
 extern int do_ipmonitor(int argc, char **argv);
 extern int do_multiaddr(int argc, char **argv);
 extern int do_multiroute(int argc, char **argv);
+extern int do_multirule(int argc, char **argv);
 extern int do_xfrm(int argc, char **argv);
 
 static inline int rtm_get_table(struct rtmsg *r, struct rtattr **tb)
diff --git a/ip/iprule.c b/ip/iprule.c
index 7140375..9c8c6ef 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -436,3 +436,20 @@ int do_iprule(int argc, char **argv)
 	exit(-1);
 }
 
+int do_multirule(int argc, char **argv)
+{
+	switch (preferred_family) {
+	case AF_UNSPEC:
+	case AF_INET:
+		preferred_family = RTNL_FAMILY_IPMR;
+		break;
+	case AF_INET6:
+		preferred_family = RTNL_FAMILY_IP6MR;
+		break;
+	default:
+		fprintf(stderr, "Multicast rules are only supported for IPv4/IPv6\n");
+		exit(-1);
+	}
+
+	return do_iprule(argc, argv);
+}

--------------010605090000040301080808--
