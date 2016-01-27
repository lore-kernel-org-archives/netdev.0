From: "Rosen, Rami" <rami.rosen@intel.com>
Subject: RE: [PATCH iproute2] bridge: support for static fdb entries
Date: Wed, 27 Jan 2016 19:30:18 +0000
Message-ID: <9B0331B6EBBD0E4684FBFAEDA55776F92CB5E597@HASMSX110.ger.corp.intel.com>
References: <1453914577-43389-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wkok@cumulusnetworks.com" <wkok@cumulusnetworks.com>,
	"scotte@cumulusnetworks.com" <scotte@cumulusnetworks.com>,
	"nikolay@cumulusnetworks.com" <nikolay@cumulusnetworks.com>,
	"makita.toshiaki@lab.ntt.co.jp" <makita.toshiaki@lab.ntt.co.jp>,
	"Rosen, Rami" <rami.rosen@intel.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64695 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934408AbcA0TaX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 14:30:23 -0500
In-Reply-To: <1453914577-43389-1-git-send-email-roopa@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+1
'temp' seems indeed not to be intuitive enough as 'static' in this context.

Regards,
Rami Rosen
Intel Corporation


-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Roopa Prabhu
Sent: Wednesday, January 27, 2016 7:10 PM
To: stephen@networkplumber.org
Cc: netdev@vger.kernel.org; wkok@cumulusnetworks.com; scotte@cumulusnetworks.com; nikolay@cumulusnetworks.com; makita.toshiaki@lab.ntt.co.jp
Subject: [PATCH iproute2] bridge: support for static fdb entries

From: Roopa Prabhu <roopa@cumulusnetworks.com>

There is no intuitive option to add static fdb entries today.
'temp' seems to have a side effect of adding
'static' fdb entries. But the name and intent
of 'temp' does not say anything about it being static.

example:
bridge fdb add operates as follows:

$bridge fdb add 00:01:02:03:04:05 dev eth0 master
$bridge fdb add 00:01:02:03:04:06 dev eth0 master temp
$bridge fdb add 00:01:02:03:04:07 dev eth0 master local

$bridge fdb show
00:01:02:03:04:05 dev eth0 permanent
00:01:02:03:04:06 dev eth0 static
00:01:02:03:04:07 dev eth0 permanent
00:01:02:03:04:08 dev eth0 <<== dynamic, ageable learned mac

This patch adds a new bridge fdb type 'static' which
makes sure NUD_NOARP and NUD_REACHABLE is set for static
entries. This effectively is nothing but what 'temp'
does today. But the name 'temp' is misleading.

After the patch:
$bridge fdb add 00:01:02:03:04:06 dev eth0 master static

$bridge fdb show
00:01:02:03:04:06 dev eth0 static

'temp' could ideally be a dynamic mac that can age (ie just
NUD_REACHABLE). But, 'temp' sets 'NUD_NOARP' and 'NUD_REACHABLE'.
Too late to change 'temp' now. But, we are thinking of introduing a
'dynamic' keyword after this patch that only sets NUD_REACHABLE.

Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
Will submit another patch to document bridge fdb options
once we agree on the behaviour and this patch is accepted.

 bridge/fdb.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index 4d10925..9bc6b94 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -33,7 +33,7 @@ static void usage(void)
 {
 	fprintf(stderr, "Usage: bridge fdb { add | append | del | replace } ADDR dev DEV\n"
 			"              [ self ] [ master ] [ use ] [ router ]\n"
-			"              [ local | temp ] [ dst IPADDR ] [ vlan VID ]\n"
+			"              [ local | temp | static ] [ dst IPADDR ] [ vlan VID ]\n"
 		        "              [ port PORT] [ vni VNI ] [ via DEV ]\n");
 	fprintf(stderr, "       bridge fdb [ show [ br BRDEV ] [ brport DEV ] ]\n");
 	exit(-1);
@@ -301,7 +301,8 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 		} else if (matches(*argv, "local") == 0||
 			   matches(*argv, "permanent") == 0) {
 			req.ndm.ndm_state |= NUD_PERMANENT;
-		} else if (matches(*argv, "temp") == 0) {
+		} else if (matches(*argv, "temp") == 0 ||
+			   matches(*argv, "static") == 0) {
 			req.ndm.ndm_state |= NUD_REACHABLE;
 		} else if (matches(*argv, "vlan") == 0) {
 			if (vid >= 0)
-- 
1.9.1
