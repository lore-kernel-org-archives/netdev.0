From: Davide Caratti <dcaratti@redhat.com>
Subject: [iproute PATCH 1/3] macsec: fix input of 'port', improve documentation of 'address'
Date: Tue, 30 Aug 2016 13:23:12 +0200
Message-ID: <005f485d3a537def837597ba553923f5c8203683.1472552276.git.dcaratti@redhat.com>
References: <cover.1472552276.git.dcaratti@redhat.com>
Cc: stephen@networkplumber.org, sd@queasysnail.net, phil@nwl.cc
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46012 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757682AbcH3LX4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 Aug 2016 07:23:56 -0400
In-Reply-To: <cover.1472552276.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

remove hardcoded base 10 parsing of 'port' parameter, update man page
and fix usage() functions as well. Fix misleading line in man page that
theoretically allowed specifying 'port' keyword right after 'sci' keyword.
Provide documentation of 'address' parameter in man pages and in usage()
functions as well.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 ip/ipmacsec.c         |  6 +++---
 man/man8/ip-link.8.in | 14 +++++++++++---
 man/man8/ip-macsec.8  | 12 +++++++++---
 3 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/ip/ipmacsec.c b/ip/ipmacsec.c
index 6bd1f54..c75e9d3 100644
--- a/ip/ipmacsec.c
+++ b/ip/ipmacsec.c
@@ -95,7 +95,7 @@ static void ipmacsec_usage(void)
 	fprintf(stderr, "where  OPTS := [ pn <u32> ] [ on | off ]\n");
 	fprintf(stderr, "       ID   := 128-bit hex string\n");
 	fprintf(stderr, "       KEY  := 128-bit hex string\n");
-	fprintf(stderr, "       SCI  := { sci <u64> | port <u16> address <lladdr> }\n");
+	fprintf(stderr, "       SCI  := { sci <u64> | port { 1..2^16-1 } address <lladdr> }\n");
 
 	exit(-1);
 }
@@ -139,7 +139,7 @@ static int get_sci(__u64 *sci, const char *arg)
 
 static int get_port(__be16 *port, const char *arg)
 {
-	return get_be16(port, arg, 10);
+	return get_be16(port, arg, 0);
 }
 
 #define _STR(a) #a
@@ -1069,7 +1069,7 @@ static bool check_txsc_flags(bool es, bool scb, bool sci)
 static void usage(FILE *f)
 {
 	fprintf(f,
-		"Usage: ... macsec [ port PORT | sci SCI ]\n"
+		"Usage: ... macsec [ [ address <lladdr> ] port { 1..2^16-1 } | sci <u64> ]\n"
 		"                  [ cipher { default | gcm-aes-128 } ]\n"
 		"                  [ icvlen { 8..16 } ]\n"
 		"                  [ encrypt { on | off } ]\n"
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 58247ce..6fb5ad6 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -952,7 +952,9 @@ For a link of type
 the following additional arguments are supported:
 
 .BI "ip link add link " DEVICE " name " NAME " type macsec"
-[
+[ [
+.BI address " <lladdr>"
+]
 .BI port " PORT"
 |
 .BI sci " SCI"
@@ -976,8 +978,14 @@ the following additional arguments are supported:
 
 .in +8
 .sp
-.BI  port " PORT "
-- sets the port number for this MACsec device.
+.BI address " <lladdr> "
+- sets the system identifier component of secure channel for this MACsec device.
+
+.sp
+.BI port " PORT "
+- sets the port number component of secure channel for this MACsec device, in a
+range from 1 to 65535 inclusive. Numbers with a leading " 0 " or " 0x " are
+interpreted as octal and hexadecimal, respectively.
 
 .sp
 .BI sci " SCI "
diff --git a/man/man8/ip-macsec.8 b/man/man8/ip-macsec.8
index 105aeec..1aca3bd 100644
--- a/man/man8/ip-macsec.8
+++ b/man/man8/ip-macsec.8
@@ -3,10 +3,12 @@
 ip-macsec \- MACsec device configuration
 .SH "SYNOPSIS"
 .BI "ip link add link " DEVICE " name " NAME " type macsec "
-[
+[ [
+.BI address " <lladdr>"
+]
 .BI port " PORT"
 |
-.BI sci  " SCI"
+.BI sci " <u64>"
 ] [
 .BR cipher " { " default " | " gcm-aes-128 " } ] ["
 .BI icvlen " ICVLEN"
@@ -62,8 +64,12 @@ ip-macsec \- MACsec device configuration
 .IR SCI " := { "
 .B sci
 .IR <u64> " | "
-.BI port " <u16> " address " <lladdr> "
+.BI port
+.IR PORT
+.BI address " <lladdr> "
 }
+.br
+.IR PORT " := { " 1..2^16-1 " } "
 
 
 .SH DESCRIPTION
-- 
2.5.5
