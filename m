From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: skb_tx_hash() improvements
Date: Sun, 03 May 2009 14:44:18 -0700 (PDT)
Message-ID: <20090503.144418.255531526.davem@davemloft.net>
References: <49FAB831.6020700@cosmosbay.com>
	<49FAC112.6090808@cosmosbay.com>
	<20090501.091747.240476627.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@whydna.net, jelaas@gmail.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59303
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750847AbZECVoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2009 17:44:23 -0400
In-Reply-To: <20090501.091747.240476627.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 01 May 2009 09:17:47 -0700 (PDT)

> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 01 May 2009 11:29:54 +0200
> 
>> -	} else if (skb->sk && skb->sk->sk_hash) {
>> +		/*
>> +		 * Try to avoid an expensive divide, for symmetric setups :
>> +		 *   number of tx queues of output device ==
>> +		 *   number of rx queues of incoming device
>> +		 */
>> +		if (hash >= dev->real_num_tx_queues)
>> +			hash %= dev->real_num_tx_queues;
>> +		return hash;
>> +	}
> 
> Subtraction in a while() loop is almost certainly a lot
> faster.

To move forward on this, I've commited the following to
net-next-2.6, thanks!

net: Avoid modulus in skb_tx_hash() for forwarding case.

Based almost entirely upon a patch by Eric Dumazet.

The common case is to have num-tx-queues <= num_rx_queues
and even if num_tx_queues is larger it will not be significantly
larger.

Therefore, a subtraction loop is always going to be faster than
modulus.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8144295..3c8073f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1735,8 +1735,12 @@ u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)
 {
 	u32 hash;
 
-	if (skb_rx_queue_recorded(skb))
-		return skb_get_rx_queue(skb) % dev->real_num_tx_queues;
+	if (skb_rx_queue_recorded(skb)) {
+		hash = skb_get_rx_queue(skb);
+		while (unlikely (hash >= dev->real_num_tx_queues))
+			hash -= dev->real_num_tx_queues;
+		return hash;
+	}
 
 	if (skb->sk && skb->sk->sk_hash)
 		hash = skb->sk->sk_hash;
-- 
1.6.2.4

