From: Julien Gomes <julien@arista.com>
Subject: [PATCH net-next v3 2/4] rtnetlink: add restricted rtnl groups for ipv4 and ipv6 mroute
Date: Tue, 20 Jun 2017 13:54:16 -0700
Message-ID: <20170620205418.1648-3-julien@arista.com>
References: <20170620205418.1648-1-julien@arista.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        sharpd@cumulusnetworks.com, nicolas.dichtel@6wind.com,
        Julien Gomes <julien@arista.com>
To: davem@davemloft.net, nikolay@cumulusnetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170620205418.1648-1-julien@arista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add RTNLGRP_{IPV4,IPV6}_MROUTE_R as two new restricted groups for the
NETLINK_ROUTE family.
Binding to these groups specifically requires CAP_NET_ADMIN to allow
multicast of sensitive messages (e.g. mroute cache reports).

Suggested-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Signed-off-by: Julien Gomes <julien@arista.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/rtnetlink.h |  4 ++++
 net/core/rtnetlink.c           | 13 +++++++++++++
 2 files changed, 17 insertions(+)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index cd1afb900929..d148505010a7 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -669,6 +669,10 @@ enum rtnetlink_groups {
 #define RTNLGRP_NSID		RTNLGRP_NSID
 	RTNLGRP_MPLS_NETCONF,
 #define RTNLGRP_MPLS_NETCONF	RTNLGRP_MPLS_NETCONF
+	RTNLGRP_IPV4_MROUTE_R,
+#define RTNLGRP_IPV4_MROUTE_R	RTNLGRP_IPV4_MROUTE_R
+	RTNLGRP_IPV6_MROUTE_R,
+#define RTNLGRP_IPV6_MROUTE_R	RTNLGRP_IPV6_MROUTE_R
 	__RTNLGRP_MAX
 };
 #define RTNLGRP_MAX	(__RTNLGRP_MAX - 1)
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 3aa57848a895..4aefa5a2625f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4218,6 +4218,18 @@ static void rtnetlink_rcv(struct sk_buff *skb)
 	rtnl_unlock();
 }
 
+static int rtnetlink_bind(struct net *net, int group)
+{
+	switch (group) {
+	case RTNLGRP_IPV4_MROUTE_R:
+	case RTNLGRP_IPV6_MROUTE_R:
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
+			return -EPERM;
+		break;
+	}
+	return 0;
+}
+
 static int rtnetlink_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
@@ -4252,6 +4264,7 @@ static int __net_init rtnetlink_net_init(struct net *net)
 		.input		= rtnetlink_rcv,
 		.cb_mutex	= &rtnl_mutex,
 		.flags		= NL_CFG_F_NONROOT_RECV,
+		.bind		= rtnetlink_bind,
 	};
 
 	sk = netlink_kernel_create(net, NETLINK_ROUTE, &cfg);
-- 
2.13.1
