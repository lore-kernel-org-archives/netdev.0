From: Jiri Benc <jbenc@redhat.com>
Subject: [RFC PATCH net-next 7/9] rtnetlink: add strict parameter to validate_link_af
Date: Thu, 15 Oct 2015 18:39:12 +0200
Message-ID: <84a49d6d7f9af344e032593cd0f7397fc0ad477e.1444926905.git.jbenc@redhat.com>
References: <cover.1444926905.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56007 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751815AbbJOQjm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 12:39:42 -0400
In-Reply-To: <cover.1444926905.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is in preparation for rtnetlink to be able to handle strict
attribute checking.

Nothing complicated here, just pass the parameter through.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/net/rtnetlink.h | 3 ++-
 net/core/rtnetlink.c    | 3 ++-
 net/ipv4/devinet.c      | 6 ++++--
 net/ipv6/addrconf.c     | 6 ++++--
 4 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 9f730f2395de..71c49f5af9a0 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -148,7 +148,8 @@ struct rtnl_af_ops {
 	size_t			(*get_link_af_size)(const struct net_device *dev);
 
 	int			(*validate_link_af)(const struct net_device *dev,
-						    const struct nlattr *attr);
+						    const struct nlattr *attr,
+						    bool strict);
 	int			(*set_link_af)(struct net_device *dev,
 					       const struct nlattr *attr);
 };
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 205b7acbd6bf..9d08ad6ee5c3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1491,7 +1491,8 @@ static int validate_linkmsg(struct net_device *dev, struct nlattr *tb[])
 				return -EOPNOTSUPP;
 
 			if (af_ops->validate_link_af) {
-				err = af_ops->validate_link_af(dev, af);
+				err = af_ops->validate_link_af(dev, af,
+							       false);
 				if (err < 0)
 					return err;
 			}
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 735008472844..9ea6bc6683ec 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1679,7 +1679,8 @@ static const struct nla_policy inet_af_policy[IFLA_INET_MAX+1] = {
 };
 
 static int inet_validate_link_af(const struct net_device *dev,
-				 const struct nlattr *nla)
+				 const struct nlattr *nla,
+				 bool strict)
 {
 	struct nlattr *a, *tb[IFLA_INET_MAX+1];
 	int err, rem;
@@ -1687,7 +1688,8 @@ static int inet_validate_link_af(const struct net_device *dev,
 	if (dev && !__in_dev_get_rtnl(dev))
 		return -EAFNOSUPPORT;
 
-	err = nla_parse_nested(tb, IFLA_INET_MAX, nla, inet_af_policy);
+	err = nla_strict_parse_nested(tb, IFLA_INET_MAX, strict, nla,
+				      inet_af_policy);
 	if (err < 0)
 		return err;
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f0326aae7a02..b29f117cde72 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4876,14 +4876,16 @@ static const struct nla_policy inet6_af_policy[IFLA_INET6_MAX + 1] = {
 };
 
 static int inet6_validate_link_af(const struct net_device *dev,
-				  const struct nlattr *nla)
+				  const struct nlattr *nla,
+				  bool strict)
 {
 	struct nlattr *tb[IFLA_INET6_MAX + 1];
 
 	if (dev && !__in6_dev_get(dev))
 		return -EAFNOSUPPORT;
 
-	return nla_parse_nested(tb, IFLA_INET6_MAX, nla, inet6_af_policy);
+	return nla_strict_parse_nested(tb, IFLA_INET6_MAX, strict, nla,
+				       inet6_af_policy);
 }
 
 static int inet6_set_link_af(struct net_device *dev, const struct nlattr *nla)
-- 
1.8.3.1
