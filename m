From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/3] net: fec: align IP header in hardware
Date: Wed, 28 Sep 2016 16:42:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB010A73F@AcuExch.aculab.com>
References: <AM4PR0401MB22609D8151C2B63CA7768A1AFFCB0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <1474728139-9335-1-git-send-email-eric@nelint.com>
 <1474728139-9335-4-git-send-email-eric@nelint.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0109865@AcuExch.aculab.com>
 <4d199f32-092c-1c0a-7a01-6d0d317ef676@nelint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "fugang.duan@nxp.com" <fugang.duan@nxp.com>,
        "otavio@ossystems.com.br" <otavio@ossystems.com.br>,
        "edumazet@google.com" <edumazet@google.com>,
        "troy.kisky@boundarydevices.com" <troy.kisky@boundarydevices.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "u.kleine-koenig@pengutronix.de" <u.kleine-koenig@pengutronix.de>
To: 'Eric Nelson' <eric@nelint.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.187]:53664 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934006AbcI1QqF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 12:46:05 -0400
In-Reply-To: <4d199f32-092c-1c0a-7a01-6d0d317ef676@nelint.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Nelson
> Sent: 26 September 2016 19:40
> Hi David,
> 
> On 09/26/2016 02:26 AM, David Laight wrote:
> > From: Eric Nelson
> >> Sent: 24 September 2016 15:42
> >> The FEC receive accelerator (RACC) supports shifting the data payload of
> >> received packets by 16-bits, which aligns the payload (IP header) on a
> >> 4-byte boundary, which is, if not required, at least strongly suggested
> >> by the Linux networking layer.
> > ...
> >> +		/* align IP header */
> >> +		val |= FEC_RACC_SHIFT16;
> >
> > I can't help feeling that there needs to be corresponding
> > changes to increase the buffer size by 2 (maybe for large mtu)
> > and to discard two bytes from the frame length.
> >
> 
> In the normal case, the fec driver over-allocates all receive packets to
> be of size FEC_ENET_RX_FRSIZE (2048) minus the value of rx_align,
> which is either 0x0f (ARM) or 0x03 (PPC).
> 
> If the frame length is less than rx_copybreak (typically 256), then
> the frame length from the receive buffer descriptor is used to
> control the allocation size for a copied buffer, and this will include
> the two bytes of padding if RACC_SHIFT16 is set.
> 
> > If probably ought to be predicated on NET_IP_ALIGN as well.
> >
> Can you elaborate?

>From reading this it seems that the effect of FEC_RACC_SHIFT16 is to
add two bytes of 'junk' to the start of every receive frame.

In the 'copybreak' case the new skb would need to be 2 bytes shorter
than the length reported by the hardware, and the data copied from
2 bytes into the dma buffer.

The extra 2 bytes also mean the that maximum mtu that can be received
into a buffer is two bytes less.
If someone sets the mtu to (say) 9k for jumbo frames this might matter.
Even with fixed 2048 byte buffers it reduces the maximum value the mtu
can be set to by 2.

Now if NET_IP_ALIGN is zero then it is fine for the rx frame to start
on a 4n boundary, and the skb are likely to be allocated that way.
In this case you don't want to extra two bytes of 'junk'.

OTOH if NET_IP_ALIGN is 2 then you need to 'fiddle' things so that
the data is dma'd to offset -2 in the skb and then ensure that the
end of frame is set correctly.

	David
