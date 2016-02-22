From: "Christopher S. Hall" <christopher.s.hall@intel.com>
Subject: [PATCH v8 0/8] Patchset enabling hardware based cross-timestamps for next gen Intel platforms
Date: Mon, 22 Feb 2016 03:15:18 -0800
Message-ID: <1456139726-3327-1-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	x86@kernel.org, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	kevin.b.stanton@intel.com, kevin.j.clarke@intel.com
To: tglx@linutronix.de, richardcochran@gmail.com, mingo@redhat.com,
	john.stultz@linaro.org, hpa@zytor.com, jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modern Intel hardware adds an Always Running Timer (ART) that allows the
network and audio device clocks to precisely cross timestamp the device
clock with the system clock. This allows a precise correlation of the
device time and system time.

This patchset adds interfaces to the timekeeping code allowing drivers
to translate ART time to system time.

Changelog:

Changes from v7 to v8:

*	Fix comments in timekeeping.c
*	Re-use older TSC feature, removing "invariant" TSC in ART
	detection code

Changes from v6 to v7:

*	Reorder several patches
*	Removed correlated clocksource
*	Fixed 32-bit compile issues
*	Added multiplication overflow detection to history computation
*	Added invariant tsc CPU feature - this is related to ART, but
	is a separate feature


Changes from v5 to v6:

*	Pulled supporting code for snapshotting, correlated
	clocksource, and cycles to nanoseconds translation to separate
	patches. Added patches are marked as NEW below. There is,
	however, very little *actually* new code, just reorganized
	code
*	Renamed and moved clocksource change sequence to timekeeper
	struct (out of tk_read_base)
*	Renamed structs for system counter and synced device time
	callback to system_counterval_t and sync_device_time_cb,
	respectively
*	Changed PTP cross-timestamp callback name to getcrosststamp
	for consistency with the timekeeping code - corresponding
	function name changes in e1000e driver
*	Simplified PTP time calculations making use of ktime_to_* code

Changes from v4 to v5:

*	Changes the history mechanism to interpolate system time using
	a single historic system time pair (monotonic raw, realtime)
	rather than implementing a precise history using shadow
	timekeeper (see v4 changes). The advantage of this approach is
	that the history can be arbitrarily long. This approach may
	also be simpler in terms of coding. The major disadvantage is
	that the realtime clock can be adjusted.  When adjusted, the
	realtime clock time (when interpolating from history) is
	always approximate. In general, the longer the interpolation
	period the larger the potential error. There isn't any error
	interpolating the monotonic raw clock time.
*	This patchset also addresses objections to the previous
	patchsets overly complex correlated timestamp structure. This
	patchset splits that structure into several smaller
	structures.  The correlated timestamp interface is renamed
	cross timestamp to avoid any confusion with the correlated
	clocksource.
*	The correlated clocksource is separated from the cross
	timestamp mechanism.
*	Add monotonic raw to the PTP user interface
*	Add e1000e driver configuration option that wraps Intel PCH
	specific code

Changes v3 to v4: 

*	Adds a history mechanism to accomodate slower devices. In this
	case the response time for timestamp reads to the Intel DSP
	are too slow to be accomodated by the original correlated time
	mechanism. The history mechanism turns shadow timekeeper into
	an array where the history is stored.

Christopher S. Hall (8):
  time: Add cycles to nanoseconds translation
  time: Add timekeeping snapshot code capturing system time and counter
  time: Remove duplicated code in ktime_get_raw_and_real()
  time: Add driver cross timestamp interface for higher precision time
    synchronization
  time: Add history to cross timestamp interface supporting slower
    devices
  x86: tsc: Always Running Timer (ART) correlated clocksource
  ptp: Add PTP_SYS_OFFSET_PRECISE for driver crosstimestamping
  net: e1000e: Adds hardware supported cross timestamp on e1000e nic

 Documentation/ptp/testptp.c                 |   6 +-
 arch/x86/include/asm/cpufeature.h           |   2 +-
 arch/x86/include/asm/tsc.h                  |   2 +
 arch/x86/kernel/tsc.c                       |  49 +++++
 drivers/net/ethernet/intel/Kconfig          |   9 +
 drivers/net/ethernet/intel/e1000e/defines.h |   5 +
 drivers/net/ethernet/intel/e1000e/ptp.c     |  85 ++++++++
 drivers/net/ethernet/intel/e1000e/regs.h    |   4 +
 drivers/ptp/ptp_chardev.c                   |  27 +++
 include/linux/pps_kernel.h                  |  17 +-
 include/linux/ptp_clock_kernel.h            |   8 +
 include/linux/timekeeper_internal.h         |   2 +
 include/linux/timekeeping.h                 |  58 ++++++
 include/uapi/linux/ptp_clock.h              |  13 +-
 kernel/time/timekeeping.c                   | 290 +++++++++++++++++++++++++---
 15 files changed, 537 insertions(+), 40 deletions(-)

-- 
2.1.4
