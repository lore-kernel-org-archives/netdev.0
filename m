From: Bart De Schuymer <bdschuym@pandora.be>
Subject: [PATCH] Add sysctl entries for bridge-nf
Date: Mon, 22 Dec 2003 23:01:47 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312222301.47186.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S.Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

The following patch adds these sysctl entries in /proc/sys/net/bridge/:
bridge-nf-call-arptables - pass or don't pass bridged ARP traffic to
arptables' FORWARD chain.
bridge-nf-call-iptables - pass or don't pass bridged IPv4 traffic to
iptables' chains.
bridge-nf-filter-vlan-tagged - pass or don't pass bridged vlan-tagged
ARP/IP traffic to arptables/iptables.

It adds the necessary constants to sysctl.h, changes br_netfilter.c and
adds some info to the ip-sysctl documentation.
The default values are so that the old behavior is kept by default.

cheers,
Bart


--- linux-2.6.0/include/linux/sysctl.h.old	2003-12-21 16:46:05.000000000 +0100
+++ linux-2.6.0/include/linux/sysctl.h	2003-12-21 16:53:09.000000000 +0100
@@ -579,6 +579,14 @@
 	NET_SCTP_MAX_BURST               = 12,
 };
 
+/* /proc/sys/net/bridge */
+enum {
+	NET_BRIDGE_NF_CALL_ARPTABLES = 1,
+	NET_BRIDGE_NF_CALL_IPTABLES = 2,
+	NET_BRIDGE_NF_CALL_IP6TABLES = 3,
+	NET_BRIDGE_NF_FILTER_VLAN_TAGGED = 4,
+};
+
 /* CTL_PROC names: */
 
 /* CTL_FS names: */
--- linux-2.6.0/net/bridge/br_netfilter.c.earlier	2003-12-21 13:29:59.000000000 +0100
+++ linux-2.6.0/net/bridge/br_netfilter.c	2003-12-22 22:16:45.000000000 +0100
@@ -35,6 +35,9 @@
 #include <asm/uaccess.h>
 #include <asm/checksum.h>
 #include "br_private.h"
+#ifdef CONFIG_SYSCTL
+#include <linux/sysctl.h>
+#endif
 
 
 #define skb_origaddr(skb)	 (((struct bridge_skb_cb *) \
@@ -45,10 +48,21 @@
 #define has_bridge_parent(device)	((device)->br_port != NULL)
 #define bridge_parent(device)		((device)->br_port->br->dev)
 
-#define IS_VLAN_IP (skb->protocol == __constant_htons(ETH_P_8021Q) && \
-	hdr->h_vlan_encapsulated_proto == __constant_htons(ETH_P_IP))
-#define IS_VLAN_ARP (skb->protocol == __constant_htons(ETH_P_8021Q) && \
-	hdr->h_vlan_encapsulated_proto == __constant_htons(ETH_P_ARP))
+#ifdef CONFIG_SYSCTL
+static struct ctl_table_header *brnf_sysctl_header;
+static int brnf_call_iptables = 1;
+static int brnf_call_arptables = 1;
+static int brnf_filter_vlan_tagged = 1;
+#else
+#define brnf_filter_vlan_tagged 1
+#endif
+
+#define IS_VLAN_IP (skb->protocol == __constant_htons(ETH_P_8021Q) &&    \
+	hdr->h_vlan_encapsulated_proto == __constant_htons(ETH_P_IP) &&  \
+	brnf_filter_vlan_tagged)
+#define IS_VLAN_ARP (skb->protocol == __constant_htons(ETH_P_8021Q) &&   \
+	hdr->h_vlan_encapsulated_proto == __constant_htons(ETH_P_ARP) && \
+	brnf_filter_vlan_tagged)
 
 /* We need these fake structures to make netfilter happy --
  * lots of places assume that skb->dst != NULL, which isn't
@@ -72,8 +86,7 @@ static struct rtable __fake_rtable = {
 			.metrics		= {[RTAX_MTU - 1] = 1500},
 		}
 	},
-
-	.rt_flags	= 0
+	.rt_flags	= 0,
 };
 
 
@@ -247,6 +260,11 @@ static unsigned int br_nf_pre_routing(un
 	struct sk_buff *skb = *pskb;
 	struct nf_bridge_info *nf_bridge;
 
+#ifdef CONFIG_SYSCTL
+	if (!brnf_call_iptables)
+		return NF_ACCEPT;
+#endif
+
 	if (skb->protocol != __constant_htons(ETH_P_IP)) {
 		struct vlan_ethhdr *hdr = (struct vlan_ethhdr *)
 					  ((*pskb)->mac.ethernet);
@@ -369,7 +387,7 @@ static int br_nf_forward_finish(struct s
  * because of the ipt_physdev.c module. For ARP, indev and outdev are the
  * bridge ports.
  */
