From: horms@vergenet.net
Subject: [patch 2/2] ipvs: Syncrhonise Closing of Connections
Date: Mon, 05 Nov 2007 12:08:53 +0900
Message-ID: <20071105030958.813581208@vergenet.net>
References: <20071105030851.615630269@vergenet.net>
Cc: "Rumen G. Bogdanovski" <rumen@voicecho.com>,
	Graeme Fowler <graeme@graemef.net>,
	Joseph Mack NA3T <jmack@wm7d.net>,
	Julian Anastasov <ja@ssi.bg>,
	Wensong Zhang <wensong@linux-vs.org>,
	"David S. Miller" <davem@davemloft.net>
To: lvs-devel@linuxvirtualserver.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:47130 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753305AbXKEDNj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Nov 2007 22:13:39 -0500
From: Simon Horman <horms@verge.net.au>
Content-Disposition: inline; filename=linux-2.6.23.1-ipvs-csync-ag-inc-rb.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rumen G. Bogdanovski <rumen@voicecho.com>

This patch makes the master daemon to sync the connection when it is about
to close.  This makes the connections on the backup to close or timeout
according their state.  Before the sync was performed only if the
connection is in ESTABLISHED state which always made the connections to
timeout in the hard coded 3 minutes. However the Andy Gospodarek's patch
([IPVS]: use proper timeout instead of fixed value) effectively did nothing
more than increasing this to 15 minutes (Established state timeout).  So
this patch makes use of proper timeout since it syncs the connections on
status changes to FIN_WAIT (2min timeout) and CLOSE (10sec timeout).
However if the backup misses CLOSE hopefully it did not miss FIN_WAIT.
Otherwise we will just have to wait for the ESTABLISHED state timeout. As
it is without this patch.  This way the number of the hanging connections
on the backup is kept to minimum. And very few of them will be left to
timeout with a long timeout.

This is important if we want to make use of the fix for the real server
overcommit on master/backup fail-over.

Regards,
Rumen Bogdanovski

Signed-off-by: Rumen G. Bogdanovski <rumen@voicecho.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

--- 
Thu, 01 Nov 2007 18:25:10 +0900, Horms
* Redifed for net-2.6
* Ran through scripts/checkpatch.pl and fixed up everything
  that it complains about except the use of volatile, as
  its in keeping with other fields in the structure.
  If its wrong, lets fix them all together.

WARNING: Use of volatile is usually wrong: see
Documentation/volatile-considered-harmful.txt
#49: FILE: include/net/ip_vs.h:523:
+	volatile __u16          old_state;      /* old state, to be used for

Index: net-2.6/include/net/ip_vs.h
===================================================================
--- net-2.6.orig/include/net/ip_vs.h	2007-11-05 11:37:45.000000000 +0900
+++ net-2.6/include/net/ip_vs.h	2007-11-05 11:37:49.000000000 +0900
@@ -520,6 +520,10 @@ struct ip_vs_conn {
 	spinlock_t              lock;           /* lock for state transition */
 	volatile __u16          flags;          /* status flags */
 	volatile __u16          state;          /* state info */
+	volatile __u16          old_state;      /* old state, to be used for
+						 * state transition triggerd
+						 * synchronization
+						 */
 
 	/* Control members */
 	struct ip_vs_conn       *control;       /* Master control connection */
Index: net-2.6/net/ipv4/ipvs/ip_vs_core.c
===================================================================
--- net-2.6.orig/net/ipv4/ipvs/ip_vs_core.c	2007-11-05 11:37:45.000000000 +0900
+++ net-2.6/net/ipv4/ipvs/ip_vs_core.c	2007-11-05 11:37:49.000000000 +0900
@@ -979,15 +979,23 @@ ip_vs_in(unsigned int hooknum, struct sk
 		ret = NF_ACCEPT;
 	}
 
-	/* increase its packet counter and check if it is needed
-	   to be synchronized */
+	/* Increase its packet counter and check if it is needed
+	 * to be synchronized
+	 *
+	 * Sync connection if it is about to close to
+	 * encorage the standby servers to update the connections timeout
+	 */
 	atomic_inc(&cp->in_pkts);
 	if ((ip_vs_sync_state & IP_VS_STATE_MASTER) &&
-	    (cp->protocol != IPPROTO_TCP ||
-	     cp->state == IP_VS_TCP_S_ESTABLISHED) &&
-	    (atomic_read(&cp->in_pkts) % sysctl_ip_vs_sync_threshold[1]
-	     == sysctl_ip_vs_sync_threshold[0]))
+	    (((cp->protocol != IPPROTO_TCP ||
+	       cp->state == IP_VS_TCP_S_ESTABLISHED) &&
+	      (atomic_read(&cp->in_pkts) % sysctl_ip_vs_sync_threshold[1]
+	       == sysctl_ip_vs_sync_threshold[0])) ||
+	     ((cp->protocol == IPPROTO_TCP) && (cp->old_state != cp->state) &&
+	      ((cp->state == IP_VS_TCP_S_FIN_WAIT) ||
+	       (cp->state == IP_VS_TCP_S_CLOSE)))))
 		ip_vs_sync_conn(cp);
+	cp->old_state = cp->state;
 
 	ip_vs_conn_put(cp);
 	return ret;
Index: net-2.6/net/ipv4/ipvs/ip_vs_sync.c
===================================================================
--- net-2.6.orig/net/ipv4/ipvs/ip_vs_sync.c	2007-11-05 11:37:45.000000000 +0900
+++ net-2.6/net/ipv4/ipvs/ip_vs_sync.c	2007-11-05 11:37:49.000000000 +0900
@@ -344,7 +344,6 @@ static void ip_vs_process_message(const 
 			if (!dest) {
 				/* it is an unbound entry created by
 				 * synchronization */
-				cp->state = ntohs(s->state);
 				cp->flags = flags | IP_VS_CONN_F_HASHED;
 			} else
 				atomic_dec(&dest->refcnt);
@@ -359,6 +358,7 @@ static void ip_vs_process_message(const 
 			p += SIMPLE_CONN_SIZE;
 
 		atomic_set(&cp->in_pkts, sysctl_ip_vs_sync_threshold[0]);
+		cp->state = ntohs(s->state);
 		pp = ip_vs_proto_get(s->protocol);
 		cp->timeout = pp->timeout_table[cp->state];
 		ip_vs_conn_put(cp);

-- 

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

