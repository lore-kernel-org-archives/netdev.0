From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 08/12] ptp: Added a brand new class driver for ptp
 clocks.
Date: Wed, 16 Jun 2010 16:22:24 +0200
Message-ID: <20100616142224.GA4146@riccoc20.at.omicron.at>
References: <cover.1276615626.git.richard.cochran@omicron.at>
 <4a030d2bace90f089f2f3f61496b918c6f1dfb52.1276615626.git.richard.cochran@omicron.at>
 <AANLkTin4lYghEWhjzEyARvYDgHaXdniwLbfyZ4jY0rwm@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Thomas Gleixner <tglx@linutronix.de>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:61366 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691Ab0FPOVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 10:21:36 -0400
Received: by fg-out-1718.google.com with SMTP id l26so1556906fgb.1
        for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 07:21:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <AANLkTin4lYghEWhjzEyARvYDgHaXdniwLbfyZ4jY0rwm@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 15, 2010 at 11:00:10AM -0600, Grant Likely wrote:
> 
> Question from an ignorant reviewer:  Why a new interface instead of
> working with the existing high resolution timers infrastructure?

Short answer: Timers are only one part of the PTP API. If you offer
the PTP clock as a Linux clock source, then you could just use the
existing POSIX timers. However, we decided not to offer the PTP clock
in that way. The following excerpts from an upcoming paper explain
why:

\subsection{Basic Clock Operations}

   Based on our experience with a number of commercially available
   hardware clocks, we identified a set of four basic clock
   operations. Besides simply setting or getting the clock's time
   value, two additional operations are needed for clock control.
   Once a PTP slave has an initial estimate of the offset to its
   master, it typically would need to shift the clock by the offset
   atomically.  Also, the servo loop of a slave periodically needs to
   adjust the clock frequency.

\subsection{Ancillary Clock Features}

   Perhaps the most challenging design issue was deciding how to offer
   a PTP clock's capabilities to the GNU/Linux operating system.  As
   John Eidson pointed out~\cite{eidson2006measurement}, modern
   operating systems provide surprisingly little support for
   programming based on absolute time.  As the IEEE 1588 standard is
   being applied to a wide variety of test, measurement, and control
   applications, we can imagine many possible ways to use an embedded
   computer equipped with a PTP hardware clock.  We do not expect that
   any API will be able to cover every conceivable application of this
   technology.  However, the design presented here does cover common
   use cases based on the capabilities of currently available hardware
   clocks.

   The design allows user space programs to control all of a clock's
   ancillary features.  Programs may create one-shot or periodic
   alarms, with signal delivery on expiration.  \Timestamps on
   external events are provided via a First In, First Out (FIFO)
   interface.  If the clock has output signals, then their periods are
   configurable from user space.  Synchronization of the Linux system
   time via the PPS subsystem may be enabled or disabled as desired.

\subsection{Synchronizing the Linux System Clock}

   One important question that needed to be addressed was, now that we
   have a precise time source, how do we synchronize the Linux kernel
   to it?  The Linux kernel offers a modular clock infrastructure
   comprising ``clock sources'' and ``clock event devices.'' Clock
   sources provide a monotonically increasing time base, and clock
   event devices are used to schedule the next interrupt for various
   timer events.

   We considered but ultimately rejected the idea of offering the PTP
   clock to the Linux kernel as a combined clock source and clock
   event device.  The one great advantage of this approach would have
   been that it obviates the need for synchronization when the PTP
   clock is selected as the system timer.

   However, this approach is problematic when using certain kinds of
   clock hardware. For example, physical layer (PHY) chip based clocks
   can only be accessed by the relatively slow 16 bit wide MDIO
   bus. Such a clock would not be suitable for providing high
   resolution timers, which are now a standard Linux kernel feature.
   Furthermore, we cannot even be sure that a given hardware clock
   will offer any interrupt to the system at all.

   Instead, we elected to use the Pulse Per Second (PPS) subsystem as
   a method to optionally synchronize the Linux system time to the PTP
   clock.  This method is feasible even for clocks that do not offer
   fast register access, such as the PHY clocks.  Of course, the main
   disadvantage of this approach is that the Linux system time will
   not be exactly synchronized to the PTP clock time.  Since PTP
   clocks can be synchronized an order of magnitude better than the
   typical operating system scheduling latency, we expect that this
   method will still yield acceptable results for many applications.
   Applications with more demanding time requirements may use the new
   PTP interfaces directly when needed.

\subsection{System Calls or Character Device}

   When adding new functionality to an operating system, a basic design
   decision is how user space programs will call into the kernel.  For
   the Linux kernel, two different ways come into question, namely
   system calls or as a ``character device.''  In an attempt to make
   the PTP clock API easy to understand, we patterned it after the
   existing Network Time Protocol (NTP) and the POSIX timer APIs, as
   described in Section~\ref{UserAPI}.  Both of these services are
   exported to the user space as system calls.  However, we decided to
   offer the PTP clock as a character device because extending the NTP
   and POSIX interfaces seemed impractical.  In addition, the
   character device's \fn{read()} method provides a
   convenient way to deliver time stamped events to user space
   programs.

