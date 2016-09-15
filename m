From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 7/7] ila: Resolver mechanism
Date: Thu, 15 Sep 2016 14:19:21 -0700
Message-ID: <1473974361-2275254-8-git-send-email-tom@herbertland.com>
References: <1473974361-2275254-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <roopa@cumulusnetworks.com>, <tgraf@suug.ch>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:34096 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755968AbcIOVTn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 17:19:43 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8FLJM9j008037
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 14:19:42 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25g2yag761-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 14:19:42 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 1d46016c7b8a11e6873424be05956610-7f4f4a50 for <netdev@vger.kernel.org>;        Thu,
 15 Sep 2016 14:19:41 -0700
In-Reply-To: <1473974361-2275254-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement an ILA resolver. This uses LWT to implement the hook to a
userspace resolver and tracks pending unresolved address using the
backend net resolver.

The idea is that the kernel sets an ILA resolver route to the
SIR prefix, something like:

ip route add 3333::/64 encap ila-resolve \
     via 2401:db00:20:911a::27:0 dev eth0

When a packet hits the route the address is looked up in a resolver
table. If the entry is created (no entry with the address already
exists) then an rtnl message is generated with group
RTNLGRP_ILA_NOTIFY and type RTM_ADDR_RESOLVE. A userspace
daemon can listen for such messages and perform an ILA resolution
protocol to determine the ILA mapping. If the mapping is resolved
then a /128 ila encap router is set so that host can perform
ILA translation and send directly to destination.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/uapi/linux/ila.h       |   9 ++
 include/uapi/linux/lwtunnel.h  |   1 +
 include/uapi/linux/rtnetlink.h |   8 +-
 net/ipv6/Kconfig               |   1 +
 net/ipv6/ila/Makefile          |   2 +-
 net/ipv6/ila/ila.h             |  16 +++
 net/ipv6/ila/ila_common.c      |   7 ++
 net/ipv6/ila/ila_lwt.c         |   9 ++
 net/ipv6/ila/ila_resolver.c    | 249 +++++++++++++++++++++++++++++++++++++++++
 net/ipv6/ila/ila_xlat.c        |  15 ++-
 10 files changed, 307 insertions(+), 10 deletions(-)
 create mode 100644 net/ipv6/ila/ila_resolver.c

diff --git a/include/uapi/linux/ila.h b/include/uapi/linux/ila.h
index 948c0a9..f186f8b 100644
--- a/include/uapi/linux/ila.h
+++ b/include/uapi/linux/ila.h
@@ -42,4 +42,13 @@ enum {
 	ILA_CSUM_NO_ACTION,
 };
 
+enum {
+	ILA_NOTIFY_ATTR_UNSPEC,
+	ILA_NOTIFY_ATTR_TIMEOUT,		/* u32 */
+
+	__ILA_NOTIFY_ATTR_MAX,
+};
+
+#define ILA_NOTIFY_ATTR_MAX	(__ILA_NOTIFY_ATTR_MAX - 1)
+
 #endif /* _UAPI_LINUX_ILA_H */
diff --git a/include/uapi/linux/lwtunnel.h b/include/uapi/linux/lwtunnel.h
index a478fe8..d880e49 100644
--- a/include/uapi/linux/lwtunnel.h
+++ b/include/uapi/linux/lwtunnel.h
@@ -9,6 +9,7 @@ enum lwtunnel_encap_types {
 	LWTUNNEL_ENCAP_IP,
 	LWTUNNEL_ENCAP_ILA,
 	LWTUNNEL_ENCAP_IP6,
+	LWTUNNEL_ENCAP_ILA_NOTIFY,
 	__LWTUNNEL_ENCAP_MAX,
 };
 
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 262f037..a775464 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -12,7 +12,8 @@
  */
 #define RTNL_FAMILY_IPMR		128
 #define RTNL_FAMILY_IP6MR		129
