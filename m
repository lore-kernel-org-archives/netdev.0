From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression on TX throughput when using bonding
Date: Thu, 14 Jun 2012 11:21:59 +0200
Message-ID: <1339665719.22704.692.camel@edumazet-glaptop>
References: <CAL8zT=j8pEVc7AHwJzk+4skj=1tfRYZ_C7CuXD_08T_VmkwoFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:59357 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755362Ab2FNJWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 05:22:03 -0400
Received: by eaak11 with SMTP id k11so481155eaa.19
        for <netdev@vger.kernel.org>; Thu, 14 Jun 2012 02:22:02 -0700 (PDT)
In-Reply-To: <CAL8zT=j8pEVc7AHwJzk+4skj=1tfRYZ_C7CuXD_08T_VmkwoFg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-14 at 10:58 +0200, Jean-Michel Hautbois wrote:
> Hi all,
> 
> I have bisected a regression which concerns TX throughput when using bonding.
> I tested only with 10Gbps cards, as it appears when bandwidth need is
> over 1Gbps on my machine.
> I send UDP multicast packets over bonding and observe the tc result.
> 
> When KO :
> $>tc -s -d qdisc show dev eth1
> qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1
> 1 1 1 1 1 1
>  Sent 1106527591 bytes 273802 pkt (dropped 306419, overlimits 0 requeues 223)
>  backlog 0b 0p requeues 223
> 
> Ok course, when OK, dropped is 0.
> $>tc -s -d qdisc show dev eth1
> qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1
> 1 1 1 1 1 1
>  Sent 1648662087 bytes 408009 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> 
> 
> Here is the incriminated commit:
> 
> fc6055a5ba31e2c14e36e8939f9bf2b6d586a7f5 is the first bad commit
> commit fc6055a5ba31e2c14e36e8939f9bf2b6d586a7f5

>     net: Introduce skb_orphan_try()

So you are saying that if you make skb_orphan_try() doing nothing, it
solves your problem ?

diff --git a/net/core/dev.c b/net/core/dev.c
index cd09819..6df40dd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2096,6 +2096,7 @@ static int dev_gso_segment(struct sk_buff *skb, netdev_features_t features)
  */
 static inline void skb_orphan_try(struct sk_buff *skb)
 {
+#if 0
 	struct sock *sk = skb->sk;
 
 	if (sk && !skb_shinfo(skb)->tx_flags) {
@@ -2106,6 +2107,7 @@ static inline void skb_orphan_try(struct sk_buff *skb)
 			skb->rxhash = sk->sk_hash;
 		skb_orphan(skb);
 	}
+#endif
 }
 
 static bool can_checksum_protocol(netdev_features_t features, __be16 protocol)
