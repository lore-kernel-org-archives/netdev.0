From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V7 0/8] ptp: IEEE 1588 hardware clock support
Date: Thu, 16 Dec 2010 16:41:37 +0100
Message-ID: <cover.1292512461.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-api@vger.kernel.org, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here comes PTP Hardware Clock (PHC) support, version 7, and hopefully
everyone will like it.

The first four patches provide infrastructure supporting dynamic POSIX
clock devices. This new code will be useful for other kinds of new
clocks, not just PHCs. The last four patches implement the PHC code.

Table of Contents
=================
1 Introduction 
2 Patch Set Overview 
3 Previous Discussions 
4 Design Issues 
    4.1 Clock Operations 
    4.2 System Calls for Clock Tuning 
        4.2.1 Using the POSIX Clock API 
        4.2.2 Tuning a POSIX Clock 
        4.2.3 Dynamic POSIX Clock IDs 
    4.3 Synchronizing the Linux System Time 
    4.4 Ancillary PHC Operations 
    4.5 User timers 
5 Drivers 
    5.1 Supported Hardware Clocks 
    5.2 Open Driver Issues 
        5.2.1 DP83640 
        5.2.2 IXP465 
6 Diff Stat

1 Introduction 
~~~~~~~~~~~~~~~

  The aim of this patch set is to add support for PTP Hardware Clocks
  (PHCs) into the Linux kernel.  Support for obtaining timestamps from
  a PHC already exists via the SO_TIMESTAMPING socket option,
  integrated in kernel version 2.6.30.  This patch set completes the
  picture by allow user space programs to adjust the PHC and to
  control its ancillary features.

2 Patch Set Overview 
~~~~~~~~~~~~~~~~~~~~~

  - Patch 1 adds an ADJ_SETOFFSET mode bit to the NTP timex
    structure. The new bit allows a correction of a time offset.

  - Patch 2 adds a new system call, clock_adjtime(), which is like the
    NTP adjtimex call for POSIX clocks.

  - Patches 3 and 4 add dynamic POSIX clocks.

  - The remaining patches add the core PHC code, complete with three
    drivers.

