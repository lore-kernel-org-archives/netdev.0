From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next v2 1/3] lwtunnel: autoload of lwt modules
Date: Fri, 19 Feb 2016 09:43:16 +0000
Message-ID: <1455874998-26795-2-git-send-email-rshearma@brocade.com>
References: <1455550923-23673-1-git-send-email-rshearma@brocade.com>
 <1455874998-26795-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Tom Herbert" <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jiri Benc <jbenc@redhat.com>,
	"Robert Shearman" <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37371 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161131AbcBSJny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 04:43:54 -0500
In-Reply-To: <1455874998-26795-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The lwt implementations using net devices can autoload using the
existing mechanism using IFLA_INFO_KIND. However, there's no mechanism
that lwt modules not using net devices can use.

Therefore, add the ability to autoload modules registering lwt
operations for lwt implementations not using a net device so that
users don't have to manually load the modules.

Only users with the CAP_NET_ADMIN capability can cause modules to be
loaded, which is ensured by rtnetlink_rcv_msg rejecting non-RTM_GETxxx
messages for users without this capability, and by
lwtunnel_build_state not being called in response to RTM_GETxxx
messages.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 include/net/lwtunnel.h |  4 +++-
 net/core/lwtunnel.c    | 37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 40 insertions(+), 1 deletion(-)

diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index 66350ce3e955..e9f116e29c22 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -170,6 +170,8 @@ static inline int lwtunnel_input(struct sk_buff *skb)
 	return -EOPNOTSUPP;
 }
 
-#endif
+#endif /* CONFIG_LWTUNNEL */
+
+#define MODULE_ALIAS_RTNL_LWT(encap_type) MODULE_ALIAS("rtnl-lwt-" __stringify(encap_type))
 
 #endif /* __NET_LWTUNNEL_H */
diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index 299cfc24d888..669ecc9f884e 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -27,6 +27,31 @@
 #include <net/rtnetlink.h>
 #include <net/ip6_fib.h>
 
+#ifdef CONFIG_MODULES
+
+static const char *lwtunnel_encap_str(enum lwtunnel_encap_types encap_type)
+{
+	/* Only lwt encaps implemented without using an interface for
+	 * the encap need to return a string here.
+	 */
+	switch (encap_type) {
+	case LWTUNNEL_ENCAP_MPLS:
+		return "MPLS";
+	case LWTUNNEL_ENCAP_ILA:
+		return "ILA";
+	case LWTUNNEL_ENCAP_IP6:
+	case LWTUNNEL_ENCAP_IP:
+	case LWTUNNEL_ENCAP_NONE:
+	case __LWTUNNEL_ENCAP_MAX:
+		/* should not have got here */
+		WARN_ON(1);
+		break;
+	}
+	return NULL;
+}
+
+#endif /* CONFIG_MODULES */
+
 struct lwtunnel_state *lwtunnel_state_alloc(int encap_len)
 {
 	struct lwtunnel_state *lws;
@@ -85,6 +110,18 @@ int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
 	ret = -EOPNOTSUPP;
 	rcu_read_lock();
 	ops = rcu_dereference(lwtun_encaps[encap_type]);
+#ifdef CONFIG_MODULES
+	if (!ops) {
+		const char *encap_type_str = lwtunnel_encap_str(encap_type);
+
+		if (encap_type_str) {
+			rcu_read_unlock();
+			request_module("rtnl-lwt-%s", encap_type_str);
+			rcu_read_lock();
+			ops = rcu_dereference(lwtun_encaps[encap_type]);
+		}
+	}
+#endif
 	if (likely(ops && ops->build_state))
 		ret = ops->build_state(dev, encap, family, cfg, lws);
 	rcu_read_unlock();
-- 
2.1.4
