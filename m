From: Ahmed Abdelsalam <amsalam20@gmail.com>
Subject: [PATCH v2] ipv6: sr: fix get_srh() to comply with IPv6 standard "RFC 8200"
Date: Wed, 30 Aug 2017 10:50:37 +0200
Message-ID: <1504083037-1605-1-git-send-email-amsalam20@gmail.com>
Cc: netdev@vger.kernel.org, david.lebrun@uclouvain.be,
        amsalam20@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35953 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751368AbdH3IvH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 04:51:07 -0400
Received: by mail-wr0-f194.google.com with SMTP id 40so3519172wrv.3
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 01:51:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 packet may carry more than one extension header, and IPv6 nodes must
accept and attempt to process extension headers in any order and occurring
any number of times in the same packet. Hence, there should be no
assumption that Segment Routing extension header is to appear immediately
after the IPv6 header.

Moreover, section 4.1 of RFC 8200 gives a recommendation on the order of
appearance of those extension headers within an IPv6 packet. According to
this recommendation, Segment Routing extension header should appear after
Hop-by-Hop and Destination Options headers (if they present).

This patch fixes the get_srh(), so it gets the segment routing header
regardless of its position in the chain of the extension headers in IPv6
packet, and makes sure that the IPv6 routing extension header is of Type 4.

Signed-off-by: Ahmed Abdelsalam <amsalam20@gmail.com>
---
The patch is tested for IPv6 packets that has the SRH immediately after
IPv6 header as well as IPv6 packets with Hop-by-Hop appearing before SRH.
Hereafter, hexdump of IPv6 packet in both cases along with the value of
the SRH offset.

[  661.433676] 00000000: 60 03 a4 cd 00 b0 2b 3f 00 0a 00 00 00 00 00 00
[  661.433691] 00000010: 00 00 00 00 00 00 00 01 00 02 00 00 00 00 00 00
[  661.433695] 00000020: 00 00 00 00 0a d6 00 f1 29 08 04 03 03 00 00 00
[  661.433699] 00000030: 00 03 00 00 00 00 00 00 00 00 00 00 00 00 00 d6
[  661.433703] 00000040: 00 02 00 00 00 00 00 00 00 00 00 00 0a d6 00 f3
[  661.433707] 00000050: 00 02 00 00 00 00 00 00 00 00 00 00 0a d6 00 f2
[  661.433711] 00000060: 00 02 00 00 00 00 00 00 00 00 00 00 0a d6 00 f1
[  661.433715] 00000070: 60 03 a4 cd 00 40 3a 40 00 0a 00 00 00 00 00 00
[  661.433719] 00000080: 00 00 00 00 00 00 00 02 00 0b 00 00 00 00 00 00
[  661.433723] 00000090: 00 00 00 00 00 00 00 02 80 00 99 f5 0a 20 00 1d
[  661.433727] 000000a0: ef 72 a6 59 00 00 00 00 82 9a 04 00 00 00 00 00
[  661.433731] 000000b0: 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f
[  661.433735] 000000c0: 20 21 22 23 24 25 26 27 28 29 2a 2b 2c 2d 2e 2f
[  661.433739] 000000d0: 30 31 32 33 34 35 36 37
[  661.433743] srhoff = 40

[  661.433754] 00000000: 60 03 a4 cd 00 b0 00 3f 00 0a 00 00 00 00 00 00
[  661.433758] 00000010: 00 00 00 00 00 00 00 01 00 02 00 00 00 00 00 00
[  661.433762] 00000020: 00 00 00 00 0a d6 00 f1 2b 00 10 00 00 00 00 00
[  661.433766] 00000030: 29 08 04 03 03 00 00 00 00 03 00 00 00 00 00 00
[  661.433770] 00000040: 00 00 00 00 00 00 00 d6 00 02 00 00 00 00 00 00
[  661.433774] 00000050: 00 00 00 00 0a d6 00 f3 00 02 00 00 00 00 00 00
[  661.433778] 00000060: 00 00 00 00 0a d6 00 f2 00 02 00 00 00 00 00 00
[  661.433782] 00000070: 00 00 00 00 0a d6 00 f1 60 03 a4 cd 00 40 3a 40
[  661.433786] 00000080: 00 0a 00 00 00 00 00 00 00 00 00 00 00 00 00 02
[  661.433790] 00000090: 00 0b 00 00 00 00 00 00 00 00 00 00 00 00 00 02
[  661.433794] 000000a0: 80 00 99 f5 0a 20 00 1d ef 72 a6 59 00 00 00 00
[  661.433798] 000000b0: 82 9a 04 00 00 00 00 00 10 11 12 13 14 15 16 17
[  661.433801] 000000c0: 18 19 1a 1b 1c 1d 1e 1f 20 21 22 23 24 25 26 27
[  661.433805] 000000d0: 28 29 2a 2b 2c 2d 2e 2f 30 31 32 33 34 35 36 37
[  661.433809] srhoff = 48

 net/ipv6/seg6_local.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/seg6_local.c b/net/ipv6/seg6_local.c
index 9c1a885..7ff54db 100644
--- a/net/ipv6/seg6_local.c
+++ b/net/ipv6/seg6_local.c
@@ -62,17 +62,23 @@ static struct seg6_local_lwt *seg6_local_lwtunnel(struct lwtunnel_state *lwt)
 static struct ipv6_sr_hdr *get_srh(struct sk_buff *skb)
 {
 	struct ipv6_sr_hdr *srh;
-	struct ipv6hdr *hdr;
-	int len;
+	int len, srhoff = 0;
+
+	if (ipv6_find_hdr(skb, &srhoff, IPPROTO_ROUTING, NULL, NULL) < 0)
+		return NULL;
+
+	if (!pskb_may_pull(skb, srhoff + sizeof(*srh)))
+		return NULL;
+
+	srh = (struct ipv6_sr_hdr *)(skb->data + srhoff);
 
-	hdr = ipv6_hdr(skb);
-	if (hdr->nexthdr != IPPROTO_ROUTING)
+	/* make sure it's a Segment Routing header (Routing Type 4) */
+	if (srh->type != IPV6_SRCRT_TYPE_4)
 		return NULL;
 
-	srh = (struct ipv6_sr_hdr *)(hdr + 1);
 	len = (srh->hdrlen + 1) << 3;
 
-	if (!pskb_may_pull(skb, sizeof(*hdr) + len))
+	if (!pskb_may_pull(skb, srhoff + len))
 		return NULL;
 
 	if (!seg6_validate_srh(srh, len))
-- 
2.7.4
