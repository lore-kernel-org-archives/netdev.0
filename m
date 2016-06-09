From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCHv2] ipaddress: Allow listing addresses by type
Date: Thu,  9 Jun 2016 19:20:36 +0200
Message-ID: <1465492836-5850-1-git-send-email-phil@nwl.cc>
References: <20160608083554.639d1286@xeon-e3>
Cc: netdev@vger.kernel.org, Vadim Kochan <vadim4j@gmail.com>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:54508 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932642AbcFIRUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2016 13:20:51 -0400
In-Reply-To: <20160608083554.639d1286@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not sure why this was limited to ip-link before. It is semantically
equal to the 'master' keyword, which is not restricted at all.

The man page and help text adjustments include the 'master' keyword as
well since that is also supported but wasn't documented before.

Cc: Vadim Kochan <vadim4j@gmail.com>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Note that I am not exactly fond of the changes here. When discovering
that I would have to split the synopsis of 'show' from 'save' and
'flush', I wanted to extend 'flush' to support the added selectors as
well. Sadly this seems to be a can of worms: filter evaluation is spread
over multiple functions, and since 'flush' uses RTM_GETADDR request the
IFLA_* attributes are not available at all. So this is rather a quick
than a clean solution.
---
 ip/ipaddress.c           | 11 ++++++++--
 man/man8/ip-address.8.in | 57 +++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 63 insertions(+), 5 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index df363b070d5de..8766530f7fa7c 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -75,8 +75,11 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip address {add|change|replace} IFADDR dev IFNAME [ LIFETIME ]\n");
 	fprintf(stderr, "                                                      [ CONFFLAG-LIST ]\n");
 	fprintf(stderr, "       ip address del IFADDR dev IFNAME [mngtmpaddr]\n");
-	fprintf(stderr, "       ip address {show|save|flush} [ dev IFNAME ] [ scope SCOPE-ID ]\n");
+	fprintf(stderr, "       ip address {save|flush} [ dev IFNAME ] [ scope SCOPE-ID ]\n");
 	fprintf(stderr, "                            [ to PREFIX ] [ FLAG-LIST ] [ label LABEL ] [up]\n");
+	fprintf(stderr, "       ip address [ show [ dev IFNAME ] [ scope SCOPE-ID ] [ master DEVICE ]\n");
+	fprintf(stderr, "                         [ type TYPE ] [ to PREFIX ] [ FLAG-LIST ]\n");
+	fprintf(stderr, "                         [ label LABEL ] [up] ]\n");
 	fprintf(stderr, "       ip address {showdump|restore}\n");
 	fprintf(stderr, "IFADDR := PREFIX | ADDR peer PREFIX\n");
 	fprintf(stderr, "          [ broadcast ADDR ] [ anycast ADDR ]\n");
@@ -90,6 +93,10 @@ static void usage(void)
 	fprintf(stderr, "CONFFLAG  := [ home | nodad | mngtmpaddr | noprefixroute | autojoin ]\n");
 	fprintf(stderr, "LIFETIME := [ valid_lft LFT ] [ preferred_lft LFT ]\n");
 	fprintf(stderr, "LFT := forever | SECONDS\n");
+	fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |\n");
+	fprintf(stderr, "          bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan |\n");
+	fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti | nlmon |\n");
+	fprintf(stderr, "          bond_slave | ipvlan | geneve | bridge_slave | vrf }\n");
 
 	exit(-1);
 }
@@ -1613,7 +1620,7 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 			if (!ifindex)
 				invarg("Device does not exist\n", *argv);
 			filter.master = ifindex;
-		} else if (do_link && strcmp(*argv, "type") == 0) {
+		} else if (strcmp(*argv, "type") == 0) {
 			NEXT_ARG();
 			filter.kind = *argv;
 		} else {
diff --git a/man/man8/ip-address.8.in b/man/man8/ip-address.8.in
index ff3fe0b96b02a..ab0942d7e94e2 100644
--- a/man/man8/ip-address.8.in
+++ b/man/man8/ip-address.8.in
@@ -23,7 +23,7 @@ ip-address \- protocol address management
 .IB IFADDR " dev " IFNAME " [ " mngtmpaddr " ]"
 
 .ti -8
-.BR "ip address" " { " show " | " save " | " flush " } [ " dev
+.BR "ip address" " { " save " | " flush " } [ " dev
 .IR IFNAME " ] [ "
 .B  scope
 .IR SCOPE-ID " ] [ "
@@ -33,6 +33,21 @@ ip-address \- protocol address management
 .IR PATTERN " ] [ " up " ]"
 
 .ti -8
+.BR "ip address" " [ " show  " [ " dev
+.IR IFNAME " ] [ "
+.B  scope
+.IR SCOPE-ID " ] [ "
+.B  to
+.IR PREFIX " ] [ " FLAG-LIST " ] [ "
+.B  label
+.IR PATTERN " ] [ "
+.B  master
+.IR DEVICE " ] [ "
+.B  type
+.IR TYPE " ] [ "
+.BR up " ] ]"
+
+.ti -8
 .BR "ip address" " { " showdump " | " restore " }"
 
 .ti -8
@@ -80,6 +95,34 @@ ip-address \- protocol address management
 .BR forever " |"
 .IR SECONDS " ]"
 
+.ti -8
+.IR TYPE " := [ "
+.BR bridge " | "
+.BR bond " | "
+.BR can " | "
+.BR dummy " | "
+.BR hsr " | "
+.BR ifb " | "
+.BR ipoib " |"
+.BR macvlan  " | "
+.BR macvtap  " | "
+.BR vcan " | "
+.BR veth " | "
+.BR vlan " | "
+.BR vxlan " |"
+.BR ip6tnl " |"
+.BR ipip " |"
+.BR sit " |"
+.BR gre " |"
+.BR gretap " |"
+.BR ip6gre " |"
+.BR ip6gretap " |"
+.BR vti " |"
+.BR nlmon " |"
+.BR ipvlan " |"
+.BR lowpan " |"
+.BR geneve " ]"
+
 .SH "DESCRIPTION"
 The
 .B address
@@ -230,6 +273,14 @@ only list addresses with labels matching the
 is a usual shell style pattern.
 
 .TP
+.BI master " DEVICE"
+only list interfaces enslaved to this master device.
+
+.TP
+.BI type " TYPE"
+only list interfaces of the given type.
+
+.TP
 .B up
 only list running interfaces.
 
@@ -280,8 +331,8 @@ This command flushes the protocol addresses selected by some criteria.
 
 .PP
 This command has the same arguments as
-.B show.
-The difference is that it does not run when no arguments are given.
+.BR show " except that " type " and " master " selectors are not supported."
+Another difference is that it does not run when no arguments are given.
 
 .PP
 .B Warning:
-- 
2.8.2
