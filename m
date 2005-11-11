From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 08/10]: [NETFILTER]: Use conntrack information to determine
 if packet was NATed
Date: Fri, 11 Nov 2005 04:19:34 +0100
Message-ID: <43740DC6.5060403@trash.net>
Mime-Version: 1.0
Content-Type: text/x-patch;
 name="08.diff"
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline;
 filename="08.diff"
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

Use conntrack information instead of saving the saving and comparing
the addresses to determine if a packet was NATed and needs to be
rerouted to make it easier to extend the key.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 351bc1c8a9c5c5e4aa48c153f0050f0a8b979201
tree 9f8a0f9472ed609beba69bf653fa7833d61db339
parent 909b664477ab16fc04f2bf24ef92676117ccbc26
author Patrick McHardy <kaber@trash.net> Fri, 11 Nov 2005 03:04:28 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 11 Nov 2005 03:04:28 +0100

 net/ipv4/netfilter/ip_nat_standalone.c |   34 ++++++++++++++++++--------------
 1 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip_nat_standalone.c
index f0fff02..ff24bac 100644
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
@@ -202,7 +204,8 @@ ip_nat_local_fn(unsigned int hooknum,
 		const struct net_device *out,
 		int (*okfn)(struct sk_buff *))
 {
-	u_int32_t saddr, daddr;
+	struct ip_conntrack *ct;
+	enum ip_conntrack_info ctinfo;
 	unsigned int ret;
 
 	/* root is playing with raw sockets. */
@@ -210,14 +213,15 @@ ip_nat_local_fn(unsigned int hooknum,
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
 
