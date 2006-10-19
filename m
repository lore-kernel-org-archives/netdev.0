From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] [NET] inet_peer : group together avl_left, avl_right, v4daddr to speedup lookups on some CPUS
Date: Thu, 19 Oct 2006 12:57:42 +0200
Message-ID: <200610191257.42549.dada1@cosmosbay.com>
References: <Pine.LNX.4.58.0610162051170.12462@dexter.psc.edu> <200610171458.37636.dada1@cosmosbay.com> <200610180938.39175.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_mo1NFYJg+GqKuJ+"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:63689 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S1422865AbWJSK5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2006 06:57:42 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <200610180938.39175.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_mo1NFYJg+GqKuJ+
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi David

Lot of routers/embedded devices still use CPUS with 16/32 bytes cache lines. 
(486, Pentium, ...  PIII)
It makes sense to group together fields used at lookup time so they fit in one 
cache line.
This reduce cache footprint and speedup lookups.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--Boundary-00=_mo1NFYJg+GqKuJ+
Content-Type: text/plain;
  charset="utf-8";
  name="inetpeer_speedup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="inetpeer_speedup.patch"

--- net-2.6/include/net/inetpeer.h	2006-10-19 12:50:29.000000000 +0200
+++ net-2.6-ed/include/net/inetpeer.h	2006-10-19 12:52:08.000000000 +0200
@@ -17,14 +17,15 @@
 
 struct inet_peer
 {
+	/* group together avl_left,avl_right,v4daddr to speedup lookups */
 	struct inet_peer	*avl_left, *avl_right;
+	__be32			v4daddr;	/* peer's address */
+	__u16			avl_height;
+	__u16			ip_id_count;	/* IP ID for the next packet */
 	struct inet_peer	*unused_next, **unused_prevp;
 	__u32			dtime;		/* the time of last use of not
 						 * referenced entries */
 	atomic_t		refcnt;
-	__be32			v4daddr;	/* peer's address */
-	__u16			avl_height;
-	__u16			ip_id_count;	/* IP ID for the next packet */
 	atomic_t		rid;		/* Frag reception counter */
 	__u32			tcp_ts;
 	unsigned long		tcp_ts_stamp;

--Boundary-00=_mo1NFYJg+GqKuJ+--
