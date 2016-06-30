From: Tom Herbert <tom@herbertland.com>
Subject: [RFC PATCH] ila: Resolver mechanism
Date: Thu, 30 Jun 2016 12:41:20 -0700
Message-ID: <1467315680-4148054-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <haoxuany@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58175 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751616AbcF3Tl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 15:41:29 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u5UJd9jp001030
	for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 12:41:28 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 23vc8tu3nj-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 12:41:28 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 a20df8b83efa11e6b2b30002c991e86a-c97af6b0 for <netdev@vger.kernel.org>;	Thu,
 30 Jun 2016 12:41:26 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the first cut at an ILA resolver using LWT to implement
the hook to a userspace resolver.

The idea is that the kernel sets an ILA resolver route to the
SIR prefix, somrhting like:

ip route add 3333::/64 encap ila-resolve \
     via 2401:db00:20:911a::27:0 dev eth0

When a packet hits the route it is forwarded to the destination
using via path and also a rtnl message is generated with
group RTNLGRP_ILA_NOTIFY and type RTM_ADDR_RESOLVE. A userspace
daemon can listen for such messages and perform an ILA resolution
protocol to determine the ILA mapping. If the mapping is resolved
then a /128 ila encap router is set so that host can perform
ILA translation and send directly to destination.

This is not yet complete, we would still need to some controls
to rate limit number of resolution requests and a means to track
pending requests. I'm posting this as RFC because it seems like
this might be part of a general mechanism to a perform address
resolution in userspace and I would appreciate comments with
regard to that.

---
 include/uapi/linux/lwtunnel.h  |   1 +
 include/uapi/linux/rtnetlink.h |   5 ++
 net/ipv6/ila/Makefile          |   2 +-
 net/ipv6/ila/ila.h             |   2 +
 net/ipv6/ila/ila_common.c      |   7 ++
 net/ipv6/ila/ila_resolver.c    | 145 +++++++++++++++++++++++++++++++++++++++++
 6 files changed, 161 insertions(+), 1 deletion(-)
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
diff --git a/net/ipv6/ila/Makefile b/net/ipv6/ila/Makefile
index 4b32e59..f2aadc3 100644
--- a/net/ipv6/ila/Makefile
+++ b/net/ipv6/ila/Makefile
@@ -4,4 +4,4 @@
 
 obj-$(CONFIG_IPV6_ILA) += ila.o
 
-ila-objs := ila_common.o ila_lwt.o ila_xlat.o
+ila-objs := ila_common.o ila_lwt.o ila_xlat.o ila_resolver.o
diff --git a/net/ipv6/ila/ila.h b/net/ipv6/ila/ila.h
index e0170f6..382d360 100644
--- a/net/ipv6/ila/ila.h
+++ b/net/ipv6/ila/ila.h
@@ -118,5 +118,7 @@ int ila_lwt_init(void);
 void ila_lwt_fini(void);
 int ila_xlat_init(void);
 void ila_xlat_fini(void);
+int ila_rslv_init(void);
+void ila_rslv_fini(void);
 
 #endif /* __ILA_H */
diff --git a/net/ipv6/ila/ila_common.c b/net/ipv6/ila/ila_common.c
index ec9efbc..0a09557 100644
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
diff --git a/net/ipv6/ila/ila_resolver.c b/net/ipv6/ila/ila_resolver.c
new file mode 100644
index 0000000..22bb2bd
--- /dev/null
+++ b/net/ipv6/ila/ila_resolver.c
@@ -0,0 +1,145 @@
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
+#include <net/protocol.h>
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
+	if (nlh == NULL)
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
+	if (nlskb == NULL)
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
+static int ila_rslv_output(struct net *net, struct sock *sk, struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+
+	/* Lookup pending notifications */
+
+	ila_rslv_notify(net, skb);
+
+	return dst->lwtstate->orig_output(net, sk, skb);
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
+        return 0;
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
+int ila_rslv_init(void)
+{
+        return lwtunnel_encap_add_ops(&ila_rslv_ops, LWTUNNEL_ENCAP_ILA_NOTIFY);
+}
+
+void ila_rslv_fini(void)
+{
+        lwtunnel_encap_del_ops(&ila_rslv_ops, LWTUNNEL_ENCAP_ILA_NOTIFY);
+}
+
-- 
2.8.0.rc2
