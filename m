From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH v3] skbuff: align sk_buff::cb to 64 bit and close some potential
 holes
Date: Tue, 23 Feb 2010 22:45:51 +0100
Message-ID: <4B844C8F.2060908@openwrt.org>
References: <1264835220.2919.10.camel@edumazet-laptop>	<4B671CEB.5080505@caviumnetworks.com>	<4B671F79.8090808@openwrt.org> <20100212.121306.225788982.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ddaney@caviumnetworks.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, buytenh@wantstofly.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([88.198.39.176]:43343 "EHLO ds10.nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754023Ab0BWVqG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2010 16:46:06 -0500
In-Reply-To: <20100212.121306.225788982.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The alignment requirement for 64-bit load/store instructions on ARM is
implementation defined. Some CPUs (such as Marvell Feroceon) do not
generate an exception, if such an instruction is executed with an
address that is not 64 bit aligned. In such a case, the Feroceon
corrupts adjacent memory, which showed up in my tests as a crash in the
rx path of ath9k that only occured with CONFIG_XFRM set.

This crash happened, because the first field of the mac80211 rx status
info in the cb is an u64, and changing it corrupted the skb->sp field.

This patch also closes some potential pre-existing holes in the sk_buff
struct surrounding the cb[] area.

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
Cc: stable@kernel.org
---
sorry that it took so long for me to post this, i completely forgot
about it, as I had other things to take care of ;)
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -315,22 +315,23 @@ struct sk_buff {
 	struct sk_buff		*next;
 	struct sk_buff		*prev;
 
-	struct sock		*sk;
 	ktime_t			tstamp;
+
+	struct sock		*sk;
 	struct net_device	*dev;
 
-	unsigned long		_skb_dst;
-#ifdef CONFIG_XFRM
-	struct	sec_path	*sp;
-#endif
 	/*
 	 * This is the control buffer. It is free to use for every
 	 * layer. Please put your private variables there. If you
 	 * want to keep them across layers you have to do a skb_clone()
 	 * first. This is owned by whoever has the skb queued ATM.
 	 */
-	char			cb[48];
+	char			cb[48] __aligned(8);
 
+	unsigned long		_skb_dst;
+#ifdef CONFIG_XFRM
+	struct	sec_path	*sp;
+#endif
 	unsigned int		len,
 				data_len;
 	__u16			mac_len,

