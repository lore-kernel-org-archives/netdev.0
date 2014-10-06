From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH V2 linux-next] net: fix rcu access on phonet_routes
Date: Mon,  6 Oct 2014 20:15:20 +0200
Message-ID: <1412619321-2212-1-git-send-email-fabf@skynet.be>
Cc: Eric Dumazet <edumazet@google.com>,
	Josh Triplett <josh@joshtriplett.org>,
	Fabian Frederick <fabf@skynet.be>,
	Remi Denis-Courmont <courmisch@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-Add __rcu annotation on table to fix sparse warnings:
net/phonet/pn_dev.c:279:25: warning: incorrect type in assignment (different address spaces)
net/phonet/pn_dev.c:279:25:    expected struct net_device *<noident>
net/phonet/pn_dev.c:279:25:    got void [noderef] <asn:4>*<noident>
net/phonet/pn_dev.c:376:17: warning: incorrect type in assignment (different address spaces)
net/phonet/pn_dev.c:376:17:    expected struct net_device *volatile <noident>
net/phonet/pn_dev.c:376:17:    got struct net_device [noderef] <asn:4>*<noident>
net/phonet/pn_dev.c:392:17: warning: incorrect type in assignment (different address spaces)
net/phonet/pn_dev.c:392:17:    expected struct net_device *<noident>
net/phonet/pn_dev.c:392:17:    got void [noderef] <asn:4>*<noident>

-Access table with rcu_access_pointer (fixes the following sparse errors):
net/phonet/pn_dev.c:278:25: error: incompatible types in comparison expression (different address spaces)
net/phonet/pn_dev.c:391:17: error: incompatible types in comparison expression (different address spaces)

Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
V2: use rcu_access_pointer instead of rcu_dereference out of rcu_read_lock context
    (suggested by Eric Dumazet).

 net/phonet/pn_dev.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 56a6146..a586800 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -36,7 +36,7 @@
 
 struct phonet_routes {
 	struct mutex		lock;
-	struct net_device	*table[64];
+	struct net_device __rcu	*table[64];
 };
 
 struct phonet_net {
@@ -275,7 +275,7 @@ static void phonet_route_autodel(struct net_device *dev)
 	bitmap_zero(deleted, 64);
 	mutex_lock(&pnn->routes.lock);
 	for (i = 0; i < 64; i++)
-		if (dev == pnn->routes.table[i]) {
+		if (rcu_access_pointer(pnn->routes.table[i]) == dev) {
 			RCU_INIT_POINTER(pnn->routes.table[i], NULL);
 			set_bit(i, deleted);
 		}
@@ -388,7 +388,7 @@ int phonet_route_del(struct net_device *dev, u8 daddr)
 
 	daddr = daddr >> 2;
 	mutex_lock(&routes->lock);
-	if (dev == routes->table[daddr])
+	if (rcu_access_pointer(routes->table[daddr]) == dev)
 		RCU_INIT_POINTER(routes->table[daddr], NULL);
 	else
 		dev = NULL;
-- 
1.9.3
