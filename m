From: David Miller <davem@davemloft.net>
Subject: [PATCH]: ipv6: skb_dst() can be NULL in ipv6_hop_jumbo().
Date: Wed, 13 Jan 2010 17:40:49 -0800 (PST)
Message-ID: <20100113.174049.09394637.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, stable@kernel.org, eugene@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58091
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753932Ab0ANBkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 20:40:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This fixes CERT-FI FICORA #341748

Discovered by Olli Jarva and Tuomo Untinen from the CROSS
project at Codenomicon Ltd.

Just like in CVE-2007-4567, we can't rely upon skb_dst() being
non-NULL at this point.  We fixed that in commit
e76b2b2567b83448c2ee85a896433b96150c92e6 ("[IPV6]: Do no rely on
skb->dst before it is assigned.")

However commit 483a47d2fe794328d29950fe00ce26dd405d9437 ("ipv6: added
net argument to IP6_INC_STATS_BH") put a new version of the same bug
into this function.

Complicating analysis further, this bug can only trigger when network
namespaces are enabled in the build.  When namespaces are turned off,
the dev_net() does not evaluate it's argument, so the dereference
would not occur.

So, for a long time, namespaces couldn't be turned on unless SYSFS was
disabled.  Therefore, this code has largely been disabled except by
people turning it on explicitly for namespace development.

With help from Eugene Teo <eugene@redhat.com>

Signed-off-by: David S. Miller <davem@davemloft.net>
CC: stable <stable@kernel.org>
---
 net/ipv6/exthdrs.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index df159ff..4bac362 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -559,6 +559,11 @@ static inline struct inet6_dev *ipv6_skb_idev(struct sk_buff *skb)
 	return skb_dst(skb) ? ip6_dst_idev(skb_dst(skb)) : __in6_dev_get(skb->dev);
 }
 
+static inline struct net *ipv6_skb_net(struct sk_buff *skb)
+{
+	return skb_dst(skb) ? dev_net(skb_dst(skb)->dev) : dev_net(skb->dev);
+}
+
 /* Router Alert as of RFC 2711 */
 
 static int ipv6_hop_ra(struct sk_buff *skb, int optoff)
@@ -580,8 +585,8 @@ static int ipv6_hop_ra(struct sk_buff *skb, int optoff)
 static int ipv6_hop_jumbo(struct sk_buff *skb, int optoff)
 {
 	const unsigned char *nh = skb_network_header(skb);
+	struct net *net = ipv6_skb_net(skb);
 	u32 pkt_len;
-	struct net *net = dev_net(skb_dst(skb)->dev);
 
 	if (nh[optoff + 1] != 4 || (optoff & 3) != 2) {
 		LIMIT_NETDEBUG(KERN_DEBUG "ipv6_hop_jumbo: wrong jumbo opt length/alignment %d\n",
-- 
1.6.5

