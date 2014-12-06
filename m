From: roopa@cumulusnetworks.com
Subject: [PATCH v3 iproute2] bridge link: add option 'self'
Date: Sat,  6 Dec 2014 00:21:01 -0800
Message-ID: <1417854061-4675-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:49217 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbaLFIVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2014 03:21:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Currently self is set internally only if hwmode is set.
This makes it necessary for the hw to have a mode.
There is no hwmode really required to go to hardware. So, introduce
self for anybody who wants to target hardware.

v1 -> v2
    - fix a few bugs. Initialize flags to zero: this was required to
    keep the current behaviour unchanged.

v2 -> v3
    - fix comment

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com> 

---
 bridge/link.c |   18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/bridge/link.c b/bridge/link.c
index 90d9e7f..3f77aab 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -261,7 +261,7 @@ static int brlink_modify(int argc, char **argv)
 	__s16 priority = -1;
 	__s8 state = -1;
 	__s16 mode = -1;
-	__u16 flags = BRIDGE_FLAGS_MASTER;
+	__u16 flags = 0;
 	struct rtattr *nest;
 
 	memset(&req, 0, sizeof(req));
@@ -321,6 +321,8 @@ static int brlink_modify(int argc, char **argv)
 					"\"veb\".\n");
 				exit(-1);
 			}
+		} else if (strcmp(*argv, "self") == 0) {
+			flags = BRIDGE_FLAGS_SELF;
 		} else {
 			usage();
 		}
@@ -369,16 +371,16 @@ static int brlink_modify(int argc, char **argv)
 
 	addattr_nest_end(&req.n, nest);
 
-	/* IFLA_AF_SPEC nested attribute.  Contains IFLA_BRIDGE_FLAGS that
-	 * designates master or self operation as well as 'vepa' or 'veb'
-	 * operation modes.  These are only valid in 'self' mode on some
-	 * devices so far.  Thus we only need to include the flags attribute
-	 * if we are setting the hw mode.
+	/* IFLA_AF_SPEC nested attribute. Contains IFLA_BRIDGE_FLAGS that
+	 * designates master or self operation and IFLA_BRIDGE_MODE
+	 * for hw 'vepa' or 'veb' operation modes. The hwmodes are
+	 * only valid in 'self' mode on some devices so far.
 	 */
-	if (mode >= 0) {
+	if (mode >= 0 || flags > 0) {
 		nest = addattr_nest(&req.n, sizeof(req), IFLA_AF_SPEC);
 
-		addattr16(&req.n, sizeof(req), IFLA_BRIDGE_FLAGS, flags);
+		if (flags > 0)
+			addattr16(&req.n, sizeof(req), IFLA_BRIDGE_FLAGS, flags);
 
 		if (mode >= 0)
 			addattr16(&req.n, sizeof(req), IFLA_BRIDGE_MODE, mode);
-- 
1.7.10.4
