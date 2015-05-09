From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/15] net: change name of flow_dissector header to match the .c file name
Date: Sat,  9 May 2015 15:10:24 +0200
Message-ID: <1431177038-11555-2-git-send-email-jiri@resnulli.us>
References: <1431177038-11555-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, therbert@google.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:33867 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbbEINKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 09:10:46 -0400
Received: by wgic8 with SMTP id c8so66890172wgi.1
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 06:10:45 -0700 (PDT)
In-Reply-To: <1431177038-11555-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add couple of empty lines on the way.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_main.c             |  2 +-
 drivers/net/ethernet/cisco/enic/enic_clsf.c |  2 +-
 include/linux/skbuff.h                      |  2 +-
 include/net/flow_dissector.h                | 68 +++++++++++++++++++++++++++++
 include/net/flow_keys.h                     | 61 --------------------------
 include/net/ip.h                            |  2 +-
 include/net/ipv6.h                          |  2 +-
 net/core/flow_dissector.c                   |  2 +-
 net/sched/cls_flow.c                        |  2 +-
 net/sched/sch_choke.c                       |  2 +-
 10 files changed, 76 insertions(+), 69 deletions(-)
 create mode 100644 include/net/flow_dissector.h
 delete mode 100644 include/net/flow_keys.h

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d5fe5d5..af0dcbb 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -76,7 +76,7 @@
 #include <net/netns/generic.h>
 #include <net/pkt_sched.h>
 #include <linux/rculist.h>
-#include <net/flow_keys.h>
+#include <net/flow_dissector.h>
 #include <net/switchdev.h>
 #include <net/bonding.h>
 #include <net/bond_3ad.h>
diff --git a/drivers/net/ethernet/cisco/enic/enic_clsf.c b/drivers/net/ethernet/cisco/enic/enic_clsf.c
index 0be6850..380f049 100644
--- a/drivers/net/ethernet/cisco/enic/enic_clsf.c
+++ b/drivers/net/ethernet/cisco/enic/enic_clsf.c
@@ -5,7 +5,7 @@
 #include <linux/in.h>
 #include <linux/types.h>
 #include <linux/skbuff.h>
-#include <net/flow_keys.h>
+#include <net/flow_dissector.h>
 #include "enic_res.h"
 #include "enic_clsf.h"
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9c2f793..6cc1096 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -34,7 +34,7 @@
 #include <linux/dma-mapping.h>
 #include <linux/netdev_features.h>
 #include <linux/sched.h>
