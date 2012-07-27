From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 5/7] netpoll: take rcu_read_lock_bh() in netpoll_rx()
Date: Fri, 27 Jul 2012 23:38:02 +0800
Message-ID: <1343403484-29347-6-git-send-email-amwang@redhat.com>
References: <1343403484-29347-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Eric Dumazet <edumazet@google.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Joe Perches <joe@perches.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1343403484-29347-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In __netpoll_rx(), it dereferences ->npinfo without rcu_dereference_bh(),
this patch fixes it by using the 'npinfo' passed from netpoll_rx()
where it is already dereferenced with rcu_dereference_bh().

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/linux/netpoll.h |    4 ++--
 net/core/netpoll.c      |    3 +--
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 5011d74..36f938c 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -52,7 +52,7 @@ void netpoll_set_trap(int trap);
 void __netpoll_cleanup(struct netpoll *np);
 void __netpoll_free_rcu(struct netpoll *np);
 void netpoll_cleanup(struct netpoll *np);
-int __netpoll_rx(struct sk_buff *skb);
+int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo);
 void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 			     struct net_device *dev);
 static inline void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
@@ -77,7 +77,7 @@ static inline bool netpoll_rx(struct sk_buff *skb)
 
 	spin_lock(&npinfo->rx_lock);
 	/* check rx_flags again with the lock held */
-	if (npinfo->rx_flags && __netpoll_rx(skb))
+	if (npinfo->rx_flags && __netpoll_rx(skb, npinfo))
 		ret = true;
 	spin_unlock(&npinfo->rx_lock);
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 19dddef..3965fdb 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -543,13 +543,12 @@ static void arp_reply(struct sk_buff *skb)
 	spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 }
 
-int __netpoll_rx(struct sk_buff *skb)
+int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 {
 	int proto, len, ulen;
 	int hits = 0;
 	const struct iphdr *iph;
 	struct udphdr *uh;
-	struct netpoll_info *npinfo = skb->dev->npinfo;
 	struct netpoll *np, *tmp;
 
 	if (list_empty(&npinfo->rx_np))
-- 
1.7.7.6
