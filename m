From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH RFC net-next v2 2/4] net: introduce skb_sctp_csum_help
Date: Tue, 28 Feb 2017 11:32:46 +0100
Message-ID: <139092e2e728bd3fba48f32d5e10b1bf47be86d6.1488199633.git.dcaratti@redhat.com>
References: <1488202783.2713.67.camel@redhat.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "linux-sctp @ vger . kernel . org" <linux-sctp@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>,
        Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60994 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751726AbdB1Kf3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Feb 2017 05:35:29 -0500
In-Reply-To: <1488202783.2713.67.camel@redhat.com>
In-Reply-To: <56fcd0848eae2b0693797e09500892659323546c.1488199633.git.dcaratti@redhat.com>
References: <56fcd0848eae2b0693797e09500892659323546c.1488199633.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_sctp_csum_help is like skb_checksum_help, but it is designed for
checksumming SCTP packets using crc32c (see RFC3309), provided that
sctp.ko has been loaded before. In case sctp.ko is not loaded, invoking
skb_sctp_csum_help on a skb results in the following printout:

sk_buff: attempt to compute crc32c without sctp.ko

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 include/linux/netdevice.h |  1 +
 include/linux/skbuff.h    |  3 ++-
 net/core/dev.c            | 40 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 43 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f40f0ab..8c34735 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3918,6 +3918,7 @@ void netdev_rss_key_fill(void *buffer, size_t len);
 
 int dev_get_nest_level(struct net_device *dev);
 int skb_checksum_help(struct sk_buff *skb);
+int skb_sctp_csum_help(struct sk_buff *skb);
 struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 				  netdev_features_t features, bool tx_path);
 struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index cab9a32..0671131 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -192,7 +192,8 @@
  *     accordingly. Note the there is no indication in the skbuff that the
  *     CHECKSUM_PARTIAL refers to an SCTP checksum, a driver that supports
  *     both IP checksum offload and SCTP CRC offload must verify which offload
- *     is configured for a packet presumably by inspecting packet headers.
+ *     is configured for a packet presumably by inspecting packet headers; in
+ *     case, skb_sctp_csum_help is provided to compute CRC on SCTP packets.
  *
  *   NETIF_F_FCOE_CRC - This feature indicates that a device is capable of
  *     offloading the FCOE CRC in a packet. To perform this offload the stack
diff --git a/net/core/dev.c b/net/core/dev.c
index 05d19c6..b9fb843 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -140,6 +140,7 @@
 #include <linux/hrtimer.h>
 #include <linux/netfilter_ingress.h>
 #include <linux/crash_dump.h>
+#include <linux/sctp.h>
 
 #include "net-sysfs.h"
 
@@ -2578,6 +2579,45 @@ int skb_checksum_help(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(skb_checksum_help);
 
+int skb_sctp_csum_help(struct sk_buff *skb)
+{
+	__le32 crc32c_csum;
+	int ret = 0, offset;
+
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		goto out;
+
+	if (unlikely(skb_is_gso(skb)))
+		goto out;
+
+	/* Before computing a checksum, we should make sure no frag could
+	 * be modified by an external entity : checksum could be wrong.
+	 */
+	if (unlikely(skb_has_shared_frag(skb))) {
+		ret = __skb_linearize(skb);
+		if (ret)
+			goto out;
+	}
+
+	offset = skb_checksum_start_offset(skb);
+	crc32c_csum = cpu_to_le32(~__skb_checksum(skb, offset,
+						  skb->len - offset, ~(__u32)0,
+						  sctp_csum_stub));
+	offset += offsetof(struct sctphdr, checksum);
+	BUG_ON(offset >= skb_headlen(skb));
+
+	if (skb_cloned(skb) &&
+	    !skb_clone_writable(skb, offset + sizeof(__le32))) {
+		ret = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+		if (ret)
+			goto out;
+	}
+	*(__le32 *)(skb->data + offset) = crc32c_csum;
+	skb->ip_summed = CHECKSUM_NONE;
+out:
+	return ret;
+}
+
 __be16 skb_network_protocol(struct sk_buff *skb, int *depth)
 {
 	__be16 type = skb->protocol;
-- 
2.7.4
