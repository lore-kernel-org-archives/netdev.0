From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/50] netfilter: conntrack: add nf_conntrack_default_on sysctl
Date: Wed,  7 Dec 2016 22:52:24 +0100
Message-ID: <1481147576-5690-19-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60220 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933001AbcLGVxk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:40 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 7BBF4C0B50
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:34 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 664C3DA861
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:34 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 2E1EFDA729
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:32 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

This switch (default on) can be used to disable automatic registration
of connection tracking functionality in newly created network
namespaces.

This means that when net namespace goes down (or the tracker protocol
module is unloaded) we *might* have to unregister the hooks.

We can either add another per-netns variable that tells if
the hooks got registered by default, or, alternatively, just call
the protocol _put() function and have the callee deal with a possible
'extra' put() operation that doesn't pair with a get() one.

This uses the latter approach, i.e. a put() without a get has no effect.

Conntrack is still enabled automatically regardless of the new sysctl
setting if the new net namespace requires connection tracking, e.g. when
NAT rules are created.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 Documentation/networking/nf_conntrack-sysctl.txt | 11 +++++++++++
 include/net/netfilter/nf_conntrack_l3proto.h     |  9 +++++++++
 net/netfilter/nf_conntrack_proto.c               | 19 ++++++++++++++++++-
 net/netfilter/nf_conntrack_standalone.c          | 10 ++++++++++
 4 files changed, 48 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/nf_conntrack-sysctl.txt b/Documentation/networking/nf_conntrack-sysctl.txt
index 433b6724797a..497d668288f9 100644
--- a/Documentation/networking/nf_conntrack-sysctl.txt
+++ b/Documentation/networking/nf_conntrack-sysctl.txt
@@ -96,6 +96,17 @@ nf_conntrack_max - INTEGER
 	Size of connection tracking table.  Default value is
 	nf_conntrack_buckets value * 4.
 
+nf_conntrack_default_on - BOOLEAN
+	0 - don't register conntrack in new net namespaces
+	1 - register conntrack in new net namespaces (default)
+
+	This controls wheter newly created network namespaces have connection
+	tracking enabled by default.  It will be enabled automatically
+	regardless of this setting if the new net namespace requires
+	connection tracking, e.g. when NAT rules are created.
+	This setting is only visible in initial user namespace, it has no
+	effect on existing namespaces.
+
 nf_conntrack_tcp_be_liberal - BOOLEAN
 	0 - disabled (default)
 	not 0 - enabled
diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
index e7dcd72be21c..e01559b4d781 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
@@ -73,9 +73,18 @@ struct nf_conntrack_l3proto {
 
 extern struct nf_conntrack_l3proto __rcu *nf_ct_l3protos[AF_MAX];
 
+#ifdef CONFIG_SYSCTL
 /* Protocol pernet registration. */
 int nf_ct_l3proto_pernet_register(struct net *net,
 				  struct nf_conntrack_l3proto *proto);
+#else
+static inline int nf_ct_l3proto_pernet_register(struct net *n,
+						struct nf_conntrack_l3proto *p)
+{
+	return 0;
+}
+#endif
+
 void nf_ct_l3proto_pernet_unregister(struct net *net,
 				     struct nf_conntrack_l3proto *proto);
 
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 758688b25fd8..2d6ee1803415 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -238,12 +238,19 @@ int nf_ct_l3proto_register(struct nf_conntrack_l3proto *proto)
 }
 EXPORT_SYMBOL_GPL(nf_ct_l3proto_register);
 
+#ifdef CONFIG_SYSCTL
+extern unsigned int nf_conntrack_default_on;
+
 int nf_ct_l3proto_pernet_register(struct net *net,
 				  struct nf_conntrack_l3proto *proto)
 {
-	return 0;
+	if (nf_conntrack_default_on == 0)
+		return 0;
+
+	return proto->net_ns_get ? proto->net_ns_get(net) : 0;
 }
 EXPORT_SYMBOL_GPL(nf_ct_l3proto_pernet_register);
+#endif
 
 void nf_ct_l3proto_unregister(struct nf_conntrack_l3proto *proto)
 {
@@ -264,6 +271,16 @@ EXPORT_SYMBOL_GPL(nf_ct_l3proto_unregister);
 void nf_ct_l3proto_pernet_unregister(struct net *net,
 				     struct nf_conntrack_l3proto *proto)
 {
+	/*
+	 * nf_conntrack_default_on *might* have registered hooks.
+	 * ->net_ns_put must cope with more puts() than get(), i.e.
+	 * if nf_conntrack_default_on was 0 at time of
+	 * nf_ct_l3proto_pernet_register invocation this net_ns_put()
+	 * should be a noop.
+	 */
+	if (proto->net_ns_put)
+		proto->net_ns_put(net);
+
 	/* Remove all contrack entries for this protocol */
 	nf_ct_iterate_cleanup(net, kill_l3proto, proto, 0, 0);
 }
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 5f446cd9f3fd..d009ae663453 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -452,6 +452,9 @@ static int log_invalid_proto_max __read_mostly = 255;
 /* size the user *wants to set */
 static unsigned int nf_conntrack_htable_size_user __read_mostly;
 
+extern unsigned int nf_conntrack_default_on;
+unsigned int nf_conntrack_default_on __read_mostly = 1;
+
 static int
 nf_conntrack_hash_sysctl(struct ctl_table *table, int write,
 			 void __user *buffer, size_t *lenp, loff_t *ppos)
@@ -517,6 +520,13 @@ static struct ctl_table nf_ct_sysctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "nf_conntrack_default_on",
+		.data		= &nf_conntrack_default_on,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 	{ }
 };
 
-- 
2.1.4
