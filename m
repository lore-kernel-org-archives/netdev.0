From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 00/11] Time Counter fixes and improvements
Date: Sun, 21 Dec 2014 19:46:55 +0100
Message-ID: <cover.1418504883.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>,
	Miroslav Lichvar <mlichvar@redhat.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tom Lendacky <thomas.lendacky@amd.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Several PTP Hardware Clock (PHC) drivers implement the clock in
software using the timecounter/cyclecounter code. This series adds one
simple improvement and one more subtle fix to the shared timecounter
facility. Credit for this series goes to Janusz U=C5=BCycki, who pointe=
d
the issues out to me off list.

Patch #1 simply move the timecounter code into its own file. When
working on this series, it was really annoying to see half the kernel
recompile after every tweak to the timecounter stuff. There is no
reason to keep this together with the clocksource code.

Patch #2 implements an improved adjtime() method, and patches 3-10
convert all of the drivers over to the new method.

Patch #11 fixes a subtle but important issue with the timecounter WRT
frequency adjustment. As it stands now, a timecounter based PHC will
exhibit a variable frequency resolution (and variable time error)
depending on how often the clock is read.

In timecounter_read_delta(), the expression

   (delta * cc->mult) >> cc->shift;

can lose resolution from the adjusted value of 'mult'. If the value
of 'delta' is too small, then small changes in 'mult' have no effect.
However, if the delta value is large enough, then small changes in
'mult' will have an effect.

Reading the clock too often means smaller 'delta' values which in turn
will spoil the fine adjustments made to 'mult'. Up until now, this
effect did not show up in my testing. The following example explains
why.

The CPTS has an input clock of 250 MHz, and the clock source uses
mult=3D0x80000000 and shift=3D29, making the ticks to nanoseconds
conversion like this:

   ticks * 2^31
   ------------
       2^29

Imagine what happens if the clock is read every 10 milliseconds. Ten
milliseconds are about 2500000 ticks, which corresponds to about 21
bits. The product in the numerator has then 52 bits. After the shift
operation, 23 bits are preserved. This results in a frequency
adjustment resolution of about 0.1 ppm (not _too_ bad.)

A frequency resolution of 1 ppm requires 20 bits.
A frequency resolution of 1 ppb requires 30 bits.

=46or the 250 MHz CPTS clock, reading every 4 seconds yields a 1 ppb
resolution (which is the finest that our API allows).

However, the error can be much higher if the clock is read too often
or if time stamps occur close in time to read operations. In general
it is really not acceptable to allow the rate of clock readings to
influence the clock accuracy.

Thanks,
Richard

Richard Cochran (11):
  time: move the timecounter/cyclecounter code into its own file.
  timecounter: provide a helper function to shift the time.
  net: xgbe: convert to timecounter adjtime.
  net: bnx2x: convert to timecounter adjtime.
  net: fec: convert to timecounter adjtime.
  net: e1000e: convert to timecounter adjtime.
  net: igb: convert to timecounter adjtime.
  net: ixgbe: convert to timecounter adjtime.
  net: mlx4: convert to timecounter adjtime.
  net: cpts: convert to timecounter adjtime.
  timecounter: keep track of accumulated fractional nanoseconds

 drivers/net/ethernet/amd/xgbe/xgbe-ptp.c         |    8 +-
 drivers/net/ethernet/amd/xgbe/xgbe.h             |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    6 +-
 drivers/net/ethernet/freescale/fec.h             |    1 +
 drivers/net/ethernet/freescale/fec_ptp.c         |   16 +--
 drivers/net/ethernet/intel/e1000e/e1000.h        |    2 +-
 drivers/net/ethernet/intel/e1000e/ptp.c          |    5 +-
 drivers/net/ethernet/intel/igb/igb.h             |    2 +-
 drivers/net/ethernet/intel/igb/igb_ptp.c         |    7 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c     |   11 +-
 drivers/net/ethernet/mellanox/mlx4/en_clock.c    |    9 +-
 drivers/net/ethernet/ti/cpts.c                   |    5 +-
 drivers/net/ethernet/ti/cpts.h                   |    1 +
 include/clocksource/arm_arch_timer.h             |    2 +-
 include/linux/clocksource.h                      |  102 --------------=
--
 include/linux/mlx4/device.h                      |    2 +-
 include/linux/timecounter.h                      |  136 ++++++++++++++=
++++++++
 include/linux/types.h                            |    3 +
 kernel/time/Makefile                             |    2 +-
 kernel/time/clocksource.c                        |   76 ------------
 kernel/time/timecounter.c                        |  112 ++++++++++++++=
++++
 sound/pci/hda/hda_priv.h                         |    2 +-
 virt/kvm/arm/arch_timer.c                        |    3 +-
 25 files changed, 274 insertions(+), 245 deletions(-)
 create mode 100644 include/linux/timecounter.h
 create mode 100644 kernel/time/timecounter.c

--=20
1.7.10.4
