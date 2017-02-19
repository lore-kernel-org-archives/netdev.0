From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net v2] ipv6: release dst on error in ip6_dst_lookup_tail
Date: Sat, 18 Feb 2017 19:00:45 -0500
Message-ID: <20170219000045.34672-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jtleight@udel.edu,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:35985 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751012AbdBSAAu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 19:00:50 -0500
Received: by mail-qt0-f196.google.com with SMTP id h53so10211900qth.3
        for <netdev@vger.kernel.org>; Sat, 18 Feb 2017 16:00:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

If ip6_dst_lookup_tail has acquired a dst and fails the IPv4-mapped
check, release the dst before returning an error.

Fixes: ec5e3b0a1d41 ("ipv6: Inhibit IPv4-mapped src address on the wire.")
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
