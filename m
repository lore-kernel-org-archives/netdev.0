From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv4: properly update pmtu
Date: Wed, 22 Aug 2012 08:48:29 +0200
Message-ID: <1345618109.5158.599.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Julian Anastasov <ja@ssi.bg>,
	Sylvain Munaut <s.munaut@whatever-company.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33471 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460Ab2HVGsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 02:48:41 -0400
Received: by bkwj10 with SMTP id j10so167312bkw.19
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 23:48:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Sylvain Munault reported following info :

 - TCP connection get "stuck" with data in send queue when doing
   "large" transfers ( like typing 'ps ax' on a ssh connection )
 - Only happens on path where the PMTU is lower than the MTU of
   the interface
 - Is not present right after boot, it only appears 10-20min after
   boot or so. (and that's inside the _same_ TCP connection, it works
   fine at first and then in the same ssh session, it'll get stuck)
 - Definitely seems related to fragments somehow since I see a router
   sending ICMP message saying fragmentation is needed.
 - Exact same setup works fine with kernel 3.5.1

Problem happens when the 10 minutes (ip_rt_mtu_expires) expiration
period is over.

ip_rt_update_pmtu() calls dst_set_expires() to rearm a new expiration,
but dst_set_expires() does nothing because dst.expires is already set.

It seems we want to set the expires field to a new value, regardless
of prior one.

With help from Julian Anastasov.

Reported-by: Sylvain Munaut <s.munaut@whatever-company.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
CC: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/route.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e4ba974..8d6d320 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -956,7 +956,7 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 		dst->obsolete = DST_OBSOLETE_KILL;
 	} else {
 		rt->rt_pmtu = mtu;
-		dst_set_expires(&rt->dst, ip_rt_mtu_expires);
+		rt->dst.expires = max(1UL, jiffies + ip_rt_mtu_expires);
 	}
 }
 
