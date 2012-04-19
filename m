From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 10/19] net llc: Don't use sysctl tables with .child entries.
Date: Thu, 19 Apr 2012 16:35:39 -0700
Message-ID: <m1mx67fg6s.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, pablo@netfilter.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:48224 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756038Ab2DSXbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 19:31:39 -0400
In-Reply-To: <m1aa27ia6h.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 19 Apr 2012 16:17:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The sysctl core no longer natively understands sysctl tables with .child
entries.

Kill the intermediate tables and use register_net_sysctl directly to
remove the need for compatibility code.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/llc/sysctl_net_llc.c |   51 ++++++++++++++-------------------------------
 1 files changed, 16 insertions(+), 35 deletions(-)

diff --git a/net/llc/sysctl_net_llc.c b/net/llc/sysctl_net_llc.c
index 9a6a65f..d75306b 100644
--- a/net/llc/sysctl_net_llc.c
+++ b/net/llc/sysctl_net_llc.c
@@ -57,48 +57,29 @@ static struct ctl_table llc_station_table[] = {
 	{ },
 };
 
-static struct ctl_table llc2_dir_timeout_table[] = {
-	{
-		.procname	= "timeout",
-		.mode		= 0555,
-		.child		= llc2_timeout_table,
-	},
-	{ },
-};
-
-static struct ctl_table llc_table[] = {
-	{
-		.procname	= "llc2",
-		.mode		= 0555,
-		.child		= llc2_dir_timeout_table,
-	},
-	{
-		.procname       = "station",
-		.mode           = 0555,
-		.child          = llc_station_table,
-	},
-	{ },
-};
-
-static struct ctl_path llc_path[] = {
-	{ .procname = "net", },
-	{ .procname = "llc", },
-	{ }
-};
-
-static struct ctl_table_header *llc_table_header;
+static struct ctl_table_header *llc2_timeout_header;
+static struct ctl_table_header *llc_station_header;
 
 int __init llc_sysctl_init(void)
 {
-	llc_table_header = register_net_sysctl_table(&init_net, llc_path, llc_table);
+	llc2_timeout_header = register_net_sysctl(&init_net, "net/llc/llc2/timeout", llc2_timeout_table);
+	llc_station_header = register_net_sysctl(&init_net, "net/llc/station", llc_station_table);
 
-	return llc_table_header ? 0 : -ENOMEM;
+	if (!llc2_timeout_header || !llc_station_header) {
+		llc_sysctl_exit();
+		return -ENOMEM;
+	}
+	return 0;
 }
 
 void llc_sysctl_exit(void)
 {
-	if (llc_table_header) {
-		unregister_net_sysctl_table(llc_table_header);
-		llc_table_header = NULL;
+	if (llc2_timeout_header) {
+		unregister_net_sysctl_table(llc2_timeout_header);
+		llc2_timeout_header = NULL;
+	}
+	if (llc_station_header) {
+		unregister_net_sysctl_table(llc_station_header);
+		llc_station_header = NULL;
 	}
 }
-- 
1.7.2.5
