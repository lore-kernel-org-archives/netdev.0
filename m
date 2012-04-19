From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 16/19] net:  Convert nf_conntrack_proto to use register_net_sysctl
Date: Thu, 19 Apr 2012 16:43:55 -0700
Message-ID: <m1r4vje18k.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, pablo@netfilter.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:53815 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272Ab2DSXjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 19:39:55 -0400
In-Reply-To: <m1aa27ia6h.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 19 Apr 2012 16:17:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There isn't much advantage here except that strings paths are a bit
easier to read, and converting everything to them allows me to kill off
ctl_path.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/netfilter/nf_conntrack_l3proto.h   |    2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    2 +-
 net/netfilter/nf_conntrack_proto.c             |    8 ++++----
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
index e8010f4..9699c02 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
@@ -65,7 +65,7 @@ struct nf_conntrack_l3proto {
 
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*ctl_table_header;
-	struct ctl_path		*ctl_table_path;
+	const char		*ctl_table_path;
 	struct ctl_table	*ctl_table;
 #endif /* CONFIG_SYSCTL */
 
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 345c7dc..91747d4 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -365,7 +365,7 @@ struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv4 __read_mostly = {
 	.nla_policy	 = ipv4_nla_policy,
 #endif
 #if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
-	.ctl_table_path  = nf_net_ipv4_netfilter_sysctl_path,
+	.ctl_table_path  = "net/ipv4/netfilter",
 	.ctl_table	 = ip_ct_sysctl_table,
 #endif
 	.me		 = THIS_MODULE,
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index bbc753f..8b631b0 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -36,11 +36,11 @@ static DEFINE_MUTEX(nf_ct_proto_mutex);
 
 #ifdef CONFIG_SYSCTL
 static int
-nf_ct_register_sysctl(struct ctl_table_header **header, struct ctl_path *path,
+nf_ct_register_sysctl(struct ctl_table_header **header, const char *path,
 		      struct ctl_table *table, unsigned int *users)
 {
 	if (*header == NULL) {
-		*header = register_net_sysctl_table(&init_net, path, table);
+		*header = register_net_sysctl(&init_net, path, table);
 		if (*header == NULL)
 			return -ENOMEM;
 	}
@@ -250,7 +250,7 @@ static int nf_ct_l4proto_register_sysctl(struct nf_conntrack_l4proto *l4proto)
 #ifdef CONFIG_SYSCTL
 	if (l4proto->ctl_table != NULL) {
 		err = nf_ct_register_sysctl(l4proto->ctl_table_header,
-					    nf_net_netfilter_sysctl_path,
+					    "net/netfilter",
 					    l4proto->ctl_table,
 					    l4proto->ctl_table_users);
 		if (err < 0)
@@ -259,7 +259,7 @@ static int nf_ct_l4proto_register_sysctl(struct nf_conntrack_l4proto *l4proto)
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
 	if (l4proto->ctl_compat_table != NULL) {
 		err = nf_ct_register_sysctl(&l4proto->ctl_compat_table_header,
-					    nf_net_ipv4_netfilter_sysctl_path,
+					    "net/ipv4/netfilter",
 					    l4proto->ctl_compat_table, NULL);
 		if (err == 0)
 			goto out;
-- 
1.7.2.5
