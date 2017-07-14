From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 00/22] gcc-7 -Wformat-* warnings
Date: Fri, 14 Jul 2017 14:06:52 +0200
Message-ID: <20170714120720.906842-1-arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org,
        netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        linux-scsi@vger.kernel.org, x86@kernel.org,
        Arnd Bergmann <arnd@arndb.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series addresses all warnings that gcc-7 introduces for
-Wformat-overflow= and turns off the -Wformat-truncation by default
(they remain enabled with "make W=1").

The -Wformat-overflow patches take varying approaches:

- When the final use of the buffer is not limited and we print
  into an intermediate variable on the stack, I generally make
  the temporary buffer slightly larger to accomodate all
  theoretically possible values. Usually the code is already
  correct for all expected values, but gcc doesn't see that.

- In some cases, we use a fixed-length buffer as the %s input
  for an sprintf to another buffer of the same length. Here
  I could make the first buffer slightly smaller so that gcc
  can prove the copies to be correct.

- In cases where the output buffer is required to have a fixed
  length, I use snprintf() instead of sprintf(). This turns
  the overflow warning into a truncation warning that is then
  ignored. Here it would be much nicer to have a way to tell
  the compiler what the maximum expected length is, but I
  couldn't figure out a way to actually shut up the truncation
  warning completely. Any ideas would be welcome.

Please review and apply as needed.

      Arnd

Arnd Bergmann (22):
  kbuild: disable -Wformat-truncation warnings by default
  scsi: megaraid: fix format-overflow warning
  scsi: mpt3sas: fix format overflow warning
  scsi: fusion: fix string overflow warning
  scsi: gdth: avoid buffer overflow warning
  scsi: fnic: fix format string overflow warning
  scsi: gdth: increase the procfs event buffer size
  isdn: divert: fix sprintf buffer overflow warning
  net: niu: fix format string overflow warning:
  bnx2x: fix format overflow warning
  net: thunder_bgx: avoid format string overflow warning
  vmxnet3: avoid format strint overflow warning
  liquidio: fix possible eeprom format string overflow
  [media] usbvision-i2c: fix format overflow warning
  hwmon: applesmc: fix format string overflow
  x86: intel-mid: fix a format string overflow warning
  platform/x86: alienware-wmi: fix format string overflow warning
  gpio: acpi: fix string overflow for large pin numbers
  block: DAC960: shut up format-overflow warning
  sound: pci: avoid string overflow warnings
  fscache: fix fscache_objlist_show format processing
  IB/mlx4: fix sprintf format warning

 .../intel-mid/device_libs/platform_max7315.c       |  6 ++++--
 drivers/block/DAC960.c                             | 12 +++++++----
 drivers/gpio/gpiolib-acpi.c                        |  2 +-
 drivers/hwmon/applesmc.c                           |  2 +-
 drivers/infiniband/hw/mlx4/sysfs.c                 |  2 +-
 drivers/isdn/divert/isdn_divert.c                  | 25 +++++++++++-----------
 drivers/media/usb/usbvision/usbvision-i2c.c        |  4 ++--
 drivers/message/fusion/mptbase.c                   |  2 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |  3 ++-
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c |  2 +-
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c  |  2 +-
 drivers/net/ethernet/sun/niu.c                     |  4 ++--
 drivers/net/vmxnet3/vmxnet3_int.h                  |  2 +-
 drivers/platform/x86/alienware-wmi.c               |  2 +-
 drivers/scsi/fnic/fnic.h                           |  2 +-
 drivers/scsi/gdth.c                                |  2 +-
 drivers/scsi/gdth_proc.c                           |  2 +-
 drivers/scsi/megaraid.c                            |  6 ++++--
 drivers/scsi/mpt3sas/mpt3sas_base.h                |  2 +-
 fs/fscache/object-list.c                           |  3 ++-
 scripts/Makefile.extrawarn                         |  3 +++
 sound/pci/mixart/mixart.h                          |  4 ++--
 sound/pci/pcxhr/pcxhr.h                            |  4 ++--
 sound/pci/rme9652/hdspm.c                          |  2 +-
 24 files changed, 57 insertions(+), 43 deletions(-)

-- 
2.9.0
