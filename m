From: Elof Vrigborn <elof.vrigborn@ericsson.com>
Subject: [PATCH 1/1] cdc_ncm: Fix TCP Window Size issue by CDC NCM driver
Date: Fri, 10 Jun 2011 15:39:34 +0200
Message-ID: <1307713174-533-1-git-send-email-elof.vrigborn@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Elof Vrigborn <elof.vrigborn@ericsson.com>
To: Oliver Neukum <oliver@neukum.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:65110 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756444Ab1FJNkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 09:40:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CDC NCM driver clones SKBs for received data and update SKB
members of the clones according to received frames.

If SKB clone len member is updated but truesize member is not, it
could cause check #2 of the tcp_grow_window function to increase
the TCP window by the __tcp_grow_window function instead of the
expected increment by 2*advmss. This could to a great extent
limit the rcv_ssthres and by that the advertised TCP Window Size,
and in the end the data rate of a TCP connection, as according to
the TCP Sliding Window concept.

With this patch the truesize member of the SKB clones is updated
in similarity to the len member and by this the expected incremental
of the advertised TCP Window Size is seen and the TCP connection
data rate will not be unnecessarily limited.

Signed-off-by: Elof Vrigborn <elof.vrigborn@ericsson.com>
---
 drivers/net/usb/cdc_ncm.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index f33ca6a..09923cd 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1083,6 +1083,7 @@ static int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in)
 			if (!skb)
 				goto error;
 			skb->len = temp;
+			skb->truesize = temp + sizeof(struct sk_buff);
 			skb->data = ((u8 *)skb_in->data) + offset;
 			skb_set_tail_pointer(skb, temp);
 			usbnet_skb_return(dev, skb);
-- 
1.7.4.4

