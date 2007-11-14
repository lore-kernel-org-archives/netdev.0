From: Simon Horman <horms@verge.net.au>
Subject: [patch 2/2] ipvs: Create synced connections with their real state
Date: Wed, 14 Nov 2007 10:24:41 -0800
Message-ID: <20071114182720.091263955@natsuko.shinjuku.tokyo.vergenet.net>
References: <20071114182439.821730508@natsuko.shinjuku.tokyo.vergenet.net>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>,
	jmack@wm7d.net, graeme@graemef.net,
	Rumen Bogdanovski <rumen@voicecho.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:36812 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751764AbXKNS3H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 13:29:07 -0500
Content-Disposition: inline; filename=ipvs-sync-setstate.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With this patch the synced connections are created with their real state,
which can be changed on the next synchronizations if necessary. This way 
on fail-over all the connections will be treated according to their actual
state, causing no scheduling problems (the active and the nonactive 
connections have different weights in the schedulers). 
The backwards compatibility is preserved and the existing tools will show
the true connection states even on the backup director. 
 
Signed-off-by: Rumen G. Bogdanovski <rumen@voicecho.com> 
Signed-off-by: Simon Horman <horms@verge.net.au>

diff -Naur net-2.6_work/net/ipv4/ipvs/ip_vs_conn.c net-2.6_work1/net/ipv4/ipvs/ip_vs_conn.c
--- net-2.6_work/net/ipv4/ipvs/ip_vs_conn.c	2007-11-13 21:57:58.000000000 +0200
+++ net-2.6_work1/net/ipv4/ipvs/ip_vs_conn.c	2007-11-13 23:12:39.000000000 +0200
@@ -393,7 +393,15 @@
 	atomic_inc(&dest->refcnt);
 
 	/* Bind with the destination and its corresponding transmitter */
-	cp->flags |= atomic_read(&dest->conn_flags);
+	if ((cp->flags & IP_VS_CONN_F_SYNC) &&
+	    (!(cp->flags & IP_VS_CONN_F_TEMPLATE)))
+		/* if the connection is not template and is created
+		 * by sync, preserve the activity flag.
+		 */
+		cp->flags |= atomic_read(&dest->conn_flags) &
+			     (~IP_VS_CONN_F_INACTIVE);
+	else
+		cp->flags |= atomic_read(&dest->conn_flags);
 	cp->dest = dest;
 
 	IP_VS_DBG(7, "Bind-dest %s c:%u.%u.%u.%u:%d v:%u.%u.%u.%u:%d "
@@ -412,7 +420,11 @@
 		/* It is a normal connection, so increase the inactive
 		   connection counter because it is in TCP SYNRECV
 		   state (inactive) or other protocol inacive state */
-		atomic_inc(&dest->inactconns);
+		if ((cp->flags & IP_VS_CONN_F_SYNC) &&
+		    (!(cp->flags & IP_VS_CONN_F_INACTIVE)))
+			atomic_inc(&dest->activeconns);
+		else
+			atomic_inc(&dest->inactconns);
 	} else {
 		/* It is a persistent connection/template, so increase
 		   the peristent connection counter */
diff -Naur net-2.6_work/net/ipv4/ipvs/ip_vs_sync.c net-2.6_work1/net/ipv4/ipvs/ip_vs_sync.c
--- net-2.6_work/net/ipv4/ipvs/ip_vs_sync.c	2007-11-13 21:42:59.000000000 +0200
+++ net-2.6_work1/net/ipv4/ipvs/ip_vs_sync.c	2007-11-13 23:04:04.000000000 +0200
@@ -305,10 +305,11 @@
 
 	p = (char *)buffer + sizeof(struct ip_vs_sync_mesg);
 	for (i=0; i<m->nr_conns; i++) {
-		unsigned flags;
+		unsigned flags, state;
 
 		s = (struct ip_vs_sync_conn *)p;
 		flags = ntohs(s->flags) | IP_VS_CONN_F_SYNC;
+		state = ntohs(s->state);
 		if (!(flags & IP_VS_CONN_F_TEMPLATE))
 			cp = ip_vs_conn_in_get(s->protocol,
 					       s->caddr, s->cport,
@@ -326,6 +327,13 @@
 			dest = ip_vs_find_dest(s->daddr, s->dport,
 					       s->vaddr, s->vport,
 					       s->protocol);
+			/*  Set the approprite ativity flag */
+			if (s->protocol == IPPROTO_TCP) {
+				if (state != IP_VS_TCP_S_ESTABLISHED)
+					flags |= IP_VS_CONN_F_INACTIVE;
+				else
+					flags &= ~IP_VS_CONN_F_INACTIVE;
+			}
 			cp = ip_vs_conn_new(s->protocol,
 					    s->caddr, s->cport,
 					    s->vaddr, s->vport,
@@ -337,7 +345,7 @@
 				IP_VS_ERR("ip_vs_conn_new failed\n");
 				return;
 			}
-			cp->state = ntohs(s->state);
+			cp->state = state;
 		} else if (!cp->dest) {
 			dest = ip_vs_try_bind_dest(cp);
 			if (!dest) {
@@ -346,8 +354,22 @@
 				cp->flags = flags | IP_VS_CONN_F_HASHED;
 			} else
 				atomic_dec(&dest->refcnt);
-		}	/* Note that we don't touch its state and flags
-			   if it is a normal entry. */
+		} else if ((cp->dest) && (cp->protocol == IPPROTO_TCP) &&
+			   (cp->state != state)) {
+			/* update active/inactive flag for the connection */
+			dest = cp->dest;
+			if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
+				(state != IP_VS_TCP_S_ESTABLISHED)) {
+				atomic_dec(&dest->activeconns);
+				atomic_inc(&dest->inactconns);
+				cp->flags |= IP_VS_CONN_F_INACTIVE;
+			} else if ((cp->flags & IP_VS_CONN_F_INACTIVE) &&
+				(state == IP_VS_TCP_S_ESTABLISHED)) {
+				atomic_inc(&dest->activeconns);
+				atomic_dec(&dest->inactconns);
+				cp->flags &= ~IP_VS_CONN_F_INACTIVE;
+			}
+		}
 
 		if (flags & IP_VS_CONN_F_SEQ_MASK) {
 			opt = (struct ip_vs_sync_conn_options *)&s[1];
@@ -357,7 +379,7 @@
 			p += SIMPLE_CONN_SIZE;
 
 		atomic_set(&cp->in_pkts, sysctl_ip_vs_sync_threshold[0]);
-		cp->state = ntohs(s->state);
+		cp->state = state;
 		pp = ip_vs_proto_get(s->protocol);
 		cp->timeout = pp->timeout_table[cp->state];
 		ip_vs_conn_put(cp);

-- 

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

