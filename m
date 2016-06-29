From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH] ipv4: Fix ip_skb_dst_mtu to use the sk passed by ip_finish_output
Date: Wed, 29 Jun 2016 21:47:03 +0300
Message-ID: <1467226023-4168-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Andy Zhou <azhou@ovn.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: "David S . Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34340 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752161AbcF2StK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 14:49:10 -0400
Received: by mail-wm0-f66.google.com with SMTP id 187so16473734wmz.1
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 11:49:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_skb_dst_mtu uses skb->sk, assuming it is an AF_INET socket (e.g. it
calls ip_sk_use_pmtu which casts sk as an inet_sk).

However, in the case of UDP tunneling, the skb->sk is not necessarily an
inet socket (could be AF_PACKET socket, or AF_UNSPEC if arriving from
tun/tap).

OTOH, the sk passed as an argument throughout IP stack's output path is
the one which is of PMTU interest:
 - In case of local sockets, sk is same as skb->sk;
 - In case of a udp tunnel, sk is the tunneling socket.

Fix, by passing ip_finish_output's sk to ip_skb_dst_mtu.
This augments 7026b1ddb6 'netfilter: Pass socket pointer down through okfn().'

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---

Discovered while debugging other issue in adjacent code area.

My setup seems to be handling this well; However I'd appreciate a
Tested-by or Reviewed-by as one can only cover relatively few of the
possible code flows leading to ip_skb_dst_mtu.

 include/net/ip.h                | 5 ++---
 net/bridge/br_netfilter_hooks.c | 2 +-
 net/ipv4/ip_output.c            | 4 ++--
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 37165fba37..08f36cd2b8 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -313,10 +313,9 @@ static inline unsigned int ip_dst_mtu_maybe_forward(const struct dst_entry *dst,
 	return min(dst->dev->mtu, IP_MAX_MTU);
 }
 
-static inline unsigned int ip_skb_dst_mtu(const struct sk_buff *skb)
+static inline unsigned int ip_skb_dst_mtu(struct sock *sk,
+					  const struct sk_buff *skb)
 {
-	struct sock *sk = skb->sk;
-
 	if (!sk || !sk_fullsock(sk) || ip_sk_use_pmtu(sk)) {
 		bool forwarding = IPCB(skb)->flags & IPSKB_FORWARDED;
 
diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 2d25979273..77e7f69bf8 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -700,7 +700,7 @@ static int
 br_nf_ip_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 		  int (*output)(struct net *, struct sock *, struct sk_buff *))
 {
-	unsigned int mtu = ip_skb_dst_mtu(skb);
+	unsigned int mtu = ip_skb_dst_mtu(sk, skb);
 	struct iphdr *iph = ip_hdr(skb);
 
 	if (unlikely(((iph->frag_off & htons(IP_DF)) && !skb->ignore_df) ||
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index cbac493c91..e23f141c9b 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -271,7 +271,7 @@ static int ip_finish_output(struct net *net, struct sock *sk, struct sk_buff *sk
 		return dst_output(net, sk, skb);
 	}
 #endif
-	mtu = ip_skb_dst_mtu(skb);
+	mtu = ip_skb_dst_mtu(sk, skb);
 	if (skb_is_gso(skb))
 		return ip_finish_output_gso(net, sk, skb, mtu);
 
@@ -541,7 +541,7 @@ int ip_do_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 
 	iph = ip_hdr(skb);
 
-	mtu = ip_skb_dst_mtu(skb);
+	mtu = ip_skb_dst_mtu(sk, skb);
 	if (IPCB(skb)->frag_max_size && IPCB(skb)->frag_max_size < mtu)
 		mtu = IPCB(skb)->frag_max_size;
 
-- 
2.7.4
