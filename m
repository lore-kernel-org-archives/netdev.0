From: Jonathan Basseri <misterikkit@google.com>
Subject: [PATCH net v2] xfrm: Clear sk_dst_cache when applying per-socket policy.
Date: Wed, 25 Oct 2017 09:52:27 -0700
Message-ID: <20171025165227.6469-1-misterikkit@google.com>
References: <20170815222510.21711-1-misterikkit@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: jkbs@redhat.com, davem@davemloft.net, steffen.klassert@secunet.com,
        lorenzo@google.com, eric.dumazet@gmail.com,
        Jonathan Basseri <misterikkit@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f202.google.com ([209.85.220.202]:45739 "EHLO
        mail-qk0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751421AbdJYQw6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 12:52:58 -0400
Received: by mail-qk0-f202.google.com with SMTP id g74so423708qke.4
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 09:52:58 -0700 (PDT)
In-Reply-To: <20170815222510.21711-1-misterikkit@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
 net/xfrm/xfrm_state.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 12213477cd3a..1f5cee2269af 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2045,33 +2045,34 @@ EXPORT_SYMBOL(km_is_alive);
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
+		__sk_dst_reset(sk);
 		err = 0;
 	}
 
 	kfree(data);
 	return err;
 }
-- 
2.15.0.rc2.357.g7e34df9404-goog
