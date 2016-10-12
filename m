From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 2/5] udp: UDP flow dissector
Date: Wed, 12 Oct 2016 16:25:44 -0700
Message-ID: <20161012232547.2383961-3-tom@herbertland.com>
References: <20161012232547.2383961-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:54703 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933426AbcJLXZ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 19:25:57 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9CNNhc9004029
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 16:25:56 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 261raxtbqd-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 16:25:56 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 396548fe90d311e68b800002c99293a0-797faa50 for <netdev@vger.kernel.org>;        Wed,
 12 Oct 2016 16:25:55 -0700
In-Reply-To: <20161012232547.2383961-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add infrastructure for performing per protocol flow dissection and
support flow dissection in UDP payloads (e.g. flow dissection on a
UDP encapsulated tunnel.

The per protocol flow dissector is called by flow_dissect function
in the offload_callbacks of a protocol. The arguments of this function
include the necessary information to do flow dissection as derived
from __skb_flow_dissect which is where the callback is intended to be
called from. There are return codes from the callback in the form
FLOW_DIS_RET_* that indicate the result. FLOW_DIS_RET_IPPROTO
means that the payload should be dissected as an IP proto, the
specific protocol is returned in a pointer argument. Likewise,
FLOW_DIS_RET_PROTO indicate the payload should be processed as
an ethertype which is returned in another argument.

A case for IPPROTO_UDP was added to __skb_flow_dissect. Since
UDP flow dissector involves a relatively expensive socket lookup
there is a static key check first to see if there are any sockets
that have enabled flow dissection. After this check, the offload
ops for UDP for either IPv4 or IPv6 is considered. If the
flow_dissect function is it is called. Upon return the result
is processed (pass, out_bad, process as IP protocol, process
as ethertype). Note that if the result indicates a protocol must
be processed it is expected that nhoff has been updated to the
encapsulated protocol header.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/netdevice.h    |  5 +++
 include/linux/udp.h          |  7 +++++
 include/net/flow_dissector.h |  8 +++++
 include/net/udp.h            |  4 +++
 net/core/flow_dissector.c    | 73 ++++++++++++++++++++++++++++++++++++++++++--
 net/ipv4/udp.c               |  3 ++
 6 files changed, 98 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 136ae6bb..51b43fb1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2199,6 +2199,11 @@ struct offload_callbacks {
 	struct sk_buff		**(*gro_receive)(struct sk_buff **head,
 						 struct sk_buff *skb);
 	int			(*gro_complete)(struct sk_buff *skb, int nhoff);
+	int			(*flow_dissect)(const struct sk_buff *skb,
+		void *data, int hlen,
+		int *nhoff, u8 *ip_proto,
+		__be16 *proto,
+		 struct flow_dissector_key_addrs *key_addrs);
 };
 
 struct packet_offload {
diff --git a/include/linux/udp.h b/include/linux/udp.h
index d1fd8cd..608ebf4 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -79,6 +79,13 @@ struct udp_sock {
 	int			(*gro_complete)(struct sock *sk,
 						struct sk_buff *skb,
 						int nhoff);
+
+	/* Flow dissector function for UDP socket */
+	int			(*flow_dissect)(struct sock *sk,
+						const struct sk_buff *skb,
+						void *data, int hlen,
+						int *nhoff, u8 *ip_proto,
+						__be16 *proto);
 };
 
 static inline struct udp_sock *udp_sk(const struct sock *sk)
diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index d953492..9de4904 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -203,4 +203,12 @@ static inline void *skb_flow_dissector_target(struct flow_dissector *flow_dissec
 	return ((char *)target_container) + flow_dissector->offset[key_id];
 }
 
+/* Return codes from per socket flow dissector (e.g. UDP) */
+enum {
+	FLOW_DIS_RET_PASS = 0,
+	FLOW_DIS_RET_BAD,
+	FLOW_DIS_RET_IPPROTO,
+	FLOW_DIS_RET_PROTO,
+};
+
 #endif
diff --git a/include/net/udp.h b/include/net/udp.h
index 717a972..8d364e8 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -360,4 +360,8 @@ void udp_encap_enable(void);
 #if IS_ENABLED(CONFIG_IPV6)
 void udpv6_encap_enable(void);
 #endif
+
+void udp_flow_dissect_enable(void);
+void udp_flow_dissect_disable(void);
+
 #endif	/* _UDP_H */
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 1a7b80f..5a4dfaf 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -8,6 +8,8 @@
 #include <net/ipv6.h>
 #include <net/gre.h>
 #include <net/pptp.h>
+#include <net/protocol.h>
+#include <net/udp.h>
 #include <linux/igmp.h>
 #include <linux/icmp.h>
 #include <linux/sctp.h>
@@ -57,6 +59,20 @@ void skb_flow_dissector_init(struct flow_dissector *flow_dissector,
 }
 EXPORT_SYMBOL(skb_flow_dissector_init);
 
+static struct static_key udp_flow_dissect __read_mostly;
+
+void udp_flow_dissect_enable(void)
+{
+	static_key_slow_inc(&udp_flow_dissect);
+}
+EXPORT_SYMBOL(udp_flow_dissect_enable);
+
+void udp_flow_dissect_disable(void)
+{
+	static_key_slow_dec(&udp_flow_dissect);
+}
+EXPORT_SYMBOL(udp_flow_dissect_disable);
+
 /**
  * __skb_flow_get_ports - extract the upper layer ports and return them
  * @skb: sk_buff to extract the ports from
@@ -115,7 +131,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 {
 	struct flow_dissector_key_control *key_control;
 	struct flow_dissector_key_basic *key_basic;
-	struct flow_dissector_key_addrs *key_addrs;
+	struct flow_dissector_key_addrs *key_addrs = NULL;
 	struct flow_dissector_key_ports *key_ports;
 	struct flow_dissector_key_tags *key_tags;
 	struct flow_dissector_key_vlan *key_vlan;
@@ -245,7 +261,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	}
 	case htons(ETH_P_8021AD):
 	case htons(ETH_P_8021Q): {
-		const struct vlan_hdr *vlan;
+		const struct vlan_hdr *vlan = NULL;
 
 		if (skb_vlan_tag_present(skb))
 			proto = skb->protocol;
@@ -535,6 +551,59 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	case IPPROTO_MPLS:
 		proto = htons(ETH_P_MPLS_UC);
 		goto mpls;
+	case IPPROTO_UDP:
+	{
+		const struct net_offload **offloads;
+		const struct net_offload *ops;
+		int ret;
+
+		if (!static_key_false(&udp_flow_dissect))
+			break;
+
+		if (!key_addrs)
+			break;
+
+		/* See if there is a flow dissector for UDP protocol */
+
+		switch (key_control->addr_type) {
+		case FLOW_DISSECTOR_KEY_IPV4_ADDRS:
+			offloads = inet_offloads;
+			break;
+		case FLOW_DISSECTOR_KEY_IPV6_ADDRS:
+			offloads = inet6_offloads;
+			break;
+		default:
+			goto udp_finish;
+		}
+
+		rcu_read_lock();
+
+		ops = rcu_dereference(offloads[IPPROTO_UDP]);
+
+		if (!ops || !ops->callbacks.flow_dissect) {
+			rcu_read_unlock();
+			break;
+		}
+
+		ret = ops->callbacks.flow_dissect(skb, data, hlen, &nhoff,
+						  &ip_proto, &proto, key_addrs);
+
+		rcu_read_unlock();
+
+		switch (ret) {
+		case FLOW_DIS_RET_IPPROTO:
+			goto ip_proto_again;
+		case FLOW_DIS_RET_PROTO:
+			goto again;
+		case FLOW_DIS_RET_BAD:
+			goto out_bad;
+		case FLOW_DIS_RET_PASS:
+		default:
+			break;
+		}
+udp_finish:
+		break;
+	}
 	default:
 		break;
 	}
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 7f84c51..b4b528e 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1977,6 +1977,9 @@ void udp_destroy_sock(struct sock *sk)
 		if (encap_destroy)
 			encap_destroy(sk);
 	}
+
+	if (up->flow_dissect)
+		udp_flow_dissect_disable();
 }
 
 /*
-- 
2.9.3
