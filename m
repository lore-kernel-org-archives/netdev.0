From: Christopher Hall <christopher.s.hall@intel.com>
Subject: [PATCH v2 0/4] Patchset enabling hardware based cross-timestamps for next gen Intel platforms
Date: Fri,  7 Aug 2015 16:01:31 -0700
Message-ID: <1438988495-9942-1-git-send-email-christopher.s.hall@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Christopher Hall <christopher.s.hall@intel.com>
To: john.stultz@linaro.org, tglx@linutronix.de,
	richardcochran@gmail.com, mingo@redhat.com,
	jeffrey.t.kirsher@intel.com, john.ronciak@intel.com, hpa@zytor.com,
	x86@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

6th generation Intel platforms will have an Always Running
Timer (ART) that always runs when the system is powered and
is available to both the CPU and various on-board devices.
Initially, those devices include audio and network.  The
ART will give these devices the capability of precisely
cross timestamping their local device clock with the system
clock.

A system clock value like TSC or ART is not useful
unless translated to system time. The first *two* patches
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

* v2 re-submit based on tglx provided correlated clocksource patch.  This has
  been included verbatim as the first patch in the series.  Additions and
  modifications are in the second patch.  The PTP driver patch is unchanged
  and the e1000e driver patch uses the *new* correlated clocksource interface
  but is otherwise (in terms of hardware and PTP driver) unchanged.

* ART is removed as a compile option

* ART is added as an X86_FEATURE

Christopher Hall (4):
  Add generic correlated clocksource code and ART to TSC conversion code
  Add ART initialization code
  Add support for driver cross-timestamp to PTP_SYS_OFFSET ioctl
  Added getsynctime64() callback

 Documentation/ptp/testptp.c                 |  6 +-
 arch/x86/include/asm/cpufeature.h           |  3 +-
 arch/x86/include/asm/tsc.h                  |  1 +
 arch/x86/kernel/tsc.c                       | 45 +++++++++++++++
 drivers/net/ethernet/intel/e1000e/defines.h |  7 +++
 drivers/net/ethernet/intel/e1000e/ptp.c     | 88 +++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/e1000e/regs.h    |  4 ++
 drivers/ptp/ptp_chardev.c                   | 29 +++++++---
 include/linux/clocksource.h                 | 32 +++++++++++
 include/linux/ptp_clock_kernel.h            |  7 +++
 include/linux/timekeeping.h                 |  4 ++
 include/uapi/linux/ptp_clock.h              |  4 +-
 kernel/time/timekeeping.c                   | 64 +++++++++++++++++++++
 13 files changed, 282 insertions(+), 12 deletions(-)

-- 
1.9.1
