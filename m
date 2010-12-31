From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH V8 00/13] ptp: IEEE 1588 hardware clock support
Date: Fri, 31 Dec 2010 20:11:26 +0100
Message-ID: <cover.1293820862.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

* Introduction

  The aim of this patch set is to add support for PTP Hardware Clocks
  (PHCs) into the Linux kernel.

* PTP Patch ChangeLog
** v8
   - incorporates Arnd Bergmann's and Thomas Gleixner's comments from v7
   - use John Stultz's timekeeping_inject_offset in do_adjtimex()
   - adds new syscall clock_adjtime to each arch individually
   - cleaned up the CLOCK_DISPATCH mess
   - redsigned posix_clock_operations:
     . remove compat_ioctl
     . flatten clock ops and chardev ops into one structure
     . drivers use container_of to get private data
   - removed unused and useless code from posix-clock.c|h
   - moved posix-clock syscall prototypes into private header
   - moved extern declaration from c source file into header
   - ptp drivers use container_of to get private data

* Previous Discussions

  This patch set previously appeared on the netdev list. Since V5 of
  the character device patch set, the discussion has moved to the
  lkml.

  - IEEE 1588 hardware clock support [V5]
    http://lkml.org/lkml/2010/8/16/90

  - POSIX clock tuning syscall with static clock ids
    http://lkml.org/lkml/2010/8/23/49

  - POSIX clock tuning syscall with dynamic clock ids
    http://lkml.org/lkml/2010/9/3/119

  - IEEE 1588 hardware clock support [V6]
    http://lkml.org/lkml/2010/9/23/310

  - Dynamic clock devices [RFC]
    http://lkml.org/lkml/2010/11/4/290

  - IEEE 1588 hardware clock support [V7]
    http://lkml.org/lkml/2010/12/16/195


John Stultz (1):
  time: Introduce timekeeping_inject_offset

Richard Cochran (12):
  ntp: add ADJ_SETOFFSET mode bit
  posix clocks: introduce a syscall for clock tuning.
  posix_clocks: add clock_adjtime for arm
  posix_clocks: add clock_adjtime for blackfin
  posix_clocks: add clock_adjtime for powerpc
  posix_clocks: add clock_adjtime for x86
  posix clocks: cleanup the CLOCK_DISPTACH macro
  posix clocks: introduce dynamic clocks
  ptp: Added a brand new class driver for ptp clocks.
  ptp: Added a clock that uses the eTSEC found on the MPC85xx.
  ptp: Added a clock driver for the IXP46x.
  ptp: Added a clock driver for the National Semiconductor PHYTER.

 Documentation/ABI/testing/sysfs-ptp             |   97 +++
 Documentation/powerpc/dts-bindings/fsl/tsec.txt |   57 ++
 Documentation/ptp/ptp.txt                       |   93 +++
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
 drivers/net/gianfar_ptp.c                       |  448 +++++++++++
 drivers/net/gianfar_ptp_reg.h                   |  113 +++
 drivers/net/phy/Kconfig                         |   29 +
 drivers/net/phy/Makefile                        |    1 +
 drivers/net/phy/dp83640.c                       |  896 +++++++++++++++++++++++
 drivers/net/phy/dp83640_reg.h                   |  261 +++++++
 drivers/ptp/Kconfig                             |   53 ++
 drivers/ptp/Makefile                            |    7 +
 drivers/ptp/ptp_chardev.c                       |  146 ++++
 drivers/ptp/ptp_clock.c                         |  318 ++++++++
 drivers/ptp/ptp_ixp46x.c                        |  344 +++++++++
 drivers/ptp/ptp_private.h                       |   86 +++
 drivers/ptp/ptp_sysfs.c                         |  226 ++++++
 include/linux/Kbuild                            |    1 +
 include/linux/posix-clock.h                     |  137 ++++
 include/linux/posix-timers.h                    |   23 +-
 include/linux/ptp_clock.h                       |   79 ++
 include/linux/ptp_clock_kernel.h                |  141 ++++
 include/linux/syscalls.h                        |    2 +
 include/linux/time.h                            |    3 +
 include/linux/timex.h                           |    3 +-
 kernel/compat.c                                 |  136 +++--
 kernel/posix-cpu-timers.c                       |    6 +
 kernel/posix-timers.c                           |  279 ++++++--
 kernel/time/Makefile                            |    3 +-
 kernel/time/ntp.c                               |   11 +
 kernel/time/posix-clock-syscalls.h              |   39 +
 kernel/time/posix-clock.c                       |  454 ++++++++++++
 kernel/time/timekeeping.c                       |   36 +
 54 files changed, 5163 insertions(+), 97 deletions(-)
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
 create mode 100644 kernel/time/posix-clock-syscalls.h
 create mode 100644 kernel/time/posix-clock.c
