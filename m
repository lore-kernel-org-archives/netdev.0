From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [linux-pm] [PATCH 0/4] Fix forcedeth hibernate/wake-on-lan
 problems
Date: Tue, 3 Jun 2008 10:12:38 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.0806031002510.2363-100000@iolanthe.rowland.org>
References: <20080603061618.GB9301@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, <linux-kernel@vger.kernel.org>,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Brownell <david-b@pacbell.net>,
	<linux-acpi@vger.kernel.org>, <linux-pm@lists.linux-foundation.org>
To: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20080603061618.GB9301@yamamaya.is-a-geek.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 3 Jun 2008, Tobias Diedrich wrote:

> One of the ports on the back of the board seems to be broken (Maybe
> esd?), the other three work fine, but nothing happens when I plug a
> device into that one, so I guess that's the culprit.

Sounds like it.

> > The log didn't reveal anything.  Perhaps you can learn more by looking 
> > at the "registers" file for that OHCI controller in debugfs.
> 
> Ok, I can try that this evening...
> 
> > Also, you should run "lspci -vv" as root to see what wakeup signals the 
> > USB controllers are issuing.

...

> 00:02.0 USB Controller: nVidia Corporation MCP55 USB Controller (rev a1) (prog-if 10 [OHCI])
> 	Subsystem: ASUSTeK Computer Inc. Unknown device 8239
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0 (750ns min, 250ns max)
> 	Interrupt: pin A routed to IRQ 23
> 	Region 0: Memory at fe02f000 (32-bit, non-prefetchable) [size=4K]
> 	Capabilities: [44] Power Management version 2
> 		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 	Kernel driver in use: ohci_hcd

The OHCI controller settings look normal.  It doesn't appear to be 
sending a wakeup signal.

> 00:02.1 USB Controller: nVidia Corporation MCP55 USB Controller (rev a2) (prog-if 20 [EHCI])
> 	Subsystem: ASUSTeK Computer Inc. Unknown device 8239
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0 (750ns min, 250ns max)
> 	Interrupt: pin B routed to IRQ 20
> 	Region 0: Memory at fe02e000 (32-bit, non-prefetchable) [size=256]
> 	Capabilities: [44] Debug port: BAR=1 offset=0098
> 	Capabilities: [80] Power Management version 2
> 		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME+
> 	Kernel driver in use: ehci_hcd

The EHCI controller settings, however, are strange.  The relevant part 
is the Power Management Status line near the end:

> 		Status: D0 PME-Enable- DSel=0 DScale=0 PME+

This means the controller is in the D0 state (as expected) and 
PME-Enable is currently turned off ("PME" stands for "Power Management 
Event").  But the PME+ at the end means that as soon as PME does get 
enabled -- like when the controller is suspended at the start of a 
system sleep -- it _will_ send a PME signal.

So for some reason your EHCI controller thinks a wakeup event is 
pending.  This means you should examine the contents of the "registers" 
file in the debugfs directory for the EHCI controller, not OHCI.

Alan Stern

