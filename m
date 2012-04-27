From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 01/17] netfilter: add struct nf_proto_net for register l4proto sysctl
Date: Fri, 27 Apr 2012 17:37:48 +0800
Message-ID: <1335519484-6089-2-git-send-email-gaofeng@cn.fujitsu.com>
References: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitus.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:36137 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1759938Ab2D0Jhq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2012 05:37:46 -0400
In-Reply-To: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitus.com>

the struct nf_proto_net stroes proto's ctl_table_header and ctl_table,
nf_ct_l4proto_(un)register_sysctl use it to register sysctl.

there are some changes for struct nf_conntrack_l4proto:
- add field compat to identify if this proto should do compat.
- the net_id field is used to store the pernet_operations id
  that belones to l4proto.
- init_net will be used to initial the proto's pernet data

and add init_net for struct nf_conntrack_l3proto too.

Signed-off-by: Gao feng <gaofeng@cn.fujitus.com>
---
 include/net/netfilter/nf_conntrack_l3proto.h |    3 +++
 include/net/netfilter/nf_conntrack_l4proto.h |    6 ++++++
 include/net/netns/conntrack.h                |   12 ++++++++++++
 3 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
index 9699c02..9766005 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
@@ -69,6 +69,9 @@ struct nf_conntrack_l3proto {
 	struct ctl_table	*ctl_table;
 #endif /* CONFIG_SYSCTL */
 
+	/* Init l3proto pernet data */
+	int (*init_net)(struct net *net);
+
 	/* Module (if any) which this is connected to. */
 	struct module *me;
 };
diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 3b572bb..ad8ff89 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -21,6 +21,8 @@ struct nf_conntrack_l4proto {
 
 	/* L4 Protocol number. */
 	u_int8_t l4proto;
+
+	u_int8_t compat;
 
 	/* Try to fill in the third arg: dataoff is offset past network protocol
            hdr.  Return true if possible. */
@@ -103,6 +105,10 @@ struct nf_conntrack_l4proto {
 	struct ctl_table	*ctl_compat_table;
 #endif
 #endif
+	int	*net_id;
+	/* Init l4proto pernet data */
+	int (*init_net)(struct net *net, u_int8_t compat);
+
 	/* Protocol name */
 	const char *name;
 
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 7a911ec..59afb87 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -8,6 +8,18 @@
 struct ctl_table_header;
 struct nf_conntrack_ecache;
 
+struct nf_proto_net {
+#ifdef CONFIG_SYSCTL
+	struct ctl_table_header *ctl_table_header;
+	struct ctl_table        *ctl_table;
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	struct ctl_table_header *ctl_compat_header;
+	struct ctl_table        *ctl_compat_table;
+#endif
+#endif
+	unsigned int		users;
+};
+
 struct netns_ct {
 	atomic_t		count;
 	unsigned int		expect_count;
-- 
1.7.7.6
