From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] PKT_SCHED: Fix ingress qdisc to pick up IPv6 packets when using netfilter hooks
Date: Mon, 31 Jan 2005 19:48:27 +0100
Message-ID: <20050131184827.GH31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal, close your eyes please.

Fixes the ingress qdisc to pick up IPv6 packets when using the old
style netfilter hooks, i.e. when CONFIG_NET_CLS_ACT is not enabled.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.11-rc2-bk8.orig/net/sched/sch_ingress.c	2005-01-30 21:19:51.000000000 +0100
+++ linux-2.6.11-rc2-bk8/net/sched/sch_ingress.c	2005-01-31 19:32:29.000000000 +0100
@@ -14,6 +14,7 @@
 #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <linux/netfilter_ipv4.h>
+#include <linux/netfilter_ipv6.h>
 #include <linux/netfilter.h>
 #include <linux/smp.h>
 #include <net/pkt_sched.h>
@@ -271,6 +272,14 @@
 	.priority       = NF_IP_PRI_FILTER + 1,
 };
 
+static struct nf_hook_ops ing6_ops = {
+	.hook           = ing_hook,
+	.owner		= THIS_MODULE,
+	.pf             = PF_INET6,
+	.hooknum        = NF_IP6_PRE_ROUTING,
+	.priority       = NF_IP6_PRI_FILTER + 1,
+};
+
 #endif
 #endif
 
@@ -297,6 +306,12 @@
 			return -EINVAL;
 		}
 		nf_registered++;
+
+		if (nf_register_hook(&ing6_ops) < 0) {
+			printk("IPv6 ingress qdisc registration error, " \
+			    "disabling IPv6 support.\n");
+		} else
+			nf_registered++;
 	}
 #endif
 #endif
@@ -408,8 +423,11 @@
 	unregister_qdisc(&ingress_qdisc_ops);
 #ifndef CONFIG_NET_CLS_ACT
 #ifdef CONFIG_NETFILTER
-	if (nf_registered)
+	if (nf_registered) {
 		nf_unregister_hook(&ing_ops);
+		if (nf_registered > 1)
+			nf_unregister_hook(&ing6_ops);
+	}
 #endif
 #endif
 }
