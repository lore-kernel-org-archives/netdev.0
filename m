From: Daniel Turull <daniel.turull@gmail.com>
Subject: [PATCH] pktgen: fix transmission headers with frags=0
Date: Mon, 14 Mar 2011 14:22:06 +0100
Message-ID: <4D7E167E.2090807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <robert@herjulf.net>,
	Jens Laas <jens.laas@its.uu.se>,
	Voravit Tanyingyong <voravit@kth.se>,
	Daniel Turull <daniel.turull@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54556 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755026Ab1CNNWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 09:22:12 -0400
Received: by fxm17 with SMTP id 17so2875153fxm.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 06:22:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The headers of pktgen were incorrectly added in a pktgen packet
without frags (frags=0). There was an offset in the pktgen headers.

The cause was in reusing the pgh variable as a return variable in skb_put
when adding the payload to the skb.

A rename of the variable is done.

Signed-off-by: Daniel Turull <daniel.turull@gmail.com>
---
The PKTGEN magic (be9b e955) now starts in the correct offset.
Before the patch, it was starting at the end of the packet (be9b)

Capture from tcpdump:

before patch:
14:57:37.854812 IP 10.0.0.2.discard > 10.254.254.84.discard: UDP, length 18
	0x0000:  001b 2157 ed84 001b 215d 01d0 0800 4500
	0x0010:  002e 0004 0000 2011 8767 0a00 0002 0afe
	0x0020:  fe54 0009 0009 001a 0000 0000 0000 b072
	0x0030:  9102 00ea ffff 0010 0000 be9b

after patch:
14:44:32.896048 IP 10.0.0.2.discard > 10.217.234.56.discard: UDP, length 18
	0x0000:  001b 2157 ed84 001b 215d 01d0 0800 4500
	0x0010:  002e 0000 0000 2011 9bac 0a00 0002 0ad9
	0x0020:  ea38 0009 0009 001a 0000 be9b e955 0000
	0x0030:  0001 4d7e 1b09 0005 5f23 af00

---
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index f0aec6c..5baa9d9 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2615,13 +2615,14 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 {
 	struct timeval timestamp;
 	struct pktgen_hdr *pgh;
+	void *data;
 
 	pgh = (struct pktgen_hdr *)skb_put(skb, sizeof(*pgh));
 	datalen -= sizeof(*pgh);
 
 	if (pkt_dev->nfrags <= 0) {
-		pgh = (struct pktgen_hdr *)skb_put(skb, datalen);
-		memset(pgh + 1, 0, datalen);
+		data = skb_put(skb, datalen);
+		memset(data + 1, 0, datalen);
 	} else {
 		int frags = pkt_dev->nfrags;
 		int i, len;
