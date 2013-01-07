From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: introduce skb_transport_header_was_set()
Date: Mon, 07 Jan 2013 11:28:21 -0800
Message-ID: <1357586901.6919.3551.camel@edumazet-glaptop>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com>
	 <50CCE961.5050204@mojatatu.com>
	 <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr>
	 <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com>
	 <50CDFB6A.3090806@mojatatu.com> <50CE1A04.1000405@mojatatu.com>
	 <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr>
	 <50CE3203.9080007@mojatatu.com> <50CF1071.1050405@mojatatu.com>
	 <CAASe=fRuJdtisEvp7uo=PHwN3nKHqsYDW4Om1gk2MK-vyNvBrA@mail.gmail.com>
	 <50D06177.2090905@mojatatu.com>
	 <CAASe=fR6Hm2dxp=1wDchtrzqnaH6qacHpg2wrsqLfmGpPbQ9Fg@mail.gmail.com>
	 <50D1A8A7.1090002@mojatatu.com> <50D1AB7E.5060000@mojatatu.com>
	 <50D2D229.6040802@gmail.com> <50D305FD.7000901@mojatatu.com>
	 <50D327CD.3050904@gmail.com> <50D45E25.7050703@mojatatu.com>
	 <50D46060.2070308@gmail.com> <50D46928.9070809@mojatatu.com>
	 <alpine.LNX.2.01.1212211533360.957@nerf07.vanv.qr>
	 <1356104720.21834.7497.camel@edumazet-glaptop>
	 <50D5B8BA.9010808@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f52.google.com ([209.85.210.52]:43602 "EHLO
	mail-da0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755315Ab3AGT2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 14:28:25 -0500
Received: by mail-da0-f52.google.com with SMTP id f10so8781091dak.11
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 11:28:25 -0800 (PST)
In-Reply-To: <50D5B8BA.9010808@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Sat, 2012-12-22 at 08:42 -0500, Jamal Hadi Salim wrote:
> On 12-12-21 10:45 AM, Eric Dumazet wrote:
> > On Fri, 2012-12-21 at 15:35 +0100, Jan Engelhardt wrote:
> >
> 
> > This reminds me this might be the reason we have
> > skb_reset_transport_header(skb);
> > in __netif_receive_skb(), while its not very logical.
> >
> 
> You seem to have nailed the egress part finally. That has
> been a constant battle. At one point the standard answer
> was "turn off TSO" ;->
> 
> > (Yes, sorry for being off topic, but I am referring to
> > http://www.spinics.net/lists/netdev/msg214662.html )
> 
> 
> I think the skb_reset_transport_header() when Acme made
> a major overhaul to replace direct pointer access.
> For this reason i think your second option seems preferable.

It seems we already have a special case for mac_header, with the
skb_mac_header_was_set() helper.

We could have same logic for transport_header

Something like :

[PATCH net-next] net: introduce skb_transport_header_was_set()

We have skb_mac_header_was_set() helper to tell if mac_header
was set on a skb. We would like the same for transport_header.

__netif_receive_skb() doesn't reset the transport header if already
set by GRO layer.

Note that network stacks usually reset the transport header anyway,
after pulling the network header, so this change only allows
a followup patch to have more precise qdisc pkt_len computation
for GSO packets at ingress side.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/linux/skbuff.h |   10 ++++++++++
 net/core/dev.c         |    3 ++-
 net/core/skbuff.c      |    2 ++
 3 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 320e976..8b2256e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1492,6 +1492,11 @@ static inline void skb_set_inner_network_header(struct sk_buff *skb,
 	skb->inner_network_header += offset;
 }
 
+static inline bool skb_transport_header_was_set(const struct sk_buff *skb)
+{
+	return skb->transport_header != ~0U;
+}
+
 static inline unsigned char *skb_transport_header(const struct sk_buff *skb)
 {
 	return skb->head + skb->transport_header;
@@ -1580,6 +1585,11 @@ static inline void skb_set_inner_network_header(struct sk_buff *skb,
 	skb->inner_network_header = skb->data + offset;
 }
 
+static inline bool skb_transport_header_was_set(const struct sk_buff *skb)
+{
+	return skb->transport_header != NULL;
+}
+
 static inline unsigned char *skb_transport_header(const struct sk_buff *skb)
 {
 	return skb->transport_header;
diff --git a/net/core/dev.c b/net/core/dev.c
index a51ccf4..2e24482 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3352,7 +3352,8 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	orig_dev = skb->dev;
 
 	skb_reset_network_header(skb);
-	skb_reset_transport_header(skb);
+	if (!skb_transport_header_was_set(skb))
+		skb_reset_transport_header(skb);
 	skb_reset_mac_len(skb);
 
 	pt_prev = NULL;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b03fc0c..1e1b9ea 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -260,6 +260,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	skb->end = skb->tail + size;
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 	skb->mac_header = ~0U;
+	skb->transport_header = ~0U;
 #endif
 
 	/* make sure we initialize shinfo sequentially */
@@ -328,6 +329,7 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
 	skb->end = skb->tail + size;
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 	skb->mac_header = ~0U;
+	skb->transport_header = ~0U;
 #endif
 
 	/* make sure we initialize shinfo sequentially */
