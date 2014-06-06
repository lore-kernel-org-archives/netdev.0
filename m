From: Dmitry Popov <ixaphire@qrator.net>
Subject: [PATCH] ip_tunnel: fix possible rtable leak
Date: Fri, 6 Jun 2014 04:34:37 +0400
Message-ID: <20140606043437.f50f21cd56243ffa30165710@qrator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	trivial@kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ip_rt_put(rt) is always called in "error" branches above, but was missed in
skb_cow_head branch. As rt is not yet bound to skb here we have to release it by 
hand.

Signed-off-by: Dmitry Popov <ixaphire@qrator.net>
---
 net/ipv4/ip_tunnel.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 2acc233..3f6135b 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -668,6 +668,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		dev->needed_headroom = max_headroom;
 
 	if (skb_cow_head(skb, dev->needed_headroom)) {
+		ip_rt_put(rt);
 		dev->stats.tx_dropped++;
 		kfree_skb(skb);
 		return;
