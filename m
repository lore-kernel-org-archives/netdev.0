From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2.4] PKT_SCHED: Fix ingress qdisc to pick up IPv6 packets
Date: Wed, 2 Feb 2005 23:36:29 +0100
Message-ID: <20050202223629.GS31837@postel.suug.ch>
References: <20050131184827.GH31837@postel.suug.ch> <20050202130743.065bc627.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050202130743.065bc627.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.4.29-bk8.orig/net/sched/sch_ingress.c	2005-02-02 22:32:51.000000000 +0100
+++ linux-2.4.29-bk8/net/sched/sch_ingress.c	2005-02-02 22:56:33.000000000 +0100
@@ -14,6 +14,7 @@
 #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <linux/netfilter_ipv4.h>
+#include <linux/netfilter_ipv6.h>
 #include <linux/netfilter.h>
 #include <linux/smp.h>
 #include <net/pkt_sched.h>
@@ -241,6 +242,15 @@
 	NF_IP_PRI_FILTER + 1
 };
 
+static struct nf_hook_ops ing6_ops =
+{
+	{ NULL, NULL},
+	ing_hook,
+	PF_INET6,
+	NF_IP6_PRE_ROUTING,
+	NF_IP6_PRI_FILTER + 1
+};
+
 int ingress_init(struct Qdisc *sch,struct rtattr *opt)
 {
 	struct ingress_qdisc_data *p = PRIV(sch);
@@ -249,8 +259,13 @@
 		if (nf_register_hook(&ing_ops) < 0) {
 			printk("ingress qdisc registration error \n");
 			goto error;
-			}
+		}
 		nf_registered++;
+		if (nf_register_hook(&ing6_ops) < 0) {
+			printk("IPv6 ingress qdisc registration error, " \
+			    "disabling IPv6 support.\n");
+		} else
+			nf_registered++;
 	}
 
 	DPRINTK("ingress_init(sch %p,[qdisc %p],opt %p)\n",sch,p,opt);
@@ -374,8 +389,11 @@
 void cleanup_module(void) 
 {
 	unregister_qdisc(&ingress_qdisc_ops);
-	if (nf_registered)
+	if (nf_registered) {
 		nf_unregister_hook(&ing_ops);
+		if (nf_registered > 1)
+			nf_unregister_hook(&ing6_ops);
+	}
 }
 #endif
 MODULE_LICENSE("GPL");