3 Previous Discussions 
~~~~~~~~~~~~~~~~~~~~~~~

  This patch set previously appeared on the netdev list. Since V5 of
  the character device patch set, the discussion has moved to the
  lkml.

  - IEEE 1588 hardware clock support [V5]
    [http://lkml.org/lkml/2010/8/16/90]

  - POSIX clock tuning syscall with static clock ids
    [http://lkml.org/lkml/2010/8/23/49]

  - POSIX clock tuning syscall with dynamic clock ids
    [http://lkml.org/lkml/2010/9/3/119]

  - IEEE 1588 hardware clock support [V6]
    [http://lkml.org/lkml/2010/9/23/310]

  - Dynamic clock devices [RFC]
    [http://lkml.org/lkml/2010/11/4/290]

4 Design Issues 
~~~~~~~~~~~~~~~~

  The following treatment of the design issues previously appeared
  with the V6 version of the patch set. The text has been updated to
  reflect the current patch set.

4.1 Clock Operations 
=====================

   Based on experience with several commercially available PHCs, we
   identified a set of essential operations and a set of ancillary
   operations.

   - Basic clock operations

     1. Set time
     2. Get time
     3. Shift the clock by a given offset atomically
     4. Adjust clock frequency

   - Ancillary clock features

     1. Time stamp external events
     2. Enable Linux PPS subsystem events
     3. Periodic output signals
     4. One shot or periodic alarms, with CPU interrupt

    The patch set includes examples of the first two ancillary
    features, and implementing the third point for a particular PHC is
    fairly straightforward. The fourth point is discussed below.

4.2 System Calls for Clock Tuning 
==================================

4.2.1 Using the POSIX Clock API 
--------------------------------

    Looking at the mapping from PHC operation to the POSIX clock API,
    we see that two of the basic clock operations, marked with *, have
    no POSIX equivalent. The items marked NA are peculiar to PHCs and
    will be discussed separately, below.
    
      Clock Operation               POSIX function               
     -----------------------------+-----------------------------
      Set time                      clock_gettime                
      Get time                      clock_settime                
      Shift the clock               *                            
      Adjust clock frequency        *                            
     -----------------------------+-----------------------------
      Time stamp external events    NA                           
      Enable PPS events             NA                           
      Periodic output signals       NA                           
      One shot or periodic alarms   timer_create, timer_settime  

    In contrast to the standard Linux system clock, a PHC is
    adjustable in hardware, for example using frequency compensation
    registers or a VCO. The ability to directly tune the PHC is
    essential to reap the benefit of hardware timestamping.

4.2.2 Tuning a POSIX Clock 
---------------------------

    The patch set introduces a new system call which allows tuning of
    a POSIX clock. The function combines the 'struct timex' from the
    NTP adjtimex syscall with a POSIX clock id.

    clock_adjtime(clockid_t, struct timex *);

    Using the timex interface as the basis of the new call allows
    supporting the tried and true NTP semantics.  By adding one
    additional mode flag to the struct timex, the requirements for
    PHCs are also satisfied. In the future, if new clocks appear that
    require more elaborate control, then the padding at the end of the
    struct reserves 44 bytes for new fields.

4.2.3 Dynamic POSIX Clock IDs 
------------------------------

    The reaction on the list to having a static id like CLOCK_PTP was
    mostly negative. However, the idea of generating a clock id
    dynamically seems to have gained acceptance. The general idea is
    to represent the clocks as character devices. After opening the
    character device, the file descriptor may be also used as a clock
    id by applying a simple transformation.

4.3 Synchronizing the Linux System Time 
========================================

   One could offer a PHC as a combined clock source and clock event
   device. The advantage of this approach would be that it obviates
   the need for synchronization when the PHC is selected as the system
   timer. However, some PHCs, namely the PHY based clocks, cannot be
   used in this way.

   Instead, the patch set provides a way to offer a Pulse Per Second
   (PPS) event from the PHC to the Linux PPS subsystem. A user space
   application can read the PPS events and tune the system clock, just
   like when using other external time sources like radio clocks or
   GPS.

4.4 Ancillary PHC Operations 
=============================

   Most PHCs offer hardware interfaces to the outside world, that is,
   the "real world". It is important to offer support for these
   operations, since leaving them out would defeat the utility of
   having a PHC in the first place. These operations do not map at all
   to the POSIX clock functions, but one could offer them as a
   character device or via sysfs.

   Fearing a lkml debate on the merits of either one, I went ahead and
   implemented both cases. Both approaches adequately cover the needed
   functionality, in my opinion. The code for each is in its own .c
   file, so it will be easy enough to remove one of them. I don't mind
   leaving both ways in, either.

4.5 User timers 
================

   Using the POSIX clock API gived user space the possibility to
   create and use timers with timer_create and timer_settime. In the
   current patch set the kernel functionality is not implemented,
   since there are some issues to consider first. I see two ways to do
   about this.

   1. Implement the functionality anew. This approach might end up
      duplicating similar code that already exists. Also, looking at
      the hrtimer code, getting user timers right seems to have a
      number of gotchas and thorny issues.

   2. Reuse the hrtimer code. Since the hrtimer code uses a clock
      event device under the hood, it might be possible (in theory) to
      offer capable PHCs as clock event devices. However, the current
      hrtimers are hard-coded to the event device via a per-cpu
      global. Perhaps one could associate an event device with a
      hrtimer via the timer itself.

   At this point I am not optimistic about either approach, and I
   would vote for postponing the timer issue indefinitely. The
   implementation effort would be high, but the utility low.

   If the Linux system time is synchronized to the PHC via the PPS
   method, then using standard hrtimers would be good enough for most
   purposes. Consider the time scales involved. The PHC can be
   synchronized to within 100 nanoseconds of an external time source,
   while timer wakeup latency (even with rt kernels) is tens of
   microseconds.

5 Drivers 
~~~~~~~~~~

5.1 Supported Hardware Clocks 
==============================

   + Freescale eTSEC gianfar
     - 2 Time stamp external triggers, programmable polarity (opt. interrupt)
     - 2 Alarm registers (optional interrupt)
     - 3 Periodic signals (optional interrupt)

   + National Semiconductor DP83640
     - 6 GPIOs programmable as inputs or outputs
     - 6 GPIOs with dedicated functions (LED/JTAG/clock) can also be
       used as general inputs or outputs
     - GPIO inputs can time stamp external triggers
     - GPIO outputs can produce periodic signals
     - 1 interrupt pin

   + Intel IXP465
     - Auxiliary Slave/Master Mode Snapshot (optional interrupt)
     - Target Time (optional interrupt)

5.2 Open Driver Issues 
=======================

5.2.1 DP83640 
--------------
    In order to make this work, one line must be added into the MAC
    driver. If you have the DP83640 and want to try the driver, you
    need to add this one line to your MAC driver: In the
    .ndo_start_xmit function, add skb_tx_timestamp(skb).

5.2.2 IXP465 
-------------
    I do not know how to correctly choose the timestamp "channel"
    based on the port identifier:

+#define PORT2CHANNEL(p)                1
+/*
+ * PHYSICAL_ID(p->id) ?
+ * TODO - Figure out correct mapping.
+ */

   Krzysztof, can you help?

6 Diff Stat
~~~~~~~~~~~

Richard Cochran (8):
  ntp: add ADJ_SETOFFSET mode bit
  posix clocks: introduce a syscall for clock tuning.
  posix clocks: introduce dynamic clocks
  posix clocks: hook dynamic clocks into system calls
  ptp: Added a brand new class driver for ptp clocks.
  ptp: Added a clock that uses the eTSEC found on the MPC85xx.
  ptp: Added a clock driver for the IXP46x.
  ptp: Added a clock driver for the National Semiconductor PHYTER.

 Documentation/ABI/testing/sysfs-ptp             |  107 +++
 Documentation/powerpc/dts-bindings/fsl/tsec.txt |   57 ++
 Documentation/ptp/ptp.txt                       |   94 +++
 Documentation/ptp/testptp.c                     |  352 +++++++++
 Documentation/ptp/testptp.mk                    |   33 +
 arch/arm/include/asm/unistd.h                   |    1 +
 arch/arm/kernel/calls.S                         |    1 +
 arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h   |   78 ++
 arch/blackfin/include/asm/unistd.h              |    3 +-
 arch/blackfin/mach-common/entry.S               |    1 +
 arch/powerpc/boot/dts/mpc8313erdb.dts           |   14 +
 arch/powerpc/boot/dts/mpc8572ds.dts             |   14 +
 arch/powerpc/boot/dts/p2020ds.dts               |   14 +
 arch/powerpc/boot/dts/p2020rdb.dts              |   14 +
 arch/powerpc/include/asm/systbl.h               |    1 +
 arch/powerpc/include/asm/unistd.h               |    3 +-
 arch/x86/ia32/ia32entry.S                       |    1 +
 arch/x86/include/asm/unistd_32.h                |    3 +-
 arch/x86/include/asm/unistd_64.h                |    2 +
 arch/x86/kernel/syscall_table_32.S              |    1 +
 drivers/Kconfig                                 |    2 +
 drivers/Makefile                                |    1 +
 drivers/char/mmtimer.c                          |    1 +
 drivers/net/Makefile                            |    1 +
 drivers/net/arm/ixp4xx_eth.c                    |  191 +++++
 drivers/net/gianfar_ptp.c                       |  444 +++++++++++
 drivers/net/gianfar_ptp_reg.h                   |  113 +++
 drivers/net/phy/Kconfig                         |   29 +
 drivers/net/phy/Makefile                        |    1 +
 drivers/net/phy/dp83640.c                       |  890 +++++++++++++++++++++++
 drivers/net/phy/dp83640_reg.h                   |  261 +++++++
 drivers/ptp/Kconfig                             |   53 ++
 drivers/ptp/Makefile                            |    7 +
 drivers/ptp/ptp_chardev.c                       |  144 ++++
 drivers/ptp/ptp_clock.c                         |  317 ++++++++
 drivers/ptp/ptp_ixp46x.c                        |  342 +++++++++
 drivers/ptp/ptp_private.h                       |   68 ++
 drivers/ptp/ptp_sysfs.c                         |  230 ++++++
 include/linux/Kbuild                            |    1 +
 include/linux/posix-clock.h                     |  136 ++++
 include/linux/posix-timers.h                    |   32 +-
 include/linux/ptp_clock.h                       |   79 ++
 include/linux/ptp_clock_kernel.h                |  139 ++++
 include/linux/syscalls.h                        |    2 +
 include/linux/time.h                            |    2 +
 include/linux/timex.h                           |    3 +-
 kernel/compat.c                                 |  136 +++--
 kernel/posix-cpu-timers.c                       |    6 +
 kernel/posix-timers.c                           |  151 ++++-
 kernel/time/Makefile                            |    3 +-
 kernel/time/ntp.c                               |   26 +
 kernel/time/posix-clock.c                       |  376 ++++++++++
 52 files changed, 4911 insertions(+), 70 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-ptp
 create mode 100644 Documentation/ptp/ptp.txt
 create mode 100644 Documentation/ptp/testptp.c
 create mode 100644 Documentation/ptp/testptp.mk
 create mode 100644 arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h
 create mode 100644 drivers/net/gianfar_ptp.c
 create mode 100644 drivers/net/gianfar_ptp_reg.h
 create mode 100644 drivers/net/phy/dp83640.c
 create mode 100644 drivers/net/phy/dp83640_reg.h
 create mode 100644 drivers/ptp/Kconfig
 create mode 100644 drivers/ptp/Makefile
 create mode 100644 drivers/ptp/ptp_chardev.c
 create mode 100644 drivers/ptp/ptp_clock.c
 create mode 100644 drivers/ptp/ptp_ixp46x.c
 create mode 100644 drivers/ptp/ptp_private.h
 create mode 100644 drivers/ptp/ptp_sysfs.c
 create mode 100644 include/linux/posix-clock.h
 create mode 100644 include/linux/ptp_clock.h
 create mode 100644 include/linux/ptp_clock_kernel.h
 create mode 100644 kernel/time/posix-clock.c
