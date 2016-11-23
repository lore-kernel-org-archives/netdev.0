From: Jisheng Zhang <jszhang@marvell.com>
Subject: Re: [PATCH net-next 1/4] net: mvneta: Convert to be 64 bits compatible
Date: Wed, 23 Nov 2016 17:53:41 +0800
Message-ID: <20161123175341.4777595f@xhacker>
References: <20161122164844.19566-1-gregory.clement@free-electrons.com>
 <20161122164844.19566-2-gregory.clement@free-electrons.com>
 <2948812.F3se4ieqO6@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Jason
 Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org,
 Gregory CLEMENT <gregory.clement@free-electrons.com>,
 Marcin Wojtas <mw@semihalf.com>, "David
 S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <2948812.F3se4ieqO6@wuerfel>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Nov 2016 22:04:12 +0100 Arnd Bergmann wrote:

> On Tuesday, November 22, 2016 5:48:41 PM CET Gregory CLEMENT wrote:
> > +#ifdef CONFIG_64BIT
> > +       void *data_tmp;
> > +
> > +       /* In Neta HW only 32 bits data is supported, so in order to
> > +        * obtain whole 64 bits address from RX descriptor, we store
> > +        * the upper 32 bits when allocating buffer, and put it back
> > +        * when using buffer cookie for accessing packet in memory.
> > +        * Frags should be allocated from single 'memory' region,
> > +        * hence common upper address half should be sufficient.
> > +        */
> > +       data_tmp = mvneta_frag_alloc(pp->frag_size);
> > +       if (data_tmp) {
> > +               pp->data_high = (u64)upper_32_bits((u64)data_tmp) << 32;
> > +               mvneta_frag_free(pp->frag_size, data_tmp);
> > +       }
> >   
> 
> How does this work when the region spans a n*4GB address boundary?

indeed. We also make use of this driver on 64bit platforms. We use
different solution to make the driver 64bit safe.

solA: make use of the reserved field in the mvneta_rx_desc, such
as reserved2 etc. Yes, the field is marked as "for future use, PnC", but
now it's not used at all. This is one possible solution however.

solB: allocate a shadow buf cookie during init, e.g

rxq->descs_bufcookie = kmalloc(rxq->size * sizeof(void*), GFP_KERNEL);

then modify mvneta_rx_desc_fill a bit to save the 64bit pointer in
the shadow buf cookie, e.g
static void mvneta_rx_desc_fill(struct mvneta_rx_desc *rx_desc,
                                u32 phys_addr, u32 cookie,
				struct mvneta_rx_queue *rxq)

{
	int i;

	rx_desc->buf_cookie = cookie;
	rx_desc->buf_phys_addr = phys_addr;
	i = rx_desc - rxq->descs;
	rxq->descs_bufcookie[i] = cookie;
}

then fetch the desc from the shadow buf cookie in all code path, such
as mvneta_rx() etc.

Both solutions should not have the problems pointed out by Arnd.

Thanks,
Jisheng
