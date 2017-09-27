From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v2] netlink: do not proceed if dump's start() errs
Date: Thu, 28 Sep 2017 00:41:44 +0200
Message-ID: <20170927224144.1749-1-Jason@zx2c4.com>
References: <CAHmME9oA+dE3eOCTWweJjZGL4sog30JShoCJoWaPn4JV7h3auA@mail.gmail.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Johannes Berg <johannes@sipsolutions.net>
To: davem@davemloft.net, johannes.berg@intel.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9oA+dE3eOCTWweJjZGL4sog30JShoCJoWaPn4JV7h3auA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drivers that use the start method for netlink dumping rely on dumpit not
being called if start fails. For example, ila_xlat.c allocates memory
and assigns it to cb->args[0] in its start() function. It might fail to
do that and return -ENOMEM instead. However, even when returning an
error, dumpit will be called, which, in the example above, quickly
dereferences the memory in cb->args[0], which will OOPS the kernel. This
is but one example of how this goes wrong.

Since start() has always been a function with an int return type, it
therefore makes sense to use it properly, rather than ignoring it. This
patch thus returns early and does not call dumpit() when start() fails.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: Johannes Berg <johannes@sipsolutions.net>
---
 net/netlink/af_netlink.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 327807731b44..94c11cf0459d 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2270,10 +2270,13 @@ int __netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 
 	mutex_unlock(nlk->cb_mutex);
 
+	ret = 0;
 	if (cb->start)
-		cb->start(cb);
+		ret = cb->start(cb);
+
+	if (!ret)
+		ret = netlink_dump(sk);
 
-	ret = netlink_dump(sk);
 	sock_put(sk);
 
 	if (ret)
-- 
2.14.1
