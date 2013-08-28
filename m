From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/3] net: packet: add randomized fanout scheduler
Date: Wed, 28 Aug 2013 22:13:09 +0200
Message-ID: <1377720791-15844-2-git-send-email-dborkman@redhat.com>
References: <1377720791-15844-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30319 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755155Ab3H1UNQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 16:13:16 -0400
In-Reply-To: <1377720791-15844-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently allow for different fanout scheduling policies in pf_packet
such as scheduling by skb's rxhash, round-robin, by cpu, and rollover.
Also allow for a random, equidistributed selection of the socket from the
fanout process group.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/uapi/linux/if_packet.h |  1 +
 net/packet/af_packet.c         | 13 ++++++++++++-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
index b950c02..dbf0666 100644
--- a/include/uapi/linux/if_packet.h
+++ b/include/uapi/linux/if_packet.h
@@ -56,6 +56,7 @@ struct sockaddr_ll {
 #define PACKET_FANOUT_LB		1
 #define PACKET_FANOUT_CPU		2
 #define PACKET_FANOUT_ROLLOVER		3
+#define PACKET_FANOUT_RND		4
 #define PACKET_FANOUT_FLAG_ROLLOVER	0x1000
 #define PACKET_FANOUT_FLAG_DEFRAG	0x8000
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 6c53dd9..91596f5 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -88,7 +88,7 @@
 #include <linux/virtio_net.h>
 #include <linux/errqueue.h>
 #include <linux/net_tstamp.h>
-
+#include <linux/reciprocal_div.h>
 #ifdef CONFIG_INET
 #include <net/inet_common.h>
 #endif
@@ -1158,6 +1158,13 @@ static unsigned int fanout_demux_cpu(struct packet_fanout *f,
 	return smp_processor_id() % num;
 }
 
+static unsigned int fanout_demux_rnd(struct packet_fanout *f,
+				     struct sk_buff *skb,
+				     unsigned int num)
+{
+	return reciprocal_divide(prandom_u32(), num);
+}
+
 static unsigned int fanout_demux_rollover(struct packet_fanout *f,
 					  struct sk_buff *skb,
 					  unsigned int idx, unsigned int skip,
@@ -1215,6 +1222,9 @@ static int packet_rcv_fanout(struct sk_buff *skb, struct net_device *dev,
 	case PACKET_FANOUT_CPU:
 		idx = fanout_demux_cpu(f, skb, num);
 		break;
+	case PACKET_FANOUT_RND:
+		idx = fanout_demux_rnd(f, skb, num);
+		break;
 	case PACKET_FANOUT_ROLLOVER:
 		idx = fanout_demux_rollover(f, skb, 0, (unsigned int) -1, num);
 		break;
@@ -1284,6 +1294,7 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 	case PACKET_FANOUT_HASH:
 	case PACKET_FANOUT_LB:
 	case PACKET_FANOUT_CPU:
+	case PACKET_FANOUT_RND:
 		break;
 	default:
 		return -EINVAL;
-- 
1.7.11.7
