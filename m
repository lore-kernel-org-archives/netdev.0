From: kaber@trash.net
Subject: [PATCH 46/72] ipvs: do not schedule conns from real servers
Date: Thu, 21 Oct 2010 17:19:33 +0200
Message-ID: <1287674399-31455-47-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>

 	This patch is needed to avoid scheduling of
packets from local real server when we add ip_vs_in
in LOCAL_OUT hook to support local client.

 	Currently, when ip_vs_in can not find existing
connection it tries to create new one by calling ip_vs_schedule.

 	The default indication from ip_vs_schedule was if
connection was scheduled to real server. If real server is
not available we try to use the bypass forwarding method
or to send ICMP error. But in some cases we do not want to use
the bypass feature. So, add flag 'ignored' to indicate if
the scheduler ignores this packet.

 	Make sure we do not create new connections from replies.
We can hit this problem for persistent services and local real
server when ip_vs_in is added to LOCAL_OUT hook to handle
local clients.

 	Also, make sure ip_vs_schedule ignores SYN packets
for Active FTP DATA from local real server. The FTP DATA
connection should be created on SYN+ACK from client to assign
correct connection daddr.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h                   |    3 +-
 net/netfilter/ipvs/ip_vs_core.c       |   34 +++++++++++++++++++++++++++++++-
 net/netfilter/ipvs/ip_vs_proto_sctp.c |    6 +++-
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |    7 ++++-
 net/netfilter/ipvs/ip_vs_proto_udp.c  |    6 +++-
 5 files changed, 47 insertions(+), 9 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 0e46184..9d5c1b9 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -849,7 +849,8 @@ extern int ip_vs_unbind_scheduler(struct ip_vs_service *svc);
 extern struct ip_vs_scheduler *ip_vs_scheduler_get(const char *sched_name);
 extern void ip_vs_scheduler_put(struct ip_vs_scheduler *scheduler);
 extern struct ip_vs_conn *
-ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb);
+ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
+	       struct ip_vs_protocol *pp, int *ignored);
 extern int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 			struct ip_vs_protocol *pp);
 
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 2224530..0090d6d 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -342,7 +342,8 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
  *  Protocols supported: TCP, UDP
  */
 struct ip_vs_conn *
-ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb)
+ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
+	       struct ip_vs_protocol *pp, int *ignored)
 {
 	struct ip_vs_conn *cp = NULL;
 	struct ip_vs_iphdr iph;
@@ -350,16 +351,43 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb)
 	__be16 _ports[2], *pptr;
 	unsigned int flags;
 
+	*ignored = 1;
 	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
 	if (pptr == NULL)
 		return NULL;
 
 	/*
+	 * FTPDATA needs this check when using local real server.
+	 * Never schedule Active FTPDATA connections from real server.
+	 * For LVS-NAT they must be already created. For other methods
+	 * with persistence the connection is created on SYN+ACK.
+	 */
+	if (pptr[0] == FTPDATA) {
+		IP_VS_DBG_PKT(12, pp, skb, 0, "Not scheduling FTPDATA");
+		return NULL;
+	}
+
+	/*
+	 * Do not schedule replies from local real server. It is risky
+	 * for fwmark services but mostly for persistent services.
+	 */
+	if ((!skb->dev || skb->dev->flags & IFF_LOOPBACK) &&
+	    (svc->flags & IP_VS_SVC_F_PERSISTENT || svc->fwmark) &&
+	    (cp = pp->conn_in_get(svc->af, skb, pp, &iph, iph.len, 1))) {
+		IP_VS_DBG_PKT(12, pp, skb, 0,
+			      "Not scheduling reply for existing connection");
+		__ip_vs_conn_put(cp);
+		return NULL;
+	}
+
+	/*
 	 *    Persistent service
 	 */
-	if (svc->flags & IP_VS_SVC_F_PERSISTENT)
+	if (svc->flags & IP_VS_SVC_F_PERSISTENT) {
+		*ignored = 0;
 		return ip_vs_sched_persist(svc, skb, pptr);
+	}
 
 	/*
 	 *    Non-persistent service
@@ -372,6 +400,8 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb)
 		return NULL;
 	}
 
+	*ignored = 0;
+
 	dest = svc->scheduler->schedule(svc, skb);
 	if (dest == NULL) {
 		IP_VS_DBG(1, "Schedule: no dest found.\n");
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 4c0855c..9ab5232 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -31,6 +31,8 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 	if ((sch->type == SCTP_CID_INIT) &&
 	    (svc = ip_vs_service_get(af, skb->mark, iph.protocol,
 				     &iph.daddr, sh->dest))) {
+		int ignored;
+
 		if (ip_vs_todrop()) {
 			/*
 			 * It seems that we are very loaded.
@@ -44,8 +46,8 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		 * Let the virtual server select a real server for the
 		 * incoming connection, and create a connection entry.
 		 */
-		*cpp = ip_vs_schedule(svc, skb);
-		if (!*cpp) {
+		*cpp = ip_vs_schedule(svc, skb, pp, &ignored);
+		if (!*cpp && !ignored) {
 			*verdict = ip_vs_leave(svc, skb, pp);
 			return 0;
 		}
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 64dc295..85d80a6 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -43,9 +43,12 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		return 0;
 	}
 
+	/* No !th->ack check to allow scheduling on SYN+ACK for Active FTP */
 	if (th->syn &&
 	    (svc = ip_vs_service_get(af, skb->mark, iph.protocol, &iph.daddr,
 				     th->dest))) {
+		int ignored;
+
 		if (ip_vs_todrop()) {
 			/*
 			 * It seems that we are very loaded.
@@ -60,8 +63,8 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		 * Let the virtual server select a real server for the
 		 * incoming connection, and create a connection entry.
 		 */
-		*cpp = ip_vs_schedule(svc, skb);
-		if (!*cpp) {
+		*cpp = ip_vs_schedule(svc, skb, pp, &ignored);
+		if (!*cpp && !ignored) {
 			*verdict = ip_vs_leave(svc, skb, pp);
 			return 0;
 		}
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 9c558c4..5d21f08 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -46,6 +46,8 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 	svc = ip_vs_service_get(af, skb->mark, iph.protocol,
 				&iph.daddr, uh->dest);
 	if (svc) {
+		int ignored;
+
 		if (ip_vs_todrop()) {
 			/*
 			 * It seems that we are very loaded.
@@ -60,8 +62,8 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		 * Let the virtual server select a real server for the
 		 * incoming connection, and create a connection entry.
 		 */
-		*cpp = ip_vs_schedule(svc, skb);
-		if (!*cpp) {
+		*cpp = ip_vs_schedule(svc, skb, pp, &ignored);
+		if (!*cpp && !ignored) {
 			*verdict = ip_vs_leave(svc, skb, pp);
 			return 0;
 		}
-- 
1.7.1

