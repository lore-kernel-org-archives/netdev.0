From: Julia Cartwright <julia@ni.com>
Subject: Re: Kernel 4.6.7-rt13: Intel Ethernet driver igb causes huge
 latencies in cyclictest
Date: Thu, 13 Oct 2016 11:18:39 -0500
Message-ID: <20161013161839.GV10625@jcartwri.amer.corp.natinst.com>
References: <487032ca81f84e70bdacc39a024eff5e@FE-MBX1012.de.bosch.com>
 <20161004193445.GF10625@jcartwri.amer.corp.natinst.com>
 <584755c2766e4b94a604ece16760fe14@FE-MBX1012.de.bosch.com>
 <20161005155959.GH10625@jcartwri.amer.corp.natinst.com>
 <13c3cd3ffee4490fb22b8de383e51361@FE-MBX1012.de.bosch.com>
 <AAEA33E297BCAC4B9BB20A7C2DF0AB8D8045E418@FMSMSX113.amr.corp.intel.com>
 <29250f87b1d84aacb8aa312935582291@FE-MBX1012.de.bosch.com>
 <20161010193958.GE22235@jcartwri.amer.corp.natinst.com>
 <e9661abf93194ad3849e3864a8361993@FE-MBX1012.de.bosch.com>
 <b77ea8ab312149d2b20a717d3ab0a8dc@FE-MBX1012.de.bosch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "linux-rt-users@vger.kernel.org" <linux-rt-users@vger.kernel.org>,
        Sebastian Andrzej Siewior <sebastian.siewior@linutronix.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        Greg <gvrose8192@gmail.com>
To: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod2.natinst.com ([130.164.80.23]:37535 "EHLO ni.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756050AbcJMQT3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Oct 2016 12:19:29 -0400
In-Reply-To: <b77ea8ab312149d2b20a717d3ab0a8dc@FE-MBX1012.de.bosch.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Mathias-

On Thu, Oct 13, 2016 at 10:57:18AM +0000, Koehrer Mathias (ETAS/ESW5) wrote:
[..]

Interesting indeed!

> > Here are some places where I added traces:
> > In file igb_ptp.c:
> > void igb_ptp_rx_hang(struct igb_adapter *adapter) {
> >         struct e1000_hw *hw = &adapter->hw;
> >         unsigned long rx_event;
> >         u32 tsyncrxctl;
> >         trace_igb(700);
> >         tsyncrxctl = rd32(E1000_TSYNCRXCTL);
> >         trace_igb(701);
> >
> >         /* Other hardware uses per-packet timestamps */
> >         if (hw->mac.type != e1000_82576)
> >                 return;
> > ...
> >
> > In file igb_main.c:
> > static void igb_check_lvmmc(struct igb_adapter *adapter) {
> >         struct e1000_hw *hw = &adapter->hw;
> >         u32 lvmmc;
> >
> >         trace_igb(600);
> >         lvmmc = rd32(E1000_LVMMC);
> >         trace_igb(601);
> >         if (lvmmc) {
> > ...
> >
[..]
> > The time between my trace points 700 and 701 is about 30us, the time between my
> > trace points 600 and 601 is even 37us!!
> >
> > The code in between is
> >      tsyncrxctl = rd32(E1000_TSYNCRXCTL); resp.
> >      lvmmc = rd32(E1000_LVMMC);
> >
> > In both cases this is a single read from a register.
> >
> > I have no idea why this single read could take that much time!

Are these the only registers you see this amount of delay when reading?

It's also possible that it's not these registers themselves that cause
problems, but any writes prior to these reads.  That is, given to PCI's
posted write behavior, it could be that these reads are delayed only
because it's flushing previously writes to the device.

> > Is it possible that the igb hardware is in a state that delays the read access and this is
> > why the whole I/O system might be delayed?

One additional hypothesis is that some register accesses trigger
accesses to off-chip resources synchronously; for example, a write to
enable timestamping needs to access an external phy on a slower bus,
etc.  I don't know enough about this device to say whether or not that
happens or not.

> To have a proper comparison, I did the same with kernel 3.18.27-rt27.
> Also here, I instrumented the igb driver to get traces for the rd32 calls.
> However, here everything is generally much faster!

> In the idle system the maximum I got for a read was about 6us, most times it was 1-2us.
> On the 4.8 kernel this is always much slower (see above).
> My question is now: Is there any kernel config option that has been introduced in the meantime
> that may lead to this effect and which is not set in my 4.8 config?

Have you tested on a vanilla (non-RT) kernel?  I doubt there is anything
RT specific about what you are seeing, but it might be nice to get
confirmation.  Also, bisection would probably be easier if you confirm
on a vanilla kernel.

I find it unlikely that it's a kernel config option that changed which
regressed you, but instead was a code change to a driver.  Which driver
is now the question, and the surface area is still big (processor
mapping attributes for this region, PCI root complex configuration, PCI
brige configuration, igb driver itself, etc.).

Big enough that I'd recommend a bisection.  It looks like a bisection
between 3.18 and 4.8 would take you about 18 tries to narrow down,
assuming all goes well.

   Julia
