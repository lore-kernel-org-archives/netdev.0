From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qeth: Move away from using neighbour entries in
 qeth_l3_fill_header()
Date: Thu, 02 Feb 2012 14:36:55 -0500 (EST)
Message-ID: <20120202.143655.414409800134970100.davem@davemloft.net>
References: <OF3D0DFDEF.D4DC17E5-ONC1257998.00496C84-C1257998.0049A282@de.ibm.com>
	<1328190291.15969.3.camel@br9gv9yg.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ursula.braun@de.ibm.com, netdev@vger.kernel.org,
	elelueck@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752986Ab2BBThj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 14:37:39 -0500
In-Reply-To: <1328190291.15969.3.camel@br9gv9yg.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Thu, 02 Feb 2012 14:44:51 +0100

> I have tested your qeth patch on top of net-next with ipv4 and ipv6
> traffic successfully. I just had to add includes for net/route.h and
> net/ip6_fib.h.

Thanks a lot, here is the final version I checked in:

--------------------
qeth: Move away from using neighbour entries in qeth_l3_fill_header()

We've moving to a model where dst_entry objects to not have
a reference to the associated neighbour entry, instead such
neighbours must be looked up on-demand.

Here in qeth_l3_fill_header() it's actually much simpler to
use the information in the route itself.  The code is
already conditionalized upon protocol type.

Signed-off-by: David S. Miller <davem@davemloft.net>
Tested-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c |   35 ++++++++++++++++-------------------
 1 files changed, 16 insertions(+), 19 deletions(-)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 9648e4e..25cd379 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -28,6 +28,8 @@
 
 #include <net/ip.h>
 #include <net/arp.h>
+#include <net/route.h>
+#include <net/ip6_fib.h>
 #include <net/ip6_checksum.h>
 #include <net/iucv/af_iucv.h>
 
@@ -2832,7 +2834,6 @@ static void qeth_l3_fill_af_iucv_hdr(struct qeth_card *card,
 static void qeth_l3_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 		struct sk_buff *skb, int ipv, int cast_type)
 {
-	struct neighbour *n = NULL;
 	struct dst_entry *dst;
 
 	memset(hdr, 0, sizeof(struct qeth_hdr));
@@ -2855,33 +2856,29 @@ static void qeth_l3_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 
 	rcu_read_lock();
 	dst = skb_dst(skb);
-	if (dst)
-		n = dst_get_neighbour_noref(dst);
 	if (ipv == 4) {
+		struct rtable *rt = (struct rtable *) dst;
+		__be32 *pkey = &ip_hdr(skb)->daddr;
+
+		if (rt->rt_gateway)
+			pkey = &rt->rt_gateway;
+
 		/* IPv4 */
 		hdr->hdr.l3.flags = qeth_l3_get_qeth_hdr_flags4(cast_type);
 		memset(hdr->hdr.l3.dest_addr, 0, 12);
-		if (n) {
-			*((u32 *) (&hdr->hdr.l3.dest_addr[12])) =
-			    *((u32 *) n->primary_key);
-		} else {
-			/* fill in destination address used in ip header */
-			*((u32 *) (&hdr->hdr.l3.dest_addr[12])) =
-							ip_hdr(skb)->daddr;
-		}
+		*((__be32 *) (&hdr->hdr.l3.dest_addr[12])) = *pkey;
 	} else if (ipv == 6) {
+		struct rt6_info *rt = (struct rt6_info *) dst;
+		struct in6_addr *pkey = &ipv6_hdr(skb)->daddr;
+
+		if (!ipv6_addr_any(&rt->rt6i_gateway))
+			pkey = &rt->rt6i_gateway;
+
 		/* IPv6 */
 		hdr->hdr.l3.flags = qeth_l3_get_qeth_hdr_flags6(cast_type);
 		if (card->info.type == QETH_CARD_TYPE_IQD)
 			hdr->hdr.l3.flags &= ~QETH_HDR_PASSTHRU;
-		if (n) {
-			memcpy(hdr->hdr.l3.dest_addr,
-			       n->primary_key, 16);
-		} else {
-			/* fill in destination address used in ip header */
-			memcpy(hdr->hdr.l3.dest_addr,
-			       &ipv6_hdr(skb)->daddr, 16);
-		}
+		memcpy(hdr->hdr.l3.dest_addr, pkey, 16);
 	} else {
 		/* passthrough */
 		if ((skb->dev->type == ARPHRD_IEEE802_TR) &&
-- 
1.7.7.6
