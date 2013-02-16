From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 2/4] tunneling: Capture inner mac header during encapsulation.
Date: Fri, 15 Feb 2013 17:06:08 -0800
Message-ID: <1360976768-1858-1-git-send-email-pshelar@nicira.com>
Cc: edumazet@google.com, jesse@nicira.com, stephen@networkplumber.org,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:53787 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751156Ab3BPBE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 20:04:26 -0500
Received: by mail-gh0-f199.google.com with SMTP id r16so1534380ghr.10
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 17:04:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds missing inner mac header. This will be used in
next patch.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/linux/skbuff.h |   34 ++++++++++++++++++++++++++++++++++
 net/core/skbuff.c      |    2 ++
 2 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 821c7f4..d7f96ff 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -387,6 +387,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@vlan_tci: vlan tag control information
  *	@inner_transport_header: Inner transport layer header (encapsulation)
  *	@inner_network_header: Network layer header (encapsulation)
+ *	@inner_mac_header: Link layer header (encapsulation)
  *	@transport_header: Transport layer header
  *	@network_header: Network layer header
  *	@mac_header: Link layer header
@@ -505,6 +506,7 @@ struct sk_buff {
 
 	sk_buff_data_t		inner_transport_header;
 	sk_buff_data_t		inner_network_header;
+	sk_buff_data_t		inner_mac_header;
 	sk_buff_data_t		transport_header;
 	sk_buff_data_t		network_header;
 	sk_buff_data_t		mac_header;
@@ -1466,6 +1468,7 @@ static inline void skb_reserve(struct sk_buff *skb, int len)
 
 static inline void skb_reset_inner_headers(struct sk_buff *skb)
 {
+	skb->inner_mac_header = skb->mac_header;
 	skb->inner_network_header = skb->network_header;
 	skb->inner_transport_header = skb->transport_header;
 }
@@ -1511,6 +1514,22 @@ static inline void skb_set_inner_network_header(struct sk_buff *skb,
 	skb->inner_network_header += offset;
 }
 
+static inline unsigned char *skb_inner_mac_header(const struct sk_buff *skb)
+{
+	return skb->head + skb->inner_mac_header;
+}
+
+static inline void skb_reset_inner_mac_header(struct sk_buff *skb)
+{
+	skb->inner_mac_header = skb->data - skb->head;
+}
+
+static inline void skb_set_inner_mac_header(struct sk_buff *skb,
+					    const int offset)
+{
+	skb_reset_inner_mac_header(skb);
+	skb->inner_mac_header += offset;
+}
 static inline bool skb_transport_header_was_set(const struct sk_buff *skb)
 {
 	return skb->transport_header != ~0U;
@@ -1604,6 +1623,21 @@ static inline void skb_set_inner_network_header(struct sk_buff *skb,
 	skb->inner_network_header = skb->data + offset;
 }
 
+static inline unsigned char *skb_inner_mac_header(const struct sk_buff *skb)
+{
+	return skb->inner_mac_header;
+}
+
+static inline void skb_reset_inner_mac_header(struct sk_buff *skb)
+{
+	skb->inner_mac_header = skb->data;
+}
+
+static inline void skb_set_inner_mac_header(struct sk_buff *skb,
+						const int offset)
+{
+	skb->inner_mac_header = skb->data + offset;
+}
 static inline bool skb_transport_header_was_set(const struct sk_buff *skb)
 {
 	return skb->transport_header != NULL;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d388e77..ba8f89c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -673,6 +673,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->mac_header		= old->mac_header;
 	new->inner_transport_header = old->inner_transport_header;
 	new->inner_network_header = old->inner_network_header;
+	new->inner_mac_header = old->inner_mac_header;
 	skb_dst_copy(new, old);
 	new->rxhash		= old->rxhash;
 	new->ooo_okay		= old->ooo_okay;
@@ -876,6 +877,7 @@ static void skb_headers_offset_update(struct sk_buff *skb, int off)
 		skb->mac_header += off;
 	skb->inner_transport_header += off;
 	skb->inner_network_header += off;
+	skb->inner_mac_header += off;
 }
 
 static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
-- 
1.7.1
