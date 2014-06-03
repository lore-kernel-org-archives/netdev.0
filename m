From: stannous@cumulusnetworks.com
Subject: [PATCH v2 ethtool] Force speed and duplex mode setting if link down
Date: Mon,  2 Jun 2014 22:45:17 -0400
Message-ID: <1401763517-13439-1-git-send-email-stannous@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, sfeldma@cumulusnetworks.com,
	stannous@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:48373 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518AbaFCCpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 22:45:07 -0400
Received: from localhost (localhost [127.0.0.1])
	by ext3.cumulusnetworks.com (Postfix) with ESMTP id EB7A517A398C
	for <netdev@vger.kernel.org>; Mon,  2 Jun 2014 19:45:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sam Tannous <stannous@cumulusnetworks.com>

This patch forces the user to set both the speed and the duplex
mode if the user only specifies the speed while the interface is down.

If the interface is down, we'll get an ecmd speed
and duplex mode of 0. This has the ill effect of
setting the duplex to HALF and this often results in an
error since many higher speed will not support HALF duplex.

Signed-off-by: Sam Tannous <stannous@cumulusnetworks.com>

---
v2:
* Corrected comment block.
---
 ethtool.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/ethtool.c b/ethtool.c
index 8e968a8..9285284 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2461,6 +2461,22 @@ static int do_sset(struct cmd_context *ctx)
 		if (err < 0) {
 			perror("Cannot get current device settings");
 		} else {
+			/* If the interface is down, we'll get an ecmd speed and
+			 * duplex of 0.  This has the effect of defaulting
+			 * the duplex mode to HALF.  This results in an
+			 * error since many of our speeds will not support HALF
+			 * any more.  To prevent this, we need to insist that
+			 * the user provide us with specific duplex mode if
+			 * they haven't already (likely FULL) if both the speed
+			 * and duplex are 0 here.
+			 */
+			if (speed_wanted != -1 && duplex_wanted == -1
+			    && !(ecmd.speed || ecmd.duplex)) {
+			    fprintf(stderr, "Setting the speed while the link "
+				    "is down requires both the speed and the "
+				    "duplex mode to be set");
+			    exit_bad_args();
+			}
 			/* Change everything the user specified. */
 			if (speed_wanted != -1)
 				ethtool_cmd_speed_set(&ecmd, speed_wanted);
-- 
1.7.10.4
