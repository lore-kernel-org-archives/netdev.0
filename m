From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [net-next] netlink: Use random autobind rover
Date: Sun, 17 May 2015 10:45:34 +0800
Message-ID: <20150517024534.GA5570@gondor.apana.org.au>
References: <20150515.130219.331336809636676892.davem@redhat.com>
 <20150516123242.GA683@gondor.apana.org.au>
 <20150516134007.GA1152@gondor.apana.org.au>
 <20150516.170819.1082459707799000658.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, tgraf@suug.ch, netdev@vger.kernel.org,
	ying.xue@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:39211 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774AbbEQCpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 22:45:44 -0400
Content-Disposition: inline
In-Reply-To: <20150516.170819.1082459707799000658.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 16, 2015 at 05:08:19PM -0400, David Miller wrote:
>
> As far as I can tell, this ought to be fine as-is.

OK what about dropping the global rover altogether? Let's just
start randomly like UDP.

---8<---
Currently we use a global rover to select a port ID that is unique.
This used to work consistently when it was protected with a global
lock.  However as we're now lockless, the global rover can exhibit
pathological behaviour should multiple threads all stomp on it at
the same time.

Granted this will eventually resolve itself but the process is
suboptimal.

This patch replaces the global rover with a pseudorandom starting
point to avoid this issue.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ec4adbd..716c6d2 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1296,20 +1296,24 @@ static int netlink_autobind(struct socket *sock)
 	struct netlink_table *table = &nl_table[sk->sk_protocol];
 	s32 portid = task_tgid_vnr(current);
 	int err;
-	static s32 rover = -4097;
+	s32 rover = -4096;
+	bool ok;
 
 retry:
 	cond_resched();
 	rcu_read_lock();
-	if (__netlink_lookup(table, portid, net)) {
+	ok = !__netlink_lookup(table, portid, net);
+	rcu_read_unlock();
+	if (!ok) {
 		/* Bind collision, search negative portid values. */
-		portid = rover--;
-		if (rover > -4097)
+		if (rover == -4096)
+			/* rover will be in range [S32_MIN, -4097] */
+			rover = S32_MIN + prandom_u32_max(-4096 - S32_MIN);
+		else if (rover >= -4096)
 			rover = -4097;
-		rcu_read_unlock();
+		portid = rover--;
 		goto retry;
 	}
-	rcu_read_unlock();
 
 	err = netlink_insert(sk, portid);
 	if (err == -EADDRINUSE)
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
