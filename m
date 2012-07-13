From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] be2net: dont pull too much data in skb linear part
Date: Fri, 13 Jul 2012 15:19:41 +0200
Message-ID: <1342185581.3265.8355.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34949 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162970Ab2GMNTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 09:19:46 -0400
Received: by bkwj10 with SMTP id j10so3099951bkw.19
        for <netdev@vger.kernel.org>; Fri, 13 Jul 2012 06:19:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

skb_fill_rx_data() pulls 64 byte of data in skb->data

Its too much for TCP (with no options) on IPv4, as total size of headers
is 14 + 40 = 54

This means tcp stack and splice() are suboptimal, since tcp payload
is in part in tcp->data, and in part in skb frag.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 7e989d0..f18375c 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1228,16 +1228,16 @@ static void skb_fill_rx_data(struct be_rx_obj *rxo, struct sk_buff *skb,
 	/* Copy data in the first descriptor of this completion */
 	curr_frag_len = min(rxcp->pkt_size, rx_frag_size);
 
-	/* Copy the header portion into skb_data */
-	hdr_len = min(BE_HDR_LEN, curr_frag_len);
-	memcpy(skb->data, start, hdr_len);
 	skb->len = curr_frag_len;
 	if (curr_frag_len <= BE_HDR_LEN) { /* tiny packet */
+		memcpy(skb->data, start, curr_frag_len);
 		/* Complete packet has now been moved to data */
 		put_page(page_info->page);
 		skb->data_len = 0;
 		skb->tail += curr_frag_len;
 	} else {
+		hdr_len = ETH_HLEN;
+		memcpy(skb->data, start, hdr_len);
 		skb_shinfo(skb)->nr_frags = 1;
 		skb_frag_set_page(skb, 0, page_info->page);
 		skb_shinfo(skb)->frags[0].page_offset =
