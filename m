From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14691] New: Complete NAPI IRQ lockup in b44
 driver: code fundamentally incompatible with netconsole requirements
Date: Wed, 25 Nov 2009 13:16:31 -0800
Message-ID: <20091125131631.46483ce0.akpm@linux-foundation.org>
References: <bug-14691-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	andi@lisas.de
To: Gary Zambrano <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34577 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758099AbZKYVRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 16:17:01 -0500
In-Reply-To: <bug-14691-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 25 Nov 2009 20:15:33 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14691
> 
>            Summary: Complete NAPI IRQ lockup in b44 driver: code
>                     fundamentally incompatible with netconsole
>                     requirements
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.32-rc8
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: andi@lisas.de
>         Regression: No
> 
> 
> Hi,
> 
> severity "blocking" (== "Blocks development and/or testing work"): it's my
> primary window to the world on this router - netconsole - and crashes multiple
> times when loading various drivers, thus for me there's no productive
> proceeding possible, plus there have been multiple reports on this issue since
> at least 2004.
> 
> The kernel version I'm testing it on is 2.6.30.9 (OpenWrt MIPSEL, on ASUS
> WL-500gP v2), but since b44 interrupt handler is unchanged I assume it's still
> unfixed.
> 
> Frequently when doing some medium activity such as loading modules such as
> ftdi_sio, usb_audio etc. (especially with kobject debugging enabled), the
> network LED starts blinking like crazy and when re-listening to netconsole
> output, there's simply a flood of
> %s: Error, poll already scheduled
> and the box is DEAD (again! *curse*).
> 
> Productive debugging of multiple USB and ftdi_sio issues is simply impossible
> with this kind of problem remaining.
> 
> See also:
> "RE:hostname freeze" (2004!!):
> http://lists.linuxcoding.com/rhl/2004/msg51048.html
> 
> "b44 driver suspend/resume (was Re: [ACPI] Re: Re: various problems with Acer
> TM654, suspend, ACAD, radeon)":
> http://osdir.com/ml/network.general/2004-08/msg00208.html
> 
> "acpi and b44: irq disabled, b44: Error, poll already scheduled" (2004!!):
> http://lkml.indiana.edu/hypermail/linux/kernel/0408.3/0078.html
> 
> And a very related fix and long discussion is at:
> "[PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts":
> http://kerneltrap.org/mailarchive/linux-netdev/2009/5/23/5791863
> 
> I'm very uncertain whether the interrupt handler method of simply screaming
> this error message on every interrupt without doing any actual remedies is a
> good idea.
> HAH! Now I've got it: the fact that we're on netconsole means that this error
> message gets sent _immediately_ (out to the netconsole device!!), thus this
> very network transmission encounters an IRQ handler at a time where the
> previous scheduled NAPI processing had no chance yet of being done, thus
> napi_schedule_prep() FAIL, thus error message again, thus... ad nauseam!
> Or, IOW, now I'm _certain_ that it is _NOT_ a good idea to scream this message
> on every IRQ without doing anything about it.
> 
> 
> I want to report this issue now to make sure it can get the attention it
> deserves, but for now I'll try to come up with a bandaid locally (simply
> silencing the error message) in order to be able to debug the other driver
> issues mentioned above.
> 
> Thanks!

