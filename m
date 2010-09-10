From: Cyril Chemparathy <cyril@ti.com>
Subject: Re: [PATCH v3 00/10] split out emac cpdma and mdio for reuse
Date: Fri, 10 Sep 2010 18:59:38 -0400
Message-ID: <4C8AB85A.8060909@ti.com>
References: <1283891142-15522-1-git-send-email-cyril@ti.com> <871v95f2xv.fsf@deeprootsystems.com> <4C86F369.6040906@criticallink.com> <4C880733.5010909@ti.com> <4C882EAA.9030903@criticallink.com> <4C892AC0.80409@criticallink.com> <4C893ADE.809@ti.com> <4C8950D4.9060102@criticallink.com>
Reply-To: cyril@ti.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Kevin Hilman <khilman@deeprootsystems.com>,
	"tony@atomide.com" <tony@atomide.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Michael Williamson <michael.williamson@criticallink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:50930 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751991Ab0IJW7o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Sep 2010 18:59:44 -0400
In-Reply-To: <4C8950D4.9060102@criticallink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mike,

I have merged your latest two emails and responded to both here.

[...]
> Your patch doesn't work with my board.  It does attempt to reset the bus on the read call, 
> but following wait_for_user_access() calls are timing out and the _read() and _write() calls punt.  
> I bumped up the MDIO_TIMEOUT to 100 ms, and it works.  I'm wondering if the scanning logic 
> has to complete an entire cycle (all 32 phys) before issuing a request, and if it's a lot 
> slower than expected.

Based on the mdio module's state machine code, the scan does not need to
complete before a user-request is issued.  However, when the module is
first enabled, it _must_ poll at least one phy (phy id 0) before it
handles the user-access request.  Consequently, the first access after
coming out of reset may be slower than subsequent accesses.

One of the patches posted on my repo [1] replaces the dumb mdelay() with
a bit more logic that calculates the worst-case access time.  This
mechanism may work a lot better for you.  Would you mind trying it out?

Since the MDIO_TIMEOUT is simply a defensive measure, I have no
objections to raising this timeout (included in the updated stack).

> I also found that the initial scanning logic would not reliably find the PHY until I bumped
> up the delay time following the reset operation.  Sometimes it would, sometimes no.
> 
> Also, your while(1) loops with the continue conditions on the second wait_for_user_access() 
> in the read and writes might need some consideration, i.e.:
> 
>         while (1) {
>                 ret = wait_for_user_access(data);
>                 if (ret == -EAGAIN)
>                         continue;
>                 if (ret < 0)
>                         break;
> 
>                 __raw_writel(reg, &data->regs->user[0].access);
> 
>                 ret = wait_for_user_access(data);
>                 if (ret == -EAGAIN)
>                         continue;
>                         ^^^^^^^^^ <--- this will re-issue the request.... what you want?

Yes, the wait_for_user_access() would have reset the controller,
throwing the current transaction out.  The intent here is to restart the
current transaction with a newly initialized controller.

>                 if (ret < 0)
>                         break;
> 
>                 reg = __raw_readl(&data->regs->user[0].access);
>                 ret = (reg & USERACCESS_ACK) ? (reg & USERACCESS_DATA) : -EIO;
>                 break;
>         }
> 
> Also, on the shutdown, I get a major kernel trace.  Here is the dump, as much 
> as I could catch of it.... (I need a better terminal program)

[...]
> WARNING: at drivers/net/davinci_emac.c:1025 __cpdma_chan_free+0xac/0xb0()

The current code spits out a huge volume of stuff as a result of a
WARN_ON in the rx handler.  The gitweb on [1] has a patch that fixes this.

[...]
>> > The MDIO module upgrade (rev 1.4 -> 1.5) could have something to do with
>> > this behavior.  Even so, I can't explain why this issue wasn't seen on
>> > da8xx prior to this series.  The original code should (at least in
>> > theory) have sporadically locked up on emac open.
>> > 
> I think, if I understand it correctly, that in the previous version of 
> this code, the emac was reset *prior* to enabling, scanning, and assigning 
> the associated phy on the MDIO bus.  The new implementation sets up and scans 
> the MDIO bus first, then comes back around to the EMAC second... hits a reset,
> and doesn't re-ENABLE the MDIO.

AFAICS, that isn't entirely accurate.  In the previous version, the mdio
bus was being brought up at probe time in davinci_emac_probe().  The
soft-reset was happening later on when the device is opened, in
emac_hw_enable().

The difference, however, is that the original code forced an
emac_mii_reset() immediately after the emac_hw_enable().  This is not
being done with the separated mdio, and that is the problem.  In terms
of behavior, with the current work around, the new and old versions
should be close to identical.  More below...

> Also, maybe hitting the EMAC reset while the MDIO state machine is up is *bad*, I 
> seem to recall some text in the user's guide about waiting for the state
> machine to stop before disabling it.  I wonder if that also applies to reset?

You are correct.  EMAC soft-reset stops the MDIO mid-transaction, quite
unlike disabling the module via the control register.  Therefore, there
is a risk that a badly designed phy could be left hanging in an
arbitrary state.  However, all earlier versions of the emac code have
been exposed to this very same vulnerability (i.e. arbitrary emac
soft-reset regardless of mdio state) all along.

Regards
Cyril.


[1]
http://arago-project.org/git/people/?p=cyril/linux-tnetv107x.git;a=shortlog;h=refs/heads/emac-cpdma-mdio-fixes
