From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 2/3] ipv6/udp: Use the correct variable to determine non-blocking condition
Date: Tue, 21 Jun 2011 16:43:39 -0400
Message-ID: <1308689020-1873-3-git-send-email-paul.gortmaker@windriver.com>
References: <1308689020-1873-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Xufeng Zhang <xufeng.zhang@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58244 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757240Ab1FUUoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 16:44:06 -0400
In-Reply-To: <1308689020-1873-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xufeng Zhang <xufeng.zhang@windriver.com>

udpv6_recvmsg() function is not using the correct variable to determine
whether or not the socket is in non-blocking operation, this will lead
to unexpected behavior when a UDP checksum error occurs.

Consider a non-blocking udp receive scenario: when udpv6_recvmsg() is
called by sock_common_recvmsg(), MSG_DONTWAIT bit of flags variable in
udpv6_recvmsg() is cleared by "flags & ~MSG_DONTWAIT" in this call:

    err = sk->sk_prot->recvmsg(iocb, sk, msg, size, flags & MSG_DONTWAIT,
                   flags & ~MSG_DONTWAIT, &addr_len);

i.e. with udpv6_recvmsg() getting these values:

	int noblock = flags & MSG_DONTWAIT
	int flags = flags & ~MSG_DONTWAIT

So, when udp checksum error occurs, the execution will go to
csum_copy_err, and then the problem happens:

    csum_copy_err:
            ...............
            if (flags & MSG_DONTWAIT)
                    return -EAGAIN;
            goto try_again;
            ...............

But it will always go to try_again as MSG_DONTWAIT has been cleared
from flags at call time -- only noblock contains the original value
of MSG_DONTWAIT, so the test should be:

            if (noblock)
                    return -EAGAIN;

This is also consistent with what the ipv4/udp code does.

Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/ipv6/udp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 41f8c9c..1e7a43f 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -453,7 +453,7 @@ csum_copy_err:
 	}
 	unlock_sock_fast(sk, slow);
 
-	if (flags & MSG_DONTWAIT)
+	if (noblock)
 		return -EAGAIN;
 	goto try_again;
 }
-- 
1.7.4.4