-#include <net/flow_keys.h>
+#include <net/flow_dissector.h>
 
 /* A. Checksumming of received packets by device.
  *
diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
new file mode 100644
index 0000000..5e99a7b
--- /dev/null
+++ b/include/net/flow_dissector.h
@@ -0,0 +1,68 @@
+#ifndef _NET_FLOW_DISSECTOR_H
+#define _NET_FLOW_DISSECTOR_H
+
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
+struct flow_keys {
+	/* (src,dst) must be grouped, in the same way than in IP header */
+	__be32 src;
+	__be32 dst;
+	union {
+		__be32 ports;
+		__be16 port16[2];
+	};
+	u16	thoff;
+	__be16	n_proto;
+	u8	ip_proto;
+};
+
+bool __skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow,
+			void *data, __be16 proto, int nhoff, int hlen);
+
+static inline bool skb_flow_dissect(const struct sk_buff *skb,
+				    struct flow_keys *flow)
+{
+	return __skb_flow_dissect(skb, flow, NULL, 0, 0, 0);
+}
+
+__be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
+			    void *data, int hlen_proto);
+
+static inline __be32 skb_flow_get_ports(const struct sk_buff *skb,
+					int thoff, u8 ip_proto)
+{
+	return __skb_flow_get_ports(skb, thoff, ip_proto, NULL, 0);
+}
+
+u32 flow_hash_from_keys(struct flow_keys *keys);
+
+unsigned int flow_get_hlen(const unsigned char *data, unsigned int max_len,
+			   __be16 protocol);
+
+/* struct flow_keys_digest:
+ *
+ * This structure is used to hold a digest of the full flow keys. This is a
+ * larger "hash" of a flow to allow definitively matching specific flows where
+ * the 32 bit skb->hash is not large enough. The size is limited to 16 bytes so
+ * that it can by used in CB of skb (see sch_choke for an example).
+ */
+#define FLOW_KEYS_DIGEST_LEN	16
+struct flow_keys_digest {
+	u8	data[FLOW_KEYS_DIGEST_LEN];
+};
+
+void make_flow_keys_digest(struct flow_keys_digest *digest,
+			   const struct flow_keys *flow);
+
+#endif
diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
deleted file mode 100644
index 6d6ef62..0000000
--- a/include/net/flow_keys.h
+++ /dev/null
@@ -1,61 +0,0 @@
-#ifndef _NET_FLOW_KEYS_H
-#define _NET_FLOW_KEYS_H
-
-/* struct flow_keys:
- *	@src: source ip address in case of IPv4
- *	      For IPv6 it contains 32bit hash of src address
- *	@dst: destination ip address in case of IPv4
- *	      For IPv6 it contains 32bit hash of dst address
- *	@ports: port numbers of Transport header
- *		port16[0]: src port number
- *		port16[1]: dst port number
- *	@thoff: Transport header offset
- *	@n_proto: Network header protocol (eg. IPv4/IPv6)
- *	@ip_proto: Transport header protocol (eg. TCP/UDP)
- * All the members, except thoff, are in network byte order.
- */
-struct flow_keys {
-	/* (src,dst) must be grouped, in the same way than in IP header */
-	__be32 src;
-	__be32 dst;
-	union {
-		__be32 ports;
-		__be16 port16[2];
-	};
-	u16	thoff;
-	__be16	n_proto;
-	u8	ip_proto;
-};
-
-bool __skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow,
-			void *data, __be16 proto, int nhoff, int hlen);
-static inline bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow)
-{
-	return __skb_flow_dissect(skb, flow, NULL, 0, 0, 0);
-}
-__be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
-			    void *data, int hlen_proto);
-static inline __be32 skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto)
-{
-	return __skb_flow_get_ports(skb, thoff, ip_proto, NULL, 0);
-}
-u32 flow_hash_from_keys(struct flow_keys *keys);
-unsigned int flow_get_hlen(const unsigned char *data, unsigned int max_len,
-			   __be16 protocol);
-
-/* struct flow_keys_digest:
- *
- * This structure is used to hold a digest of the full flow keys. This is a
- * larger "hash" of a flow to allow definitively matching specific flows where
- * the 32 bit skb->hash is not large enough. The size is limited to 16 bytes so
- * that it can by used in CB of skb (see sch_choke for an example).
- */
-#define FLOW_KEYS_DIGEST_LEN	16
-struct flow_keys_digest {
-	u8	data[FLOW_KEYS_DIGEST_LEN];
-};
-
-void make_flow_keys_digest(struct flow_keys_digest *digest,
-			   const struct flow_keys *flow);
-
-#endif
diff --git a/include/net/ip.h b/include/net/ip.h
index d14af7e..562eb65 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -31,7 +31,7 @@
 #include <net/route.h>
 #include <net/snmp.h>
 #include <net/flow.h>
-#include <net/flow_keys.h>
+#include <net/flow_dissector.h>
 
 struct sock;
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 53d25ef..9932b86 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -19,7 +19,7 @@
 #include <net/if_inet6.h>
 #include <net/ndisc.h>
 #include <net/flow.h>
-#include <net/flow_keys.h>
+#include <net/flow_dissector.h>
 #include <net/snmp.h>
 
 #define SIN6_LEN_RFC2133	24
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index d3acc4d..eaa86b5 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -12,7 +12,7 @@
 #include <linux/if_tunnel.h>
 #include <linux/if_pppox.h>
 #include <linux/ppp_defs.h>
-#include <net/flow_keys.h>
+#include <net/flow_dissector.h>
 #include <scsi/fc/fc_fcoe.h>
 
 /* copy saddr & daddr, possibly using 64bit load/store
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index a620c4e..4c5a922 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -26,7 +26,7 @@
 #include <net/pkt_cls.h>
 #include <net/ip.h>
 #include <net/route.h>
-#include <net/flow_keys.h>
+#include <net/flow_dissector.h>
 
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 #include <net/netfilter/nf_conntrack.h>
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index dfe3da7..2624e99 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -18,7 +18,7 @@
 #include <net/pkt_sched.h>
 #include <net/inet_ecn.h>
 #include <net/red.h>
-#include <net/flow_keys.h>
+#include <net/flow_dissector.h>
 
 /*
    CHOKe stateless AQM for fair bandwidth allocation
-- 
1.9.3
