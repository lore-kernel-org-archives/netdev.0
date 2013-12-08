From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] ipv4: add support for IFA_FLAGS nl attribute
Date: Sun,  8 Dec 2013 12:16:10 +0100
Message-ID: <1386501370-9007-3-git-send-email-jiri@resnulli.us>
References: <1386501370-9007-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	hannes@stressinduktion.org, bcrl@kvack.org, gaofeng@cn.fujitsu.com,
	joe@perches.com, tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:34171 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753596Ab3LHLQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 06:16:19 -0500
Received: by mail-ee0-f47.google.com with SMTP id e51so1035806eek.34
        for <netdev@vger.kernel.org>; Sun, 08 Dec 2013 03:16:18 -0800 (PST)
In-Reply-To: <1386501370-9007-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/inetdevice.h | 2 +-
 net/ipv4/devinet.c         | 8 ++++++--
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 0d678ae..8c6a4ae 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -136,8 +136,8 @@ struct in_ifaddr {
 	__be32			ifa_mask;
 	__be32			ifa_broadcast;
 	unsigned char		ifa_scope;
-	unsigned char		ifa_flags;
 	unsigned char		ifa_prefixlen;
+	__u32			ifa_flags;
 	char			ifa_label[IFNAMSIZ];
 
 	/* In seconds, relative to tstamp. Expiry is at tstamp + HZ * lft. */
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index a1b5bcb..b877bb4 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -99,6 +99,7 @@ static const struct nla_policy ifa_ipv4_policy[IFA_MAX+1] = {
 	[IFA_BROADCAST] 	= { .type = NLA_U32 },
 	[IFA_LABEL]     	= { .type = NLA_STRING, .len = IFNAMSIZ - 1 },
 	[IFA_CACHEINFO]		= { .len = sizeof(struct ifa_cacheinfo) },
+	[IFA_FLAGS]		= { .type = NLA_U32 },
 };
 
 #define IN4_ADDR_HSIZE_SHIFT	8
@@ -755,7 +756,8 @@ static struct in_ifaddr *rtm_to_ifaddr(struct net *net, struct nlmsghdr *nlh,
 	INIT_HLIST_NODE(&ifa->hash);
 	ifa->ifa_prefixlen = ifm->ifa_prefixlen;
 	ifa->ifa_mask = inet_make_mask(ifm->ifa_prefixlen);
-	ifa->ifa_flags = ifm->ifa_flags;
+	ifa->ifa_flags = tb[IFA_FLAGS] ? nla_get_u32(tb[IFA_FLAGS]) :
+					 ifm->ifa_flags;
 	ifa->ifa_scope = ifm->ifa_scope;
 	ifa->ifa_dev = in_dev;
 
@@ -1435,7 +1437,8 @@ static size_t inet_nlmsg_size(void)
 	       + nla_total_size(4) /* IFA_ADDRESS */
 	       + nla_total_size(4) /* IFA_LOCAL */
 	       + nla_total_size(4) /* IFA_BROADCAST */
-	       + nla_total_size(IFNAMSIZ); /* IFA_LABEL */
+	       + nla_total_size(IFNAMSIZ) /* IFA_LABEL */
+	       + nla_total_size(4);  /* IFA_FLAGS */
 }
 
 static inline u32 cstamp_delta(unsigned long cstamp)
@@ -1503,6 +1506,7 @@ static int inet_fill_ifaddr(struct sk_buff *skb, struct in_ifaddr *ifa,
 	     nla_put_be32(skb, IFA_BROADCAST, ifa->ifa_broadcast)) ||
 	    (ifa->ifa_label[0] &&
 	     nla_put_string(skb, IFA_LABEL, ifa->ifa_label)) ||
+	    nla_put_u32(skb, IFA_FLAGS, ifa->ifa_flags) ||
 	    put_cacheinfo(skb, ifa->ifa_cstamp, ifa->ifa_tstamp,
 			  preferred, valid))
 		goto nla_put_failure;
-- 
1.8.3.1
