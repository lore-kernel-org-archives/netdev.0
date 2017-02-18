From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net] ipv6: release dst on error in ip6_dst_lookup_tail
Date: Sat, 18 Feb 2017 18:51:43 -0500
Message-ID: <20170218235144.29670-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jtleight@udel.edu,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:36613 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750806AbdBRXw6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 18:52:58 -0500
Received: by mail-qt0-f195.google.com with SMTP id h53so10200590qth.3
        for <netdev@vger.kernel.org>; Sat, 18 Feb 2017 15:52:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

If ip6_dst_lookup_tail has acquired a dst and fails the IPv4-mapped
check, release the dst before returning an error.

Fixes: b2e6f0c8dde5 ("ipv6: Inhibit IPv4-mapped src address on the wire.")
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv6/ip6_output.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index e164684456df..7cebee58e55b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1022,8 +1022,10 @@ static int ip6_dst_lookup_tail(struct net *net, const struct sock *sk,
 	}
 #endif
 	if (ipv6_addr_v4mapped(&fl6->saddr) &&
-	    !(ipv6_addr_v4mapped(&fl6->daddr) || ipv6_addr_any(&fl6->daddr)))
-		return -EAFNOSUPPORT;
+	    !(ipv6_addr_v4mapped(&fl6->daddr) || ipv6_addr_any(&fl6->daddr))) {
+		err = -EAFNOSUPPORT;
+		goto out_err_release;
+	}
 
 	return 0;
 
-- 
2.11.0.483.g087da7b7c-goog
