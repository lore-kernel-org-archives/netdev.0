From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] ip6_tunnel: update mtu properly for ARPHRD_ETHER tunnel device in tx path
Date: Thu, 28 Sep 2017 13:24:07 +0800
Message-ID: <f4105462b42f560a0aaace0be3e66129200bdf29.1506576247.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Dmitry Kozlov <xeb@mail.ru>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36969 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751113AbdI1FYP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 01:24:15 -0400
Received: by mail-pf0-f196.google.com with SMTP id e69so496748pfg.4
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 22:24:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when updating mtu in tx path, it doesn't consider ARPHRD_ETHER tunnel
device, like ip6gre_tap tunnel, for which it should also subtract ether
header to get the correct mtu.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv6/ip6_tunnel.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index f2f21c2..a1c2444 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1043,6 +1043,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 	struct dst_entry *dst = NULL, *ndst = NULL;
 	struct net_device *tdev;
 	int mtu;
+	unsigned int eth_hlen = t->dev->type == ARPHRD_ETHER ? ETH_HLEN : 0;
 	unsigned int psh_hlen = sizeof(struct ipv6hdr) + t->encap_hlen;
 	unsigned int max_headroom = psh_hlen;
 	bool use_cache = false;
@@ -1124,7 +1125,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 				     t->parms.name);
 		goto tx_err_dst_release;
 	}
-	mtu = dst_mtu(dst) - psh_hlen - t->tun_hlen;
+	mtu = dst_mtu(dst) - eth_hlen - psh_hlen - t->tun_hlen;
 	if (encap_limit >= 0) {
 		max_headroom += 8;
 		mtu -= 8;
@@ -1133,7 +1134,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 		mtu = IPV6_MIN_MTU;
 	if (skb_dst(skb) && !t->parms.collect_md)
 		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
-	if (skb->len - t->tun_hlen > mtu && !skb_is_gso(skb)) {
+	if (skb->len - t->tun_hlen - eth_hlen > mtu && !skb_is_gso(skb)) {
 		*pmtu = mtu;
 		err = -EMSGSIZE;
 		goto tx_err_dst_release;
-- 
2.1.0
