From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] netfilter: ipt_CLUSTERIP: fix build error without procfs
Date: Fri, 13 Jan 2017 16:41:03 +0100
Message-ID: <20170113154204.2737978-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Xin Long <lucien.xin@gmail.com>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We can't access c->pde if CONFIG_PROC_FS is disabled:

net/ipv4/netfilter/ipt_CLUSTERIP.c: In function 'clusterip_config_find_get':
net/ipv4/netfilter/ipt_CLUSTERIP.c:147:9: error: 'struct clusterip_config' has no member named 'pde'

This moves the check inside of another #ifdef.

Fixes: 6c5d5cfbe3c5 ("netfilter: ipt_CLUSTERIP: check duplicate config when initializing")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 1e38d8bf5631..52f26459efc3 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -144,7 +144,12 @@ clusterip_config_find_get(struct net *net, __be32 clusterip, int entry)
 	rcu_read_lock_bh();
 	c = __clusterip_config_find(net, clusterip);
 	if (c) {
-		if (!c->pde || unlikely(!atomic_inc_not_zero(&c->refcount)))
+#ifdef CONFIG_PROC_FS
+		if (!c->pde)
+			c = NULL;
+		else
+#endif
+		if (unlikely(!atomic_inc_not_zero(&c->refcount)))
 			c = NULL;
 		else if (entry)
 			atomic_inc(&c->entries);
-- 
2.9.0

