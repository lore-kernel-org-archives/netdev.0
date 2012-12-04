From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 4/7] ipmr/ip6mr: report origin of mfc entry into rtnl msg
Date: Tue,  4 Dec 2012 12:13:38 +0100
Message-ID: <1354619621-16016-5-git-send-email-nicolas.dichtel@6wind.com>
References: <1354619621-16016-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56630 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751737Ab2LDLNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 06:13:50 -0500
In-Reply-To: <1354619621-16016-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A mfc entry can be static or not (added via the mroute_sk socket). The patch
reports MFC_STATIC flag into rtm_protocol by setting rtm_protocol to
RTPROT_STATIC or RTPROT_MROUTED.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/rtnetlink.h | 1 +
 net/ipv4/ipmr.c                | 5 ++++-
 net/ipv6/ip6mr.c               | 5 ++++-
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 80abe27..33d29ce 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -227,6 +227,7 @@ enum {
 #define RTPROT_XORP	14	/* XORP */
 #define RTPROT_NTK	15	/* Netsukuku */
 #define RTPROT_DHCP	16      /* DHCP client */
+#define RTPROT_MROUTED	17      /* Multicast daemon */
 
 /* rtm_scope
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index c5617d6..91782a7 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2169,7 +2169,10 @@ static int ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 		goto nla_put_failure;
 	rtm->rtm_type     = RTN_MULTICAST;
 	rtm->rtm_scope    = RT_SCOPE_UNIVERSE;
-	rtm->rtm_protocol = RTPROT_UNSPEC;
+	if (c->mfc_flags & MFC_STATIC)
+		rtm->rtm_protocol = RTPROT_STATIC;
+	else
+		rtm->rtm_protocol = RTPROT_MROUTED;
 	rtm->rtm_flags    = 0;
 
 	if (nla_put_be32(skb, RTA_SRC, c->mfc_origin) ||
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index b744b98..e9ef38f 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -2249,7 +2249,10 @@ static int ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 	if (nla_put_u32(skb, RTA_TABLE, mrt->id))
 		goto nla_put_failure;
 	rtm->rtm_scope    = RT_SCOPE_UNIVERSE;
-	rtm->rtm_protocol = RTPROT_UNSPEC;
+	if (c->mfc_flags & MFC_STATIC)
+		rtm->rtm_protocol = RTPROT_STATIC;
+	else
+		rtm->rtm_protocol = RTPROT_MROUTED;
 	rtm->rtm_flags    = 0;
 
 	if (nla_put(skb, RTA_SRC, 16, &c->mf6c_origin) ||
-- 
1.8.0.1
