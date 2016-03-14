From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/2] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Mon, 14 Mar 2016 15:51:44 +0100
Message-ID: <20160314145144.GE2346@nanopsycho.orion>
References: <1457834186-45727-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35898 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932353AbcCNOvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 10:51:48 -0400
Received: by mail-wm0-f66.google.com with SMTP id l68so15607344wml.3
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 07:51:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1457834186-45727-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Mar 13, 2016 at 02:56:25AM CET, roopa@cumulusnetworks.com wrote:
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>This patch adds a new RTM_GETSTATS message to query link stats via netlink
>from the kernel. RTM_NEWLINK also dumps stats today, but RTM_NEWLINK
>returns a lot more than just stats and is expensive in some cases when
>frequent polling for stats from userspace is a common operation.
>
>RTM_GETSTATS is an attempt to provide a light weight netlink message
>to explicity query only link stats from the kernel on an interface.
>The idea is to also keep it extensible so that new kinds of stats can be
>added to it in the future.
>
>This patch adds the following attribute for NETDEV stats:
>struct nla_policy ifla_stats_policy[IFLA_STATS_MAX + 1] = {
>        [IFLA_STATS_LINK64]  = { .len = sizeof(struct rtnl_link_stats64) },
>};
>
>This patch also allows for af family stats (an example af stats for IPV6
>is available with the second patch in the series).
>
>Like any other rtnetlink message, RTM_GETSTATS can be used to get stats of
>a single interface or all interfaces with NLM_F_DUMP.
>
>Future possible new types of stat attributes:
>- IFLA_MPLS_STATS  (nested. for mpls/mdev stats)
>- IFLA_EXTENDED_STATS (nested. extended software netdev stats like bridge,
>  vlan, vxlan etc)
>- IFLA_EXTENDED_HW_STATS (nested. extended hardware stats which are
>  available via ethtool today)
>
>This patch also declares a filter mask for all stat attributes.
>User has to provide a mask of stats attributes to query. This will be
>specified in a new hdr 'struct if_stats_msg' for stats messages.
>
>Without any attributes in the filter_mask, no stats will be returned.
>
>This patch has been tested with modified iproute2 ifstat.
>
>Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
>Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>---
> include/net/rtnetlink.h        |   5 ++
> include/uapi/linux/if_link.h   |  19 ++++
> include/uapi/linux/rtnetlink.h |   7 ++
> net/core/rtnetlink.c           | 200 +++++++++++++++++++++++++++++++++++++++++
> 4 files changed, 231 insertions(+)
>
>diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
>index 2f87c1b..fa68158 100644
>--- a/include/net/rtnetlink.h
>+++ b/include/net/rtnetlink.h
>@@ -131,6 +131,11 @@ struct rtnl_af_ops {
> 						    const struct nlattr *attr);
> 	int			(*set_link_af)(struct net_device *dev,
> 					       const struct nlattr *attr);
>+	size_t			(*get_link_af_stats_size)(const struct net_device *dev,
>+							  u32 filter_mask);
>+	int			(*fill_link_af_stats)(struct sk_buff *skb,
>+						      const struct net_device *dev,
>+						      u32 filter_mask);
> };
> 
> void __rtnl_af_unregister(struct rtnl_af_ops *ops);
>diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>index 249eef9..0840f3e 100644
>--- a/include/uapi/linux/if_link.h
>+++ b/include/uapi/linux/if_link.h
>@@ -741,4 +741,23 @@ enum {
> 
> #define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
> 
>+/* STATS section */
>+
>+struct if_stats_msg {
>+	__u8  family;
>+	__u32 ifindex;
>+	__u32 filter_mask;

This limit future extension to only 32 groups of stats. I can imagine
that more than that can be added, easily. Why don't you use nested
attribute IFLA_STATS_FILTER with flag attributes for every type? That
would be easily extendable.

Using netlink header struct for this does not look correct to me.
In past, this was done lot of times and turned out to be a problem later.



>+};
>+
>+enum {
>+	IFLA_STATS_UNSPEC,
>+	IFLA_STATS_LINK64,
>+	IFLA_STATS_INET6,
>+	__IFLA_STATS_MAX,
>+};
>+
>+#define IFLA_STATS_MAX (__IFLA_STATS_MAX - 1)
>+
>+#define IFLA_STATS_FILTER_BIT(ATTR)	(1 << (ATTR))
>+
