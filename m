From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: Re: [PATCH RFC 2/2] net: qualcomm: new Ethernet over SPI driver for
 QCA7000
Date: Wed, 30 Apr 2014 17:36:18 +0200
Message-ID: <53611872.2070001@i2se.com>
References: <1398707697-43785-1-git-send-email-stefan.wahren@i2se.com> <4860368.6Apskanc4s@wuerfel> <535FCB24.2010507@i2se.com> <4693879.NBTVQb29rJ@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, f.fainelli@gmail.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:61288 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759366AbaD3Pgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 11:36:33 -0400
In-Reply-To: <4693879.NBTVQb29rJ@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnd,

Am 29.04.2014 20:14, schrieb Arnd Bergmann:
> On a related note, there is one part I don't understand:
>
> +netdev_tx_t
> +qcaspi_netdev_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +       u32 frame_len;
> +       u8 *ptmp;
> +       struct qcaspi *qca = netdev_priv(dev);
> +       u32 new_tail;
> +       struct sk_buff *tskb;
> +       u8 pad_len = 0;
> +
> +       if (skb->len < QCAFRM_ETHMINLEN)
> +               pad_len = QCAFRM_ETHMINLEN - skb->len;
> +
> +       if (qca->txq.skb[qca->txq.tail]) {
> +               netdev_warn(qca->net_dev, "queue was unexpectedly full!\n");
> +               netif_stop_queue(qca->net_dev);
> +               qca->stats.queue_full++;
> +               return NETDEV_TX_BUSY;
> +       }
>
> You print a 'netdev_warn' message here when the queue is full, expecting
> this to be rare. If the device is so slow, why doesn't this happen
> all the time?
>
> 	Arnd

i think i've found it. A little bit later in the function the "expected"
queue full condition is handled.
After the new skb is added to the buffer, the new tail is checked. In
the case the tx queue is now full, netif_stop_queue is called. I've
forgot to increment the queue_full counter for that case.

After the skb has been transmitted to the QCA7000 over spi, the function
netif_wake_queue is called. If i'm right, the message "queue was
unexpectedly full" should never appear under normal condition.

Stefan
