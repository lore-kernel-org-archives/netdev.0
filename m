From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH] Fix for race condition introduced by the temporary drop of the socket =?iso-8859-1?q?=A0lock_in?= skb_splice_bits.
Date: Wed, 28 May 2008 22:53:22 +0300
Message-ID: <200805282253.22688.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_ygbPIilNz5kGg7+"
Cc: netdev@vger.kernel.org, Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:4255 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752230AbYE1Tye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 15:54:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_ygbPIilNz5kGg7+
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


Hi David,

This patch applies to 2.6.25 and fixes the crashes in tcp_read_sock and 
skb_splice_bits reported on the mailing list earlier. 

Thanks,
tavi

--Boundary-00=_ygbPIilNz5kGg7+
Content-Type: text/x-diff;
  charset="us-ascii";
  name="0001-Fix-for-race-condition-introduced-by-the-temporary-d.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="0001-Fix-for-race-condition-introduced-by-the-temporary-d.patch"

>From e701750462892024a2260fd344aa9ef9900f4454 Mon Sep 17 00:00:00 2001
From: Octavian Purdila <opurdila@ixiacom.com>
Date: Wed, 28 May 2008 22:14:56 +0300
Subject: [PATCH] Fix for race condition introduced by the temporary drop of the socket
 lock in skb_splice_bits.

skb_splice_bits temporary drops the socket lock while iterating over
the socket queue in order to break a reverse locking condition which
happens with sendfile. This, however, opens a window of opportunity
for tcp_collapse() to aggregate skbs and thus potentially free the
current skb used in skb_splice_bits and tcp_read_sock.

This patch fixes the problem by (re-)getting the same "logical
skb" after the lock has been temporary dropped.

Based on idea and initial patch from Evgeniy Polyakov.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 net/core/skbuff.c |    5 +++--
 net/ipv4/tcp.c    |    9 ++++++++-
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 0a9002b..b0a9f43 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1358,6 +1358,7 @@ done:
 
 	if (spd.nr_pages) {
 		int ret;
+		struct sock *sk = __skb->sk;
 
 		/*
 		 * Drop the socket lock, otherwise we have reverse
@@ -1368,9 +1369,9 @@ done:
 		 * we call into ->sendpage() with the i_mutex lock held
 		 * and networking will grab the socket lock.
 		 */
-		release_sock(__skb->sk);
+		release_sock(sk);
 		ret = splice_to_pipe(pipe, &spd);
-		lock_sock(__skb->sk);
+		lock_sock(sk);
 		return ret;
 	}
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3e91b28..680546a 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1227,7 +1227,14 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 				copied += used;
 				offset += used;
 			}
-			if (offset != skb->len)
+			/*
+			 * If recv_actor drops the lock (e.g. TCP splice
+			 * receive) the skb pointer might be invalid when
+			 * getting here: tcp_collapse might have deleted it
+			 * while aggregating skbs from the socket queue.
+			 */
+			skb = tcp_recv_skb(sk, seq-1, &offset);
+			if (!skb || (offset+1 != skb->len))
 				break;
 		}
 		if (tcp_hdr(skb)->fin) {
-- 
1.5.4.3


--Boundary-00=_ygbPIilNz5kGg7+--
