From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: [PATCH net-next-2.6] ipv4: Fix PMTU update.
Date: Thu, 10 Mar 2011 15:09:58 +0900
Message-ID: <20110310150958.123c9f7f.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:45460 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394Ab1CJGKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 01:10:02 -0500
Received: by gwaa18 with SMTP id a18so292919gwa.19
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2011 22:10:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On current net-next-2.6, when Linux receives ICMP Type: 3, Code: 4
(Destination unreachable (Fragmentation needed)), 

  icmp_unreach
    -> ip_rt_frag_needed
         (peer->pmtu_expires is set here)
    -> tcp_v4_err
         -> do_pmtu_discovery
              -> ip_rt_update_pmtu
                   (peer->pmtu_expires is already set,
                    so check_peer_pmtu is skipped.)
                   -> check_peer_pmtu

check_peer_pmtu is skipped and MTU is not updated.

To fix this, let check_peer_pmtu execute unconditionally.
And some minor fixes
1) Avoid potential peer->pmtu_expires set to be zero.
2) In check_peer_pmtu, argument of time_before is reversed.
3) check_peer_pmtu expects peer->pmtu_orig is initialized as zero,
   but not initialized.

Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
---
 net/ipv4/inetpeer.c |    1 +
 net/ipv4/route.c    |   22 +++++++++++++++++-----
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 6442c35..86b1d08 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -511,6 +511,7 @@ struct inet_peer *inet_getpeer(struct inetpeer_addr *daddr, int create)
 		p->rate_tokens = 0;
 		p->rate_last = 0;
 		p->pmtu_expires = 0;
+		p->pmtu_orig = 0;
 		memset(&p->redirect_learned, 0, sizeof(p->redirect_learned));
 		INIT_LIST_HEAD(&p->unused);
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 92a24ea..3cf8001 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1533,9 +1533,15 @@ unsigned short ip_rt_frag_needed(struct net *net, struct iphdr *iph,
 		if (mtu < ip_rt_min_pmtu)
 			mtu = ip_rt_min_pmtu;
 		if (!peer->pmtu_expires || mtu < peer->pmtu_learned) {
+			unsigned long pmtu_expires;
+
+			pmtu_expires = jiffies + ip_rt_mtu_expires;
+			if (!pmtu_expires)
+				pmtu_expires = 1UL;
+
 			est_mtu = mtu;
 			peer->pmtu_learned = mtu;
-			peer->pmtu_expires = jiffies + ip_rt_mtu_expires;
+			peer->pmtu_expires = pmtu_expires;
 		}
 
 		inet_putpeer(peer);
@@ -1549,7 +1555,7 @@ static void check_peer_pmtu(struct dst_entry *dst, struct inet_peer *peer)
 {
 	unsigned long expires = peer->pmtu_expires;
 
-	if (time_before(expires, jiffies)) {
+	if (time_before(jiffies, expires)) {
 		u32 orig_dst_mtu = dst_mtu(dst);
 		if (peer->pmtu_learned < orig_dst_mtu) {
 			if (!peer->pmtu_orig)
@@ -1574,14 +1580,20 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 		if (mtu < ip_rt_min_pmtu)
 			mtu = ip_rt_min_pmtu;
 		if (!peer->pmtu_expires || mtu < peer->pmtu_learned) {
+			unsigned long pmtu_expires;
+
+			pmtu_expires = jiffies + ip_rt_mtu_expires;
+			if (!pmtu_expires)
+				pmtu_expires = 1UL;
+
 			peer->pmtu_learned = mtu;
-			peer->pmtu_expires = jiffies + ip_rt_mtu_expires;
+			peer->pmtu_expires = pmtu_expires;
 
 			atomic_inc(&__rt_peer_genid);
 			rt->rt_peer_genid = rt_peer_genid();
-
-			check_peer_pmtu(dst, peer);
 		}
+		check_peer_pmtu(dst, peer);
+
 		inet_putpeer(peer);
 	}
 }
