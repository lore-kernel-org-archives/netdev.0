From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/5] net: add CONFIG_NET_INGRESS to enable ingress filtering
Date: Wed, 13 May 2015 18:19:37 +0200
Message-ID: <1431533978-26901-5-git-send-email-pablo@netfilter.org>
References: <1431533978-26901-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, jhs@mojatatu.com,
	daniel@iogearbox.net, eric.dumazet@gmail.com, kaber@trash.net,
	ast@plumgrid.com
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1431533978-26901-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This new config switch enables the ingress filtering infrastructure that is
controlled through the ingress_needed static key. This prepares the
introduction of the Netfilter ingress hook that resides under this unique
static key.

Note that CONFIG_SCH_INGRESS automatically selects this, that should be no
problem since this also depends on CONFIG_NET_CLS_ACT.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/rtnetlink.h |    2 +-
 net/Kconfig               |    3 +++
 net/core/dev.c            |    7 ++++---
 net/sched/Kconfig         |    1 +
 4 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index bd29ab4..a2324fb 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -79,7 +79,7 @@ static inline struct netdev_queue *dev_ingress_queue(struct net_device *dev)
 
 struct netdev_queue *dev_ingress_queue_create(struct net_device *dev);
 
-#ifdef CONFIG_NET_CLS_ACT
+#ifdef CONFIG_NET_INGRESS
 void net_inc_ingress_queue(void);
 void net_dec_ingress_queue(void);
 #endif
diff --git a/net/Kconfig b/net/Kconfig
index 44dd578..57a7c5a 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -45,6 +45,9 @@ config COMPAT_NETLINK_MESSAGES
 	  Newly written code should NEVER need this option but do
 	  compat-independent messages instead!
 
+config NET_INGRESS
+	bool
+
 menu "Networking options"
 
 source "net/packet/Kconfig"
diff --git a/net/core/dev.c b/net/core/dev.c
index e5f77c4..5b3dc5c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1630,7 +1630,7 @@ int call_netdevice_notifiers(unsigned long val, struct net_device *dev)
 }
 EXPORT_SYMBOL(call_netdevice_notifiers);
 
-#ifdef CONFIG_NET_CLS_ACT
+#ifdef CONFIG_NET_INGRESS
 static struct static_key ingress_needed __read_mostly;
 
 void net_inc_ingress_queue(void)
@@ -3692,13 +3692,14 @@ another_round:
 	}
 
 skip_taps:
-#ifdef CONFIG_NET_CLS_ACT
+#ifdef CONFIG_NET_INGRESS
 	if (static_key_false(&ingress_needed)) {
 		skb = handle_ing(skb, &pt_prev, &ret, orig_dev);
 		if (!skb)
 			goto unlock;
 	}
-
+#endif
+#ifdef CONFIG_NET_CLS_ACT
 	skb->tc_verd = 0;
 ncls:
 #endif
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 2274e72..36700d8 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -312,6 +312,7 @@ config NET_SCH_PIE
 config NET_SCH_INGRESS
 	tristate "Ingress Qdisc"
 	depends on NET_CLS_ACT
+	select NET_INGRESS
 	---help---
 	  Say Y here if you want to use classifiers for incoming packets.
 	  If unsure, say Y.
-- 
1.7.10.4

