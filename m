From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH] r8169: fix checksum broken
Date: Fri, 12 Nov 2010 18:15:25 +0800
Message-ID: <4CDD13BD.7060109@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61152 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755633Ab0KLKQ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Nov 2010 05:16:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If r8196 received packets with invalid sctp/igmp(not tcp, udp) checksum, r8196 set skb->ip_summed
wit CHECKSUM_UNNECESSARY. This cause that upper protocol don't check checksum field.

I am not family with r8196 driver. I try to guess the meaning of RxProtoIP and IPFail.
RxProtoIP stands for received IPv4 packet that upper protocol is not tcp and udp. 
!(opts1 & IPFail) is true means that driver correctly to check checksum in IPv4 header.

If it's right, I think we should not set ip_summed wit CHECKSUM_UNNECESSARY for my sctp packets
with invalid checksum. 

If it's not right, please tell me. 


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 drivers/net/r8169.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index d88ce9f..2cf6c2e 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4440,8 +4440,7 @@ static inline void rtl8169_rx_csum(struct sk_buff *skb, u32 opts1)
 	u32 status = opts1 & RxProtoMask;
 
 	if (((status == RxProtoTCP) && !(opts1 & TCPFail)) ||
-	    ((status == RxProtoUDP) && !(opts1 & UDPFail)) ||
-	    ((status == RxProtoIP) && !(opts1 & IPFail)))
+	    ((status == RxProtoUDP) && !(opts1 & UDPFail)))
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	else
 		skb_checksum_none_assert(skb);
-- 
1.6.3.3

