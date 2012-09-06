From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] udp: increment UDP_MIB_INERRORS if copy failed
Date: Thu, 06 Sep 2012 11:34:44 +0200
Message-ID: <1346924084.2484.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:36492 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752554Ab2IFJes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 05:34:48 -0400
Received: by eekc1 with SMTP id c1so586079eek.19
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2012 02:34:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In UDP recvmsg(), we miss an increase of UDP_MIB_INERRORS if the copy
of skb to userspace failed for whatever reason.

Reported-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/udp.c |    5 +++++
 net/ipv6/udp.c |   11 +++++++++++
 2 files changed, 16 insertions(+)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 6f6d1ac..2814f66 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1226,6 +1226,11 @@ try_again:
 
 	if (unlikely(err)) {
 		trace_kfree_skb(skb, udp_recvmsg);
+		if (!peeked) {
+			atomic_inc(&sk->sk_drops);
+			UDP_INC_STATS_USER(sock_net(sk),
+					   UDP_MIB_INERRORS, is_udplite);
+		}
 		goto out_free;
 	}
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 99d0077..07e2bfe 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -394,6 +394,17 @@ try_again:
 	}
 	if (unlikely(err)) {
 		trace_kfree_skb(skb, udpv6_recvmsg);
+		if (!peeked) {
+			atomic_inc(&sk->sk_drops);
+			if (is_udp4)
+				UDP_INC_STATS_USER(sock_net(sk),
+						   UDP_MIB_INERRORS,
+						   is_udplite);
+			else
+				UDP6_INC_STATS_USER(sock_net(sk),
+						    UDP_MIB_INERRORS,
+						    is_udplite);
+		}
 		goto out_free;
 	}
 	if (!peeked) {
