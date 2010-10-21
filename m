From: kaber@trash.net
Subject: [PATCH 24/72] IPVS: Allow configuration of persistence engines
Date: Thu, 21 Oct 2010 17:19:11 +0200
Message-ID: <1287674399-31455-25-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>

Allow the persistence engine of a virtual service to be set, edited
and unset.

This feature only works with the netlink user-space interface.

Signed-off-by: Simon Horman <horms@verge.net.au>
Acked-by: Julian Anastasov <ja@ssi.bg>
---
 include/linux/ip_vs.h          |    3 ++
 include/net/ip_vs.h            |    1 +
 net/netfilter/ipvs/ip_vs_ctl.c |   57 +++++++++++++++++++++++++++++++++++++--
 3 files changed, 58 insertions(+), 3 deletions(-)

diff --git a/include/linux/ip_vs.h b/include/linux/ip_vs.h
index 0a9c44d..5f43a3b 100644
--- a/include/linux/ip_vs.h
+++ b/include/linux/ip_vs.h
@@ -336,6 +336,9 @@ enum {
 	IPVS_SVC_ATTR_NETMASK,		/* persistent netmask */
 
 	IPVS_SVC_ATTR_STATS,		/* nested attribute for service stats */
+
+	IPVS_SVC_ATTR_PE_NAME,		/* name of ct retriever */
+
 	__IPVS_SVC_ATTR_MAX,
 };
 
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index a6b93a2..52fbe23 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -444,6 +444,7 @@ struct ip_vs_service_user_kern {
 
 	/* virtual service options */
 	char			*sched_name;
+	char			*pe_name;
 	unsigned		flags;		/* virtual service flags */
 	unsigned		timeout;	/* persistent timeout in sec */
 	u32			netmask;	/* persistent netmask */
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5f20caf..a697591 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1134,6 +1134,7 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 {
 	int ret = 0;
 	struct ip_vs_scheduler *sched = NULL;
+	struct ip_vs_pe *pe = NULL;
 	struct ip_vs_service *svc = NULL;
 
 	/* increase the module use count */
@@ -1147,6 +1148,16 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 		goto out_err;
 	}
 
+	if (u->pe_name && *u->pe_name) {
+		pe = ip_vs_pe_get(u->pe_name);
+		if (pe == NULL) {
+			pr_info("persistence engine module ip_vs_pe_%s "
+				"not found\n", u->pe_name);
+			ret = -ENOENT;
+			goto out_err;
+		}
+	}
+
 #ifdef CONFIG_IP_VS_IPV6
 	if (u->af == AF_INET6 && (u->netmask < 1 || u->netmask > 128)) {
 		ret = -EINVAL;
@@ -1184,6 +1195,10 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 		goto out_err;
 	sched = NULL;
 
+	/* Bind the ct retriever */
+	ip_vs_bind_pe(svc, pe);
+	pe = NULL;
+
 	/* Update the virtual service counters */
 	if (svc->port == FTPPORT)
 		atomic_inc(&ip_vs_ftpsvc_counter);
@@ -1215,6 +1230,7 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 		kfree(svc);
 	}
 	ip_vs_scheduler_put(sched);
+	ip_vs_pe_put(pe);
 
 	/* decrease the module use count */
 	ip_vs_use_count_dec();
@@ -1230,6 +1246,7 @@ static int
 ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 {
 	struct ip_vs_scheduler *sched, *old_sched;
+	struct ip_vs_pe *pe = NULL, *old_pe = NULL;
 	int ret = 0;
 
 	/*
@@ -1242,6 +1259,17 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 	}
 	old_sched = sched;
 
+	if (u->pe_name && *u->pe_name) {
+		pe = ip_vs_pe_get(u->pe_name);
+		if (pe == NULL) {
+			pr_info("persistence engine module ip_vs_pe_%s "
+				"not found\n", u->pe_name);
+			ret = -ENOENT;
+			goto out;
+		}
+		old_pe = pe;
+	}
+
 #ifdef CONFIG_IP_VS_IPV6
 	if (u->af == AF_INET6 && (u->netmask < 1 || u->netmask > 128)) {
 		ret = -EINVAL;
@@ -1293,12 +1321,17 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 		}
 	}
 
+	old_pe = svc->pe;
+	if (pe != old_pe) {
+		ip_vs_unbind_pe(svc);
+		ip_vs_bind_pe(svc, pe);
+	}
+
   out_unlock:
 	write_unlock_bh(&__ip_vs_svc_lock);
-#ifdef CONFIG_IP_VS_IPV6
   out:
-#endif
 	ip_vs_scheduler_put(old_sched);
+	ip_vs_pe_put(old_pe);
 	return ret;
 }
 
@@ -1312,6 +1345,9 @@ static void __ip_vs_del_service(struct ip_vs_service *svc)
 {
 	struct ip_vs_dest *dest, *nxt;
 	struct ip_vs_scheduler *old_sched;
+	struct ip_vs_pe *old_pe;
+
+	pr_info("%s: enter\n", __func__);
 
 	/* Count only IPv4 services for old get/setsockopt interface */
 	if (svc->af == AF_INET)
@@ -1324,6 +1360,11 @@ static void __ip_vs_del_service(struct ip_vs_service *svc)
 	ip_vs_unbind_scheduler(svc);
 	ip_vs_scheduler_put(old_sched);
 
+	/* Unbind persistence engine */
+	old_pe = svc->pe;
+	ip_vs_unbind_pe(svc);
+	ip_vs_pe_put(old_pe);
+
 	/* Unbind app inc */
 	if (svc->inc) {
 		ip_vs_app_inc_put(svc->inc);
@@ -2026,6 +2067,8 @@ static const unsigned char set_arglen[SET_CMDID(IP_VS_SO_SET_MAX)+1] = {
 static void ip_vs_copy_usvc_compat(struct ip_vs_service_user_kern *usvc,
 				  struct ip_vs_service_user *usvc_compat)
 {
+	memset(usvc, 0, sizeof(*usvc));
+
 	usvc->af		= AF_INET;
 	usvc->protocol		= usvc_compat->protocol;
 	usvc->addr.ip		= usvc_compat->addr;
@@ -2043,6 +2086,8 @@ static void ip_vs_copy_usvc_compat(struct ip_vs_service_user_kern *usvc,
 static void ip_vs_copy_udest_compat(struct ip_vs_dest_user_kern *udest,
 				   struct ip_vs_dest_user *udest_compat)
 {
+	memset(udest, 0, sizeof(*udest));
+
 	udest->addr.ip		= udest_compat->addr;
 	udest->port		= udest_compat->port;
 	udest->conn_flags	= udest_compat->conn_flags;
@@ -2539,6 +2584,8 @@ static const struct nla_policy ip_vs_svc_policy[IPVS_SVC_ATTR_MAX + 1] = {
 	[IPVS_SVC_ATTR_FWMARK]		= { .type = NLA_U32 },
 	[IPVS_SVC_ATTR_SCHED_NAME]	= { .type = NLA_NUL_STRING,
 					    .len = IP_VS_SCHEDNAME_MAXLEN },
+	[IPVS_SVC_ATTR_PE_NAME]		= { .type = NLA_NUL_STRING,
+					    .len = IP_VS_PENAME_MAXLEN },
 	[IPVS_SVC_ATTR_FLAGS]		= { .type = NLA_BINARY,
 					    .len = sizeof(struct ip_vs_flags) },
 	[IPVS_SVC_ATTR_TIMEOUT]		= { .type = NLA_U32 },
@@ -2615,6 +2662,8 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
 	}
 
 	NLA_PUT_STRING(skb, IPVS_SVC_ATTR_SCHED_NAME, svc->scheduler->name);
+	if (svc->pe)
+		NLA_PUT_STRING(skb, IPVS_SVC_ATTR_PE_NAME, svc->pe->name);
 	NLA_PUT(skb, IPVS_SVC_ATTR_FLAGS, sizeof(flags), &flags);
 	NLA_PUT_U32(skb, IPVS_SVC_ATTR_TIMEOUT, svc->timeout / HZ);
 	NLA_PUT_U32(skb, IPVS_SVC_ATTR_NETMASK, svc->netmask);
@@ -2741,11 +2790,12 @@ static int ip_vs_genl_parse_service(struct ip_vs_service_user_kern *usvc,
 
 	/* If a full entry was requested, check for the additional fields */
 	if (full_entry) {
-		struct nlattr *nla_sched, *nla_flags, *nla_timeout,
+		struct nlattr *nla_sched, *nla_flags, *nla_pe, *nla_timeout,
 			      *nla_netmask;
 		struct ip_vs_flags flags;
 
 		nla_sched = attrs[IPVS_SVC_ATTR_SCHED_NAME];
+		nla_pe = attrs[IPVS_SVC_ATTR_PE_NAME];
 		nla_flags = attrs[IPVS_SVC_ATTR_FLAGS];
 		nla_timeout = attrs[IPVS_SVC_ATTR_TIMEOUT];
 		nla_netmask = attrs[IPVS_SVC_ATTR_NETMASK];
@@ -2763,6 +2813,7 @@ static int ip_vs_genl_parse_service(struct ip_vs_service_user_kern *usvc,
 		usvc->flags = (usvc->flags & ~flags.mask) |
 			      (flags.flags & flags.mask);
 		usvc->sched_name = nla_data(nla_sched);
+		usvc->pe_name = nla_pe ? nla_data(nla_pe) : NULL;
 		usvc->timeout = nla_get_u32(nla_timeout);
 		usvc->netmask = nla_get_u32(nla_netmask);
 	}
-- 
1.7.1

