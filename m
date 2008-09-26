From: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware restart.
Date: Fri, 26 Sep 2008 09:56:52 +0400
Message-ID: <20080926055651.GA19560@2ka.mipt.ru>
References: <20080921172316.GA6306@2ka.mipt.ru> <20080921110422.1d010b96@infradead.org> <20080921182835.GA11473@2ka.mipt.ru> <20080921113513.16677c4e@infradead.org> <20080921190050.GA20484@2ka.mipt.ru> <20080921205744.2d78f1fa@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	holtmann-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080921205744.2d78f1fa-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 21, 2008 at 08:57:44PM +0100, Alan Cox (alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org) wrote:
> > Getting the fact, that rmmod/insmod does not always fix the problem (but
> > most of the time for a short period of time), I again want to point,
> > that it looks like a firmware problem related to some inner timings. You
> > ask me to fix the driver and do not even listen to what I said
> > previously and do not get that into account and analyze.
> 
> Try putting it into D3 counting to 10 and powering it back up. Thats
> about as close as you can get to pulling the plug when it hangs.

I made several experimetns with power states in reset handler,
like put to d3 (hot), disable device, save/resetore states.
Fatal interrupts continue to fire with essentially the same rate.

The same error address does not always contain the same error value, but
frequently it is finit small set.

Here are some data:
[41773.200686] ipw2100: Fatal interrupt. Scheduling firmware restart.
[41773.200707] eth1: Fatal error value: 0x500185B8, address: 0x08004501,
	inta: 0x40000000
[41773.200810] ipw2100 0000:02:04.0: PCI INT A disabled
[41773.203110] ipw2100: IRQ INTA == 0xFFFFFFFF
[41773.224446] ipw2100: IRQ INTA == 0xFFFFFFFF
[41773.245781] ipw2100: IRQ INTA == 0xFFFFFFFF
[41773.249360] ipw2100 0000:02:04.0: enabling device (0000 -> 0002)
[41773.249384] ipw2100 0000:02:04.0: PCI INT A -> Link[C0C8] -> GSI 11
	(level, low) -> IRQ 11
[41773.249426] ipw2100 0000:02:04.0: restoring config space at
	offset 0x1 (was 0x2900002, writing 0x2900006)

That is quite harmless, since interrupt handler just sees that device is
dissapearing. This brought me to think more about interrupt processing
(irq handler and related tasklet), and I found races between interrupt
tasklet, ipw2100_wx_event_work() handler, reset task and probably
others. Register access in some cases are proteceted by lock (interrupt
handler), and in some cases is not (all others). Although every user
first disables interrupts, but it can be handled right now and scheduled
tasklet already. Also priv->status field is frequently accessed and
modified with and without locks. This may be harmless, but still a red
flag.

Another data about the same failed address:
eth1: Fatal error value: 0x50018584, address: 0x61C00000, inta:
0x40000000
eth1: Fatal error value: 0x50018584, address: 0x61C00000, inta:
0x40000000
eth1: Fatal error value: 0x5000CEE4, address: 0x61C00000, inta:
0x40000000
eth1: Fatal error value: 0x50018584, address: 0x61C00000, inta:
0x40000000
eth1: Fatal error value: 0x5000CEE4, address: 0x61C00000, inta:
0x40000000
eth1: Fatal error value: 0x50018584, address: 0x61C00000, inta:
0x40000000
eth1: Fatal error value: 0x50018584, address: 0x61C00000, inta:
0x40000000
eth1: Fatal error value: 0x5000CEE4, address: 0x61C00000, inta:
0x40000000
eth1: Fatal error value: 0x50018584, address: 0x61C00000, inta:
0x40000000
eth1: Fatal error value: 0x50018584, address: 0x61C00000, inta:
0x40000000

values are quite limited, but I saw at different address wider set of
different data, but still limited. Addresses and values of the fatal
interrupt do not follow some immediately obvious law, so this looks more
like firmware losts its mind. The reason for this actually may be a
register access races described above. I will continue experiments with
this.

-- 
	Evgeniy Polyakov
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
