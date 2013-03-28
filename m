From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] net: fix compile error of implicit declaration of skb_probe_transport_header
Date: Thu, 28 Mar 2013 10:46:06 +0800
Message-ID: <1364438766-14042-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <jasowang@redhat.com>, <edumazet@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:37988 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755139Ab3C1CqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 22:46:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 40893fd(net: switch to use skb_probe_transport_header())
involes a new error accidently. When NET_SKBUFF_DATA_USES_OFFSE is
not enabled, below compile error happens:

  CC      net/packet/af_packet.o
  net/packet/af_packet.c: In function =E2=80=98packet_sendmsg_spkt=E2=80=
=99:
  net/packet/af_packet.c:1516:2: error: implicit declaration of functio=
n =E2=80=98skb_probe_transport_header=E2=80=99 [-Werror=3Dimplicit-func=
tion-declaration]
  cc1: some warnings being treated as errors
  make[2]: *** [net/packet/af_packet.o] Error 1
  make[1]: *** [net/packet] Error 2
  make: *** [net] Error 2

As it seems skb_probe_transport_header() is not related to
NET_SKBUFF_DATA_USES_OFFSE, we should move the definition of
skb_probe_transport_header() out of scope of
NET_SKBUFF_DATA_USES_OFFSE macro.

Cc: Jason Wang <jasowang@redhat.com>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 include/linux/skbuff.h |   26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index fa88b96..878e0ee 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1560,19 +1560,6 @@ static inline void skb_set_transport_header(stru=
ct sk_buff *skb,
 	skb->transport_header +=3D offset;
 }
=20
-static inline void skb_probe_transport_header(struct sk_buff *skb,
-					      const int offset_hint)
-{
-	struct flow_keys keys;
-
-	if (skb_transport_header_was_set(skb))
-		return;
-	else if (skb_flow_dissect(skb, &keys))
-		skb_set_transport_header(skb, keys.thoff);
-	else
-		skb_set_transport_header(skb, offset_hint);
-}
-
 static inline unsigned char *skb_network_header(const struct sk_buff *=
skb)
 {
 	return skb->head + skb->network_header;
@@ -1716,6 +1703,19 @@ static inline void skb_set_mac_header(struct sk_=
buff *skb, const int offset)
 }
 #endif /* NET_SKBUFF_DATA_USES_OFFSET */
=20
+static inline void skb_probe_transport_header(struct sk_buff *skb,
+					      const int offset_hint)
+{
+	struct flow_keys keys;
+
+	if (skb_transport_header_was_set(skb))
+		return;
+	else if (skb_flow_dissect(skb, &keys))
+		skb_set_transport_header(skb, keys.thoff);
+	else
+		skb_set_transport_header(skb, offset_hint);
+}
+
 static inline void skb_mac_header_rebuild(struct sk_buff *skb)
 {
 	if (skb_mac_header_was_set(skb)) {
--=20
1.7.9.5
