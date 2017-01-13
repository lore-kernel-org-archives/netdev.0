From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [PATCH net] ip6_tunnel: Account for tunnel header in tunnel MTU
Date: Fri, 13 Jan 2017 10:12:20 +0100
Message-ID: <1484298740-29199-1-git-send-email-jkbs@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:33656 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751146AbdAMJMZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 04:12:25 -0500
Received: by mail-qk0-f175.google.com with SMTP id s140so48104250qke.0
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 01:12:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With ip6gre we have a tunnel header which also makes the tunnel MTU
smaller. We need to reserve room for it. Previously we were using up
space reserved for the Tunnel Encapsulation Limit option
header (RFC 2473).

Also, after commit b05229f44228 ("gre6: Cleanup GREv6 transmit path,
call common GRE functions") our contract with the caller has
changed. Now we check if the packet length exceeds the tunnel MTU after
the tunnel header has been pushed, unlike before.

This is reflected in the check where we look at the packet length minus
the size of the tunnel header, which is already accounted for in tunnel
MTU.

Fixes: b05229f44228 ("gre6: Cleanup GREv6 transmit path, call common GRE functions")
Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>
---
 net/ipv6/ip6_tunnel.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 36d2921..753d6d0 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1108,7 +1108,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 				     t->parms.name);
 		goto tx_err_dst_release;
 	}
-	mtu = dst_mtu(dst) - psh_hlen;
+	mtu = dst_mtu(dst) - psh_hlen - t->tun_hlen;
 	if (encap_limit >= 0) {
 		max_headroom += 8;
 		mtu -= 8;
@@ -1117,7 +1117,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 		mtu = IPV6_MIN_MTU;
 	if (skb_dst(skb) && !t->parms.collect_md)
 		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
-	if (skb->len > mtu && !skb_is_gso(skb)) {
+	if (skb->len - t->tun_hlen > mtu && !skb_is_gso(skb)) {
 		*pmtu = mtu;
 		err = -EMSGSIZE;
 		goto tx_err_dst_release;
-- 
2.7.4
