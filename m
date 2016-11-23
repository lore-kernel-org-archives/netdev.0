From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net-next 1/4] net: mvneta: Convert to be 64 bits compatible
Date: Wed, 23 Nov 2016 14:07:49 +0100
Message-ID: <87mvgqmjiy.fsf@free-electrons.com>
References: <20161122164844.19566-1-gregory.clement@free-electrons.com>
        <2948812.F3se4ieqO6@wuerfel> <20161123175341.4777595f@xhacker>
        <9432400.S1OrxC027t@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-arm-kernel@lists.infradead.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Marcin Wojtas <mw@semihalf.com>,
        "David S. Miller" <davem@davemloft.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Jisheng Zhang <jszhang@marvell.com>, Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9432400.S1OrxC027t@wuerfel> (Arnd Bergmann's message of "Wed, 23
        Nov 2016 11:15:32 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jisheng, Arnd,


Thanks for your feedback.


 On mer., nov. 23 2016, Arnd Bergmann <arnd@arndb.de> wrote:

> On Wednesday, November 23, 2016 5:53:41 PM CET Jisheng Zhang wrote:
>> On Tue, 22 Nov 2016 22:04:12 +0100 Arnd Bergmann wrote:
>> 
>> > On Tuesday, November 22, 2016 5:48:41 PM CET Gregory CLEMENT wrote:
>> > > +#ifdef CONFIG_64BIT
>> > > +       void *data_tmp;
>> > > +
>> > > +       /* In Neta HW only 32 bits data is supported, so in order to
>> > > +        * obtain whole 64 bits address from RX descriptor, we store
>> > > +        * the upper 32 bits when allocating buffer, and put it back
>> > > +        * when using buffer cookie for accessing packet in memory.
>> > > +        * Frags should be allocated from single 'memory' region,
>> > > +        * hence common upper address half should be sufficient.
>> > > +        */
>> > > +       data_tmp = mvneta_frag_alloc(pp->frag_size);
>> > > +       if (data_tmp) {
>> > > +               pp->data_high = (u64)upper_32_bits((u64)data_tmp) << 32;
>> > > +               mvneta_frag_free(pp->frag_size, data_tmp);
>> > > +       }
>> > >   
>> > 
>> > How does this work when the region spans a n*4GB address boundary?
>> 
>> indeed. We also make use of this driver on 64bit platforms. We use
>> different solution to make the driver 64bit safe.
>> 
>> solA: make use of the reserved field in the mvneta_rx_desc, such
>> as reserved2 etc. Yes, the field is marked as "for future use, PnC", but
>> now it's not used at all. This is one possible solution however.
>
> Right, this sounds like the most straightforward choice.

The PnC (which stands for Parsing and Classification) is not used yet
indeed but this field will be needed when we will enable it. It is
something we want to do but it is not planned in a near future. However
from the datasheets I have it seems only present on the Armada XP. It is
not mentioned on datasheets for the Armada 38x or the Armada 3700.

That would mean it was safe to use on of this field in 64-bits mode on
the Armada 3700.

So I am going to take this approach.

Thanks,

Gregory

>
>> solB: allocate a shadow buf cookie during init, e.g
>> 
>> rxq->descs_bufcookie = kmalloc(rxq->size * sizeof(void*), GFP_KERNEL);
>> 
>> then modify mvneta_rx_desc_fill a bit to save the 64bit pointer in
>> the shadow buf cookie, e.g
>> static void mvneta_rx_desc_fill(struct mvneta_rx_desc *rx_desc,
>>                                 u32 phys_addr, u32 cookie,
>> 				struct mvneta_rx_queue *rxq)
>> 
>> {
>> 	int i;
>> 
>> 	rx_desc->buf_cookie = cookie;
>> 	rx_desc->buf_phys_addr = phys_addr;
>> 	i = rx_desc - rxq->descs;
>> 	rxq->descs_bufcookie[i] = cookie;
>> }
>> 
>> then fetch the desc from the shadow buf cookie in all code path, such
>> as mvneta_rx() etc.
>> 
>> Both solutions should not have the problems pointed out by Arnd.
>
> Wait, since you compute an index 'i' here, can't you just store 'i'
> directly in the descriptor instead of the pointer?
>
> 	Arnd

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
