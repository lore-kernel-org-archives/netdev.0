From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2] bridge: add support for dynamic fdb entries
Date: Fri, 19 Feb 2016 21:34:52 -0800
Message-ID: <1455946492-14209-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, wkok@cumulusnetworks.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33135 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752359AbcBTFe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Feb 2016 00:34:56 -0500
Received: by mail-pf0-f172.google.com with SMTP id q63so62472397pfb.0
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 21:34:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch is a follow up to the recently added
'static' fdb option.

It introduces a new option 'dynamic' which adds
dynamic fdb entries with NUD_REACHABLE.

$bridge fdb add 00:01:02:03:04:06 dev eth0 master dynamic

$bridge fdb show
00:01:02:03:04:06 dev eth0

This patch also documents all fdb types. Removes 'temp'
from usage message since it is now replaced by 'static'.
'temp' still works and is synonymous with static.

Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 bridge/fdb.c      |  5 ++++-
 man/man8/bridge.8 | 14 +++++++++++++-
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index 9bc6b94..1400b65 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -33,7 +33,7 @@ static void usage(void)
 {
 	fprintf(stderr, "Usage: bridge fdb { add | append | del | replace } ADDR dev DEV\n"
 			"              [ self ] [ master ] [ use ] [ router ]\n"
-			"              [ local | temp | static ] [ dst IPADDR ] [ vlan VID ]\n"
+			"              [ local | static | dynamic ] [ dst IPADDR ] [ vlan VID ]\n"
 		        "              [ port PORT] [ vni VNI ] [ via DEV ]\n");
 	fprintf(stderr, "       bridge fdb [ show [ br BRDEV ] [ brport DEV ] ]\n");
 	exit(-1);
@@ -304,6 +304,9 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 		} else if (matches(*argv, "temp") == 0 ||
 			   matches(*argv, "static") == 0) {
 			req.ndm.ndm_state |= NUD_REACHABLE;
+		} else if (matches(*argv, "dynamic") == 0) {
+			req.ndm.ndm_state |= NUD_REACHABLE;
+			req.ndm.ndm_state &= ~NUD_NOARP;
 		} else if (matches(*argv, "vlan") == 0) {
 			if (vid >= 0)
 				duparg2("vlan", *argv);
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 0ec6f17..efd416e 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -54,7 +54,7 @@ bridge \- show / manipulate bridge addresses and devices
 .I LLADDR
 .B dev
 .IR DEV " { "
-.BR local " | " temp " } [ "
+.BR local " | " static " | " dynamic " } [ "
 .BR self " ] [ " master " ] [ " router " ] [ " use " ] [ "
 .B dst
 .IR IPADDR " ] [ "
@@ -338,6 +338,18 @@ the Ethernet MAC address.
 .BI dev " DEV"
 the interface to which this address is associated.
 
+.B local
+- is a local permanent fdb entry
+.sp
+
+.B static
+- is a static (no arp) fdb entry
+.sp
+
+.B dynamic
+- is a dynamic reachable age-able fdb entry
+.sp
+
 .B self
 - the address is associated with the port drivers fdb. Usually hardware.
 .sp
-- 
1.9.1
