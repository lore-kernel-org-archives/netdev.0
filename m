From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 16/17] netfilter: add namespace support for cttimeout
Date: Fri, 27 Apr 2012 17:38:03 +0800
Message-ID: <1335519484-6089-17-git-send-email-gaofeng@cn.fujitsu.com>
References: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:1624 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1759953Ab2D0Jh6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2012 05:37:58 -0400
In-Reply-To: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add struct net as a param of ctnl_timeout.nlattr_to_obj,

modify ctnl_timeout_parse_policy and cttimeout_new_timeout
to transmit struct net to nlattr_to_obj.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netfilter/nf_conntrack_l4proto.h |    3 ++-
 net/netfilter/nfnetlink_cttimeout.c          |   13 ++++++++-----
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index b271b6f..63f12b6 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -88,7 +88,8 @@ struct nf_conntrack_l4proto {
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
 	struct {
 		size_t obj_size;
-		int (*nlattr_to_obj)(struct nlattr *tb[], void *data);
+		int (*nlattr_to_obj)(struct nlattr *tb[],
+				     struct net *net, void *data);
 		int (*obj_to_nlattr)(struct sk_buff *skb, const void *data);
 
 		unsigned int nlattr_max;
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 3e65528..cdecbc8 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -49,8 +49,9 @@ static const struct nla_policy cttimeout_nla_policy[CTA_TIMEOUT_MAX+1] = {
 
 static int
 ctnl_timeout_parse_policy(struct ctnl_timeout *timeout,
-			       struct nf_conntrack_l4proto *l4proto,
-			       const struct nlattr *attr)
+			  struct nf_conntrack_l4proto *l4proto,
+			  struct net *net,
+			  const struct nlattr *attr)
 {
 	int ret = 0;
 
@@ -60,7 +61,8 @@ ctnl_timeout_parse_policy(struct ctnl_timeout *timeout,
 		nla_parse_nested(tb, l4proto->ctnl_timeout.nlattr_max,
 				 attr, l4proto->ctnl_timeout.nla_policy);
 
-		ret = l4proto->ctnl_timeout.nlattr_to_obj(tb, &timeout->data);
+		ret = l4proto->ctnl_timeout.nlattr_to_obj(tb, net,
+							  &timeout->data);
 	}
 	return ret;
 }
@@ -74,6 +76,7 @@ cttimeout_new_timeout(struct sock *ctnl, struct sk_buff *skb,
 	__u8 l4num;
 	struct nf_conntrack_l4proto *l4proto;
 	struct ctnl_timeout *timeout, *matching = NULL;
+	struct net *net = sock_net(skb->sk);
 	char *name;
 	int ret;
 
@@ -117,7 +120,7 @@ cttimeout_new_timeout(struct sock *ctnl, struct sk_buff *skb,
 				goto err_proto_put;
 			}
 
-			ret = ctnl_timeout_parse_policy(matching, l4proto,
+			ret = ctnl_timeout_parse_policy(matching, l4proto, net,
 							cda[CTA_TIMEOUT_DATA]);
 			return ret;
 		}
@@ -132,7 +135,7 @@ cttimeout_new_timeout(struct sock *ctnl, struct sk_buff *skb,
 		goto err_proto_put;
 	}
 
-	ret = ctnl_timeout_parse_policy(timeout, l4proto,
+	ret = ctnl_timeout_parse_policy(timeout, l4proto, net,
 					cda[CTA_TIMEOUT_DATA]);
 	if (ret < 0)
 		goto err;
-- 
1.7.7.6
