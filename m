From: "Frans van de Wiel" <fvdw@fvdw.eu>
Subject: Re: mv643xxx_eth driver, failed to linearize skb with tiny unaligned fragment
Date: Sat, 1 Oct 2016 14:35:48 +0200
Message-ID: <40328409E3E6450589A06A98E62B1A88@FransW7>
References: <9ABBF443071A48919A5E612F97EE0B09@FransW7> <1475103882.28155.119.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
        format=flowed;
        charset="UTF-8";
        reply-type=original
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>,
        "Ezequiel Garcia" <ezequiel.garcia@free-electrons.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isp-bos-02.edutel.nl ([88.159.1.177]:50554 "EHLO
        isp-bos-02.edutel.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750771AbcJAMgq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2016 08:36:46 -0400
In-Reply-To: <1475103882.28155.119.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric
thank you for your reply. I am not that familiar with driver programming, do 
you think it is safe to ignore the message without changing the driver?.
We did extensive testing and found no data corruption so far.

regards

-----Oorspronkelijk bericht----- 
From: Eric Dumazet
Sent: Thursday, September 29, 2016 1:04 AM
To: Frans van de Wiel
Cc: netdev@vger.kernel.org ; Ezequiel Garcia
Subject: Re: mv643xxx_eth driver, failed to linearize skb with tiny 
unaligned fragment

On Wed, 2016-09-28 at 22:37 +0200, Frans van de Wiel wrote:
> We compiled kernel 4.6.6 for our nas devices running on ARM kirkwood cpu’s.
> These nas devices have only 256 MB of RAM so limited memory resources
> When we fully load the cpu and are copying files via the interface we get
> frequently this “ error” message in dmesg log
>
> [ 1978.149929] mv643xx_eth_port mv643xx_eth_port.0 eth0: failed to 
> linearize
> skb with tiny unaligned fragment
> [ 1978.150138] mv643xx_eth_port mv643xx_eth_port.0 eth0: failed to 
> linearize
> skb with tiny unaligned fragment
> [ 1978.150318] mv643xx_eth_port mv643xx_eth_port.0 eth0: failed to 
> linearize
> skb with tiny unaligned fragment
> [ 1978.150360] mv643xx_eth_port mv643xx_eth_port.0 eth0: failed to 
> linearize
> skb with tiny unaligned fragment
>
> ...
>
> CPU[|||||||||||||||||||||||||||||||||||98.9%]     Tasks: 29, 0 thr; 2
> running
>   Mem[||||||||||||||||||||||||||||||||30/244MB]     Load average: 1.36 
> 1.29
> 0.92
>   Swp[                                 0/511MB]     Uptime: 00:38:11
>
> We analyzed the driver code code and think that it does not seems to be an
> error but a warning, this we want to verify and if this warning can be 
> taken
> out without risk
>
> The message originates from this part of the code of the driver
>
> 1023 if (has_tiny_unaligned_frags(skb) && __skb_linearize(skb)) {
> 1024                 netdev_printk(KERN_DEBUG, dev,
> 1025                               "failed to linearize skb with tiny
> unaligned fragment\n");
> 1026                 return NETDEV_TX_BUSY;
> 1027         }
>
> __skb_linearize is set in skbuff.h and comments are useful
>
> static inline int __skb_linearize(struct sk_buff *skb)
> 1636 {
> 1637         return __pskb_pull_tail(skb, skb->data_len) ? 0 : -ENOMEM;
> 1638 }
> 1639
> 1640 /**
> 1641  *      skb_linearize - convert paged skb to linear one
> 1642  *      @skb: buffer to linarize
> 1643  *
> 1644  *      If there is no free memory -ENOMEM is returned, otherwise 
> zero
> 1645  *      is returned and the old skb data released.
> 1646  */
> 1647 static inline int skb_linearize(struct sk_buff *skb)
> 1648 {
>
> So return a false state (0) if there is enough free memory and true on the
> other case.
>
> Please to note mv643xx_eth.c returns also a busy state. So I assume on 
> this
> case the driver repeats this step up to success
>
> So in my opinion, this is not an error message but a warning and does not
> mean corrupted data and I think is should be possible to remove it.
> Is conclusion is correct ?

Well, linearizing an skb only because one fragment is tiny and not
aligned is unfortunate.

This driver should copy the ~7 bytes into temp storage instead.

It would be faster, and would avoid dropping packet when the (possibly
huge) allocation fails.

Strange thing is that txq_submit_tso() can happily present 'tiny frags'
after segmentation is done on a 'big frag', so I wonder if the
has_tiny_unaligned_frags() is really needed.

If this is needed, then a fix in txq_submit_tso() is also needed.
