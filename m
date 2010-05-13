From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH 2/3] net: fix conflict between null_or_orig and null_or_bond
Date: Thu, 13 May 2010 00:31:11 -0700
Message-ID: <20100513073111.3528.19949.stgit@jf-dev2-dcblab>
References: <20100513073106.3528.45412.stgit@jf-dev2-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com
To: andy@greyhouse.net, fubar@us.ibm.com, nhorman@tuxdriver.com,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:12944 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756207Ab0EMHak (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 03:30:40 -0400
In-Reply-To: <20100513073106.3528.45412.stgit@jf-dev2-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a skb is received on an inactive bond that does not meet
the special cases checked for by skb_bond_should_drop it should
only be delivered to exact matches as the comment in
netif_receive_skb() says.

However because null_or_bond could also be null this is not
always true.  This patch renames null_or_bond to orig_or_bond
and initializes it to orig_dev.  This keeps the intent of
null_or_bond to pass frames received on VLAN interfaces stacked
on bonding interfaces without invalidating the statement for
null_or_orig.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/core/dev.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 32611c8..3dc691d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2784,7 +2784,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	struct net_device *orig_dev;
 	struct net_device *master;
 	struct net_device *null_or_orig;
-	struct net_device *null_or_bond;
+	struct net_device *orig_or_bond;
 	int ret = NET_RX_DROP;
 	__be16 type;
 
@@ -2857,10 +2857,10 @@ ncls:
 	 * device that may have registered for a specific ptype.  The
 	 * handler may have to adjust skb->dev and orig_dev.
 	 */
-	null_or_bond = NULL;
+	orig_or_bond = orig_dev;
 	if ((skb->dev->priv_flags & IFF_802_1Q_VLAN) &&
 	    (vlan_dev_real_dev(skb->dev)->priv_flags & IFF_BONDING)) {
-		null_or_bond = vlan_dev_real_dev(skb->dev);
+		orig_or_bond = vlan_dev_real_dev(skb->dev);
 	}
 
 	type = skb->protocol;
@@ -2868,7 +2868,7 @@ ncls:
 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
 		if (ptype->type == type && (ptype->dev == null_or_orig ||
 		     ptype->dev == skb->dev || ptype->dev == orig_dev ||
-		     ptype->dev == null_or_bond)) {
+		     ptype->dev == orig_or_bond)) {
 			if (pt_prev)
 				ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = ptype;

