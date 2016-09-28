From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: mv643xxx_eth driver, failed to linearize skb with tiny
 unaligned fragment
Date: Wed, 28 Sep 2016 16:04:42 -0700
Message-ID: <1475103882.28155.119.camel@edumazet-glaptop3.roam.corp.google.com>
References: <9ABBF443071A48919A5E612F97EE0B09@FransW7>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
        Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: Frans van de Wiel <fvdw@fvdw.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33531 "EHLO
        mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932539AbcI1XEo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 19:04:44 -0400
Received: by mail-pa0-f47.google.com with SMTP id cd13so17705984pac.0
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 16:04:44 -0700 (PDT)
In-Reply-To: <9ABBF443071A48919A5E612F97EE0B09@FransW7>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-09-28 at 22:37 +0200, Frans van de Wiel wrote:
> We compiled kernel 4.6.6 for our nas devices running on ARM kirkwood cpu’s. 
> These nas devices have only 256 MB of RAM so limited memory resources
> When we fully load the cpu and are copying files via the interface we get 
> frequently this “ error” message in dmesg log
> 
> [ 1978.149929] mv643xx_eth_port mv643xx_eth_port.0 eth0: failed to linearize 
> skb with tiny unaligned fragment
> [ 1978.150138] mv643xx_eth_port mv643xx_eth_port.0 eth0: failed to linearize 
> skb with tiny unaligned fragment
> [ 1978.150318] mv643xx_eth_port mv643xx_eth_port.0 eth0: failed to linearize 
> skb with tiny unaligned fragment
> [ 1978.150360] mv643xx_eth_port mv643xx_eth_port.0 eth0: failed to linearize 
> skb with tiny unaligned fragment
> 
> ...
> 
> CPU[|||||||||||||||||||||||||||||||||||98.9%]     Tasks: 29, 0 thr; 2 
> running
>   Mem[||||||||||||||||||||||||||||||||30/244MB]     Load average: 1.36 1.29 
> 0.92
>   Swp[                                 0/511MB]     Uptime: 00:38:11
> 
> We analyzed the driver code code and think that it does not seems to be an 
> error but a warning, this we want to verify and if this warning can be taken 
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
> 1644  *      If there is no free memory -ENOMEM is returned, otherwise zero
> 1645  *      is returned and the old skb data released.
> 1646  */
> 1647 static inline int skb_linearize(struct sk_buff *skb)
> 1648 {
> 
> So return a false state (0) if there is enough free memory and true on the 
> other case.
> 
> Please to note mv643xx_eth.c returns also a busy state. So I assume on this 
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
