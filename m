From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 09/25] netns ct: get proper netns from netdevice
Date: Sun, 22 Jun 2008 05:08:21 +0400
Message-ID: <20080622010821.GJ5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Get netns from skb->dev on input, from skb->dst->dev on output to know
where to create or search for conntrack.

Is there some documentation re which device accessible from skb is valid
at which point?

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/netfilter/nf_conntrack_core.c |   12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -29,7 +29,7 @@
 #include <linux/netdevice.h>
 #include <linux/socket.h>
 #include <linux/mm.h>
-
+#include <net/dst.h>
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_l3proto.h>
 #include <net/netfilter/nf_conntrack_l4proto.h>
@@ -615,6 +615,8 @@ resolve_normal_ct(struct sk_buff *skb,
 		  int *set_reply,
 		  enum ip_conntrack_info *ctinfo)
 {
+	struct net_device *dev;
+	struct net *net;
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
@@ -626,10 +628,14 @@ resolve_normal_ct(struct sk_buff *skb,
 		return NULL;
 	}
 
+	dev = skb->dev;
+	if (!dev)
+		dev = skb->dst->dev;
+	net = dev_net(dev);
 	/* look for tuple match */
-	h = nf_conntrack_find_get(&init_net, &tuple);
+	h = nf_conntrack_find_get(net, &tuple);
 	if (!h) {
-		h = init_conntrack(&init_net, &tuple, l3proto, l4proto, skb, dataoff);
+		h = init_conntrack(net, &tuple, l3proto, l4proto, skb, dataoff);
 		if (!h)
 			return NULL;
 		if (IS_ERR(h))
-- 
1.5.4.5


