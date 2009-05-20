From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] af_packet: Teach to listen for multiple unicast addresses.
Date: Tue, 19 May 2009 21:27:17 -0700
Message-ID: <m163fwflga.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:42733 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725AbZETE1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 00:27:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The the PACKET_ADD_MEMBERSHIP and the PACKET_DROP_MEMBERSHIP setsockopt
calls for af_packet already has all of the infrastructure needed to subscribe
to multiple mac addresses.  All that is missing is a flag to say that
the address we want to listen on is a unicast address.

So introduce PACKET_MR_UNICAST and wire it up to dev_unicast_add and
dev_unicast_delete.

Additionally I noticed that errors from dev_mc_add were not propagated
from packet_dev_mc so fix that.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 include/linux/if_packet.h |    1 +
 net/packet/af_packet.c    |   10 ++++++++--
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index 18db066..ed26d4f 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -135,5 +135,6 @@ struct packet_mreq
 #define PACKET_MR_MULTICAST	0
 #define PACKET_MR_PROMISC	1
 #define PACKET_MR_ALLMULTI	2
+#define PACKET_MR_UNICAST	3
 
 #endif
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 1fc4a78..2abaf83 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1254,9 +1254,9 @@ static int packet_dev_mc(struct net_device *dev, struct packet_mclist *i,
 	switch (i->type) {
 	case PACKET_MR_MULTICAST:
 		if (what > 0)
-			dev_mc_add(dev, i->addr, i->alen, 0);
+			return dev_mc_add(dev, i->addr, i->alen, 0);
 		else
-			dev_mc_delete(dev, i->addr, i->alen, 0);
+			return dev_mc_delete(dev, i->addr, i->alen, 0);
 		break;
 	case PACKET_MR_PROMISC:
 		return dev_set_promiscuity(dev, what);
@@ -1264,6 +1264,12 @@ static int packet_dev_mc(struct net_device *dev, struct packet_mclist *i,
 	case PACKET_MR_ALLMULTI:
 		return dev_set_allmulti(dev, what);
 		break;
+	case PACKET_MR_UNICAST:
+		if (what > 0)
+			return dev_unicast_add(dev, i->addr, i->alen);
+		else
+			return dev_unicast_delete(dev, i->addr, i->alen);
+		break;
 	default:;
 	}
 	return 0;
-- 
1.6.0.6

