From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-stable] ipv4: keep skb->dst around in presence of IP
 options
Date: Mon, 20 Mar 2017 21:23:48 -0700
Message-ID: <1490070228.16816.98.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAC9A2PqFcJ2k5Nm8QyxbOrO6rQnfHxcPvsnkzPMGUuJ5hCXM1Q@mail.gmail.com>
         <1489987500.16816.19.camel@edumazet-glaptop3.roam.corp.google.com>
         <1490056423.4770.6.camel@decadent.org.uk>
         <1490056561.4770.7.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Anarcheuz Fritz <anarcheuz@gmail.com>, davem@davemloft.net,
        security@kernel.org, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35435 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752227AbdCUEY2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 00:24:28 -0400
Received: by mail-pf0-f194.google.com with SMTP id n11so8843783pfg.2
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 21:23:51 -0700 (PDT)
In-Reply-To: <1490056561.4770.7.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Upstream commit 34b2cef20f19c87999fff3da4071e66937db9644
("ipv4: keep skb->dst around in presence of IP options") incorrectly
root caused commit d826eb14ecef ("ipv4: PKTINFO doesnt need dst
reference") as bug origin.

This patch should fix the issue for 3.2.xx stable kernels, since IPv4
options seem to get more traction these days, after years of oblivion ;)

Fixes: f84af32cbca70 ("net: ip_queue_rcv_skb() helper"))
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Anarcheuz Fritz <anarcheuz@gmail.com>
---

This is a backport for 3.2 kernels.

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index b3648bbef0da..a6e1eeb02267 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1009,7 +1009,8 @@ e_inval:
  */
 int ip_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
-	if (!(inet_sk(sk)->cmsg_flags & IP_CMSG_PKTINFO))
+	if (!(inet_sk(sk)->cmsg_flags & IP_CMSG_PKTINFO) &&
+	    !IPCB(skb)->opt.optlen)
 		skb_dst_drop(skb);
 	return sock_queue_rcv_skb(sk, skb);
 }
