From: roopa@cumulusnetworks.com
Subject: [PATCH v2 iproute] bridge link: add option 'self'
Date: Fri,  5 Dec 2014 16:59:23 -0800
Message-ID: <1417827563-811-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:39454 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbaLFA7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 19:59:22 -0500
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

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 bridge/link.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/bridge/link.c b/bridge/link.c
index 90d9e7f..b8b8675 100644
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
@@ -375,10 +377,11 @@ static int brlink_modify(int argc, char **argv)
 	 * devices so far.  Thus we only need to include the flags attribute
 	 * if we are setting the hw mode.
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
