From: Bart De Schuymer <bdschuym@pandora.be>
Subject: [PATCH] don't require ip_forwarding for reset on a bridge
Date: Mon, 29 Mar 2004 23:14:12 +0200
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <200403292314.12855.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>,
	netfilter-devel <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: David S.Miller <davem@redhat.com>
Content-Disposition: inline
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

Hi Dave,

Currently, to be able to send a reset in the FORWARD chain of iptables
for bridged traffic, ip forwarding must be enabled. This causes confusion
and in some situations people really don't want to enable ip forwarding.
The patch below lets the user send reset packets for bridged frames in
the FORWARD chain, with ip forwarding disabled (as long as there is a
route).

cheers,
Bart

--- linux-2.6.4/net/ipv4/netfilter/ipt_REJECT.c.old	Sun Mar 21 19:34:04 2004
+++ linux-2.6.4/net/ipv4/netfilter/ipt_REJECT.c	Mon Mar 22 22:54:56 2004
@@ -24,6 +24,9 @@
 #include <net/route.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
 #include <linux/netfilter_ipv4/ipt_REJECT.h>
+#ifdef CONFIG_BRIDGE_NETFILTER
+#include <linux/netfilter_bridge.h>
+#endif
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
@@ -56,7 +59,13 @@ static inline struct rtable *route_rever
 	struct flowi fl = {};
 	struct rtable *rt;
 
-	if (hook != NF_IP_FORWARD) {
+	/* We don't require ip forwarding to be enabled to be able to
+	 * send a RST reply for bridged traffic. */
+	if (hook != NF_IP_FORWARD
+#ifdef CONFIG_BRIDGE_NETFILTER
+	    || (skb->nf_bridge && skb->nf_bridge->mask & BRNF_BRIDGED)
+#endif
+	   ) {
 		fl.nl_u.ip4_u.daddr = iph->saddr;
 		if (hook == NF_IP_LOCAL_IN)
 			fl.nl_u.ip4_u.saddr = iph->daddr;
