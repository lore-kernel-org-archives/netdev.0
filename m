From: Michael Rozhavsky <mike@minantech.com>
Subject: [PATCH] fix locking
Date: Fri, 5 Sep 2003 17:26:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030906002649.GA32369@server-mrozhavsky.dyndns.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="i0/AhcQY5QxfSsSZ"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--i0/AhcQY5QxfSsSZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

I've found two problems with locking in networking code.

--

	Michael


--i0/AhcQY5QxfSsSZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="tcp_ipv4.c.diff"

--- ../../../linux-2.4.22/net/ipv4/tcp_ipv4.c	Mon Aug 25 04:44:44 2003
+++ tcp_ipv4.c	Fri Sep  5 16:56:54 2003
@@ -907,9 +907,9 @@
 	req->expires = jiffies + TCP_TIMEOUT_INIT;
 	req->retrans = 0;
 	req->sk = NULL;
-	req->dl_next = lopt->syn_table[h];
 
 	write_lock(&tp->syn_wait_lock);
+	req->dl_next = lopt->syn_table[h];
 	lopt->syn_table[h] = req;
 	write_unlock(&tp->syn_wait_lock);
 

--i0/AhcQY5QxfSsSZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sit.c.diff"

--- sit.c.orig	Fri Sep  5 17:07:55 2003
+++ sit.c	Fri Sep  5 17:08:37 2003
@@ -125,14 +125,14 @@
 {
 	struct ip_tunnel **tp;
 
+	write_lock_bh(&ipip6_lock);
 	for (tp = ipip6_bucket(t); *tp; tp = &(*tp)->next) {
 		if (t == *tp) {
-			write_lock_bh(&ipip6_lock);
 			*tp = t->next;
-			write_unlock_bh(&ipip6_lock);
 			break;
 		}
 	}
+	write_unlock_bh(&ipip6_lock);
 }
 
 static void ipip6_tunnel_link(struct ip_tunnel *t)
@@ -141,8 +141,8 @@
 
 	write_lock_bh(&ipip6_lock);
 	t->next = *tp;
-	write_unlock_bh(&ipip6_lock);
 	*tp = t;
+	write_unlock_bh(&ipip6_lock);
 }
 
 struct ip_tunnel * ipip6_tunnel_locate(struct ip_tunnel_parm *parms, int create)

--i0/AhcQY5QxfSsSZ--
