From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] udp reuseport: fix packet of same flow hashed to
 different socket
Date: Wed, 08 Jun 2016 08:43:40 -0700
Message-ID: <1465400620.7945.16.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465357219-34240-1-git-send-email-suxm@chinanetcenter.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Su Xuemin <suxm@chinanetcenter.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35201 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325AbcFHPnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 11:43:43 -0400
In-Reply-To: <1465357219-34240-1-git-send-email-suxm@chinanetcenter.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-08 at 11:40 +0800, Su Xuemin wrote:
> From: "Su, Xuemin" <suxm@chinanetcenter.com>
> 
> There is a corner case in which udp packets belonging to a same
> flow are hashed to different socket when hslot->count changes from 10
> to 11:

> It's the same case for IPv6, and this patch also fixes that.
> 
> Signed-off-by: Su, Xuemin <suxm@chinanetcenter.com>
> ---
> The patch v1 does not fix the code in IPv6. Thank Eric Dumazet for
> pointing that.
> And I use this tree to generate this patch, hope it's correct:
>   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
> 

I am not convinced this is the right way to fix the issue.

Fact that you did not change udp4_lib_lookup2() is telling me something.


1) If host has 100 different IP, and 10 sockets bound to 0.0.0.0:53 
2) If we receive datagrams from SRCIP:srcport send to IP{1..100}:53
will all be hashed on same slot.

See the hash used in soreuseport logic as an equivalent of a 4-tuple
hash really, not a 3-tuple one.

I would try instead :

(Looks like we missed this when commit 1223c67c093 ("udp: fix for
unicast RX path optimization") was reviewed/merged.

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d56c0559b477cb96ce78c9b9b7dacc3109594f3a..5847fe48f17d64bee32551e9dd42024a8e65fb10 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -563,7 +563,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 				goto begin;
 
 			result = udp4_lib_lookup2(net, saddr, sport,
-						  htonl(INADDR_ANY), hnum, dif,
+						  daddr, hnum, dif,
 						  hslot2, slot2, skb);
 		}
 		return result;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 2da1896af93496cc58762c67b4cd4b4f42924901..501b5563234d0921eff9f1e50155db76f27b3837 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -277,7 +277,7 @@ struct sock *__udp6_lib_lookup(struct net *net,
 				goto begin;
 
 			result = udp6_lib_lookup2(net, saddr, sport,
-						  &in6addr_any, hnum, dif,
+						  daddr, hnum, dif,
 						  hslot2, slot2, skb);
 		}
 		return result;

 
