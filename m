From: Zhangfei Gao <zhangfei.gao@gmail.com>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Fri, 4 Apr 2014 14:52:08 +0800
Message-ID: <CAMj5BkgMxDtTe0iQVVddcMbYYhVasmHzURHOMtANVbMNU_Z-Yg@mail.gmail.com>
References: <1396358832-15828-1-git-send-email-zhangfei.gao@linaro.org>
	<1396358832-15828-4-git-send-email-zhangfei.gao@linaro.org>
	<9532591.5yuCbpL4pV@wuerfel>
	<20140403152746.GQ7528@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Arnd Bergmann <arnd@arndb.de>, Mark Rutland <mark.rutland@arm.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev <netdev@vger.kernel.org>,
	David Laight <David.Laight@aculab.com>,
	Zhangfei Gao <zhangfei.gao@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:60350 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752730AbaDDGwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 02:52:10 -0400
In-Reply-To: <20140403152746.GQ7528@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Russell

On Thu, Apr 3, 2014 at 11:27 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Wed, Apr 02, 2014 at 11:21:45AM +0200, Arnd Bergmann wrote:
>> - As David Laight pointed out earlier, you must also ensure that
>>   you don't have too much /data/ pending in the descriptor ring
>>   when you stop the queue. For a 10mbit connection, you have already
>>   tested (as we discussed on IRC) that 64 descriptors with 1500 byte
>>   frames gives you a 68ms round-trip ping time, which is too much.
>>   Conversely, on 1gbit, having only 64 descriptors actually seems
>>   a little low, and you may be able to get better throughput if
>>   you extend the ring to e.g. 512 descriptors.
>
> You don't manage that by stopping the queue - there's separate interfaces
> where you report how many bytes you've queued (netdev_sent_queue()) and
> how many bytes/packets you've sent (netdev_tx_completed_queue()).  This
> allows the netdev schedulers to limit how much data is held in the queue,
> preserving interactivity while allowing the advantages of larger rings.

My god, it's awesome.
The latency can be solved via adding netdev_sent_queue in xmit, and
netdev_completed_queue in reclaim.
In the experiment,
iperf -P 3 could get 930M, and ping could get response within 0.4 ms
in the meantime.

Is that mean the timer -> reclaim should be removed at all?
The background are.
1. No xmit_complete interrupt.
2. Only xmit call reclaim used buffer can achieve best throughput.
Adding timer in case no next xmit for reclaim.

>
>> > +       phys = dma_map_single(&ndev->dev, skb->data, skb->len, DMA_TO_DEVICE);
>> > +       if (dma_mapping_error(&ndev->dev, phys)) {
>> > +               dev_kfree_skb(skb);
>> > +               return NETDEV_TX_OK;
>> > +       }
>> > +
>> > +       priv->tx_skb[tx_head] = skb;
>> > +       priv->tx_phys[tx_head] = phys;
>> > +       desc->send_addr = cpu_to_be32(phys);
>> > +       desc->send_size = cpu_to_be16(skb->len);
>> > +       desc->cfg = cpu_to_be32(DESC_DEF_CFG);
>> > +       phys = priv->tx_desc_dma + tx_head * sizeof(struct tx_desc);
>> > +       desc->wb_addr = cpu_to_be32(phys);
>>
>> One detail: since you don't have cache-coherent DMA, "desc" will
>> reside in uncached memory, so you try to minimize the number of accesses.
>> It's probably faster if you build the descriptor on the stack and
>> then atomically copy it over, rather than assigning each member at
>> a time.
>
> DMA coherent memory is write combining, so multiple writes will be
> coalesced.  This also means that barriers may be required to ensure the
> descriptors are pushed out in a timely manner if something like writel()
> is not used in the transmit-triggering path.
>
Currently writel is used in xmit.
And regmap_write -> writel is used in poll.

Thanks
