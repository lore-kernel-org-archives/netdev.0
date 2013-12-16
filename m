From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6: sit: update mtu check to take care of gso packets
Date: Mon, 16 Dec 2013 06:31:23 -0800
Message-ID: <1387204283.19078.240.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52AB322B.7030802@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michal Schmidt <mschmidt@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:48777 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753781Ab3LPOb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 09:31:26 -0500
Received: by mail-pd0-f180.google.com with SMTP id q10so5414984pdj.11
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 06:31:26 -0800 (PST)
In-Reply-To: <52AB322B.7030802@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While testing my changes for TSO support in SIT devices,
I was using sit0 tunnel which appears to include nopmtudisc flag.

But using :

ip tun add sittun mode sit remote $REMOTE_IPV4 local $LOCAL_IPV4 \
   dev $IFACE

We get a tunnel which rejects too long packets because of the mtu check
which is not yet GSO aware.

erd:~# ip tunnel
sittun: ipv6/ip  remote 10.246.17.84  local 10.246.17.83  ttl inherit  6rd-prefix 2002::/16 
sit0: ipv6/ip  remote any  local any  ttl 64  nopmtudisc 6rd-prefix 2002::/16 

This patch is based on an excellent report from
Michal Shmidt.

In the future, we probably want to extend the MTU check to do the
right thing for GSO packets...

Fixes: ("61c1db7fae21 ipv6: sit: add GSO/TSO support")
Reported-by: Michal Schmidt <mschmidt@redhat.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/sit.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 366fbba3359a..a710fdec42d3 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -924,7 +924,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		if (tunnel->parms.iph.daddr && skb_dst(skb))
 			skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
 
-		if (skb->len > mtu) {
+		if (skb->len > mtu && !skb_is_gso(skb)) {
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 			ip_rt_put(rt);
 			goto tx_error;
