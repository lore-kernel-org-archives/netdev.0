From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH net-next v2 2/2] net: mvneta: Use cacheable memory to
 store the rx buffer DMA address
Date: Fri, 17 Feb 2017 14:55:01 +0100
Message-ID: <20170217145501.5b90a977@free-electrons.com>
References: <20170217100233.2325-1-jszhang@marvell.com>
        <20170217100233.2325-3-jszhang@marvell.com>
        <87o9y1aqsk.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jisheng Zhang <jszhang@marvell.com>, <davem@davemloft.net>,
        <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87o9y1aqsk.fsf@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Fri, 17 Feb 2017 14:30:03 +0100, Gregory CLEMENT wrote:

> I have just tested it and as I feared, with HWBM enabled, a simple iperf
> just doesn't work.

And that's expected: the whole point of HWBM is that the buffer into
which a RX packet is placed is allocated by the HW, and its address
stored in the RX descriptor. So the following code:

> >  	rx_desc->buf_phys_addr = phys_addr;
> >  	i = rx_desc - rxq->descs;
> > +	rxq->buf_dma_addr[i] = phys_addr;

Does not make sense, because it's not the SW that refills the RX
descriptors with the address of the RX buffers. It's done by the HW.

With HWBM, I believe you have no choice but to read the physical
address from the RX descriptor. But you can probably optimize things a
little bit by reading it only once, and then storing it into a
cacheable variable.

So maybe:

 - For SWBM, use the strategy proposed by Jisheng
 - For HWBM, at the beginning of the RX completion path, read once the
   rx_desc->buf_phys_addr, and store it in rxq->buf_dma_addr[index]

Of course that's just a very rough proposal. I've been looking mainly
at mvpp2 lately, and I'm not sure I still remember how mvneta works in
the details.

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
