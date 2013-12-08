From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] dn_dev: add support for IFA_FLAGS nl attribute
Date: Sun,  8 Dec 2013 12:16:09 +0100
Message-ID: <1386501370-9007-2-git-send-email-jiri@resnulli.us>
References: <1386501370-9007-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	hannes@stressinduktion.org, bcrl@kvack.org, gaofeng@cn.fujitsu.com,
	joe@perches.com, tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:42312 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753245Ab3LHLQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 06:16:17 -0500
Received: by mail-ee0-f49.google.com with SMTP id c41so1029414eek.22
        for <netdev@vger.kernel.org>; Sun, 08 Dec 2013 03:16:16 -0800 (PST)
In-Reply-To: <1386501370-9007-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/dn_dev.h |  2 +-
 net/decnet/dn_dev.c  | 13 +++++++++----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/include/net/dn_dev.h b/include/net/dn_dev.h
index 20b5ab0..197886c 100644
--- a/include/net/dn_dev.h
+++ b/include/net/dn_dev.h
@@ -9,7 +9,7 @@ struct dn_ifaddr {
 	struct dn_dev    *ifa_dev;
 	__le16            ifa_local;
 	__le16            ifa_address;
-	__u8              ifa_flags;
+	__u32             ifa_flags;
 	__u8              ifa_scope;
 	char              ifa_label[IFNAMSIZ];
 	struct rcu_head   rcu;
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index dd0dfb2..a603823 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -561,6 +561,7 @@ static const struct nla_policy dn_ifa_policy[IFA_MAX+1] = {
 	[IFA_LOCAL]		= { .type = NLA_U16 },
 	[IFA_LABEL]		= { .type = NLA_STRING,
 				    .len = IFNAMSIZ - 1 },
+	[IFA_FLAGS]		= { .type = NLA_U32 },
 };
 
 static int dn_nl_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
@@ -648,7 +649,8 @@ static int dn_nl_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	ifa->ifa_local = nla_get_le16(tb[IFA_LOCAL]);
 	ifa->ifa_address = nla_get_le16(tb[IFA_ADDRESS]);
-	ifa->ifa_flags = ifm->ifa_flags;
+	ifa->ifa_flags = tb[IFA_FLAGS] ? nla_get_u32(tb[IFA_FLAGS]) :
+					 ifm->ifa_flags;
 	ifa->ifa_scope = ifm->ifa_scope;
 	ifa->ifa_dev = dn_db;
 
@@ -669,7 +671,8 @@ static inline size_t dn_ifaddr_nlmsg_size(void)
 	return NLMSG_ALIGN(sizeof(struct ifaddrmsg))
 	       + nla_total_size(IFNAMSIZ) /* IFA_LABEL */
 	       + nla_total_size(2) /* IFA_ADDRESS */
-	       + nla_total_size(2); /* IFA_LOCAL */
+	       + nla_total_size(2) /* IFA_LOCAL */
+	       + nla_total_size(4); /* IFA_FLAGS */
 }
 
 static int dn_nl_fill_ifaddr(struct sk_buff *skb, struct dn_ifaddr *ifa,
@@ -677,6 +680,7 @@ static int dn_nl_fill_ifaddr(struct sk_buff *skb, struct dn_ifaddr *ifa,
 {
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr *nlh;
+	u32 ifa_flags = ifa->ifa_flags | IFA_F_PERMANENT;
 
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*ifm), flags);
 	if (nlh == NULL)
@@ -685,7 +689,7 @@ static int dn_nl_fill_ifaddr(struct sk_buff *skb, struct dn_ifaddr *ifa,
 	ifm = nlmsg_data(nlh);
 	ifm->ifa_family = AF_DECnet;
 	ifm->ifa_prefixlen = 16;
-	ifm->ifa_flags = ifa->ifa_flags | IFA_F_PERMANENT;
+	ifm->ifa_flags = ifa_flags;
 	ifm->ifa_scope = ifa->ifa_scope;
 	ifm->ifa_index = ifa->ifa_dev->dev->ifindex;
 
@@ -694,7 +698,8 @@ static int dn_nl_fill_ifaddr(struct sk_buff *skb, struct dn_ifaddr *ifa,
 	    (ifa->ifa_local &&
 	     nla_put_le16(skb, IFA_LOCAL, ifa->ifa_local)) ||
 	    (ifa->ifa_label[0] &&
-	     nla_put_string(skb, IFA_LABEL, ifa->ifa_label)))
+	     nla_put_string(skb, IFA_LABEL, ifa->ifa_label)) ||
+	     nla_put_u32(skb, IFA_FLAGS, ifa_flags))
 		goto nla_put_failure;
 	return nlmsg_end(skb, nlh);
 
-- 
1.8.3.1
