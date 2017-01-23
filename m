From: Davide Caratti <dcaratti@redhat.com>
Subject: [RFC PATCH net-next 3/5] net: introduce skb_sctp_csum_help
Date: Mon, 23 Jan 2017 17:52:44 +0100
Message-ID: <654992ae00322bc26ab0065d0249a36d446bce97.1485177252.git.dcaratti@redhat.com>
References: <cover.1485177252.git.dcaratti@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36014 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750828AbdAWQ7V (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 11:59:21 -0500
In-Reply-To: <cover.1485177252.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_sctp_csum_help is like skb_checksum_help, but it is designed for
checksumming SCTP packets using crc32c (see RFC3309), provided that
sctp.ko has been loaded before. In case sctp.ko is not loaded, invoking
skb_sctp_csum_help() on a skb results in the following printout:

sk_buff: attempt to compute crc32c without sctp.ko

Reviewed-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 include/linux/netdevice.h |  1 +
 include/linux/skbuff.h    |  3 ++-
 net/core/dev.c            | 29 +++++++++++++++++++++++++++++
 3 files changed, 32 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3868c32..9d72824 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3902,6 +3902,7 @@ void netdev_rss_key_fill(void *buffer, size_t len);
 
 int dev_get_nest_level(struct net_device *dev);
 int skb_checksum_help(struct sk_buff *skb);
+int skb_sctp_csum_help(struct sk_buff *skb);
 struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 				  netdev_features_t features, bool tx_path);
 struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 44fc804..91b4e22 100644
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
index 6742160..45cee84 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2554,6 +2554,29 @@ static int skb_rfc1624_csum(struct sk_buff *skb, int offset)
 	return ret;
 }
 
+/* compute 32-bit RFC3309 checksum and store it at skb->data + offset */
+static int skb_rfc3309_csum(struct sk_buff *skb, int offset)
+{
+	__le32 crc32c_csum;
+	int ret = 0;
+
+	crc32c_csum = cpu_to_le32(~__skb_checksum(skb, offset,
+						  skb->len - offset, ~(__u32)0,
+						  sctp_csum_stub));
+	offset += skb->csum_offset;
+	BUG_ON((offset + sizeof(__le32)) > skb_headlen(skb));
+
+	if (skb_cloned(skb) &&
+	    !skb_clone_writable(skb, offset + sizeof(__le32))) {
+		ret = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+		if (ret)
+			goto out;
+	}
+	*(__le32 *)(skb->data + offset) = crc32c_csum;
+out:
+	return ret;
+}
+
 /* Invalidate hardware checksum when packet is to be mangled, and
  * complete checksum manually on outgoing path.
  *    @skb - buffer that needs checksum
@@ -2599,6 +2622,12 @@ int skb_checksum_help(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(skb_checksum_help);
 
+int skb_sctp_csum_help(struct sk_buff *skb)
+{
+	return __skb_checksum_help(skb, skb_rfc3309_csum);
+}
+EXPORT_SYMBOL(skb_sctp_csum_help);
+
 __be16 skb_network_protocol(struct sk_buff *skb, int *depth)
 {
 	__be16 type = skb->protocol;
-- 
2.7.4
