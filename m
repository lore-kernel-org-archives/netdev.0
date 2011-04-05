From: Michal Marek <mmarek@suse.cz>
Subject: [PATCH 00/34] Make kernel build deterministic
Date: Tue,  5 Apr 2011 16:58:47 +0200
Message-ID: <1302015561-21047-1-git-send-email-mmarek@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: anil_ravindranath@pmc-sierra.com, mchehab@redhat.com,
	benh@kernel.crashing.org, x86@kernel.org, mac@melware.de,
	aacraid@adaptec.com, linux-mtd@lists.infradead.org,
	allan.stephens@windriver.com, hpa@zytor.com,
	netdev@vger.kernel.org, t.sailer@alumni.ethz.ch,
	gwingerde@gmail.com, IvDoorn@gmail.com, elf@buici.com,
	cluster-devel@redhat.com, ccaulfie@redhat.com, mingo@redhat.com,
	dougthompson@xmission.com, linux-usb@vger.kernel.org,
	linux-media@vger.kernel.org, arnaud.giersch@free.fr,
	teigland@redhat.com, tony.olech@elandigitalsystems.com,
	apw@canonical.com, linux-hams@vger.kernel.org,
	tglx@linutronix.de, swhiteho@redhat.com,
	linux-arm-kernel@lists.infradead.org, linux-edac@vger.kernel.org,
	jon.maloy@ericsson.com, linux-scsi@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, gregkh@suse.de,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	bluesmoke-devel@lists.so
To: linux-kbuild@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


Hi,

this series makes it possible to build bit-identical kernel image and
modules from identical sources. Of course the build is already
deterministic in terms of behavior of the code, but the various
timestamps embedded in the object files make it hard to compare two
builds, for instance to verify that a makefile cleanup didn't
accidentally change something. A prime example is /proc/config.gz, which
has both a timestamp in the gzip header and a timestamp in the payload
data. With this series applied, a script like this will produce
identical kernels each time:

#!/bin/bash
rm -rf /dev/shm/{source,build}{,1,2}
export KCONFIG_NOTIMESTAMP=1
export KBUILD_BUILD_TIMESTAMP='Sun May  1 12:00:00 CEST 2011'
export KBUILD_BUILD_USER=user
export KBUILD_BUILD_HOST=host
export ROOT_DEV=FLOPPY
for i in 1 2; do
	mkdir /dev/shm/source
	# randomize the inode order just for fun
	git ls-tree -r -z --name-only HEAD | sort -R -z | xargs -0 \
		cp --parents --target=/dev/shm/source
	pushd /dev/shm/source
	mkdir /dev/shm/build
	>/dev/shm/build/all.config
	for opt in GCOV_KERNEL UBIFS_FS_DEBUG; do
		echo "# CONFIG_$opt is not set" >>"/dev/shm/build"/all.config
	done
	make O="/dev/shm/build" KCONFIG_ALLCONFIG=1 allmodconfig
	make O="/dev/shm/build" -j64
	popd
	mv /dev/shm/source /dev/shm/source$i
	mv /dev/shm/build /dev/shm/build$i
done
diff -rq /dev/shm/build{1,2}

Unfortunatelly, this cannot be used to validate indentation-only
patches, even if CONFIG_DEBUG_INFO is turned off. This is because of the
__FILE__ and __LINE__ macros used in many places. For the same reason,
the source and build directory needs to be the same, otherwise the
results will differ. This was tested on
x86_64/{defconfig,allmodconfig,allyesconfig} and ppc64/defconfig. The
series is also available at

git://git.kernel.org/pub/scm/linux/kernel/git/mmarek/kbuild-2.6.git deterministic-build-v1

Michal


