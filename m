From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH] skbuff: align sk_buff::cb to 64 bit
Date: Fri, 29 Jan 2010 23:09:37 +0100
Message-ID: <4B635CA1.8070803@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([88.198.39.176]:37611 "EHLO ds10.nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752554Ab0A2WJj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 17:09:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The alignment requirement for 64-bit load/store instructions on ARM is
implementation defined. Some CPUs (such as Marvell Feroceon) do not
generate an exception, if such an instruction is executed with an
address that is not 64 bit aligned. 
In such a case, the Feroceon corrupts adjacent memory, which showed up
in my tests as a crash in the rx path of ath9k that only occured with
CONFIG_XFRM set. This crash happened, because the first field of the
mac80211 rx status info in the cb is an u64, and changing it corrupted
the skb->sp field.

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
Cc: stable@kernel.org
---
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -329,7 +329,7 @@ struct sk_buff {
 	 * want to keep them across layers you have to do a skb_clone()
 	 * first. This is owned by whoever has the skb queued ATM.
 	 */
-	char			cb[48];
+	char			cb[48] __attribute__((aligned(8)));
 
 	unsigned int		len,
 				data_len;

