From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/5] ipvs: Fix reuse connection if real server is dead
Date: Wed, 29 May 2013 18:03:11 +0200
Message-ID: <1369843394-24251-4-git-send-email-pablo@netfilter.org>
References: <1369843394-24251-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1369843394-24251-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>

Expire cached connection for new TCP/SCTP connection if real
server is down. Otherwise, IPVS uses the dead server for the
reused connection, instead of a new working one.

Signed-off-by: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>
Acked-by: Hans Schillstrom <hans@schillstrom.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipvs/ip_vs_core.c |   35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 085b588..05565d2 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1001,6 +1001,32 @@ static inline int is_tcp_reset(const struct sk_buff *skb, int nh_len)
 	return th->rst;
 }
 
+static inline bool is_new_conn(const struct sk_buff *skb,
+			       struct ip_vs_iphdr *iph)
+{
+	switch (iph->protocol) {
+	case IPPROTO_TCP: {
+		struct tcphdr _tcph, *th;
+
+		th = skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
+		if (th == NULL)
+			return false;
+		return th->syn;
+	}
+	case IPPROTO_SCTP: {
+		sctp_chunkhdr_t *sch, schunk;
+
+		sch = skb_header_pointer(skb, iph->len + sizeof(sctp_sctphdr_t),
+					 sizeof(schunk), &schunk);
+		if (sch == NULL)
+			return false;
+		return sch->type == SCTP_CID_INIT;
+	}
+	default:
+		return false;
+	}
+}
+
 /* Handle response packets: rewrite addresses and send away...
  */
 static unsigned int
@@ -1612,6 +1638,15 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	 * Check if the packet belongs to an existing connection entry
 	 */
 	cp = pp->conn_in_get(af, skb, &iph, 0);
+
+	if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp && cp->dest &&
+	    unlikely(!atomic_read(&cp->dest->weight)) && !iph.fragoffs &&
+	    is_new_conn(skb, &iph)) {
+		ip_vs_conn_expire_now(cp);
+		__ip_vs_conn_put(cp);
+		cp = NULL;
+	}
+
 	if (unlikely(!cp) && !iph.fragoffs) {
 		/* No (second) fragments need to enter here, as nf_defrag_ipv6
 		 * replayed fragment zero will already have created the cp
-- 
1.7.10.4

