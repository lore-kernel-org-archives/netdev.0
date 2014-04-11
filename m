From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH net] net: ipv6: Fix oif in TCP SYN+ACK route lookup.
Date: Fri, 11 Apr 2014 13:19:12 +0900
Message-ID: <1397189952-31438-1-git-send-email-lorenzo@google.com>
Cc: hannes@stressinduktion.org, davem@davemloft.net,
	wangyufen@huawei.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:62647 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbaDKETe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 00:19:34 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so4791884pab.8
        for <netdev@vger.kernel.org>; Thu, 10 Apr 2014 21:19:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net-next commit 9c76a11, ipv6: tcp_ipv6 policy route issue, had
a boolean logic error that caused incorrect behaviour for TCP
SYN+ACK when oif-based rules are in use. Specifically:

1. If a SYN comes in from a global address, and sk_bound_dev_if
   is not set, the routing lookup has oif set to the interface
   the SYN came in on. Instead, it should have oif unset,
   because for global addresses, the incoming interface doesn't
   necessarily have any bearing on the interface the SYN+ACK is
   sent out on.
2. If a SYN comes in from a link-local address, and
   sk_bound_dev_if is set, the routing lookup has oif set to the
   interface the SYN came in on. Instead, it should have oif set
   to sk_bound_dev_if, because that's what the application
   requested.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 net/ipv6/tcp_ipv6.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5ca56ce..e289830 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -798,7 +798,7 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	__tcp_v6_send_check(buff, &fl6.saddr, &fl6.daddr);
 
 	fl6.flowi6_proto = IPPROTO_TCP;
-	if (rt6_need_strict(&fl6.daddr) || !oif)
+	if (rt6_need_strict(&fl6.daddr) && !oif)
 		fl6.flowi6_oif = inet6_iif(skb);
 	else
 		fl6.flowi6_oif = oif;
-- 
1.9.1.423.g4596e3a
