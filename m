From: Lorenzo Colitti <lorenzo@google.com>
Subject: [RFC net-next 4/4] net: core: Add a RTA_UID attribute to routes.
Date: Sat, 26 Apr 2014 13:48:25 +0900
Message-ID: <1398487705-13430-5-git-send-email-lorenzo@google.com>
References: <1398487705-13430-1-git-send-email-lorenzo@google.com>
Cc: hannes@stressinduktion.org, davem@davemloft.net, jpa@google.com,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:43889 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246AbaDZEs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 00:48:58 -0400
Received: by mail-pb0-f41.google.com with SMTP id rr13so3902165pbb.14
        for <netdev@vger.kernel.org>; Fri, 25 Apr 2014 21:48:58 -0700 (PDT)
In-Reply-To: <1398487705-13430-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is so that userspace can do per-UID route lookups.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/uapi/linux/rtnetlink.h | 1 +
 net/ipv4/fib_frontend.c        | 1 +
 net/ipv4/route.c               | 5 +++++
 net/ipv6/route.c               | 7 +++++++
 4 files changed, 14 insertions(+)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index eb0f1a5..01757b7 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -297,6 +297,7 @@ enum rtattr_type_t {
 	RTA_TABLE,
 	RTA_MARK,
 	RTA_MFC_STATS,
+	RTA_UID,
 	__RTA_MAX
 };
 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 255aa99..dca307c 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -531,6 +531,7 @@ const struct nla_policy rtm_ipv4_policy[RTA_MAX + 1] = {
 	[RTA_METRICS]		= { .type = NLA_NESTED },
 	[RTA_MULTIPATH]		= { .len = sizeof(struct rtnexthop) },
 	[RTA_FLOW]		= { .type = NLA_U32 },
+	[RTA_UID]		= { .type = NLA_U32 },
 };
 
 static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 58017b1..57daf60 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2385,6 +2385,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	int err;
 	int mark;
 	struct sk_buff *skb;
+	kuid_t uid;
 
 	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv4_policy);
 	if (err < 0)
@@ -2412,6 +2413,9 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	dst = tb[RTA_DST] ? nla_get_be32(tb[RTA_DST]) : 0;
 	iif = tb[RTA_IIF] ? nla_get_u32(tb[RTA_IIF]) : 0;
 	mark = tb[RTA_MARK] ? nla_get_u32(tb[RTA_MARK]) : 0;
+	uid = tb[RTA_UID] ?
+		make_kuid(current_user_ns(), nla_get_u32(tb[RTA_UID])) :
+		current_uid();
 
 	memset(&fl4, 0, sizeof(fl4));
 	fl4.daddr = dst;
@@ -2419,6 +2423,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	fl4.flowi4_tos = rtm->rtm_tos;
 	fl4.flowi4_oif = tb[RTA_OIF] ? nla_get_u32(tb[RTA_OIF]) : 0;
 	fl4.flowi4_mark = mark;
+	fl4.flowi4_uid = uid;
 
 	if (iif) {
 		struct net_device *dev;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4011617..75a5d41 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2321,6 +2321,7 @@ static const struct nla_policy rtm_ipv6_policy[RTA_MAX+1] = {
 	[RTA_PRIORITY]          = { .type = NLA_U32 },
 	[RTA_METRICS]           = { .type = NLA_NESTED },
 	[RTA_MULTIPATH]		= { .len = sizeof(struct rtnexthop) },
+	[RTA_UID]		= { .type = NLA_U32 },
 };
 
 static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
@@ -2707,6 +2708,12 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh)
 	if (tb[RTA_OIF])
 		oif = nla_get_u32(tb[RTA_OIF]);
 
+	if (tb[RTA_UID])
+		fl6.flowi6_uid = make_kuid(current_user_ns(),
+					   nla_get_u32(tb[RTA_UID]));
+	else
+		fl6.flowi6_uid = current_uid();
+
 	if (iif) {
 		struct net_device *dev;
 		int flags = 0;
-- 
1.9.1.423.g4596e3a