-#define RTNL_FAMILY_MAX			129
+#define RTNL_FAMILY_ILA			130
+#define RTNL_FAMILY_MAX			130
 
 /****
  *		Routing/neighbour discovery messages.
@@ -144,6 +145,9 @@ enum {
 	RTM_GETSTATS = 94,
 #define RTM_GETSTATS RTM_GETSTATS
 
+	RTM_ADDR_RESOLVE = 95,
+#define RTM_ADDR_RESOLVE RTM_ADDR_RESOLVE
+
 	__RTM_MAX,
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
@@ -656,6 +660,8 @@ enum rtnetlink_groups {
 #define RTNLGRP_MPLS_ROUTE	RTNLGRP_MPLS_ROUTE
 	RTNLGRP_NSID,
 #define RTNLGRP_NSID		RTNLGRP_NSID
+	RTNLGRP_ILA_NOTIFY,
+#define RTNLGRP_ILA_NOTIFY	RTNLGRP_ILA_NOTIFY
 	__RTNLGRP_MAX
 };
 #define RTNLGRP_MAX	(__RTNLGRP_MAX - 1)
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 2343e4f..cf3ea8e 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -97,6 +97,7 @@ config IPV6_ILA
 	tristate "IPv6: Identifier Locator Addressing (ILA)"
 	depends on NETFILTER
 	select LWTUNNEL
+	select NET_EXT_RESOLVER
 	---help---
 	  Support for IPv6 Identifier Locator Addressing (ILA).
 
diff --git a/net/ipv6/ila/Makefile b/net/ipv6/ila/Makefile
index 4b32e59..f2aadc3 100644
--- a/net/ipv6/ila/Makefile
+++ b/net/ipv6/ila/Makefile
@@ -4,4 +4,4 @@
 
 obj-$(CONFIG_IPV6_ILA) += ila.o
 
-ila-objs := ila_common.o ila_lwt.o ila_xlat.o
+ila-objs := ila_common.o ila_lwt.o ila_xlat.o ila_resolver.o
diff --git a/net/ipv6/ila/ila.h b/net/ipv6/ila/ila.h
index e0170f6..e369611 100644
--- a/net/ipv6/ila/ila.h
+++ b/net/ipv6/ila/ila.h
@@ -15,6 +15,7 @@
 #include <linux/ip.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
+#include <linux/rhashtable.h>
 #include <linux/socket.h>
 #include <linux/skbuff.h>
 #include <linux/types.h>
@@ -23,6 +24,16 @@
 #include <net/protocol.h>
 #include <uapi/linux/ila.h>
 
+extern unsigned int ila_net_id;
+
+struct ila_net {
+	struct rhashtable rhash_table;
+	spinlock_t *locks; /* Bucket locks for entry manipulation */
+	unsigned int locks_mask;
+	bool hooks_registered;
+	struct net_rslv *nrslv;
+};
+
 struct ila_locator {
 	union {
 		__u8            v8[8];
@@ -114,9 +125,14 @@ void ila_update_ipv6_locator(struct sk_buff *skb, struct ila_params *p,
 
 void ila_init_saved_csum(struct ila_params *p);
 
+void ila_rslv_resolved(struct ila_net *ilan, struct ila_addr *iaddr);
 int ila_lwt_init(void);
 void ila_lwt_fini(void);
 int ila_xlat_init(void);
 void ila_xlat_fini(void);
+int ila_rslv_init(void);
+void ila_rslv_fini(void);
+int ila_init_resolver_net(struct ila_net *ilan);
+void ila_exit_resolver_net(struct ila_net *ilan);
 
 #endif /* __ILA_H */
diff --git a/net/ipv6/ila/ila_common.c b/net/ipv6/ila/ila_common.c
index aba0998..83c7d4a 100644
--- a/net/ipv6/ila/ila_common.c
+++ b/net/ipv6/ila/ila_common.c
@@ -157,7 +157,13 @@ static int __init ila_init(void)
 	if (ret)
 		goto fail_xlat;
 
+	ret = ila_rslv_init();
+	if (ret)
+		goto fail_rslv;
+
 	return 0;
+fail_rslv:
+	ila_xlat_fini();
 fail_xlat:
 	ila_lwt_fini();
 fail_lwt:
@@ -168,6 +174,7 @@ static void __exit ila_fini(void)
 {
 	ila_xlat_fini();
 	ila_lwt_fini();
+	ila_rslv_fini();
 }
 
 module_init(ila_init);
diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
index 30a6920..70d8988 100644
--- a/net/ipv6/ila/ila_lwt.c
+++ b/net/ipv6/ila/ila_lwt.c
@@ -9,6 +9,7 @@
 #include <net/ip.h>
 #include <net/ip6_fib.h>
 #include <net/lwtunnel.h>
+#include <net/netns/generic.h>
 #include <net/protocol.h>
 #include <uapi/linux/ila.h>
 #include "ila.h"
@@ -122,6 +123,14 @@ static int ila_build_state(struct net *net, struct net_device *dev,
 
 	*ts = newts;
 
+	if (cfg6->fc_dst_len >= sizeof(struct ila_addr)) {
+		struct net *net = dev_net(dev);
+		struct ila_net *ilan = net_generic(net, ila_net_id);
+
+		/* Cancel any pending resolution on this address */
+		ila_rslv_resolved(ilan, iaddr);
+	}
+
 	return 0;
 }
 
diff --git a/net/ipv6/ila/ila_resolver.c b/net/ipv6/ila/ila_resolver.c
new file mode 100644
index 0000000..0f5a819
--- /dev/null
+++ b/net/ipv6/ila/ila_resolver.c
@@ -0,0 +1,249 @@
+#include <linux/errno.h>
+#include <linux/ip.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netlink.h>
+#include <linux/skbuff.h>
+#include <linux/socket.h>
+#include <linux/types.h>
+#include <net/checksum.h>
+#include <net/ip.h>
+#include <net/ip6_fib.h>
+#include <net/lwtunnel.h>
+#include <net/netns/generic.h>
+#include <net/protocol.h>
+#include <net/resolver.h>
+#include <uapi/linux/ila.h>
+#include "ila.h"
+
+struct ila_notify_params {
+	unsigned int timeout;
+};
+
+static inline struct ila_notify_params *ila_notify_params_lwtunnel(
+	struct lwtunnel_state *lwstate)
+{
+	return (struct ila_notify_params *)lwstate->data;
+}
+
+static int ila_fill_notify(struct sk_buff *skb, struct in6_addr *addr,
+			   u32 pid, u32 seq, int event, int flags)
+{
+	struct nlmsghdr *nlh;
+	struct rtmsg *rtm;
+
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*rtm), flags);
+	if (!nlh)
+		return -EMSGSIZE;
+
+	rtm = nlmsg_data(nlh);
+	rtm->rtm_family   = RTNL_FAMILY_ILA;
+	rtm->rtm_dst_len  = 128;
+	rtm->rtm_src_len  = 0;
+	rtm->rtm_tos      = 0;
+	rtm->rtm_table    = RT6_TABLE_UNSPEC;
+	rtm->rtm_type     = RTN_UNICAST;
+	rtm->rtm_scope    = RT_SCOPE_UNIVERSE;
+
+	if (nla_put_in6_addr(skb, RTA_DST, addr)) {
+		nlmsg_cancel(skb, nlh);
+		return -EMSGSIZE;
+	}
+
+	nlmsg_end(skb, nlh);
+	return 0;
+}
+
+static size_t ila_rslv_msgsize(void)
+{
+	size_t len =
+		NLMSG_ALIGN(sizeof(struct rtmsg))
+		+ nla_total_size(16)     /* RTA_DST */
+		;
+
+	return len;
+}
+
+void ila_rslv_notify(struct net *net, struct sk_buff *skb)
+{
+	struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	struct sk_buff *nlskb;
+	int err = 0;
+
+	/* Send ILA notification to user */
+	nlskb = nlmsg_new(ila_rslv_msgsize(), GFP_KERNEL);
+	if (!nlskb)
+		goto errout;
+
+	err = ila_fill_notify(nlskb, &ip6h->daddr, 0, 0, RTM_ADDR_RESOLVE,
+			      NLM_F_MULTI);
+	if (err < 0) {
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(nlskb);
+		goto errout;
+	}
+	rtnl_notify(nlskb, net, 0, RTNLGRP_ILA_NOTIFY, NULL, GFP_ATOMIC);
+	return;
+
+errout:
+	if (err < 0)
+		rtnl_set_sk_err(net, RTNLGRP_ILA_NOTIFY, err);
+}
+
+static int ila_rslv_output(struct net *net, struct sock *sk,
+			   struct sk_buff *skb)
+{
+	struct ila_net *ilan = net_generic(net, ila_net_id);
+	struct dst_entry *dst = skb_dst(skb);
+	struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	struct ila_notify_params *p;
+	bool new;
+
+	p = ila_notify_params_lwtunnel(dst->lwtstate);
+
+	/* Don't bother taking rcu lock, we only want to know if the entry
+	 * exists or not.
+	 */
+	net_rslv_lookup_and_create(ilan->nrslv, &ip6h->daddr, &new,
+				   p->timeout);
+
+	if (new)
+		ila_rslv_notify(net, skb);
+
+	return dst->lwtstate->orig_output(net, sk, skb);
+}
+
+void ila_rslv_resolved(struct ila_net *ilan, struct ila_addr *iaddr)
+{
+	if (ilan->nrslv)
+		net_rslv_resolved(ilan->nrslv, iaddr);
+}
+
+static int ila_rslv_input(struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+
+	return dst->lwtstate->orig_input(skb);
+}
+
+static const struct nla_policy ila_notify_nl_policy[ILA_NOTIFY_ATTR_MAX + 1] = {
+	[ILA_NOTIFY_ATTR_TIMEOUT] = { .type = NLA_U32, },
+};
+
+static int ila_rslv_build_state(struct net *net, struct net_device *dev,
+				struct nlattr *nla, unsigned int family,
+				const void *cfg, struct lwtunnel_state **ts)
+{
+	struct ila_notify_params *p;
+	struct nlattr *tb[ILA_NOTIFY_ATTR_MAX + 1];
+	struct lwtunnel_state *newts;
+	struct ila_net *ilan = net_generic(net, ila_net_id);
+	size_t encap_len = sizeof(*p);
+	int ret;
+
+	if (unlikely(!ilan->nrslv)) {
+		int err;
+
+		/* Only create net resolver on demand */
+		err = ila_init_resolver_net(ilan);
+		if (err)
+			return err;
+	}
+
+	if (family != AF_INET6)
+		return -EINVAL;
+
+	ret = nla_parse_nested(tb, ILA_NOTIFY_ATTR_MAX, nla,
+			       ila_notify_nl_policy);
+
+	if (ret < 0)
+		return ret;
+
+	newts = lwtunnel_state_alloc(encap_len);
+	if (!newts)
+		return -ENOMEM;
+
+	newts->len = 0;
+	newts->type = LWTUNNEL_ENCAP_ILA_NOTIFY;
+	newts->flags |= LWTUNNEL_STATE_OUTPUT_REDIRECT |
+			LWTUNNEL_STATE_INPUT_REDIRECT;
+
+	p = ila_notify_params_lwtunnel(newts);
+
+	if (tb[ILA_NOTIFY_ATTR_TIMEOUT])
+		p->timeout = msecs_to_jiffies(nla_get_u32(
+			tb[ILA_NOTIFY_ATTR_TIMEOUT]));
+
+	*ts = newts;
+
+	return 0;
+}
+
+static int ila_rslv_fill_encap_info(struct sk_buff *skb,
+				    struct lwtunnel_state *lwtstate)
+{
+	struct ila_notify_params *p = ila_notify_params_lwtunnel(lwtstate);
+
+	if (nla_put_u32(skb, ILA_NOTIFY_ATTR_TIMEOUT,
+			(__force u32)jiffies_to_msecs(p->timeout)))
+		goto nla_put_failure;
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static int ila_rslv_nlsize(struct lwtunnel_state *lwtstate)
+{
+	return nla_total_size(sizeof(u32)) + /* ILA_NOTIFY_ATTR_TIMEOUT */
+	       0;
+}
+
+static int ila_rslv_cmp(struct lwtunnel_state *a, struct lwtunnel_state *b)
+{
+	return 0;
+}
+
+static const struct lwtunnel_encap_ops ila_rslv_ops = {
+	.build_state = ila_rslv_build_state,
+	.output = ila_rslv_output,
+	.input = ila_rslv_input,
+	.fill_encap = ila_rslv_fill_encap_info,
+	.get_encap_size = ila_rslv_nlsize,
+	.cmp_encap = ila_rslv_cmp,
+};
+
+#define ILA_MAX_SIZE 8192
+
+int ila_init_resolver_net(struct ila_net *ilan)
+{
+	struct net_rslv *nrslv;
+
+	nrslv = net_rslv_create(sizeof(struct ila_addr),
+				sizeof(struct ila_addr), ILA_MAX_SIZE,
+				NULL, NULL, NULL);
+
+	if (IS_ERR(nrslv))
+		return PTR_ERR(nrslv);
+
+	ilan->nrslv = nrslv;
+
+	return 0;
+}
+
+void ila_exit_resolver_net(struct ila_net *ilan)
+{
+	if (ilan->nrslv)
+		net_rslv_destroy(ilan->nrslv);
+}
+
+int ila_rslv_init(void)
+{
+	return lwtunnel_encap_add_ops(&ila_rslv_ops, LWTUNNEL_ENCAP_ILA_NOTIFY);
+}
+
+void ila_rslv_fini(void)
+{
+	lwtunnel_encap_del_ops(&ila_rslv_ops, LWTUNNEL_ENCAP_ILA_NOTIFY);
+}
diff --git a/net/ipv6/ila/ila_xlat.c b/net/ipv6/ila/ila_xlat.c
index 7d1c34b..857f8b5 100644
--- a/net/ipv6/ila/ila_xlat.c
+++ b/net/ipv6/ila/ila_xlat.c
@@ -21,14 +21,7 @@ struct ila_map {
 	struct rcu_head rcu;
 };
 
-static unsigned int ila_net_id;
-
-struct ila_net {
-	struct rhashtable rhash_table;
-	spinlock_t *locks; /* Bucket locks for entry manipulation */
-	unsigned int locks_mask;
-	bool hooks_registered;
-};
+unsigned int ila_net_id;
 
 static u32 hashrnd __read_mostly;
 static __always_inline void __ila_hash_secret_init(void)
@@ -546,6 +539,10 @@ static __net_init int ila_init_net(struct net *net)
 	if (err)
 		return err;
 
+	/* Resolver net is created on demand when LWT ILA resolver route
+	 * is made.
+	 */
+
 	rhashtable_init(&ilan->rhash_table, &rht_params);
 
 	return 0;
@@ -557,6 +554,8 @@ static __net_exit void ila_exit_net(struct net *net)
 
 	rhashtable_free_and_destroy(&ilan->rhash_table, ila_free_cb, NULL);
 
+	ila_exit_resolver_net(ilan);
+
 	free_bucket_spinlocks(ilan->locks);
 
 	if (ilan->hooks_registered)
-- 
2.8.0.rc2
