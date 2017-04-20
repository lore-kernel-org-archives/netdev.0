From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH RFC net-next v4 2/7] net: introduce skb_crc32c_csum_help
Date: Thu, 20 Apr 2017 15:38:08 +0200
Message-ID: <2d4895be40590b624bed89df38ea64e560aa2f10.1492692976.git.dcaratti@redhat.com>
References: <CALx6S36rem=OuN_At6qYA=se5cpuYM1N2R8efoaszvo8b8Tz5A@mail.gmail.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36622 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S945050AbdDTNj0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 09:39:26 -0400
In-Reply-To: <CALx6S36rem=OuN_At6qYA=se5cpuYM1N2R8efoaszvo8b8Tz5A@mail.gmail.com>
In-Reply-To: <cover.1492692976.git.dcaratti@redhat.com>
References: <cover.1492692976.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_crc32c_csum_help is like skb_checksum_help, but it is designed for
checksumming SCTP packets using crc32c (see RFC3309), provided that
libcrc32c.ko has been loaded before. In case libcrc32c is not loaded,
invoking skb_crc32c_csum_help on a skb results in one the following
printouts:

warn_crc32c_csum_update: attempt to compute crc32c without libcrc32c.ko
warn_crc32c_csum_combine: attempt to compute crc32c without libcrc32c.ko

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 include/linux/netdevice.h |  1 +
 include/linux/skbuff.h    |  3 ++-
 net/core/dev.c            | 40 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 43 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b0aa089..bf84a67 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3898,6 +3898,7 @@ void netdev_rss_key_fill(void *buffer, size_t len);
 
 int dev_get_nest_level(struct net_device *dev);
 int skb_checksum_help(struct sk_buff *skb);
+int skb_crc32c_csum_help(struct sk_buff *skb);
 struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 				  netdev_features_t features, bool tx_path);
 struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ba3ae21..ec4551b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -193,7 +193,8 @@
  *     accordingly. Note the there is no indication in the skbuff that the
  *     CHECKSUM_PARTIAL refers to an SCTP checksum, a driver that supports
  *     both IP checksum offload and SCTP CRC offload must verify which offload
- *     is configured for a packet presumably by inspecting packet headers.
+ *     is configured for a packet presumably by inspecting packet headers; in
+ *     case, skb_crc32c_csum_help is provided to compute CRC on SCTP packets.
  *
  *   NETIF_F_FCOE_CRC - This feature indicates that a device is capable of
  *     offloading the FCOE CRC in a packet. To perform this offload the stack
diff --git a/net/core/dev.c b/net/core/dev.c
index 5d33e2b..c7aec95 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -140,6 +140,7 @@
 #include <linux/hrtimer.h>
 #include <linux/netfilter_ingress.h>
 #include <linux/crash_dump.h>
+#include <linux/sctp.h>
 
 #include "net-sysfs.h"
 
@@ -2606,6 +2607,45 @@ int skb_checksum_help(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(skb_checksum_help);
 
+int skb_crc32c_csum_help(struct sk_buff *skb)
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
+						  crc32c_csum_stub));
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
