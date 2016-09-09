From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 6/6] ila: Resolver mechanism
Date: Fri, 9 Sep 2016 16:19:57 -0700
Message-ID: <1473463197-3076903-7-git-send-email-tom@herbertland.com>
References: <1473463197-3076903-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <tgraf@suug.ch>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56928 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755622AbcIIXUb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 19:20:31 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u89NJjU9006371
        for <netdev@vger.kernel.org>; Fri, 9 Sep 2016 16:20:31 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25c120a621-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 16:20:31 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.212.236.89) with ESMTP id
 ffa36ffa76e311e6bdb50002c95209d8-93bfca50 for <netdev@vger.kernel.org>;        Fri,
 09 Sep 2016 16:20:30 -0700
In-Reply-To: <1473463197-3076903-1-git-send-email-tom@herbertland.com>
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
 include/uapi/linux/lwtunnel.h  |   1 +
 include/uapi/linux/rtnetlink.h |   5 ++
 net/ipv6/Kconfig               |   1 +
 net/ipv6/ila/Makefile          |   2 +-
 net/ipv6/ila/ila.h             |  16 ++++
 net/ipv6/ila/ila_common.c      |   7 ++
 net/ipv6/ila/ila_lwt.c         |   9 ++
 net/ipv6/ila/ila_resolver.c    | 192 +++++++++++++++++++++++++++++++++++++++++
 net/ipv6/ila/ila_xlat.c        |  15 ++--
 9 files changed, 239 insertions(+), 9 deletions(-)
 create mode 100644 net/ipv6/ila/ila_resolver.c

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
index 262f037..271215f 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -144,6 +144,9 @@ enum {
 	RTM_GETSTATS = 94,
 #define RTM_GETSTATS RTM_GETSTATS
 
+	RTM_ADDR_RESOLVE = 95,
+#define RTM_ADDR_RESOLVE RTM_ADDR_RESOLVE
+
 	__RTM_MAX,
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
@@ -656,6 +659,8 @@ enum rtnetlink_groups {
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
index e50c27a..02594aa 100644
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
@@ -122,6 +123,14 @@ static int ila_build_state(struct net_device *dev, struct nlattr *nla,
 
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
index 0000000..4dd6262
--- /dev/null
+++ b/net/ipv6/ila/ila_resolver.c
@@ -0,0 +1,192 @@
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
+struct ila_notify {
+	int type;
+	struct in6_addr addr;
+};
+
+#define ILA_NOTIFY_SIR_DEST 1
+
+static int ila_fill_notify(struct sk_buff *skb, struct in6_addr *addr,
+			   u32 pid, u32 seq, int event, int flags)
+{
+	struct ila_notify *nila;
+	struct nlmsghdr *nlh;
+
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*nila), flags);
+	if (!nlh)
+		return -EMSGSIZE;
+
+	nila = nlmsg_data(nlh);
+	nila->type = ILA_NOTIFY_SIR_DEST;
+	nila->addr = *addr;
+
+	nlmsg_end(skb, nlh);
+
+	return 0;
+}
+
+void ila_rslv_notify(struct net *net, struct sk_buff *skb)
+{
+	struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	struct sk_buff *nlskb;
+	int err = 0;
+
+	/* Send ILA notification to user */
+	nlskb = nlmsg_new(NLMSG_ALIGN(sizeof(struct ila_notify) +
+			nlmsg_total_size(1)), GFP_KERNEL);
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
+	struct net_rslv_ent *nrent;
+	struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	bool new;
+
+	/* Don't bother taking rcu lock, we only want to know if the entry
+	 * exists or not.
+	 */
+	nrent = net_rslv_lookup_and_create(ilan->nrslv, &ip6h->daddr, &new);
+
+	if (nrent && new)
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
+static int ila_rslv_build_state(struct net_device *dev, struct nlattr *nla,
+				unsigned int family, const void *cfg,
+				struct lwtunnel_state **ts)
+{
+	struct lwtunnel_state *newts;
+	struct ila_net *ilan = net_generic(dev_net(dev), ila_net_id);
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
+	newts = lwtunnel_state_alloc(0);
+	if (!newts)
+		return -ENOMEM;
+
+	newts->len = 0;
+	newts->type = LWTUNNEL_ENCAP_ILA_NOTIFY;
+	newts->flags |= LWTUNNEL_STATE_OUTPUT_REDIRECT |
+			LWTUNNEL_STATE_INPUT_REDIRECT;
+
+	*ts = newts;
+
+	return 0;
+}
+
+static int ila_rslv_fill_encap_info(struct sk_buff *skb,
+				    struct lwtunnel_state *lwtstate)
+{
+	return 0;
+}
+
+static int ila_rslv_nlsize(struct lwtunnel_state *lwtstate)
+{
+	return 0;
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
+#define ILA_RESOLVER_TIMEOUT 100
+#define ILA_MAX_SIZE 8192
+
+int ila_init_resolver_net(struct ila_net *ilan)
+{
+	ilan->nrslv = net_rslv_create(sizeof(struct ila_addr),
+				      sizeof(struct ila_addr), ILA_MAX_SIZE,
+				      ILA_RESOLVER_TIMEOUT, NULL, NULL, NULL);
+
+	if (!ilan->nrslv)
+		return -ENOMEM;
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
index 7d1c34b..9fcb041 100644
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
 
+	/* Resolver net is create on demand when LWT ILA resolver route
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
