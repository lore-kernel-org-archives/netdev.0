From: Bart De Schuymer <bdschuym@pandora.be>
Subject: [PATCH][BRIDGE-NF] Fix wrong use of skb->protocol
Date: Thu, 30 Dec 2004 19:55:14 +0100
Message-ID: <1104432914.15601.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

ip_sabotage_out() needs to distinguish IPv4 and IPv6 traffic. It
currently does that by looking at skb->protocol. However, for locally
originated packets, skb->protocol is not initialized.
The patch below instead looks at the version number of the packet's
data, which should be 4 or 6.

Thanks to Pasha (Crazy AMD K7 <snort2004@mail.ru>) for his patience.

Signed-off-by: Bart De Schuymer <bdschuym@telenet.be>

--- linux-2.6.10/net/bridge/br_netfilter.c.old	2004-12-30 15:34:11.000000000 +0100
+++ linux-2.6.10/net/bridge/br_netfilter.c	2004-12-30 19:13:31.000000000 +0100
@@ -845,19 +845,6 @@ static unsigned int ip_sabotage_out(unsi
 {
 	struct sk_buff *skb = *pskb;
 
-#ifdef CONFIG_SYSCTL
-	if (!skb->nf_bridge) {
-		struct vlan_ethhdr *hdr = vlan_eth_hdr(skb);
-
-		if (skb->protocol == __constant_htons(ETH_P_IP) ||
-		    IS_VLAN_IP) {
-			if (!brnf_call_iptables)
-				return NF_ACCEPT;
-		} else if (!brnf_call_ip6tables)
-			return NF_ACCEPT;
-	}
-#endif
-
 	if ((out->hard_start_xmit == br_dev_xmit &&
 	    okfn != br_nf_forward_finish &&
 	    okfn != br_nf_local_out_finish &&
@@ -869,8 +856,24 @@ static unsigned int ip_sabotage_out(unsi
 	    ) {
 		struct nf_bridge_info *nf_bridge;
 
-		if (!skb->nf_bridge && !nf_bridge_alloc(skb))
-			return NF_DROP;
+		if (!skb->nf_bridge) {
+#ifdef CONFIG_SYSCTL
+			/* This code is executed while in the IP(v6) stack,
+			   the version should be 4 or 6. We can't use
+			   skb->protocol because that isn't set on
+			   PF_INET(6)/LOCAL_OUT. */
+			struct iphdr *ip = skb->nh.iph;
+
+			if (ip->version == 4 && !brnf_call_iptables)
+				return NF_ACCEPT;
+			else if (ip->version == 6 && !brnf_call_ip6tables)
+				return NF_ACCEPT;
+#endif
+			if (hook == NF_IP_POST_ROUTING)
+				return NF_ACCEPT;
+			if (!nf_bridge_alloc(skb))
+				return NF_DROP;
+		}
 
 		nf_bridge = skb->nf_bridge;
 
