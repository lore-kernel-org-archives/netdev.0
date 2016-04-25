From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH] net: fix net_gso_ok for new GSO types.
Date: Mon, 25 Apr 2016 15:13:17 -0300
Message-ID: <3d1dadb911fa4ebacf1ca5ad298a5c696ed261a6.1461607119.git.marcelo.leitner@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51052 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932905AbcDYSNo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 14:13:44 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2E1F062644
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 18:13:44 +0000 (UTC)
Received: from localhost.localdomain.com (vpn1-6-40.gru2.redhat.com [10.97.6.40])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u3PIDg6Q012281
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 14:13:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix casting in net_gso_ok. Otherwise the shift on
gso_type << NETIF_F_GSO_SHIFT may hit the 32th bit and make it look like
a INT_MIN, which is then promoted from signed to uint64 which is
0xffffffff80000000, resulting in wrong behavior when it is and'ed with
the feature itself, as in:

This test app:
#include <stdio.h>
#include <stdint.h>

int main(int argc, char **argv)
{
	uint64_t feature1;
	uint64_t feature2;
	int gso_type = 1 << 15;

	feature1 = gso_type << 16;
	feature2 = (uint64_t)gso_type << 16;
	printf("%lx %lx\n", feature1, feature2);

	return 0;
}

Gives:
ffffffff80000000 80000000

So that this:
   return (features & feature) == feature;
Actually works on more bits than expected and invalid ones.

Fix is to promote it earlier.

Issue noted while rebasing SCTP GSO patch but posting separetely as
someone else may experience this meanwhile.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---

Dave I couldn't find a good way to indent this that wouldn't be uglier
than a bit long line, but let me know if you prefer otherwise.

 include/linux/netdevice.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1f6d5db471a24f7f23bbe425c359d64adb5dfd67..13ee05f71e3d74c9d2feef6c371547a4b2f82879 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3991,7 +3991,7 @@ netdev_features_t netif_skb_features(struct sk_buff *skb);
 
 static inline bool net_gso_ok(netdev_features_t features, int gso_type)
 {
-	netdev_features_t feature = gso_type << NETIF_F_GSO_SHIFT;
+	netdev_features_t feature = (netdev_features_t)gso_type << NETIF_F_GSO_SHIFT;
 
 	/* check flags correspondence */
 	BUILD_BUG_ON(SKB_GSO_TCPV4   != (NETIF_F_TSO >> NETIF_F_GSO_SHIFT));
-- 
2.5.0
