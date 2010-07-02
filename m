From: kaber@trash.net
Subject: [PATCH 2/9] IPVS: one-packet scheduling
Date: Fri,  2 Jul 2010 11:52:15 +0200
Message-ID: <1278064342-19059-3-git-send-email-kaber@trash.net>
References: <1278064342-19059-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1278064342-19059-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nick Chalk <nick@loadbalancer.org>

Allow one-packet scheduling for UDP connections. When the fwmark-based or
normal virtual service is marked with '-o' or '--ops' options all
connections are created only to schedule one packet. Useful to schedule UDP
packets from same client port to different real servers. Recommended with
RR or WRR schedulers (the connections are not visible with ipvsadm -L).

Signed-off-by: Nick Chalk <nick@loadbalancer.org>
Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/ip_vs.h           |    2 ++
 net/netfilter/ipvs/ip_vs_conn.c |   10 +++++++---
 net/netfilter/ipvs/ip_vs_core.c |   20 ++++++++++++++++----
 net/netfilter/ipvs/ip_vs_ctl.c  |   10 ++++++----
 4 files changed, 31 insertions(+), 11 deletions(-)

diff --git a/include/linux/ip_vs.h b/include/linux/ip_vs.h
index dfc1703..9708de2 100644
--- a/include/linux/ip_vs.h
+++ b/include/linux/ip_vs.h
@@ -19,6 +19,7 @@
  */
 #define IP_VS_SVC_F_PERSISTENT	0x0001		/* persistent port */
 #define IP_VS_SVC_F_HASHED	0x0002		/* hashed entry */
+#define IP_VS_SVC_F_ONEPACKET	0x0004		/* one-packet scheduling */
 
 /*
  *      Destination Server Flags
@@ -85,6 +86,7 @@
 #define IP_VS_CONN_F_SEQ_MASK	0x0600		/* in/out sequence mask */
 #define IP_VS_CONN_F_NO_CPORT	0x0800		/* no client port set yet */
 #define IP_VS_CONN_F_TEMPLATE	0x1000		/* template, not connection */
+#define IP_VS_CONN_F_ONE_PACKET	0x2000		/* forward only one packet */
 
 #define IP_VS_SCHEDNAME_MAXLEN	16
 #define IP_VS_IFNAME_MAXLEN	16
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index d8f7e8e..717e623 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -158,6 +158,9 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 	unsigned hash;
 	int ret;
 
+	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
+		return 0;
+
 	/* Hash by protocol, client address and port */
 	hash = ip_vs_conn_hashkey(cp->af, cp->protocol, &cp->caddr, cp->cport);
 
@@ -355,8 +358,9 @@ struct ip_vs_conn *ip_vs_conn_out_get
  */
 void ip_vs_conn_put(struct ip_vs_conn *cp)
 {
-	/* reset it expire in its timeout */
-	mod_timer(&cp->timer, jiffies+cp->timeout);
+	unsigned long t = (cp->flags & IP_VS_CONN_F_ONE_PACKET) ?
+		0 : cp->timeout;
+	mod_timer(&cp->timer, jiffies+t);
 
 	__ip_vs_conn_put(cp);
 }
@@ -649,7 +653,7 @@ static void ip_vs_conn_expire(unsigned long data)
 	/*
 	 *	unhash it if it is hashed in the conn table
 	 */
-	if (!ip_vs_conn_unhash(cp))
+	if (!ip_vs_conn_unhash(cp) && !(cp->flags & IP_VS_CONN_F_ONE_PACKET))
 		goto expire_later;
 
 	/*
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 1cd6e3f..50907d8 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -194,6 +194,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	struct ip_vs_dest *dest;
 	struct ip_vs_conn *ct;
 	__be16  dport;			/* destination port to forward */
+	__be16  flags;
 	union nf_inet_addr snet;	/* source network of the client,
 					   after masking */
 
@@ -340,6 +341,10 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 		dport = ports[1];
 	}
 
+	flags = (svc->flags & IP_VS_SVC_F_ONEPACKET
+		 && iph.protocol == IPPROTO_UDP)?
+		IP_VS_CONN_F_ONE_PACKET : 0;
+
 	/*
 	 *    Create a new connection according to the template
 	 */
@@ -347,7 +352,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 			    &iph.saddr, ports[0],
 			    &iph.daddr, ports[1],
 			    &dest->addr, dport,
-			    0,
+			    flags,
 			    dest);
 	if (cp == NULL) {
 		ip_vs_conn_put(ct);
@@ -377,7 +382,7 @@ ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	struct ip_vs_conn *cp = NULL;
 	struct ip_vs_iphdr iph;
 	struct ip_vs_dest *dest;
-	__be16 _ports[2], *pptr;
+	__be16 _ports[2], *pptr, flags;
 
 	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
@@ -407,6 +412,10 @@ ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		return NULL;
 	}
 
+	flags = (svc->flags & IP_VS_SVC_F_ONEPACKET
+		 && iph.protocol == IPPROTO_UDP)?
+		IP_VS_CONN_F_ONE_PACKET : 0;
+
 	/*
 	 *    Create a connection entry.
 	 */
@@ -414,7 +423,7 @@ ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 			    &iph.saddr, pptr[0],
 			    &iph.daddr, pptr[1],
 			    &dest->addr, dest->port ? dest->port : pptr[1],
-			    0,
+			    flags,
 			    dest);
 	if (cp == NULL)
 		return NULL;
@@ -464,6 +473,9 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 	if (sysctl_ip_vs_cache_bypass && svc->fwmark && unicast) {
 		int ret, cs;
 		struct ip_vs_conn *cp;
+		__u16 flags = (svc->flags & IP_VS_SVC_F_ONEPACKET &&
+				iph.protocol == IPPROTO_UDP)?
+				IP_VS_CONN_F_ONE_PACKET : 0;
 		union nf_inet_addr daddr =  { .all = { 0, 0, 0, 0 } };
 
 		ip_vs_service_put(svc);
@@ -474,7 +486,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 				    &iph.saddr, pptr[0],
 				    &iph.daddr, pptr[1],
 				    &daddr, 0,
-				    IP_VS_CONN_F_BYPASS,
+				    IP_VS_CONN_F_BYPASS | flags,
 				    NULL);
 		if (cp == NULL)
 			return NF_DROP;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 36dc1d8..0f0c079 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1864,14 +1864,16 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 					   svc->scheduler->name);
 			else
 #endif
-				seq_printf(seq, "%s  %08X:%04X %s ",
+				seq_printf(seq, "%s  %08X:%04X %s %s ",
 					   ip_vs_proto_name(svc->protocol),
 					   ntohl(svc->addr.ip),
 					   ntohs(svc->port),
-					   svc->scheduler->name);
+					   svc->scheduler->name,
+					   (svc->flags & IP_VS_SVC_F_ONEPACKET)?"ops ":"");
 		} else {
-			seq_printf(seq, "FWM  %08X %s ",
-				   svc->fwmark, svc->scheduler->name);
+			seq_printf(seq, "FWM  %08X %s %s",
+				   svc->fwmark, svc->scheduler->name,
+				   (svc->flags & IP_VS_SVC_F_ONEPACKET)?"ops ":"");
 		}
 
 		if (svc->flags & IP_VS_SVC_F_PERSISTENT)
-- 
1.7.0.4

