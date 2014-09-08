From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 4/5] udp: Add try convert checksum is case of skb_steal_sock
Date: Sun,  7 Sep 2014 22:26:28 -0700
Message-ID: <1410153989-23837-5-git-send-email-therbert@google.com>
References: <1410153989-23837-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:41775 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781AbaIHF1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 01:27:17 -0400
Received: by mail-pd0-f177.google.com with SMTP id r10so19859198pdi.22
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2014 22:27:17 -0700 (PDT)
In-Reply-To: <1410153989-23837-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an skb already has an associated socket that we can steal
in UDP receive then attempt checksum conversion before calling
udp_queue_rcv_skb.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/udp.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cd0db54..50d3b5c 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1769,6 +1769,10 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		if (unlikely(sk->sk_rx_dst != dst))
 			udp_sk_rx_dst_set(sk, dst);
 
+		if (udp_sk(sk)->convert_csum && uh->check && !IS_UDPLITE(sk))
+			skb_checksum_try_convert(skb, IPPROTO_UDP, uh->check,
+						 inet_compute_pseudo);
+
 		ret = udp_queue_rcv_skb(sk, skb);
 		sock_put(sk);
 		/* a return value > 0 means to resubmit the input, but
-- 
2.1.0.rc2.206.gedb03e5