Michal Marek (34):
  kconfig: Do not record timestamp in auto.conf and autoconf.h
  kbuild: Call gzip with -n
  powerpc: Call gzip with -n
  kbuild: Use the deterministic mode of ar
  powerpc: Use the deterministic mode of ar
  kbuild: Drop unused LINUX_COMPILE_TIME and LINUX_COMPILE_DOMAIN
    macros
  kbuild: Allow to override LINUX_COMPILE_BY and LINUX_COMPILE_HOST
    macros
  initramfs: Use KBUILD_BUILD_TIMESTAMP for generated entries
  x86: Allow to override the ROOT_DEV variable
  cyclades: Drop __TIME__ usage
  nozomi: Drop __TIME__ usage
  isdn/diva: Drop __TIME__ usage
  media/radio-maxiradio: Drop __TIME__ usage
  media/cx231xx: Drop __TIME__ usage
  baycom: Drop __TIME__ usage
  nand/denali: Drop __TIME__ usage
  hdlcdrv: Drop __TIME__ usage
  wan/pc300: Drop __TIME__ usage
  rt2x00: Drop __TIME__ usage
  parport: Drop __TIME__ usage
  aacraid: Drop __TIME__ usage
  scsi/in2000: Drop __TIME__ usage
  scsi/wd33c93: Drop __TIME__ usage
  usb/u132-hcd: Drop __TIME__ usage
  usb/ftdi-elan: Drop __TIME__ usage
  dlm: Drop __TIME__ usage
  gfs2: Drop __TIME__ usage
  atm: Drop __TIME__ usage
  tipc: Drop __TIME__ usage
  rio: Drop __DATE__ usage
  edac: Drop __DATE__ usage
  pmcraid: Drop __DATE__ usage
  usb/lh7a40x_udc: Drop __DATE__ usage
  checkpatch: Warn about usage of __DATE__, __TIME__ and __TIMESTAMP__

 Documentation/kbuild/kbuild.txt              |   12 ++++++++++
 arch/powerpc/boot/Makefile                   |    2 +-
 arch/powerpc/boot/wrapper                    |    6 ++--
 arch/x86/boot/Makefile                       |    2 +-
 drivers/char/cyclades.c                      |    3 +-
 drivers/char/nozomi.c                        |    3 +-
 drivers/char/rio/rioinit.c                   |    2 +-
 drivers/edac/amd76x_edac.c                   |    2 +-
 drivers/edac/amd8111_edac.c                  |    2 +-
 drivers/edac/amd8131_edac.c                  |    2 +-
 drivers/edac/cpc925_edac.c                   |    2 +-
 drivers/edac/e752x_edac.c                    |    2 +-
 drivers/edac/e7xxx_edac.c                    |    2 +-
 drivers/edac/edac_module.c                   |    2 +-
 drivers/edac/i5000_edac.c                    |    2 +-
 drivers/edac/i5400_edac.c                    |    2 +-
 drivers/edac/i7300_edac.c                    |    2 +-
 drivers/edac/i7core_edac.c                   |    2 +-
 drivers/edac/i82860_edac.c                   |    2 +-
 drivers/edac/i82875p_edac.c                  |    2 +-
 drivers/edac/i82975x_edac.c                  |    2 +-
 drivers/edac/mpc85xx_edac.h                  |    2 +-
 drivers/edac/mv64x60_edac.h                  |    2 +-
 drivers/edac/ppc4xx_edac.c                   |    2 +-
 drivers/edac/r82600_edac.c                   |    2 +-
 drivers/isdn/hardware/eicon/divasfunc.c      |    5 +--
 drivers/media/radio/radio-maxiradio.c        |    3 +-
 drivers/media/video/cx231xx/cx231xx-avcore.c |    2 +-
 drivers/mtd/nand/denali.c                    |    3 +-
 drivers/net/hamradio/baycom_epp.c            |    2 +-
 drivers/net/hamradio/baycom_par.c            |    2 +-
 drivers/net/hamradio/baycom_ser_fdx.c        |    2 +-
 drivers/net/hamradio/baycom_ser_hdx.c        |    2 +-
 drivers/net/hamradio/hdlcdrv.c               |    2 +-
 drivers/net/wan/pc300_drv.c                  |    3 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c    |    1 -
 drivers/parport/parport_ip32.c               |    1 -
 drivers/scsi/aacraid/linit.c                 |    3 +-
 drivers/scsi/in2000.c                        |    2 +-
 drivers/scsi/pmcraid.c                       |    9 +++----
 drivers/scsi/pmcraid.h                       |    1 -
 drivers/scsi/wd33c93.c                       |    7 ++---
 drivers/usb/gadget/lh7a40x_udc.c             |    7 ++---
 drivers/usb/host/u132-hcd.c                  |    3 +-
 drivers/usb/misc/ftdi-elan.c                 |    3 +-
 fs/dlm/main.c                                |    2 +-
 fs/gfs2/main.c                               |    2 +-
 net/atm/lec.c                                |    2 +-
 net/atm/mpc.c                                |    2 +-
 net/tipc/core.c                              |    3 +-
 scripts/Makefile.build                       |    4 +-
 scripts/Makefile.lib                         |    2 +-
 scripts/checkpatch.pl                        |    5 ++++
 scripts/gen_initramfs_list.sh                |    8 +++++-
 scripts/kconfig/confdata.c                   |    8 +-----
 scripts/mkcompile_h                          |   30 ++++++++++++-------------
 usr/gen_init_cpio.c                          |   17 +++++++++-----
 57 files changed, 109 insertions(+), 105 deletions(-)

-- 
1.7.4.1
