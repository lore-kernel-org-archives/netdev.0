From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 08/13]: [NETFILTER]: Use conntrack information to determine
	if packet was NATed
Date: Sun, 20 Nov 2005 17:31:38 +0100
Message-ID: <20051120163138.16666.9711.sendpatchset@localhost.localdomain>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: davem@davemloft.net
In-Reply-To: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

[NETFILTER]: Use conntrack information to determine if packet was NATed

Preparation for full IPsec support for NAT:

Use conntrack information instead of saving the saving and comparing the
addresses to determine if a packet was NATed and needs to be rerouted to
make it easier to extend the key.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 864cef1bc7d011f4a07b01043786107ad570c820
tree dbf671924ab6eb7bd87baaae9118bb57d7b3ab8e
parent ffa4445cd4284d3d9b688c80f5a3b9f8b26d59e6
author Patrick McHardy <kaber@trash.net> Sat, 19 Nov 2005 22:05:26 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 19 Nov 2005 22:05:26 +0100

 net/ipv4/netfilter/ip_nat_standalone.c |   34 ++++++++++++++++++--------------
 1 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip_nat_standalone.c
index f04111f..1bb5089 100644
--- a/net/ipv4/netfilter/ip_nat_standalone.c
+++ b/net/ipv4/netfilter/ip_nat_standalone.c
@@ -162,18 +162,20 @@ ip_nat_in(unsigned int hooknum,
           const struct net_device *out,
           int (*okfn)(struct sk_buff *))
 {
-	u_int32_t saddr, daddr;
+	struct ip_conntrack *ct;
+	enum ip_conntrack_info ctinfo;
 	unsigned int ret;
 
-	saddr = (*pskb)->nh.iph->saddr;
-	daddr = (*pskb)->nh.iph->daddr;
-
 	ret = ip_nat_fn(hooknum, pskb, in, out, okfn);
 	if (ret != NF_DROP && ret != NF_STOLEN
-	    && ((*pskb)->nh.iph->saddr != saddr
-	        || (*pskb)->nh.iph->daddr != daddr)) {
-		dst_release((*pskb)->dst);
-		(*pskb)->dst = NULL;
+	    && (ct = ip_conntrack_get(*pskb, &ctinfo)) != NULL) {
+		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
+
+		if (ct->tuplehash[dir].tuple.src.ip !=
+		    ct->tuplehash[!dir].tuple.dst.ip) {
+			dst_release((*pskb)->dst);
+			(*pskb)->dst = NULL;
+		}
 	}
 	return ret;
 }
@@ -200,7 +202,8 @@ ip_nat_local_fn(unsigned int hooknum,
 		const struct net_device *out,
 		int (*okfn)(struct sk_buff *))
 {
-	u_int32_t saddr, daddr;
+	struct ip_conntrack *ct;
+	enum ip_conntrack_info ctinfo;
 	unsigned int ret;
 
 	/* root is playing with raw sockets. */
@@ -208,14 +211,15 @@ ip_nat_local_fn(unsigned int hooknum,
 	    || (*pskb)->nh.iph->ihl * 4 < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
-	saddr = (*pskb)->nh.iph->saddr;
-	daddr = (*pskb)->nh.iph->daddr;
-
 	ret = ip_nat_fn(hooknum, pskb, in, out, okfn);
 	if (ret != NF_DROP && ret != NF_STOLEN
-	    && ((*pskb)->nh.iph->saddr != saddr
-		|| (*pskb)->nh.iph->daddr != daddr))
-		return ip_route_me_harder(pskb) == 0 ? ret : NF_DROP;
+	    && (ct = ip_conntrack_get(*pskb, &ctinfo)) != NULL) {
+		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
+
+		if (ct->tuplehash[dir].tuple.dst.ip !=
+		    ct->tuplehash[!dir].tuple.src.ip)
+			return ip_route_me_harder(pskb) == 0 ? ret : NF_DROP;
+	}
 	return ret;
 }
 
