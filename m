From: Elad Kanfi <eladkan@mellanox.com>
Subject: RE: [PATCH v2 1/2] net: nps_enet: Sync access to packet sent flag
Date: Sun, 8 May 2016 13:44:08 +0000
Message-ID: <HE1PR0501MB20265121CBDB2D48F66D408CCD7F0@HE1PR0501MB2026.eurprd05.prod.outlook.com>
References: <1461763110-15263-1-git-send-email-eladkan@mellanox.com>
 <1461763110-15263-2-git-send-email-eladkan@mellanox.com>
 <20160428.171120.2028974436439452264.davem@davemloft.net>
 <HE1PR0501MB2026E62285B397A5C7CC9705CD790@HE1PR0501MB2026.eurprd05.prod.outlook.com>
 <572736D6.5030902@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Noam Camus <noamca@mellanox.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"abrodkin@synopsys.com" <abrodkin@synopsys.com>,
	Tal Zilcer <talz@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lino Sanfilippo <lsanfil@marvell.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0075.outbound.protection.outlook.com ([157.56.112.75]:28090
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750722AbcEHN6w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 09:58:52 -0400
In-Reply-To: <572736D6.5030902@marvell.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Lino,

> Please see sections "SMP BARRIER PAIRING" and "EXAMPLES OF MEMORY BARRIER SEQUENCES" in
> memory-barriers.txt for a description why smp barriers have to be paired and a smp write barrier on CPU A without a read barrier on CPU B is _not_ sufficient.
>
> Furthermore after having a closer look into the problem you want to fix, it seems that you also have to ensure the correct order of the assignment of "tx_packet_sent" and the corresponding skb.
>
> On CPU A you do:
>
> 1. tx_skb = skb;
> 2. tx_packet_sent = true;
>
> On CPU B (the irq handler) you do:
>
> 1. Check/read tx_packet_sent.
> 2.If set then handle tx_skb.
>
> So there is a logical dependency between tx_skb and tx_packet_sent (tx_skb should only be handled if tx_packet_sent is set). However both compiler and CPU are free to reorder steps 1. and 2. on both CPU A  and CPU B and you have to ensure that tx_skb actually contains a valid pointer for CPU B as soon at it sees tx_packet_sent == true. So what you need here is:
>
> CPU A:
> 1. tx_skb = skb
> 2. smp_wmb()
> 3. tx_packet_sent = true;
>
> and CPU B:
>
> 1. read tx_packet_sent
> 2. smp_rmb()
> 3. If set then handle tx_skb
>
> So this is to ensure that tx_skb is in sync with tx_packet_sent on both writer and reader side.
>
>
> Then there is the second problem (the one you tried to address with your patch) that you have to make sure that by the time you inform the hardware about the new frame and the thus the tx-done irq may 
>
> occur both tx_packet_sent and tx_skb are actually set in the memory. Otherwise the irq may occur but CPU B may not see tx_packet_sent == true and the irq is lost. To achieve this you would have to use a (non-smp) write barrier before you inform the HW. So for CPU A the sequence would extend to:
>
> 1. tx_skb = skb
> 2. smp_wmb() /* ensure correct order between both assignments */ 3. tx_packet_sent = true; 4. wmb() /* make sure both assignments reach RAM before the HW is informed and the IRQ is fired */ 5. nps_enet_reg_set(priv, NPS_ENET_REG_TX_CTL, tx_ctrl.value);
>
> The latter barrier does not require pairing and has to be there even on UP systems because you dont want to sync between CPU A and CPU B in this case but rather between system RAM and IO-MEMORY.
>
> Please note that this is only how I understood things and it may be totally wrong. But I am sure that the initial solution with only one smp_wmb() is not correct either.
>
> Regards,
> Lino
  
After reviewing the code and your suggestion, it seems that we can do without the flag tx_packet_sent and therefor the first issue becomes irrelevant.
The indication that a packet was sent is (tx_skb != NULL) , and the sequence will be:

CPU A:
1. tx_skb = skb
2. wmb() /* make sure tx_skb reaches the RAM before the HW is informed and the IRQ is fired */
3. nps_enet_reg_set(priv, NPS_ENET_REG_TX_CTL, tx_ctrl.value); /* send frame */

CPU B:
1. read tx_skb 
2. if( tx_skb != NULL ) handle tx_skb
3. tx_skb = NULL 


Regards,
Elad.
