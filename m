From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] xfrm: export xfrm garbage collector thresholds via sysctl
Date: Mon, 27 Jul 2009 14:22:46 -0400
Message-ID: <20090727182246.GC15823@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joe@nall.com, nhorman@tuxdriver.com, davem@davemloft.net,
	herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43178 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751556AbZG0SXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 14:23:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export garbage collector thresholds for xfrm[4|6]_dst_ops

Had a problem reported to me recently in which a high volume of ipsec
connections on a system began reporting ENOBUFS for new connections eventually.
It seemed that after about 2000 connections we started being unable to create
more.  A quick look revealed that the xfrm code used a dst_ops structure that
limited the gc_thresh value to 1024, and alaways dropped route cache entries
after 2x the gc_thresh.  It seems the most direct solution is to export the
gc_thresh values in the xfrm[4|6] dst_ops as sysctls, like the main routing
table does, so that higher volumes of connections can be supported.  This patch
has been tested and allows the reporter to increase their ipsec connection
volume successfully.

Reported-by: Joe Nall <joe@nall.com>
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


ipv4/xfrm4_policy.c |   18 ++++++++++++++++++
ipv6/xfrm6_policy.c |   18 ++++++++++++++++++
2 files changed, 36 insertions(+)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 0071ee6..018ac8b 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -264,6 +264,20 @@ static struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
 	.fill_dst =		xfrm4_fill_dst,
 };
 
+static struct ctl_table xfrm4_policy_table[] = {
+	{
+		.ctl_name       = CTL_UNNUMBERED,
+		.procname       = "xfrm4_gc_thresh",
+		.data           = &xfrm4_dst_ops.gc_thresh,
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler   = proc_dointvec,
+	},
+	{ }
+};
+
+static struct ctl_table_header *sysctl_hdr;
+
 static void __init xfrm4_policy_init(void)
 {
 	xfrm_policy_register_afinfo(&xfrm4_policy_afinfo);
@@ -271,6 +285,8 @@ static void __init xfrm4_policy_init(void)
 
 static void __exit xfrm4_policy_fini(void)
 {
+	if (sysctl_hdr)
+		unregister_net_sysctl_table(sysctl_hdr);
 	xfrm_policy_unregister_afinfo(&xfrm4_policy_afinfo);
 }
 
@@ -278,5 +294,7 @@ void __init xfrm4_init(void)
 {
 	xfrm4_state_init();
 	xfrm4_policy_init();
+	sysctl_hdr = register_net_sysctl_table(&init_net, net_ipv4_ctl_path,
+						xfrm4_policy_table);
 }
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 3a3c677..4acc308 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -306,6 +306,20 @@ static void xfrm6_policy_fini(void)
 	xfrm_policy_unregister_afinfo(&xfrm6_policy_afinfo);
 }
 
+static struct ctl_table xfrm6_policy_table[] = {
+	{
+		.ctl_name       = CTL_UNNUMBERED,
+		.procname       = "xfrm6_gc_thresh",
+		.data	   	= &xfrm6_dst_ops.gc_thresh,
+		.maxlen	 	= sizeof(int),
+		.mode	   	= 0644,
+		.proc_handler   = proc_dointvec,
+	},
+	{ }
+};
+
+static struct ctl_table_header *sysctl_hdr;
+
 int __init xfrm6_init(void)
 {
 	int ret;
@@ -317,6 +331,8 @@ int __init xfrm6_init(void)
 	ret = xfrm6_state_init();
 	if (ret)
 		goto out_policy;
+	sysctl_hdr = register_net_sysctl_table(&init_net, net_ipv6_ctl_path,
+						xfrm6_policy_table);
 out:
 	return ret;
 out_policy:
@@ -326,6 +342,8 @@ out_policy:
 
 void xfrm6_fini(void)
 {
+	if (sysctl_hdr)
+		unregister_net_sysctl_table(sysctl_hdr);
 	//xfrm6_input_fini();
 	xfrm6_policy_fini();
 	xfrm6_state_fini();
