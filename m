From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 03/19] net sysctl: Initialize the network sysctls sooner to avoid problems.
Date: Thu, 19 Apr 2012 16:20:32 -0700
Message-ID: <m1ty0fgvgf.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, pablo@netfilter.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:50696 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577Ab2DSXQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 19:16:32 -0400
In-Reply-To: <m1aa27ia6h.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 19 Apr 2012 16:17:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If the netfilter code is modified to use register_net_sysctl_table the
kernel fails to boot because the per net sysctl infrasturce is not setup
soon enough.  So to avoid races call net_sysctl_init from sock_init().

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/net_namespace.h |    5 +++++
 net/socket.c                |    6 ++++++
 net/sysctl_net.c            |    3 +--
 3 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 446245e..767dcd40 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -283,6 +283,11 @@ struct ctl_path;
 struct ctl_table;
 struct ctl_table_header;
 
+#ifdef CONFIG_SYSCTL
+extern int net_sysctl_init(void);
+#else
+static inline int net_sysctl_init(void) { return 0; }
+#endif
 extern struct ctl_table_header *register_net_sysctl_table(struct net *net,
 	const struct ctl_path *path, struct ctl_table *table);
 extern struct ctl_table_header *register_net_sysctl_rotable(
diff --git a/net/socket.c b/net/socket.c
index d6c1af9..e345109 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2524,6 +2524,12 @@ EXPORT_SYMBOL(sock_unregister);
 static int __init sock_init(void)
 {
 	int err;
+	/*
+	 *      Initialize the network sysctl infrastructure.
+	 */
+	err = net_sysctl_init();
+	if (err)
+		goto out;
 
 	/*
 	 *      Initialize sock SLAB cache.
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index 2b2986d..ce97237 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -89,7 +89,7 @@ static struct pernet_operations sysctl_pernet_ops = {
 };
 
 static struct ctl_table_header *net_header;
-static __init int net_sysctl_init(void)
+__init int net_sysctl_init(void)
 {
 	static struct ctl_table empty[1];
 	int ret = -ENOMEM;
@@ -109,7 +109,6 @@ static __init int net_sysctl_init(void)
 out:
 	return ret;
 }
-subsys_initcall(net_sysctl_init);
 
 struct ctl_table_header *register_net_sysctl_table(struct net *net,
 	const struct ctl_path *path, struct ctl_table *table)
-- 
1.7.2.5
