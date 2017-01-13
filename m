From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next 1/2] net: AF-specific RTM_GETSTATS attributes
Date: Fri, 13 Jan 2017 18:14:12 +0000
Message-ID: <1484331253-5908-2-git-send-email-rshearma@brocade.com>
References: <1484331253-5908-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>, <ebiederm@xmission.com>,
        Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:35899 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750757AbdAMSPU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 13:15:20 -0500
In-Reply-To: <1484331253-5908-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the functionality for including address-family-specific per-link
stats in RTM_GETSTATS messages. This is done through adding a new
IFLA_STATS_AF_SPEC attribute under which address family attributes are
nested and then the AF-specific attributes can be further nested. This
follows the model of IFLA_AF_SPEC on RTM_*LINK messages and it has the
advantage of presenting an easily extended hierarchy. The rtnl_af_ops
structure is extended to provide AFs with the opportunity to fill and
provide the size of their stats attributes.

One alternative would have been to provide AFs with the ability to add
attributes directly into the RTM_GETSTATS message without a nested
hierarchy. I discounted this approach as it increases the rate at
which the 32 attribute number space is used up and it makes
implementation a little more tricky for stats dump resuming (at the
moment the order in which attributes are added to the message has to
match the numeric order of the attributes).

Another alternative would have been to register per-AF RTM_GETSTATS
handlers. I discounted this approach as I perceived a common use-case
to be getting all the stats for an interface and this approach would
necessitate multiple requests/dumps to retrieve them all.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 include/net/rtnetlink.h      |  4 ++++
 include/uapi/linux/if_link.h |  1 +
 net/core/rtnetlink.c         | 50 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 55 insertions(+)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 4113916cc1bb..106de5f7bf06 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -139,6 +139,10 @@ struct rtnl_af_ops {
 						    const struct nlattr *attr);
 	int			(*set_link_af)(struct net_device *dev,
 					       const struct nlattr *attr);
+
+	int			(*fill_stats_af)(struct sk_buff *skb,
+						 const struct net_device *dev);
+	size_t			(*get_stats_af_size)(const struct net_device *dev);
 };
 
 void __rtnl_af_unregister(struct rtnl_af_ops *ops);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 6b13e591abc9..184b16ed2b84 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -847,6 +847,7 @@ enum {
 	IFLA_STATS_LINK_XSTATS,
 	IFLA_STATS_LINK_XSTATS_SLAVE,
 	IFLA_STATS_LINK_OFFLOAD_XSTATS,
+	IFLA_STATS_AF_SPEC,
 	__IFLA_STATS_MAX,
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 18b5aae99bec..4edc1bd7a735 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3829,6 +3829,39 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 		*idxattr = 0;
 	}
 
+	if (stats_attr_valid(filter_mask, IFLA_STATS_AF_SPEC, *idxattr)) {
+		struct rtnl_af_ops *af_ops;
+
+		*idxattr = IFLA_STATS_AF_SPEC;
+		attr = nla_nest_start(skb, IFLA_STATS_AF_SPEC);
+		if (!attr)
+			goto nla_put_failure;
+
+		list_for_each_entry(af_ops, &rtnl_af_ops, list) {
+			if (af_ops->fill_stats_af) {
+				struct nlattr *af;
+				int err;
+
+				af = nla_nest_start(skb, af_ops->family);
+				if (!af)
+					goto nla_put_failure;
+
+				err = af_ops->fill_stats_af(skb, dev);
+
+				if (err == -ENODATA)
+					nla_nest_cancel(skb, af);
+				else if (err < 0)
+					goto nla_put_failure;
+
+				nla_nest_end(skb, af);
+			}
+		}
+
+		nla_nest_end(skb, attr);
+
+		*idxattr = 0;
+	}
+
 	nlmsg_end(skb, nlh);
 
 	return 0;
@@ -3885,6 +3918,23 @@ static size_t if_nlmsg_stats_size(const struct net_device *dev,
 	if (stats_attr_valid(filter_mask, IFLA_STATS_LINK_OFFLOAD_XSTATS, 0))
 		size += rtnl_get_offload_stats_size(dev);
 
+	if (stats_attr_valid(filter_mask, IFLA_STATS_AF_SPEC, 0)) {
+		struct rtnl_af_ops *af_ops;
+
+		/* for IFLA_STATS_AF_SPEC */
+		size += nla_total_size(0);
+
+		list_for_each_entry(af_ops, &rtnl_af_ops, list) {
+			if (af_ops->get_stats_af_size) {
+				size += nla_total_size(
+					af_ops->get_stats_af_size(dev));
+
+				/* for AF_* */
+				size += nla_total_size(0);
+			}
+		}
+	}
+
 	return size;
 }
 
-- 
2.1.4
