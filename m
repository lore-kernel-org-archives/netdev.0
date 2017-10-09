From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH] netlink: do not set cb_running if dump's start() errs
Date: Mon,  9 Oct 2017 13:56:48 +0200
Message-ID: <20171009115648.25989-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: johannes@sipsolutions.net, davem@davemloft.net,
        Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It turns out that multiple places can call netlink_dump(), which means
it's still possible to dereference partially initialized values in
dump() that were the result of a faulty returned start().

This fixes the issue by calling start() _before_ setting cb_running to
true, so that there's no chance at all of hitting the dump() function
through any indirect paths.

In testing this with several different pieces of tricky code to trigger
these issues, this commit fixes all avenues that I'm aware of.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: Johannes Berg <johannes@sipsolutions.net>
---
 net/netlink/af_netlink.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 94c11cf0459d..f34750691c5c 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2266,16 +2266,17 @@ int __netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	cb->min_dump_alloc = control->min_dump_alloc;
 	cb->skb = skb;
 
+	if (cb->start) {
+		ret = cb->start(cb);
+		if (ret)
+			goto error_unlock;
+	}
+
 	nlk->cb_running = true;
 
 	mutex_unlock(nlk->cb_mutex);
 
-	ret = 0;
-	if (cb->start)
-		ret = cb->start(cb);
-
-	if (!ret)
-		ret = netlink_dump(sk);
+	ret = netlink_dump(sk);
 
 	sock_put(sk);
 
-- 
2.14.2
