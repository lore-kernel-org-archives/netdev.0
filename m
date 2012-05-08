From: pablo@netfilter.org
Subject: [PATCH 19/25] ipvs: optimize the use of flags in ip_vs_bind_dest
Date: Tue,  8 May 2012 20:38:17 +0200
Message-ID: <1336502303-1722-20-git-send-email-pablo@netfilter.org>
References: <1336502303-1722-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, openbsc@lists.osmocom.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39005 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755777Ab2EHSj0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 14:39:26 -0400
In-Reply-To: <1336502303-1722-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

	cp->flags is marked volatile but ip_vs_bind_dest
can safely modify the flags, so save some CPU cycles by
using temp variable.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c |   15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index c7edf20..1548df9 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -548,6 +548,7 @@ static inline void
 ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 {
 	unsigned int conn_flags;
+	__u32 flags;
 
 	/* if dest is NULL, then return directly */
 	if (!dest)
@@ -559,17 +560,19 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 	conn_flags = atomic_read(&dest->conn_flags);
 	if (cp->protocol != IPPROTO_UDP)
 		conn_flags &= ~IP_VS_CONN_F_ONE_PACKET;
+	flags = cp->flags;
 	/* Bind with the destination and its corresponding transmitter */
-	if (cp->flags & IP_VS_CONN_F_SYNC) {
+	if (flags & IP_VS_CONN_F_SYNC) {
 		/* if the connection is not template and is created
 		 * by sync, preserve the activity flag.
 		 */
-		if (!(cp->flags & IP_VS_CONN_F_TEMPLATE))
+		if (!(flags & IP_VS_CONN_F_TEMPLATE))
 			conn_flags &= ~IP_VS_CONN_F_INACTIVE;
 		/* connections inherit forwarding method from dest */
-		cp->flags &= ~(IP_VS_CONN_F_FWD_MASK | IP_VS_CONN_F_NOOUTPUT);
+		flags &= ~(IP_VS_CONN_F_FWD_MASK | IP_VS_CONN_F_NOOUTPUT);
 	}
-	cp->flags |= conn_flags;
+	flags |= conn_flags;
+	cp->flags = flags;
 	cp->dest = dest;
 
 	IP_VS_DBG_BUF(7, "Bind-dest %s c:%s:%d v:%s:%d "
@@ -584,12 +587,12 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 		      atomic_read(&dest->refcnt));
 
 	/* Update the connection counters */
-	if (!(cp->flags & IP_VS_CONN_F_TEMPLATE)) {
+	if (!(flags & IP_VS_CONN_F_TEMPLATE)) {
 		/* It is a normal connection, so modify the counters
 		 * according to the flags, later the protocol can
 		 * update them on state change
 		 */
-		if (!(cp->flags & IP_VS_CONN_F_INACTIVE))
+		if (!(flags & IP_VS_CONN_F_INACTIVE))
 			atomic_inc(&dest->activeconns);
 		else
 			atomic_inc(&dest->inactconns);
-- 
1.7.9.5
