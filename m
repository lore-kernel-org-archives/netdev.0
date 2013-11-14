From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv4: fix possible seqlock deadlock
Date: Thu, 14 Nov 2013 13:37:54 -0800
Message-ID: <1384465074.28716.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131114191621.GB9630@redhat.com>
	 <1384458103.28716.33.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f177.google.com ([209.85.161.177]:45412 "EHLO
	mail-gg0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758029Ab3KNViB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 16:38:01 -0500
Received: by mail-gg0-f177.google.com with SMTP id f4so1075566ggn.8
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 13:37:59 -0800 (PST)
In-Reply-To: <1384458103.28716.33.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ip4_datagram_connect() being called from process context,
it should use IP_INC_STATS() instead of IP_INC_STATS_BH()
otherwise we can deadlock on 32bit arches, or get corruptions of
SNMP counters.

Fixes: 584bdf8cbdf6 ("[IPV4]: Fix "ipOutNoRoutes" counter error for TCP and UDP")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dave Jones <davej@redhat.com>
---
 net/ipv4/datagram.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index b28e863fe0a7..19e36376d2a0 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -57,7 +57,7 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
 		if (err == -ENETUNREACH)
-			IP_INC_STATS_BH(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
+			IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
 		goto out;
 	}
 
