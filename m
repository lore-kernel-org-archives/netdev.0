From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 0/3] [RFC] ptp: IEEE 1588 clock support
Date: Tue, 27 Apr 2010 11:13:44 +0200
Message-ID: <20100427091344.GA5086@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:59713 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830Ab0D0JNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 05:13:53 -0400
Received: by pzk42 with SMTP id 42so8673988pzk.4
        for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 02:13:52 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now and again there has been some talk on this list of adding PTP
support into Linux. One part of the picture is already in place, the
SO_TIMESTAMPING API for hardware time stamping. It has been pointed
out that this API is not perfect, however, it is good enough for many
real world uses of IEEE 1588. The second needed part has not, AFAICT,
ever been addressed.

Here I offer an early draft of an idea how to bring the missing
functionality into Linux. I don't yet have all of the features
implemented, as described below. Still I would like to get your
feedback concerning this idea before getting too far into it. I do
have all of the hardware mentioned at hand, so I have a good idea that
the proposed API covers the features of those clocks.

Thanks in advance for your comments,

Richard

* PTP infrastructure for Linux

  This patch set introduces support for IEEE 1588 PTP clocks in
  Linux. Together with the SO_TIMESTAMPING socket options, this
  presents standardized method for developing PTP user space programs,
  synchronizing Linux with external clocks, and using the ancillary
  features of PTP hardware clocks.

  A new class driver exports a kernel interface for specific clock
  drivers and a user space interface. The infrastructure supports a
  complete set of PTP functionality.

  + Basic clock operations
    - Set time
    - Get time
    - Shift the clock by a given offset atomically
    - Adjust clock frequency

  + Ancillary clock features
    - One short or periodic alarms, with signal delivery to user program
    - Time stamp external events
    - Period output signals configurable from user space
    - Synchronization of the Linux system time via the PPS subsystem

** PTP kernel API

   A PTP clock driver registers itself with the class driver. The
   class driver handles all of the dealings with user space. The
   author of a clock driver need only implement the details of
   programming the clock hardware. The clock driver notifies the class
   driver of asynchronous events (alarms and external time stamps) via
   a simple message passing interface.

   The class driver supports multiple PTP clock drivers. In normal use
   cases, only one PTP clock is needed. However, for testing and
   development, it can be useful to have more than one clock in a
   single system, in order to allow performance comparisons.

** PTP user space API

   The class driver creates a character device for each registered PTP
   clock. User space programs may control the clock via standardized
   ioctls. A program may query, enable, configure, and disable the
   ancillary clock features. User space can receive time stamped
   events via blocking read() and poll(). One shot and periodic
   signals may be configured via an ioctl API with similar semantics
   to the POSIX timer_settime() system call.

** Supported hardware

   + Standard Linux system timer
     - No special PTP features
     - For use with software time stamping

   + Freescale eTSEC gianfar
     - 2 Time stamp external triggers, programmable polarity (opt. interrupt)
     - 2 Alarm registers (optional interrupt)
     - 3 Periodic signals (optional interrupt)

   + National DP83640
     - 6 GPIOs programmable as inputs or outputs
     - 6 GPIOs with dedicated functions (LED/JTAG/clock) can also be
       used as general inputs or outputs
     - GPIO inputs can time stamp external triggers
     - GPIO outputs can produce periodic signals
     - 1 interrupt pin

   + Intel IXP465
     - Auxiliary Slave/Master Mode Snapshot (optional interrupt)
     - Target Time (optional interrupt)


Richard Cochran (3):
  ptp: Added a brand new class driver for ptp clocks.
  ptp: Added a clock that uses the Linux system time.
  ptp: Added a clock that uses the eTSEC found on the MPC85xx.

 Documentation/ptp/testptp.c      |  130 +++++++++++++++++
 Documentation/ptp/testptp.mk     |   33 +++++
 drivers/Kconfig                  |    2 +
 drivers/Makefile                 |    1 +
 drivers/net/Makefile             |    1 +
 drivers/net/gianfar_ptp.c        |  269 +++++++++++++++++++++++++++++++++++
 drivers/net/gianfar_ptp_reg.h    |  107 ++++++++++++++
 drivers/ptp/Kconfig              |   51 +++++++
 drivers/ptp/Makefile             |    6 +
 drivers/ptp/ptp_clock.c          |  287 ++++++++++++++++++++++++++++++++++++++
 drivers/ptp/ptp_linux.c          |  119 ++++++++++++++++
 include/linux/Kbuild             |    1 +
 include/linux/ptp_clock.h        |   37 +++++
 include/linux/ptp_clock_kernel.h |  132 +++++++++++++++++
 kernel/time/ntp.c                |    2 +
 15 files changed, 1178 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/ptp/testptp.c
 create mode 100644 Documentation/ptp/testptp.mk
 create mode 100644 drivers/net/gianfar_ptp.c
 create mode 100644 drivers/net/gianfar_ptp_reg.h
 create mode 100644 drivers/ptp/Kconfig
 create mode 100644 drivers/ptp/Makefile
 create mode 100644 drivers/ptp/ptp_clock.c
 create mode 100644 drivers/ptp/ptp_linux.c
 create mode 100644 include/linux/ptp_clock.h
 create mode 100644 include/linux/ptp_clock_kernel.h

