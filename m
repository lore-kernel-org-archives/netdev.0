From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH RFC 2/2] net: qualcomm: new Ethernet over SPI driver for QCA7000
Date: Tue, 29 Apr 2014 20:14:05 +0200
Message-ID: <4693879.NBTVQb29rJ@wuerfel>
References: <1398707697-43785-1-git-send-email-stefan.wahren@i2se.com> <4860368.6Apskanc4s@wuerfel> <535FCB24.2010507@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, f.fainelli@gmail.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Stefan Wahren <stefan.wahren@i2se.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:55838 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755711AbaD2SOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 14:14:18 -0400
In-Reply-To: <535FCB24.2010507@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 29 April 2014 17:54:12 Stefan Wahren wrote:
> > As far as I know it's also not mandatory.
> >
> > If the hardware interfaces require calling sleeping functions, it
> > may not actually be possible, but if you can use it, it normally
> > provides better performance.
> 
> As i understood NAPI is good for high load on 1000 MBit ethernet, but
> the QCA7000 has
> in best case only a 10 MBit powerline connection. Additionally these
> packets must be transfered
> over a half duplex SPI. So i think the current driver implementation
> isn't a bottle neck.

Ok, makes sense. What is the slowest speed you might see then?
You already have a relatively small queue of at most 10 frames,
but if this goes below 10 Mbit, that can still be noticeable
bufferbloat. 

Try adding calls to netdev_sent_queue, netdev_completed_queue and
netdev_reset_queue to let the network stack know how much data
is currently queued up for the tx thread.

On a related note, there is one part I don't understand:

+netdev_tx_t
+qcaspi_netdev_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+       u32 frame_len;
+       u8 *ptmp;
+       struct qcaspi *qca = netdev_priv(dev);
+       u32 new_tail;
+       struct sk_buff *tskb;
+       u8 pad_len = 0;
+
+       if (skb->len < QCAFRM_ETHMINLEN)
+               pad_len = QCAFRM_ETHMINLEN - skb->len;
+
+       if (qca->txq.skb[qca->txq.tail]) {
+               netdev_warn(qca->net_dev, "queue was unexpectedly full!\n");
+               netif_stop_queue(qca->net_dev);
+               qca->stats.queue_full++;
+               return NETDEV_TX_BUSY;
+       }

You print a 'netdev_warn' message here when the queue is full, expecting
this to be rare. If the device is so slow, why doesn't this happen
all the time?

	Arnd
