From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [REGRESSION, PATCH] sky2 WOL fix
Date: Fri, 17 Feb 2012 13:35:16 -0800
Message-ID: <20120217133516.498c2199@nehalam.linuxnetplumber.net>
References: <4F3A1A5E.9090803@t-online.de>
	<20120215091622.429fe9c3@nehalam.linuxnetplumber.net>
	<4F3E9AC1.6060704@t-online.de>
	<20120217110147.1c00b31d@nehalam.linuxnetplumber.net>
	<4F3EB4D1.8090002@legroom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Knut Petersen <Knut_Petersen@t-online.de>, netdev@vger.kernel.org,
	dilieto@lineone.net, Mirko Lindner <mlindner@syskonnect.de>,
	Ralph Roesler <rroesler@syskonnect.de>, arekm@maven.pl,
	Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jared <nitro@legroom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40266 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751936Ab2BQVfX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Feb 2012 16:35:23 -0500
In-Reply-To: <4F3EB4D1.8090002@legroom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Feb 2012 14:13:05 -0600
Jared <nitro@legroom.net> wrote:

> On 02/17/2012 01:01 PM, Stephen Hemminger wrote:
> > On Fri, 17 Feb 2012 19:21:53 +0100
> > Knut Petersen <Knut_Petersen@t-online.de> wrote:
> > 
> >> Your commit broke existing support for WOL on a number of boards.
> >> This is known to you and to bugzilla.kernel org since 2010.  A number of
> >> people complained about that, but nothing happened.
> >>
> >> Neither your original commit description nor the description of the
> >> PXE_LegNat_Sel I found at other places indicate that setting
> >> PXE_LegNat_Sel could do any harm.
> > 
> > 
> > Please lose the attitude. Any support of sky2 is done as a minor side
> > project by me. People find a problem, I put in one fix, then someone else
> > complains and another fix goes in. The regressions happen a lot in power management
> > because the hardware is not well documented in this area and it is a complex
> > interaction of kernel, BIOS, motherboard, and general shittiness of implementations.
> > Because of that I am more likely to believe that what the Marvell code does
> > is more based on experience on other platforms. The out-of-tree Marvell
> > driver contains bits that are part of the Windows driver.
> 
> Attitudes aside, the general problem here is that someone (which I
> believe is you, Stephen, based solely on the commit) committed a patch
> two years ago which broke WoL support for a number of users.  I have no
> doubt that you had some reason for making these changes, but a bug was
> filed about this in 10/02/2010, followed by identification and
> confirmation of both the problem and a solution 1 week later, and
> absolutely nothing has been done since then.  Here's the bug:
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=19492


Kernel bugzilla is ignored by network developers.
Sorry, but that's life.

> I think we all understand that you volunteer your time for this, and I'm
> most appreciative of your (and all kernel developer's) efforts, but
> that's a long time for a known and easily fixable regression to be
> ignored, without even a single comment on the issue since the fix was
> identified.  And I will admit that I'm also pretty frustrated by the
> need to re-patch the kernel on my server every single time I update it
> to fix an obvious and known regression that, prior 2.6.34, worked
> perfectly fine.
> 
> To Knut's points, my own motherboard (from Asus) is no longer supported
> by the vendor either at this point, so a fix from that side is not
> likely.  Is there any particular reason, any known side effects, why
> this newer patch from Knut cannot be applied?  As thing's stand now,
> there is already a definite problem, so unless there's a risk of
> creating a larger, more widespread problem I think it'd make sense to
> apply the patch and fix the current issue.
> 
> Clearly I'm no developer, but as a user that's been affected by this
> problem for over a year and a half now I thought it worth chiming in.  I
> hope some resolution can be reached on this.

Going back to the bug report:

05:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053 PCI-E
Gigabit Ethernet Controller (rev 15)
        Subsystem: ASUSTeK Computer Inc. Marvell 88E8053 Gigabit Ethernet
controller PCIe (Asus)
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 36
        Region 0: Memory at d9000000 (64-bit, non-prefetchable) [size=16K]
        Region 2: I/O ports at 9000 [size=256]
        Expansion ROM at d8000000 [disabled] [size=128K]
        Capabilities: [48] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-

The root cause of the system (in the bug report) not doing WOL
is that the device has not been configured to enable Power Management
Enable. This is a BIOS function and the driver (like most drivers)
gets the setting of PCI wakeup from core PCI layer. The core PCI
gets it's values from the BIOS.

The documentation of that bit is for Bit 15 of "Our Register 1"

  0 = PCI Express PME mechanism: Wake# can be asserted only
      when Vmain is not available (in L2 Link state). Once Wake#
      has been asserted, it must continue to be driven low until Vmain
      is restored. After deassertion of Wake# the PCI Express link is
      initialized. The the adapter sends a PM_PME message signaling
      the system to clear the PME status bit.
  1 = Debug mode of PME mechanism. This is only a debug mode.
      The behavior of the WAKE# pin is dependent on wake events
      and is independent of Vmain. No PM_PME message is generated
      in debug mode. The PME mechanism is the same as in PCI or PCI-X
      mode.
   Reset by Power On Reset

So you patch is just setting the bit that overrides proper PME
support and allows wake to work even if disabled in BIOS.
