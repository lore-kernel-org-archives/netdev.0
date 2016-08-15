From: Pavel Andrianov <andrianov@ispras.ru>
Subject: Potential data race in drivers/net/ethernet/sis/sis190.ko
Date: Mon, 15 Aug 2016 15:59:54 +0300
Message-ID: <149fe7f1-c417-d71f-972c-ba445692ba0a@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vaishali Thakkar <vaishali.thakkar@oracle.com>,
	ldv-project@linuxtesting.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

There is a potential data race in drivers/net/ethernet/sis/sis190.ko.

Regard such situation:

CPU 1 				CPU 2

...
->sis190_open
- registers interrupts
...
->sis190_tx_timeout
- is called at some point
    ->sis190_tx_clear
       skb = tp->Tx_skbuff[i]
       [skb != null]

                an interrupt comes to CPU 2

				-> sis190_irq
				  -> sis190_tx_interrupt
				    skb = tp->Tx_skbuff[entry];
       ...
       -> dev_kfree_skb_irq(skb)
         ->dev_kfree_skb(skb)

In this case the skb is freed twice. Likely, in the interrupt handler 
the same spinlock should be acquired as in
sis190_tx_timeout.

-- 
Pavel Andrianov
Linux Verification Center, ISPRAS
web: http://linuxtesting.org
e-mail: andrianov@ispras.ru
