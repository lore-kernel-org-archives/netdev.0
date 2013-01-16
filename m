From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net_sched: fix qdisc_pkt_len_init()
Date: Tue, 15 Jan 2013 21:14:21 -0800
Message-ID: <1358313261.19956.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Yuval Mintz <yuvalmin@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:52379 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047Ab3APFOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 00:14:24 -0500
Received: by mail-pb0-f51.google.com with SMTP id ro12so500954pbb.24
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 21:14:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 1def9238d4aa2 (net_sched: more precise pkt_len computation)
does a wrong computation of mac + network headers length, as it includes
the padding before the frame.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yuval Mintz <yuvalmin@broadcom.com>
---
 net/core/dev.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 862eaa7..b6d2b32 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2776,8 +2776,12 @@ static void qdisc_pkt_len_init(struct sk_buff *skb)
 	 * we add to pkt_len the headers size of all segments
 	 */
 	if (shinfo->gso_size)  {
-		unsigned int hdr_len = skb_transport_offset(skb);
+		unsigned int hdr_len;
 
+		/* mac layer + network layer */
+		hdr_len = skb_transport_header(skb) - skb_mac_header(skb);
+
+		/* + transport layer */
 		if (likely(shinfo->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)))
 			hdr_len += tcp_hdrlen(skb);
 		else
