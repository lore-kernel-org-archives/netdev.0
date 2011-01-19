From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH] xen network backend driver
Date: Wed, 19 Jan 2011 17:48:36 +0000
Message-ID: <1295459316.14981.3727.camel@zakaz.uk.xensource.com>
References: <1295449318.14981.3484.camel@zakaz.uk.xensource.com>
	 <1295455216.11126.39.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:61943 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753083Ab1ASRsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 12:48:39 -0500
In-Reply-To: <1295455216.11126.39.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

Thanks for the very speedy review!

I don't have many comments other than "yes, you are right".

There are a couple of things inline below.

On Wed, 2011-01-19 at 16:40 +0000, Ben Hutchings wrote:
> On Wed, 2011-01-19 at 15:01 +0000, Ian Campbell wrote:
> [...]
> > +	/*
> > +	 * Initialise a dummy MAC address. We choose the numerically
> > +	 * largest non-broadcast address to prevent the address getting
> > +	 * stolen by an Ethernet bridge for STP purposes.
> > +	 * (FE:FF:FF:FF:FF:FF)
> > +	 */
> > +	memset(dev->dev_addr, 0xFF, ETH_ALEN);
> > +	dev->dev_addr[0] &= ~0x01;
> 
> I'm a bit dubious about this.

Which reminds me that I need to add the hook so that the Xen userspace
stuff can actually do the right thing and set the MAC address to
FE:FF:FF:FF:FF:FF itself as it puts the device on the bridge.

The toolstack has only recently been fixed to even try that though.

In use these devices aren't typically endpoints which generate or
receive any actual traffic so letting it pick up a random MAC address by
default isn't terribly useful. The actual useful MAC address is the one
which is configured in the frontend.

> [...]
> > +static int MODPARM_netback_kthread;
> > +module_param_named(netback_kthread, MODPARM_netback_kthread, bool, 0);
> > +MODULE_PARM_DESC(netback_kthread, "Use kernel thread to replace tasklet");
> > +
> > +/*
> > + * Netback bottom half handler.
> > + * dir indicates the data direction.
> > + * rx: 1, tx: 0.
> > + */
> > +static inline void xen_netbk_bh_handler(struct xen_netbk *netbk, int dir)
> > +{
> > +	if (MODPARM_netback_kthread)
> > +		wake_up(&netbk->kthread.netbk_action_wq);
> > +	else if (dir)
> > +		tasklet_schedule(&netbk->tasklet.net_rx_tasklet);
> > +	else
> > +		tasklet_schedule(&netbk->tasklet.net_tx_tasklet);
> > +}
> 
> Ugh, please just use NAPI.

Although I only have a vague concept of what NAPI actually entails in
practice I think it most likely makes sense.

Am I right that NAPI only covers the RX case?

Does NAPI processing happen in softirq context? The reason for the
existing option to use a kthread was that the tasklets would completely
swamp the domain 0 CPU under load and prevent anything else from running
(including e.g. ssh or the toolstack allowing you to fix the
problem...). I guess this is just a case of setting the NAPI weight
correctly (i.e. appropriately high in this case)?

Last question before I go an actually investigate NAPI properly: Does
NAPI also scale out across CPUs? Currently the threads/tasklets are per
CPU and this is a significant scalability win.

> [...]
> > +#ifdef NETBE_DEBUG_INTERRUPT
> > +static irqreturn_t netif_be_dbg(int irq, void *dev_id, struct pt_regs *regs)
> 
> This wouldn't compile on anything after 2.6.18!  Clearly no-one defines
> NETBE_DEBUG_INTERRUPT, and you can remove this code entirely.

Heh, I actually enabled this and fixed it up as I was debugging this
stuff and then accidentally threw away the fixup hunk when I turned it
off again...

I think you are right to suggest removing the code though, it's not
actually all that helpful in practice and it is easy enough to hack
similar things in for local debugging as necessary.

> [...]
> > +module_init(netback_init);
> [...]
> 
> No module_fini?

Not at the moment.

Ian.

