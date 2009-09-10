From: Patrick McHardy <kaber@trash.net>
Subject: ipvs 27/31: Use atomic operations atomicly
Date: Thu, 10 Sep 2009 18:12:21 +0200 (MEST)
Message-ID: <20090910161217.31179.2565.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 1e66dafc75f40a08b2addb82779987b269b4ca23
Author: Simon Horman <horms@verge.net.au>
Date:   Mon Aug 31 14:18:48 2009 +0200

    ipvs: Use atomic operations atomicly
    
    A pointed out by Shin Hong, IPVS doesn't always use atomic operations
    in an atomic manner. While this seems unlikely to be manifest in
    strange behaviour, it seems appropriate to clean this up.
    
    Cc: shin hong <hongshin@gmail.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index b227750..a986ee2 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1259,7 +1259,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_conn *cp;
-	int ret, restart, af;
+	int ret, restart, af, pkts;
 
 	af = (skb->protocol == htons(ETH_P_IP)) ? AF_INET : AF_INET6;
 
@@ -1346,12 +1346,12 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 	 * Sync connection if it is about to close to
 	 * encorage the standby servers to update the connections timeout
 	 */
-	atomic_inc(&cp->in_pkts);
+	pkts = atomic_add_return(1, &cp->in_pkts);
 	if (af == AF_INET &&
 	    (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
 	    (((cp->protocol != IPPROTO_TCP ||
 	       cp->state == IP_VS_TCP_S_ESTABLISHED) &&
-	      (atomic_read(&cp->in_pkts) % sysctl_ip_vs_sync_threshold[1]
+	      (pkts % sysctl_ip_vs_sync_threshold[1]
 	       == sysctl_ip_vs_sync_threshold[0])) ||
 	     ((cp->protocol == IPPROTO_TCP) && (cp->old_state != cp->state) &&
 	      ((cp->state == IP_VS_TCP_S_FIN_WAIT) ||
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index 70ff82c..6182e8e 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -77,11 +77,12 @@ static int ip_vs_wrr_gcd_weight(struct ip_vs_service *svc)
 static int ip_vs_wrr_max_weight(struct ip_vs_service *svc)
 {
 	struct ip_vs_dest *dest;
-	int weight = 0;
+	int new_weight, weight = 0;
 
 	list_for_each_entry(dest, &svc->destinations, n_list) {
-		if (atomic_read(&dest->weight) > weight)
-			weight = atomic_read(&dest->weight);
+		new_weight = atomic_read(&dest->weight);
+		if (new_weight > weight)
+			weight = new_weight;
 	}
 
 	return weight;