-static unsigned int br_nf_forward(unsigned int hook, struct sk_buff **pskb,
+static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff **pskb,
    const struct net_device *in, const struct net_device *out,
    int (*okfn)(struct sk_buff *))
 {
@@ -377,9 +395,13 @@ static unsigned int br_nf_forward(unsign
 	struct nf_bridge_info *nf_bridge;
 	struct vlan_ethhdr *hdr = (struct vlan_ethhdr *)(skb->mac.ethernet);
 
-	if (skb->protocol != __constant_htons(ETH_P_IP) &&
-	    skb->protocol != __constant_htons(ETH_P_ARP)) {
-		if (!IS_VLAN_IP && !IS_VLAN_ARP)
+#ifdef CONFIG_SYSCTL
+	if (!skb->nf_bridge)
+		return NF_ACCEPT;
+#endif
+
+	if (skb->protocol != __constant_htons(ETH_P_IP)) {
+		if (!IS_VLAN_IP)
 			return NF_ACCEPT;
 		skb_pull(*pskb, VLAN_HLEN);
 		(*pskb)->nh.raw += VLAN_HLEN;
@@ -388,39 +410,58 @@ static unsigned int br_nf_forward(unsign
 #ifdef CONFIG_NETFILTER_DEBUG
 	skb->nf_debug ^= (1 << NF_BR_FORWARD);
 #endif
-	if (skb->protocol == __constant_htons(ETH_P_IP) || IS_VLAN_IP) {
-		nf_bridge = skb->nf_bridge;
-		if (skb->pkt_type == PACKET_OTHERHOST) {
-			skb->pkt_type = PACKET_HOST;
-			nf_bridge->mask |= BRNF_PKT_TYPE;
-		}
+	nf_bridge = skb->nf_bridge;
+	if (skb->pkt_type == PACKET_OTHERHOST) {
+		skb->pkt_type = PACKET_HOST;
+		nf_bridge->mask |= BRNF_PKT_TYPE;
+	}
 
-		/* The physdev module checks on this */
-		nf_bridge->mask |= BRNF_BRIDGED;
-		nf_bridge->physoutdev = skb->dev;
+	/* The physdev module checks on this */
+	nf_bridge->mask |= BRNF_BRIDGED;
+	nf_bridge->physoutdev = skb->dev;
 
-		NF_HOOK(PF_INET, NF_IP_FORWARD, skb, bridge_parent(in),
-			bridge_parent(out), br_nf_forward_finish);
-	} else {
-		struct net_device **d = (struct net_device **)(skb->cb);
-		struct arphdr *arp = skb->nh.arph;
+	NF_HOOK(PF_INET, NF_IP_FORWARD, skb, bridge_parent(in),
+		bridge_parent(out), br_nf_forward_finish);
 
-		if (arp->ar_pln != 4) {
-			if (IS_VLAN_ARP) {
-				skb_push(*pskb, VLAN_HLEN);
-				(*pskb)->nh.raw -= VLAN_HLEN;
-			}
+	return NF_STOLEN;
+}
+
+static unsigned int br_nf_forward_arp(unsigned int hook, struct sk_buff **pskb,
+   const struct net_device *in, const struct net_device *out,
+   int (*okfn)(struct sk_buff *))
+{
+	struct sk_buff *skb = *pskb;
+	struct vlan_ethhdr *hdr = (struct vlan_ethhdr *)(skb->mac.ethernet);
+	struct net_device **d = (struct net_device **)(skb->cb);
+
+	if (!brnf_call_arptables)
+		return NF_ACCEPT;
+
+	if (skb->protocol != __constant_htons(ETH_P_ARP)) {
+		if (!IS_VLAN_ARP)
 			return NF_ACCEPT;
+		skb_pull(*pskb, VLAN_HLEN);
+		(*pskb)->nh.raw += VLAN_HLEN;
+	}
+
+#ifdef CONFIG_NETFILTER_DEBUG
+	skb->nf_debug ^= (1 << NF_BR_FORWARD);
+#endif
+
+	if (skb->nh.arph->ar_pln != 4) {
+		if (IS_VLAN_ARP) {
+			skb_push(*pskb, VLAN_HLEN);
+			(*pskb)->nh.raw -= VLAN_HLEN;
 		}
-		*d = (struct net_device *)in;
-		NF_HOOK(NF_ARP, NF_ARP_FORWARD, skb, (struct net_device *)in,
-			(struct net_device *)out, br_nf_forward_finish);
+		return NF_ACCEPT;
 	}
+	*d = (struct net_device *)in;
+	NF_HOOK(NF_ARP, NF_ARP_FORWARD, skb, (struct net_device *)in,
+		(struct net_device *)out, br_nf_forward_finish);
 
 	return NF_STOLEN;
 }
 
-
 /* PF_BRIDGE/LOCAL_OUT ***********************************************/
 static int br_nf_local_out_finish(struct sk_buff *skb)
 {
@@ -471,6 +512,11 @@ static unsigned int br_nf_local_out(unsi
 	struct nf_bridge_info *nf_bridge;
 	struct vlan_ethhdr *hdr = (struct vlan_ethhdr *)(skb->mac.ethernet);
 
+#ifdef CONFIG_SYSCTL
+	if (!skb->nf_bridge)
+		return NF_ACCEPT;
+#endif
+
 	if (skb->protocol != __constant_htons(ETH_P_IP) && !IS_VLAN_IP)
 		return NF_ACCEPT;
 
@@ -481,6 +527,7 @@ static unsigned int br_nf_local_out(unsi
 		return NF_ACCEPT;
 
 	nf_bridge = skb->nf_bridge;
+
 	nf_bridge->physoutdev = skb->dev;
 
 	realindev = nf_bridge->physindev;
@@ -563,6 +610,11 @@ static unsigned int br_nf_post_routing(u
 		return NF_ACCEPT;
 	}
 
+#ifdef CONFIG_SYSCTL
+	if (!nf_bridge)
+		return NF_ACCEPT;
+#endif
+
 	if (skb->protocol != __constant_htons(ETH_P_IP) && !IS_VLAN_IP)
 		return NF_ACCEPT;
 
@@ -628,6 +680,13 @@ static unsigned int ipv4_sabotage_out(un
    const struct net_device *in, const struct net_device *out,
    int (*okfn)(struct sk_buff *))
 {
+	struct sk_buff *skb = *pskb;
+
+#ifdef CONFIG_SYSCTL
+	if (!brnf_call_iptables && !skb->nf_bridge)
+		return NF_ACCEPT;
+#endif
+
 	if ((out->hard_start_xmit == br_dev_xmit &&
 	    okfn != br_nf_forward_finish &&
 	    okfn != br_nf_local_out_finish &&
@@ -637,7 +696,6 @@ static unsigned int ipv4_sabotage_out(un
 	    VLAN_DEV_INFO(out)->real_dev->hard_start_xmit == br_dev_xmit)
 #endif
 	    ) {
-		struct sk_buff *skb = *pskb;
 		struct nf_bridge_info *nf_bridge;
 
 		if (!skb->nf_bridge && !nf_bridge_alloc(skb))
@@ -683,7 +741,12 @@ static struct nf_hook_ops br_nf_ops[] = 
 	  .pf = PF_BRIDGE,
 	  .hooknum = NF_BR_LOCAL_IN,
 	  .priority = NF_BR_PRI_BRNF, },
-	{ .hook = br_nf_forward,
+	{ .hook = br_nf_forward_ip,
+	  .owner = THIS_MODULE,
+	  .pf = PF_BRIDGE,
+	  .hooknum = NF_BR_FORWARD,
+	  .priority = NF_BR_PRI_BRNF - 1, },
+	{ .hook = br_nf_forward_arp,
 	  .owner = THIS_MODULE,
 	  .pf = PF_BRIDGE,
 	  .hooknum = NF_BR_FORWARD,
@@ -720,6 +783,69 @@ static struct nf_hook_ops br_nf_ops[] = 
 	  .priority = NF_IP_PRI_FIRST, },
 };
 
+#ifdef CONFIG_SYSCTL
+static
+int brnf_sysctl_call_tables(ctl_table *ctl, int write, struct file * filp,
+			void *buffer, size_t *lenp)
+{
+	int ret;
+
+	ret = proc_dointvec(ctl, write, filp, buffer, lenp);
+
+	if (write && *(int *)(ctl->data))
+		*(int *)(ctl->data) = 1;
+	return ret;
+}
+
+static ctl_table brnf_table[] = {
+	{
+		.ctl_name	= NET_BRIDGE_NF_CALL_ARPTABLES,
+		.procname	= "bridge-nf-call-arptables",
+		.data		= &brnf_call_arptables,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &brnf_sysctl_call_tables,
+	},
+	{
+		.ctl_name	= NET_BRIDGE_NF_CALL_IPTABLES,
+		.procname	= "bridge-nf-call-iptables",
+		.data		= &brnf_call_iptables,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &brnf_sysctl_call_tables,
+	},
+	{
+		.ctl_name	= NET_BRIDGE_NF_FILTER_VLAN_TAGGED,
+		.procname	= "bridge-nf-filter-vlan-tagged",
+		.data		= &brnf_filter_vlan_tagged,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &brnf_sysctl_call_tables,
+	},
+	{ .ctl_name = 0 }
+};
+
+static ctl_table brnf_bridge_table[] = {
+	{
+		.ctl_name	= NET_BRIDGE,
+		.procname	= "bridge",
+		.mode		= 0555,
+		.child		= brnf_table,
+	},
+	{ .ctl_name = 0 }
+};
+
+static ctl_table brnf_net_table[] = {
+	{
+		.ctl_name	= CTL_NET,
+		.procname	= "net",
+		.mode		= 0555,
+		.child		= brnf_bridge_table,
+	},
+	{ .ctl_name = 0 }
+};
+#endif
+
 int br_netfilter_init(void)
 {
 	int i;
@@ -736,6 +862,16 @@ int br_netfilter_init(void)
 		return ret;
 	}
 
+#ifdef CONFIG_SYSCTL
+	brnf_sysctl_header = register_sysctl_table(brnf_net_table, 0);
+	if (brnf_sysctl_header == NULL) {
+		printk(KERN_WARNING "br_netfilter: can't register to sysctl.\n");
+		for (i = 0; i < ARRAY_SIZE(br_nf_ops); i++)
+			nf_unregister_hook(&br_nf_ops[i]);
+		return -EFAULT;
+	}
+#endif
+
 	printk(KERN_NOTICE "Bridge firewalling registered\n");
 
 	return 0;
@@ -747,4 +883,7 @@ void br_netfilter_fini(void)
 
 	for (i = ARRAY_SIZE(br_nf_ops) - 1; i >= 0; i--)
 		nf_unregister_hook(&br_nf_ops[i]);
+#ifdef CONFIG_SYSCTL
+	unregister_sysctl_table(brnf_sysctl_header);
+#endif
 }
--- linux-2.6.0/Documentation/networking/ip-sysctl.txt.old	2003-12-21 22:12:28.000000000 +0100
+++ linux-2.6.0/Documentation/networking/ip-sysctl.txt	2003-12-21 22:22:00.000000000 +0100
@@ -678,4 +678,23 @@
 Pekka Savola <pekkas@netcore.fi>
 YOSHIFUJI Hideaki / USAGI Project <yoshfuji@linux-ipv6.org>
 
+
+/proc/sys/net/bridge/* Variables:
+
+bridge-nf-call-arptables - BOOLEAN
+	1 : pass bridged ARP traffic to arptables' FORWARD chain.
+	0 : disable this.
+	Default: 1
+
+bridge-nf-call-iptables - BOOLEAN
+	1 : pass bridged IPv4 traffic to iptables' chains.
+	0 : disable this.
+	Default: 1
+
+bridge-nf-filter-vlan-tagged - BOOLEAN
+	1 : pass bridged vlan-tagged ARP/IP traffic to arptables/iptables.
+	0 : disable this.
+	Default: 1
+
+
 $Id: ip-sysctl.txt,v 1.20 2001/12/13 09:00:18 davem Exp $
