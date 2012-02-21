From: David Miller <davem@davemloft.net>
Subject: Re: return 0 when MSG_OOB in ping_recvmsg
Date: Tue, 21 Feb 2012 17:59:39 -0500 (EST)
Message-ID: <20120221.175939.31025047537106310.davem@davemloft.net>
References: <20120221225058.GA15387@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33333 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752022Ab2BUW7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 17:59:43 -0500
In-Reply-To: <20120221225058.GA15387@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Tue, 21 Feb 2012 17:50:59 -0500

> If a packet causes the 'if (flags & MSG_OOB)' test this function does first
> thing is true, it returns an uninitialised variable from the stack.
> 
> There may be a better return code for this failure, but returning
> '0 bytes copied' seems better than just returning garbage.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

It should return something initialized, for sure, but more appropriate
is -EOPNOTSUPP as is consistent with this file's sendsmg() implementation
as well as the sendmsg and recvmsg methods from net/ipv4/raw.c upon which
these were modelled.

So that's the change I'll commit, thanks Dave!

--------------------
ipv4: ping: Fix recvmsg MSG_OOB error handling.

Don't return an uninitialized variable as the error, return
-EOPNOTSUPP instead.

Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ping.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index aea5a19..b072386 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -630,6 +630,7 @@ static int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	pr_debug("ping_recvmsg(sk=%p,sk->num=%u)\n", isk, isk->inet_num);
 
+	err = -EOPNOTSUPP;
 	if (flags & MSG_OOB)
 		goto out;
 
-- 
1.7.7.6
