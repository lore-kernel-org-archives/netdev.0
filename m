From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: sctp: fix copying sk_v6_rcv_saddr in sctp_v6_create_accept_sk
Date: Tue, 19 Nov 2013 11:51:24 +0100
Message-ID: <1384858284-2246-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Wang Weidong <wangweidong1@huawei.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23323 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751592Ab3KSKv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Nov 2013 05:51:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang reported an issue that lksctp's test_getname_v6 seems to fail.

The issue is that we do not copy sk_v6_rcv_saddr over to the new
socket, although the comment above says so regarding rcv_saddr.

Commit 914e1c8b6980 ("sctp: Inherit all socket options from parent
correctly.") originally moved that over to sctp_copy_sock(), but
after commit efe4208f47f9 ("ipv6: make lookups simpler and faster")
this no longer holds and the actual value of sk_v6_rcv_saddr was
no longer being migrated.

With this patch, the lksctp test suite passes again for IPv6.

Fixes: efe4208f47f9 ("ipv6: make lookups simpler and faster")
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sctp/ipv6.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 7567e6f..be08592 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -661,6 +661,7 @@ static struct sock *sctp_v6_create_accept_sk(struct sock *sk,
 	 * and getpeername().
 	 */
 	sctp_v6_to_sk_daddr(&asoc->peer.primary_addr, newsk);
+	newsk->sk_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
 
 	sk_refcnt_debug_inc(newsk);
 
-- 
1.8.3.1
