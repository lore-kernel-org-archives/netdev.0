From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 7/7] netfilter: bridge: Use __in6_dev_get rather than in6_dev_get in br_validate_ipv6
Date: Wed,  8 Jul 2015 11:48:20 +0200
Message-ID: <1436348900-13130-8-git-send-email-pablo@netfilter.org>
References: <1436348900-13130-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1436348900-13130-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julien Grall <julien.grall@citrix.com>

The commit efb6de9b4ba0092b2c55f6a52d16294a8a698edd "netfilter: bridge:
forward IPv6 fragmented packets" introduced a new function
br_validate_ipv6 which take a reference on the inet6 device. Although,
the reference is not released at the end.

This will result to the impossibility to destroy any netdevice using
ipv6 and bridge.

It's possible to directly retrieve the inet6 device without taking a
reference as all netfilter hooks are protected by rcu_read_lock via
nf_hook_slow.

Spotted while trying to destroy a Xen guest on the upstream Linux:
"unregister_netdevice: waiting for vif1.0 to become free. Usage count = 1"

Signed-off-by: Julien Grall <julien.grall@citrix.com>
Cc: Bernhard Thaler <bernhard.thaler@wvnet.at>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: fw@strlen.de
Cc: ian.campbell@citrix.com
Cc: wei.liu2@citrix.com
Cc: Bob Liu <bob.liu@oracle.com>
Acked-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter_ipv6.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_netfilter_ipv6.c b/net/bridge/br_netfilter_ipv6.c
index 6d12d26..13b7d1e 100644
--- a/net/bridge/br_netfilter_ipv6.c
+++ b/net/bridge/br_netfilter_ipv6.c
@@ -104,7 +104,7 @@ int br_validate_ipv6(struct sk_buff *skb)
 {
 	const struct ipv6hdr *hdr;
 	struct net_device *dev = skb->dev;
-	struct inet6_dev *idev = in6_dev_get(skb->dev);
+	struct inet6_dev *idev = __in6_dev_get(skb->dev);
 	u32 pkt_len;
 	u8 ip6h_len = sizeof(struct ipv6hdr);
 
-- 
1.7.10.4

