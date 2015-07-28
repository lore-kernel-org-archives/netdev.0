From: Christopher Hall <christopher.s.hall@intel.com>
Subject: [PATCH 0/5] Patchset enabling hardware based cross-timestamps for next gen Intel platforms
Date: Mon, 27 Jul 2015 17:46:51 -0700
Message-ID: <1438044416-15588-1-git-send-email-christopher.s.hall@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Christopher Hall <christopher.s.hall@intel.com>
To: john.stultz@linaro.org, tglx@linutronix.de,
	richardcochran@gmail.com, mingo@redhat.com,
	jeffrey.t.kirsher@intel.com, john.ronciak@intel.com, hpa@zytor.com,
	x86@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Next generation Intel platforms will have an Always Running
Timer (ART) that always runs when the system is powered and
is available to both the CPU and various on-board devices.
Initially, those devices include audio and network.  The
ART will give these devices the capability of precisely
cross timestamping their local device clock with the system
clock.

A system clock value like TSC or ART is not useful
unless translated to system time. The first three patches
enable this by changing the timekeeping code to return a
system time given a system clock value and translating ART
to TSC.

The last two patches modify the PTP driver to call a
cross timestamp function in the driver when available and
perform the cross timestamp in the e1000e driver.

Given the precise relationship between the network device
clock and system time enables better synchronization of
events on multiple network connected devices.

Changelog:

* The PTP portion of the patch set was posted 7/8/2015 (v3)
  and rejected because of there wasn't a driver that
  implemented the new API.  Now, the driver patch is added
  and the PTP patch operation is modified to revert to
  previous behavior when cross timestamp can't be
  completed.  This is indicated by the driver returning a
  non-zero value.

Christopher Hall (5):
  Add functions producing system time given a backing counter value
  Added functions mapping TSC value to system time
  Add calls to translate Always Running Timer (ART) to system time
  Add support for driver cross-timestamp to PTP_SYS_OFFSET ioctl
  Enables cross timestamping in the e1000e driver

 Documentation/ptp/testptp.c                 |   6 +-
 arch/x86/Kconfig                            |  12 ++
 arch/x86/include/asm/art.h                  |  42 ++++++
 arch/x86/include/asm/tsc.h                  |   5 +
 arch/x86/kernel/Makefile                    |   1 +
 arch/x86/kernel/art.c                       | 134 ++++++++++++++++++
 arch/x86/kernel/tsc.c                       |  22 +++
 drivers/net/ethernet/intel/e1000e/defines.h |   7 +
 drivers/net/ethernet/intel/e1000e/ptp.c     |  77 ++++++++++
 drivers/net/ethernet/intel/e1000e/regs.h    |   4 +
 drivers/ptp/ptp_chardev.c                   |  29 ++--
 include/linux/ptp_clock_kernel.h            |   7 +
 include/linux/timekeeping.h                 |   8 ++
 include/uapi/linux/ptp_clock.h              |   4 +-
 kernel/time/timekeeping.c                   | 211 +++++++++++++++++++++++++---
 15 files changed, 538 insertions(+), 31 deletions(-)
 create mode 100644 arch/x86/include/asm/art.h
 create mode 100644 arch/x86/kernel/art.c

-- 
1.9.1
