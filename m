From: kan.liang@intel.com
Subject: [RFC 1/5] ethtool: move option parsing related codes into function
Date: Thu, 17 Dec 2015 06:53:02 +0000
Message-ID: <1450335186-3062-1-git-send-email-kan.liang@intel.com>
Cc: jesse.brandeburg@intel.com, andi@firstfloor.org,
	f.fainelli@gmail.com, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net, ben@decadent.org.uk,
	Kan Liang <kan.liang@intel.com>
To: netdev@vger.kernel.org, davem@davemloft.net, bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15482 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751395AbbLQSe3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2015 13:34:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

Move option parsing code into find_option function.
No behavior changes.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 ethtool.c | 49 +++++++++++++++++++++++++++++++------------------
 1 file changed, 31 insertions(+), 18 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 92c40b8..04c5015 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -4173,6 +4173,29 @@ static int show_usage(struct cmd_context *ctx)
 	return 0;
 }
 
+static int find_option(int argc, char **argp)
+{
+	const char *opt;
+	size_t len;
+	int k;
+
+	for (k = 0; args[k].opts; k++) {
+		opt = args[k].opts;
+		for (;;) {
+			len = strcspn(opt, "|");
+			if (strncmp(*argp, opt, len) == 0 &&
+			    (*argp)[len] == 0)
+				return k;
+
+			if (opt[len] == 0)
+				break;
+			opt += len + 1;
+		}
+	}
+
+	return -1;
+}
+
 int main(int argc, char **argp)
 {
 	int (*func)(struct cmd_context *);
@@ -4190,24 +4213,14 @@ int main(int argc, char **argp)
 	 */
 	if (argc == 0)
 		exit_bad_args();
-	for (k = 0; args[k].opts; k++) {
-		const char *opt;
-		size_t len;
-		opt = args[k].opts;
-		for (;;) {
-			len = strcspn(opt, "|");
-			if (strncmp(*argp, opt, len) == 0 &&
-			    (*argp)[len] == 0) {
-				argp++;
-				argc--;
-				func = args[k].func;
-				want_device = args[k].want_device;
-				goto opt_found;
-			}
-			if (opt[len] == 0)
-				break;
-			opt += len + 1;
-		}
+
+	k = find_option(argc, argp);
+	if (k > 0) {
+		argp++;
+		argc--;
+		func = args[k].func;
+		want_device = args[k].want_device;
+		goto opt_found;
 	}
 	if ((*argp)[0] == '-')
 		exit_bad_args();
-- 
1.7.11.7
