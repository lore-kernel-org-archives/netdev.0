From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: null-ptr deref in ip_options_echo may lead to denial
 of service
Date: Sun, 19 Mar 2017 22:25:00 -0700
Message-ID: <1489987500.16816.19.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAC9A2PqFcJ2k5Nm8QyxbOrO6rQnfHxcPvsnkzPMGUuJ5hCXM1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, security@kernel.org, netdev@vger.kernel.org
To: Anarcheuz Fritz <anarcheuz@gmail.com>,
        Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34401 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752514AbdCTFZD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 01:25:03 -0400
Received: by mail-pf0-f196.google.com with SMTP id o126so15565333pfb.1
        for <netdev@vger.kernel.org>; Sun, 19 Mar 2017 22:25:02 -0700 (PDT)
In-Reply-To: <CAC9A2PqFcJ2k5Nm8QyxbOrO6rQnfHxcPvsnkzPMGUuJ5hCXM1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-03-20 at 12:59 +0800, Anarcheuz Fritz wrote:
> Hi David,
> 
> 
> While working on some legacy kernel I stumbled upon a null-ptr deref in
> ip_options_echo. The bug has been verified on the latest version
> 3.2.87 from the supported long-term branch.
> 

Fixed in commit 34b2cef20f19c87999fff3da4071e66937db9644
("ipv4: keep skb->dst around in presence of IP options")

For 3.2, since d826eb14ecef was not backported, following patch should
do it.

(Bug origin was f84af32cbca70 ("net: ip_queue_rcv_skb() helper"))

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
