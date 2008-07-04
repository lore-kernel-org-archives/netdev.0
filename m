From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next-2.6 1/4] MIB: add struct net to UDP_INC_STATS_USER
Date: Fri, 04 Jul 2008 16:00:14 +0400
Message-ID: <486E10CE.7080902@openvz.org>
References: <486E1074.7040702@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Denis Lunev <den@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:35768 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752729AbYGDMCr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 08:02:47 -0400
In-Reply-To: <486E1074.7040702@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nothing special - all the places already have a struct sock
at hands, so use the sock_net() net.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Acked-by: Denis V. Lunev <den@openvz.org>

---
 include/net/udp.h |    2 +-
 net/ipv4/udp.c    |   11 +++++++----
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 7a86848..1331909 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -158,7 +158,7 @@ DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
 /*
  * 	SNMP statistics for UDP and UDP-Lite
  */
-#define UDP_INC_STATS_USER(field, is_udplite)			       do {   \
+#define UDP_INC_STATS_USER(net, field, is_udplite)	      do { (void)net; \
 	if (is_udplite) SNMP_INC_STATS_USER(udplite_statistics, field);       \
 	else		SNMP_INC_STATS_USER(udp_statistics, field);  }  while(0)
 #define UDP_INC_STATS_BH(field, is_udplite) 			       do  {  \
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 3bbf6fb..c97da53 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -526,7 +526,8 @@ out:
 	up->len = 0;
 	up->pending = 0;
 	if (!err)
-		UDP_INC_STATS_USER(UDP_MIB_OUTDATAGRAMS, is_udplite);
+		UDP_INC_STATS_USER(sock_net(sk),
+				UDP_MIB_OUTDATAGRAMS, is_udplite);
 	return err;
 }
 
@@ -725,7 +726,8 @@ out:
 	 * seems like overkill.
 	 */
 	if (err == -ENOBUFS || test_bit(SOCK_NOSPACE, &sk->sk_socket->flags)) {
-		UDP_INC_STATS_USER(UDP_MIB_SNDBUFERRORS, is_udplite);
+		UDP_INC_STATS_USER(sock_net(sk),
+				UDP_MIB_SNDBUFERRORS, is_udplite);
 	}
 	return err;
 
@@ -888,7 +890,8 @@ try_again:
 		goto out_free;
 
 	if (!peeked)
-		UDP_INC_STATS_USER(UDP_MIB_INDATAGRAMS, is_udplite);
+		UDP_INC_STATS_USER(sock_net(sk),
+				UDP_MIB_INDATAGRAMS, is_udplite);
 
 	sock_recv_timestamp(msg, sk, skb);
 
@@ -917,7 +920,7 @@ out:
 csum_copy_err:
 	lock_sock(sk);
 	if (!skb_kill_datagram(sk, skb, flags))
-		UDP_INC_STATS_USER(UDP_MIB_INERRORS, is_udplite);
+		UDP_INC_STATS_USER(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
 	release_sock(sk);
 
 	if (noblock)
-- 
1.5.3.4

