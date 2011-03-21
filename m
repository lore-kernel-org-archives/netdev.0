From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] net ipv6: Fix duplicate /proc/sys/net/ipv6/neigh directory entries.
Date: Mon, 21 Mar 2011 14:20:18 -0700
Message-ID: <m14o6wjhm5.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, sunkan@zappa.cx
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:48872 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754520Ab1CUVUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 17:20:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When I was fixing issues with unregisgtering tables under /proc/sys/net/ipv6/neigh
by adding a mount point it appears I missed a critical ordering issue, in the
ipv6 initialization.  I had not realized that ipv6_sysctl_register is called
at the very end of the ipv6 initialization and in particular after we call
neigh_sysctl_register from ndisc_init.

"neigh" needs to be initialized in ipv6_static_sysctl_register which is
the first ipv6 table to initialized, and definitely before ndisc_init.
This removes the weirdness of duplicate tables while still providing a
"neigh" mount point which prevents races in sysctl unregistering.

This was initially reported at https://bugzilla.kernel.org/show_bug.cgi?id=31232
Reported-by: sunkan@zappa.cx
Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 net/ipv6/sysctl_net_ipv6.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 7cb65ef..6dcf5e7 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -17,6 +17,16 @@
 
 static struct ctl_table empty[1];
 
+static ctl_table ipv6_static_skeleton[] = {
+	{
+		.procname	= "neigh",
+		.maxlen		= 0,
+		.mode		= 0555,
+		.child		= empty,
+	},
+	{ }
+};
+
 static ctl_table ipv6_table_template[] = {
 	{
 		.procname	= "route",
@@ -37,12 +47,6 @@ static ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{
-		.procname	= "neigh",
-		.maxlen		= 0,
-		.mode		= 0555,
-		.child		= empty,
-	},
 	{ }
 };
 
@@ -160,7 +164,7 @@ static struct ctl_table_header *ip6_base;
 
 int ipv6_static_sysctl_register(void)
 {
-	ip6_base = register_sysctl_paths(net_ipv6_ctl_path, empty);
+	ip6_base = register_sysctl_paths(net_ipv6_ctl_path, ipv6_static_skeleton);
 	if (ip6_base == NULL)
 		return -ENOMEM;
 	return 0;
-- 
1.7.4

