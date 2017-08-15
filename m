From: Jonathan Basseri <misterikkit@google.com>
Subject: [PATCH net] xfrm: Clear sk_dst_cache when applying per-socket policy.
Date: Tue, 15 Aug 2017 15:25:10 -0700
Message-ID: <20170815222510.21711-1-misterikkit@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jonathan Basseri <misterikkit@google.com>, jkbs@redhat.com,
        davem@davemloft.net, steffen.klassert@secunet.com,
        lorenzo@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f74.google.com ([74.125.83.74]:41569 "EHLO
        mail-pg0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751095AbdHOW03 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 18:26:29 -0400
Received: by mail-pg0-f74.google.com with SMTP id r133so1035271pgr.8
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 15:26:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an IPv6 socket has a valid dst cache, then xfrm_lookup_route will get
skipped. However, the cache is not invalidated when applying policy to a
socket (i.e. IPV6_XFRM_POLICY). The result is that new policies are
sometimes ignored on those sockets.

This can be demonstrated like so,
1. Create UDPv6 socket.
2. connect() the socket.
3. Apply an outbound XFRM policy to the socket.
4. send() data on the socket.

Packets will continue to be sent in the clear instead of matching an
xfrm or returning a no-match error (EAGAIN). This affects calls to
send() and not sendto().

Note: Creating normal XFRM policies should have a similar effect on
sk_dst_cache entries that match the policy, but that is not fixed in
this patch.

Fixes: 00bc0ef5880d ("ipv6: Skip XFRM lookup if dst_entry in socket cache is valid")
Tested: https://android-review.googlesource.com/418659
Signed-off-by: Jonathan Basseri <misterikkit@google.com>
---
 net/xfrm/xfrm_state.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 6c0956d10db6..46294cc833f3 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2028,33 +2028,34 @@ EXPORT_SYMBOL(km_is_alive);
 int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen)
 {
 	int err;
 	u8 *data;
 	struct xfrm_mgr *km;
 	struct xfrm_policy *pol = NULL;
 
 	if (optlen <= 0 || optlen > PAGE_SIZE)
 		return -EMSGSIZE;
 
 	data = memdup_user(optval, optlen);
 	if (IS_ERR(data))
 		return PTR_ERR(data);
 
 	err = -EINVAL;
 	rcu_read_lock();
 	list_for_each_entry_rcu(km, &xfrm_km_list, list) {
 		pol = km->compile_policy(sk, optname, data,
 					 optlen, &err);
 		if (err >= 0)
 			break;
 	}
 	rcu_read_unlock();
 
 	if (err >= 0) {
 		xfrm_sk_policy_insert(sk, err, pol);
 		xfrm_pol_put(pol);
+		sk_dst_reset(sk);
 		err = 0;
 	}
 
 	kfree(data);
 	return err;
 }
-- 
2.14.1.480.gb18f417b89-goog
