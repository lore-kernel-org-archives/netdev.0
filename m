From: David Miller <davem@davemloft.net>
Subject: [PATCH] tcp: Set CHECKSUM_UNNECESSARY in tcp_init_nondata_skb
Date: Thu, 08 Apr 2010 01:26:17 -0700 (PDT)
Message-ID: <20100408.012617.98660541.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56216
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752675Ab0DHI0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 04:26:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Back in commit 04a0551c87363f100b04d28d7a15a632b70e18e7
("loopback: Drop obsolete ip_summed setting") we stopped
setting CHECKSUM_UNNECESSARY in the loopback xmit.

This is because such a setting was a lie since it implies that the
checksum field of the packet is properly filled in.

Instead what happens normally is that CHECKSUM_PARTIAL is set and
skb->csum is calculated as needed.

But this was only happening for TCP data packets (via the
skb->ip_summed assignment done in tcp_sendmsg()).  It doesn't
happen for non-data packets like ACKs etc.

Fix this by setting skb->ip_summed in the common non-data packet
constructor.  It already is setting skb->csum to zero.

But this reminds us that we still have things like ip_output.c's
ip_dev_loopback_xmit() which sets skb->ip_summed to the value
CHECKSUM_UNNECESSARY, which Herbert's patch teaches us is not
valid.  So we'll have to address that at some point too.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f181b78..00afbb0 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -349,6 +349,7 @@ static inline void TCP_ECN_send(struct sock *sk, struct sk_buff *skb,
  */
 static void tcp_init_nondata_skb(struct sk_buff *skb, u32 seq, u8 flags)
 {
+	skb->ip_summed = CHECKSUM_PARTIAL;
 	skb->csum = 0;
 
 	TCP_SKB_CB(skb)->flags = flags;
