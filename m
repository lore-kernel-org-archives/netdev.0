From: Wei Yongjun <yjwei@nanjing-fnst.com>
Subject: [PATCH] Bug in pskb_trim_rcsum()
Date: Sun, 16 Jul 2006 23:53:20 -0400
Message-ID: <1153108401.3651.9.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:50895 "EHLO
	localmail.nanjing-fnst.com") by vger.kernel.org with ESMTP
	id S932252AbWGQCyK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jul 2006 22:54:10 -0400
Received: from proxy.fnst.com.cn ([192.168.10.4])
	by localmail.nanjing-fnst.com (8.12.11/8.12.11) with ESMTP id k6H2s0BK024086
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 10:54:00 +0800
Received: from 192.168.4.91 ([192.168.4.91])
	by proxy.fnst.com.cn (8.12.11/8.12.11) with ESMTP id k6H2s5wU025411
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 10:54:05 +0800
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  Since network device can auto calculate and verify the checksum of a
packet, for example: some e1000 interface. Different device will set
different value of skb->ip_summed.
  a) If device do nothing to checksum, skb->ip_summed would be set to
CHECKSUM_NONE.
  b) If device can only calculate a checksum, and the checksum is
correct, skb->ip_summed would be set to CHECKSUM_HW.
  c) If device can verify the checksum, and the checksum is correct,
skb->ip_summed would be set to CHECKSUM_UNNECESSARY.
  So if I want to trim a skb, I think I must do a checksum even if the
skb->ip_summed is CHECKSUM_UNNECESSARY.

Following is the comment about CHECKSUM_UNNECESSARY in
include/linux/skbuff.h:
 *	UNNECESSARY: device parsed packet and wouldbe verified checksum.
 *		skb->csum is undefined.
 *	      It is bad option, but, unfortunately, many of vendors do this.
 *	      Apparently with secret goal to sell you new device, when you
 *	      will add new protocol to your host. F.e. IPv6. 8)

Signed-off-by: Wei Yongjun <weiyj@soft.fujitsu.com>


--- a/include/linux/skbuff.h	2006-07-17 10:14:23.175070472 -0400
+++ b/include/linux/skbuff.h	2006-07-17 10:18:31.762279472 -0400
@@ -1208,8 +1208,8 @@ static inline int pskb_trim_rcsum(struct
 {
 	if (likely(len >= skb->len))
 		return 0;
-	if (skb->ip_summed == CHECKSUM_HW)
-		skb->ip_summed = CHECKSUM_NONE;
+
+	skb->ip_summed = CHECKSUM_NONE;
 	return __pskb_trim(skb, len);
 }
 


