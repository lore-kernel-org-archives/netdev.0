From: "Steve Wise" <swise@opengridcomputing.com>
Subject: Re: [PATCH v3 1/7] AMSO1100 Low Level Driver.
Date: Fri, 23 Jun 2006 08:44:50 -0500
Message-ID: <1151070290.7808.33.camel@stevo-desktop>
References: <20060620203050.31536.5341.stgit@stevo-desktop>
 <20060620203055.31536.15131.stgit@stevo-desktop>
 <1150836226.2891.231.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com,
	linux-kernel@vger.kernel.org,
	openib-general@openib.org,
	netdev@vger.kernel.org
Return-path: <openib-general-bounces@openib.org>
To: "Arjan van de Ven" <arjan@infradead.org>
In-Reply-To: <1150836226.2891.231.camel@laptopd505.fenrus.org>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org


> 
> Also on a related note, have you checked the driver for the needed PCI
> posting flushes?
> 
> > +
> > +	/* Disable IRQs by clearing the interrupt mask */
> > +	writel(1, c2dev->regs + C2_IDIS);
> > +	writel(0, c2dev->regs + C2_NIMR0);
> 
> like here...

This code is followed by a call to c2_reset(), which interacts with the
firmware on the adapter to quiesce the hardware.  So I don't think we
need to wait here for the posted writes to flush...

> > +
> > +	elem = tx_ring->to_use;
> > +	elem->skb = skb;
> > +	elem->mapaddr = mapaddr;
> > +	elem->maplen = maplen;
> > +
> > +	/* Tell HW to xmit */
> > +	__raw_writeq(cpu_to_be64(mapaddr), elem->hw_desc + C2_TXP_ADDR);
> > +	__raw_writew(cpu_to_be16(maplen), elem->hw_desc + C2_TXP_LEN);
> > +	__raw_writew(cpu_to_be16(TXP_HTXD_READY), elem->hw_desc + C2_TXP_FLAGS);
> 
> or here
> 

No need here.  This logic submits the packet for transmission.  We don't
assume it is transmitted until we (after a completion interrupt usually)
read back the HTXD entry and see the TXP_HTXD_DONE bit set (see
c2_tx_interrupt()). 


Steve.
