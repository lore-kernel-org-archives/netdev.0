From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next 1/3] lwtunnel: autoload of lwt modules
Date: Mon, 15 Feb 2016 15:42:01 +0000
Message-ID: <1455550923-23673-2-git-send-email-rshearma@brocade.com>
References: <1455550923-23673-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Tom Herbert" <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jiri Benc <jbenc@redhat.com>,
	"Robert Shearman" <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:1723 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751619AbcBOPnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 10:43:02 -0500
In-Reply-To: <1455550923-23673-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The lwt implementations using net devices can autoload using the
existing mechanism using IFLA_INFO_KIND. However, there's no mechanism
that lwt modules not using net devices can use.

Therefore, add the ability to autoload modules registering lwt
operations for lwt implementations not using a net device so that
users don't have to manually load the modules.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 include/net/lwtunnel.h |  4 +++-
 net/core/lwtunnel.c    | 32 ++++++++++++++++++++++++++++++++
 2 files changed, 35 insertions(+), 1 deletion(-)

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
index 299cfc24d888..8ef5e5cec03e 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -27,6 +27,30 @@
 #include <net/rtnetlink.h>
 #include <net/ip6_fib.h>
 
+#ifdef CONFIG_MODULES
+
+static const char *lwtunnel_encap_str(enum lwtunnel_encap_types encap_type)
+{
+	switch (encap_type) {
+	case LWTUNNEL_ENCAP_MPLS:
+		return "LWTUNNEL_ENCAP_MPLS";
+	case LWTUNNEL_ENCAP_IP:
+		return "LWTUNNEL_ENCAP_IP";
+	case LWTUNNEL_ENCAP_ILA:
+		return "LWTUNNEL_ENCAP_ILA";
+	case LWTUNNEL_ENCAP_IP6:
+		return "LWTUNNEL_ENCAP_IP6";
+	case LWTUNNEL_ENCAP_NONE:
+	case __LWTUNNEL_ENCAP_MAX:
+		/* should not have got here */
+		break;
+	}
+	WARN_ON(1);
+	return "LWTUNNEL_ENCAP_NONE";
+}
+
+#endif /* CONFIG_MODULES */
+
 struct lwtunnel_state *lwtunnel_state_alloc(int encap_len)
 {
 	struct lwtunnel_state *lws;
@@ -85,6 +109,14 @@ int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
 	ret = -EOPNOTSUPP;
 	rcu_read_lock();
 	ops = rcu_dereference(lwtun_encaps[encap_type]);
+#ifdef CONFIG_MODULES
+	if (!ops) {
+		rcu_read_unlock();
+		request_module("rtnl-lwt-%s", lwtunnel_encap_str(encap_type));
+		rcu_read_lock();
+		ops = rcu_dereference(lwtun_encaps[encap_type]);
+	}
+#endif
 	if (likely(ops && ops->build_state))
 		ret = ops->build_state(dev, encap, family, cfg, lws);
 	rcu_read_unlock();
-- 
2.1.4
