From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] net: fix memory leak on oom with zerocopy
Date: Sun, 16 Sep 2012 11:44:16 +0300
Message-ID: <20120916084416.GA22936@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If orphan flags fails, we don't free the skb
on receive, which leaks the skb memory.

Return value was also wrong: netif_receive_skb
is supposed to return NET_RX_DROP, not ENOMEM.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Fixes a memory leak so 3.6 material?

 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8398836..899f827 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3321,7 +3321,7 @@ ncls:
 
 	if (pt_prev) {
 		if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
-			ret = -ENOMEM;
+			goto drop;
 		else
 			ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 	} else {
-- 
MST
