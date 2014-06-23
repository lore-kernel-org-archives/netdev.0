From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v3 1/8] flow_keys: Record IP layer protocol in skb_flow_dissect()
Date: Mon, 23 Jun 2014 16:07:58 +0530
Message-ID: <1403519885-4908-2-git-send-email-_govind@gmx.com>
References: <1403519885-4908-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:62766 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752340AbaFWKjT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2014 06:39:19 -0400
In-Reply-To: <1403519885-4908-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_flow_dissect() dissects only transport header type in ip_proto. It dose not
give any information about IPv4 or IPv6.

This patch adds new member, n_proto, to struct flow_keys. Which records the
IP layer type. i.e IPv4 or IPv6.

This can be used in netdev->ndo_rx_flow_steer driver function to dissect flow.

Adding new member to flow_keys increases the struct size by around 4 bytes.
This causes BUILD_BUG_ON(sizeof(qcb->data) < sz); to fail in
qdisc_cb_private_validate()

So increase data size by 4

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 include/net/flow_keys.h   | 14 ++++++++++++++
 include/net/sch_generic.h |  2 +-
 net/core/flow_dissector.c |  1 +
 3 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
index 7e64bd8..fbefdca 100644
--- a/include/net/flow_keys.h
+++ b/include/net/flow_keys.h
@@ -1,6 +1,19 @@
 #ifndef _NET_FLOW_KEYS_H
 #define _NET_FLOW_KEYS_H
 
+/* struct flow_keys:
+ *	@src: source ip address in case of IPv4
+ *	      For IPv6 it contains 32bit hash of src address
+ *	@dst: destination ip address in case of IPv4
+ *	      For IPv6 it contains 32bit hash of dst address
+ *	@ports: port numbers of Transport header
+ *		port16[0]: src port number
+ *		port16[1]: dst port number
+ *	@thoff: Transport header offset
+ *	@n_proto: Network header protocol (eg. IPv4/IPv6)
+ *	@ip_proto: Transport header protocol (eg. TCP/UDP)
+ * All the members, except thoff, are in network byte order.
+ */
 struct flow_keys {
 	/* (src,dst) must be grouped, in the same way than in IP header */
 	__be32 src;
@@ -10,6 +23,7 @@ struct flow_keys {
 		__be16 port16[2];
 	};
 	u16 thoff;
+	u16 n_proto;
 	u8 ip_proto;
 };
 
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 624f985..a3cfb8e 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -231,7 +231,7 @@ struct qdisc_skb_cb {
 	unsigned int		pkt_len;
 	u16			slave_dev_queue_mapping;
 	u16			_pad;
-	unsigned char		data[20];
+	unsigned char		data[24];
 };
 
 static inline void qdisc_cb_private_validate(const struct sk_buff *skb, int sz)
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 107ed12..c2b53c1 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -175,6 +175,7 @@ ipv6:
 		break;
 	}
 
+	flow->n_proto = proto;
 	flow->ip_proto = ip_proto;
 	flow->ports = skb_flow_get_ports(skb, nhoff, ip_proto);
 	flow->thoff = (u16) nhoff;
-- 
2.0.0
