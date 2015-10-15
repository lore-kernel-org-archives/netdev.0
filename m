From: Jiri Benc <jbenc@redhat.com>
Subject: [RFC PATCH net-next 9/9] veth: validate nested attributes
Date: Thu, 15 Oct 2015 18:39:14 +0200
Message-ID: <6e52da4b27497188dd79f64129828c967a6cdca4.1444926905.git.jbenc@redhat.com>
References: <cover.1444926905.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47275 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753498AbbJOQjo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 12:39:44 -0400
In-Reply-To: <cover.1444926905.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For strict attribute checking, it's necessary to validate nested attributes
in the validate rtnl_link_ops callback.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/veth.c      | 8 ++++++++
 include/net/rtnetlink.h | 1 +
 net/core/rtnetlink.c    | 6 ++++++
 3 files changed, 15 insertions(+)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index af0bf39147ba..86a68bd191b6 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -340,6 +340,14 @@ static int veth_validate(struct nlattr *tb[], struct nlattr *data[],
 		if (!is_valid_veth_mtu(nla_get_u32(tb[IFLA_MTU])))
 			return -EINVAL;
 	}
+	if (data != NULL && data[VETH_INFO_PEER] != NULL) {
+		struct nlattr *nla_peer = data[VETH_INFO_PEER];
+
+		return rtnl_nla_validate_ifla(
+				nla_data(nla_peer) + sizeof(struct ifinfomsg),
+				nla_len(nla_peer) - sizeof(struct ifinfomsg),
+				strict);
+	}
 	return 0;
 }
 
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 71c49f5af9a0..be75457e4cc5 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -168,6 +168,7 @@ int rtnl_delete_link(struct net_device *dev);
 int rtnl_configure_link(struct net_device *dev, const struct ifinfomsg *ifm);
 
 int rtnl_nla_parse_ifla(struct nlattr **tb, const struct nlattr *head, int len);
+int rtnl_nla_validate_ifla(const struct nlattr *head, int len, bool strict);
 
 #define MODULE_ALIAS_RTNL_LINK(kind) MODULE_ALIAS("rtnl-link-" kind)
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 1af929e468cf..89e7f0a6da44 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1449,6 +1449,12 @@ int rtnl_nla_parse_ifla(struct nlattr **tb, const struct nlattr *head, int len)
 }
 EXPORT_SYMBOL(rtnl_nla_parse_ifla);
 
+int rtnl_nla_validate_ifla(const struct nlattr *head, int len, bool strict)
+{
+	return nla_strict_validate(head, len, IFLA_MAX, strict, ifla_policy);
+}
+EXPORT_SYMBOL(rtnl_nla_validate_ifla);
+
 struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[])
 {
 	struct net *net;
-- 
1.8.3.1
