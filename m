From: kaber@trash.net
Subject: [PATCH 06/72] ipvs: extend connection flags to 32 bits
Date: Thu, 21 Oct 2010 17:18:53 +0200
Message-ID: <1287674399-31455-7-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59989 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149Ab0JUPUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:03 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

- the sync protocol supports 16 bits only, so bits 0..15 should be
used only for flags that should go to backup server, bits 16 and
above should be allocated for flags not sent to backup.

- use IP_VS_CONN_F_DEST_MASK as mask of connection flags in
destination that can be changed by user space

- allow IP_VS_CONN_F_ONE_PACKET to be set in destination

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/ip_vs.h           |    8 ++++++++
 include/net/ip_vs.h             |    2 +-
 net/netfilter/ipvs/ip_vs_conn.c |   16 ++++++++++------
 net/netfilter/ipvs/ip_vs_core.c |   11 ++++++-----
 net/netfilter/ipvs/ip_vs_ctl.c  |    5 +++--
 5 files changed, 28 insertions(+), 14 deletions(-)

diff --git a/include/linux/ip_vs.h b/include/linux/ip_vs.h
index 9708de2..003d75f 100644
--- a/include/linux/ip_vs.h
+++ b/include/linux/ip_vs.h
@@ -70,6 +70,7 @@
 
 /*
  *      IPVS Connection Flags
+ *      Only flags 0..15 are sent to backup server
  */
 #define IP_VS_CONN_F_FWD_MASK	0x0007		/* mask for the fwd methods */
 #define IP_VS_CONN_F_MASQ	0x0000		/* masquerading/NAT */
@@ -88,6 +89,13 @@
 #define IP_VS_CONN_F_TEMPLATE	0x1000		/* template, not connection */
 #define IP_VS_CONN_F_ONE_PACKET	0x2000		/* forward only one packet */
 
+/* Flags that are not sent to backup server start from bit 16 */
+
+/* Connection flags from destination that can be changed by user space */
+#define IP_VS_CONN_F_DEST_MASK (IP_VS_CONN_F_FWD_MASK | \
+				IP_VS_CONN_F_ONE_PACKET | \
+				0)
+
 #define IP_VS_SCHEDNAME_MAXLEN	16
 #define IP_VS_IFNAME_MAXLEN	16
 
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index f976885..62698a9 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -366,6 +366,7 @@ struct ip_vs_conn {
 	union nf_inet_addr       caddr;          /* client address */
 	union nf_inet_addr       vaddr;          /* virtual address */
 	union nf_inet_addr       daddr;          /* destination address */
+	volatile __u32           flags;          /* status flags */
 	__be16                   cport;
 	__be16                   vport;
 	__be16                   dport;
@@ -378,7 +379,6 @@ struct ip_vs_conn {
 
 	/* Flags and state transition */
 	spinlock_t              lock;           /* lock for state transition */
-	volatile __u16          flags;          /* status flags */
 	volatile __u16          state;          /* state info */
 	volatile __u16          old_state;      /* old state, to be used for
 						 * state transition triggerd
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index b71c69a..9fe1da7 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -505,6 +505,8 @@ static inline int ip_vs_dest_totalconns(struct ip_vs_dest *dest)
 static inline void
 ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 {
+	unsigned int conn_flags;
+
 	/* if dest is NULL, then return directly */
 	if (!dest)
 		return;
@@ -512,16 +514,18 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 	/* Increase the refcnt counter of the dest */
 	atomic_inc(&dest->refcnt);
 
+	conn_flags = atomic_read(&dest->conn_flags);
+	if (cp->protocol != IPPROTO_UDP)
+		conn_flags &= ~IP_VS_CONN_F_ONE_PACKET;
 	/* Bind with the destination and its corresponding transmitter */
-	if ((cp->flags & IP_VS_CONN_F_SYNC) &&
-	    (!(cp->flags & IP_VS_CONN_F_TEMPLATE)))
+	if (cp->flags & IP_VS_CONN_F_SYNC) {
 		/* if the connection is not template and is created
 		 * by sync, preserve the activity flag.
 		 */
-		cp->flags |= atomic_read(&dest->conn_flags) &
-			     (~IP_VS_CONN_F_INACTIVE);
-	else
-		cp->flags |= atomic_read(&dest->conn_flags);
+		if (!(cp->flags & IP_VS_CONN_F_TEMPLATE))
+			conn_flags &= ~IP_VS_CONN_F_INACTIVE;
+	}
+	cp->flags |= conn_flags;
 	cp->dest = dest;
 
 	IP_VS_DBG_BUF(7, "Bind-dest %s c:%s:%d v:%s:%d "
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 0c043b6..319991d 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -194,7 +194,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	struct ip_vs_dest *dest;
 	struct ip_vs_conn *ct;
 	__be16  dport;			/* destination port to forward */
-	__be16  flags;
+	unsigned int flags;
 	union nf_inet_addr snet;	/* source network of the client,
 					   after masking */
 
@@ -382,7 +382,8 @@ ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	struct ip_vs_conn *cp = NULL;
 	struct ip_vs_iphdr iph;
 	struct ip_vs_dest *dest;
-	__be16 _ports[2], *pptr, flags;
+	__be16 _ports[2], *pptr;
+	unsigned int flags;
 
 	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 	pptr = skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
@@ -473,9 +474,9 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 	if (sysctl_ip_vs_cache_bypass && svc->fwmark && unicast) {
 		int ret, cs;
 		struct ip_vs_conn *cp;
-		__u16 flags = (svc->flags & IP_VS_SVC_F_ONEPACKET &&
-				iph.protocol == IPPROTO_UDP)?
-				IP_VS_CONN_F_ONE_PACKET : 0;
+		unsigned int flags = (svc->flags & IP_VS_SVC_F_ONEPACKET &&
+				      iph.protocol == IPPROTO_UDP)?
+				      IP_VS_CONN_F_ONE_PACKET : 0;
 		union nf_inet_addr daddr =  { .all = { 0, 0, 0, 0 } };
 
 		ip_vs_service_put(svc);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index ca8ec8c..7bd41d2 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -765,7 +765,8 @@ __ip_vs_update_dest(struct ip_vs_service *svc,
 
 	/* set the weight and the flags */
 	atomic_set(&dest->weight, udest->weight);
-	conn_flags = udest->conn_flags | IP_VS_CONN_F_INACTIVE;
+	conn_flags = udest->conn_flags & IP_VS_CONN_F_DEST_MASK;
+	conn_flags |= IP_VS_CONN_F_INACTIVE;
 
 	/* check if local node and update the flags */
 #ifdef CONFIG_IP_VS_IPV6
@@ -782,7 +783,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc,
 		}
 
 	/* set the IP_VS_CONN_F_NOOUTPUT flag if not masquerading/NAT */
-	if ((conn_flags & IP_VS_CONN_F_FWD_MASK) != 0) {
+	if ((conn_flags & IP_VS_CONN_F_FWD_MASK) != IP_VS_CONN_F_MASQ) {
 		conn_flags |= IP_VS_CONN_F_NOOUTPUT;
 	} else {
 		/*
-- 
1.7.1

