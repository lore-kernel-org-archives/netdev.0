From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCH] packet: Allow packets with only a header (but no payload)
Date: Sat, 21 Nov 2015 01:50:12 +0100
Message-ID: <1448067012-15090-1-git-send-email-martin.blumenstingl@googlemail.com>
References: <1437495247-471-1-git-send-email-martin.blumenstingl@googlemail.com>
Cc: willemb@google.com, edumazet@google.com, dborkman@redhat.com,
	davem@davemloft.net, mostrows@earthlink.net, nbd@openwrt.org,
	Martin Blumenstingl <martin.blumenstingl@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:37410 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162986AbbKUAuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 19:50:35 -0500
Received: by wmww144 with SMTP id w144so41024867wmw.0
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 16:50:34 -0800 (PST)
In-Reply-To: <1437495247-471-1-git-send-email-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

9c70776 added validation for the packet size in packet_snd. This change
enforced that every packet needs a header with at least hard_header_len
bytes  and at least one byte payload.

This fixes PPPoE connections which do not have a "Service" or
"Host-Uniq" configured (which is violating the spec, but is still
widely used in real-world setups). Those are currently failing with the
following message: "pppd: packet size is too short (24 <= 24)"

Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
---
v2: Simply change the existing logic in ll_header_truncated instead of
    splitting it and having multiple checks.

 include/linux/netdevice.h | 3 ++-
 net/packet/af_packet.c    | 4 ++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 67bfac1..1f42cb7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1398,7 +1398,8 @@ enum netdev_priv_flags {
  *	@dma:		DMA channel
  *	@mtu:		Interface MTU value
  *	@type:		Interface hardware type
- *	@hard_header_len: Hardware header length
+ *	@hard_header_len: Hardware header length, which means that this is the
+ * 				minimum size of a packet.
  *
  *	@needed_headroom: Extra headroom the hardware may need, but not in all
  *			  cases can this be guaranteed
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 1cf928f..992396a 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2329,8 +2329,8 @@ static void tpacket_destruct_skb(struct sk_buff *skb)
 static bool ll_header_truncated(const struct net_device *dev, int len)
 {
 	/* net device doesn't like empty head */
-	if (unlikely(len <= dev->hard_header_len)) {
-		net_warn_ratelimited("%s: packet size is too short (%d <= %d)\n",
+	if (unlikely(len < dev->hard_header_len)) {
+		net_warn_ratelimited("%s: packet size is too short (%d < %d)\n",
 				     current->comm, len, dev->hard_header_len);
 		return true;
 	}
-- 
2.6.2
