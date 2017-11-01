From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/3] xfrm: Clear sk_dst_cache when applying per-socket policy.
Date: Wed, 1 Nov 2017 11:05:02 +0100
Message-ID: <1509530703-12707-3-git-send-email-steffen.klassert@secunet.com>
References: <1509530703-12707-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:60010 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754251AbdKAKFP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 06:05:15 -0400
In-Reply-To: <1509530703-12707-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonathan Basseri <misterikkit@google.com>

If a socket has a valid dst cache, then xfrm_lookup_route will get
skipped. However, the cache is not invalidated when applying policy to a
socket (i.e. IPV6_XFRM_POLICY). The result is that new policies are
sometimes ignored on those sockets. (Note: This was broken for IPv4 and
IPv6 at different times.)

This can be demonstrated like so,
1. Create UDP socket.
2. connect() the socket.
3. Apply an outbound XFRM policy to the socket. (setsockopt)
4. send() data on the socket.

Packets will continue to be sent in the clear instead of matching an
xfrm or returning a no-match error (EAGAIN). This affects calls to
send() and not sendto().

Invalidating the sk_dst_cache is necessary to correctly apply xfrm
policies. Since we do this in xfrm_user_policy(), the sk_lock was
already acquired in either do_ip_setsockopt() or do_ipv6_setsockopt(),
and we may call __sk_dst_reset().

Performance impact should be negligible, since this code is only called
when changing xfrm policy, and only affects the socket in question.

Fixes: 00bc0ef5880d ("ipv6: Skip XFRM lookup if dst_entry in socket cache is valid")
Tested: https://android-review.googlesource.com/517555
Tested: https://android-review.googlesource.com/418659
Signed-off-by: Jonathan Basseri <misterikkit@google.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 1221347..1f5cee2 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2069,6 +2069,7 @@ int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen
 	if (err >= 0) {
 		xfrm_sk_policy_insert(sk, err, pol);
 		xfrm_pol_put(pol);
+		__sk_dst_reset(sk);
 		err = 0;
 	}
 
-- 
2.7.4
