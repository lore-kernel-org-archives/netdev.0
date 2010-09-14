From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [PATCH 00/15] change default_llseek action
Date: Tue, 14 Sep 2010 22:22:28 +0200
Message-ID: <1284495763-7506-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	David Airlie <airlied-cv59FeDIM0c@public.gmane.org>,
	dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, Jeremy Kerr <jk-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>,
	Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>,
	Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The llseek file operations traditionally behaves differently
from all other file operations, the default being a generic
implementation of the call instead of a stub returning an
error.

This changes *all* instances of struct file_operations in
the kernel to have a .llseek operation and then changes
the default to no_llseek, which returns -ESPIPE, which
is what we had decided some time ago in a discussion
with Christoph Hellwig.

Where possible, the change is done automatically using
a semantic patch with coccinelle, the few cases where
an automatic conversion is not possible have separate
patches.

Finally, the default_llseek operation gets changed to
no longer require the big kernel lock. Since only
a few users are left using it, it can easily be shown
that none of them actually expects the big kernel lock
here.

I would like to get this into -next now, but will regenerate
the automatic mass-conversion part when this gets ready
for inclusion in 2.6.37, to accomodate any drivers
that got added without a .llseek method.

Stephen, please add
git+ssh://master.kernel.org/pub/scm/linux/kernel/git/arnd/bkl.git llseek

Arnd Bergmann (15):
  drm: use noop_llseek
  net/wireless: use generic_file_llseek in debugfs
  lkdtm: use generic_file_llseek in debugfs
  arm/omap: use generic_file_llseek in iommu_debug
  spufs: use llseek in all file operations
  ibmasmfs: use generic_file_llseek
  raw: use explicit llseek file operations
  irda/irnet: use noop_llseek
  viotape: use noop_llseek
  lirc: make chardev nonseekable
  mac80211: disallow seeks in minstrel debug code
  libfs: use generic_file_llseek for simple_attr
  llseek: automatically add .llseek fop
  vfs: don't use BKL in default_llseek
  vfs: make no_llseek the default

 Documentation/DocBook/drm.tmpl                   |    1 +
 arch/arm/kernel/etm.c                            |    1 +
 arch/arm/mach-msm/last_radio_log.c               |    3 +-
 arch/arm/mach-msm/smd_debug.c                    |    1 +
 arch/arm/plat-mxc/audmux-v2.c                    |    1 +
 arch/arm/plat-omap/iommu-debug.c                 |    2 +
 arch/avr32/boards/mimc200/fram.c                 |    1 +
 arch/blackfin/kernel/kgdb_test.c                 |    1 +
 arch/blackfin/mach-bf561/coreb.c                 |    1 +
 arch/cris/arch-v10/drivers/ds1302.c              |    1 +
 arch/cris/arch-v10/drivers/gpio.c                |    1 +
 arch/cris/arch-v10/drivers/i2c.c                 |    1 +
 arch/cris/arch-v10/drivers/pcf8563.c             |    1 +
 arch/cris/arch-v10/drivers/sync_serial.c         |    3 +-
 arch/cris/arch-v32/drivers/cryptocop.c           |    3 +-
 arch/cris/arch-v32/drivers/i2c.c                 |    1 +
 arch/cris/arch-v32/drivers/mach-a3/gpio.c        |    1 +
 arch/cris/arch-v32/drivers/mach-fs/gpio.c        |    1 +
 arch/cris/arch-v32/drivers/pcf8563.c             |    1 +
 arch/cris/arch-v32/drivers/sync_serial.c         |    3 +-
 arch/cris/kernel/profile.c                       |    1 +
 arch/ia64/kernel/salinfo.c                       |    2 +
 arch/ia64/sn/kernel/sn2/sn_hwperf.c              |    1 +
 arch/m68k/bvme6000/rtc.c                         |    1 +
 arch/m68k/mvme16x/rtc.c                          |    1 +
 arch/mips/kernel/rtlx.c                          |    3 +-
 arch/mips/kernel/vpe.c                           |    3 +-
 arch/mips/sibyte/common/sb_tbprof.c              |    1 +
 arch/powerpc/kernel/lparcfg.c                    |    1 +
 arch/powerpc/kernel/rtas_flash.c                 |    3 ++
 arch/powerpc/kernel/rtasd.c                      |    1 +
 arch/powerpc/platforms/cell/spufs/file.c         |   18 ++++++++++++
 arch/powerpc/platforms/iseries/mf.c              |    1 +
 arch/powerpc/platforms/pseries/reconfig.c        |    3 +-
 arch/powerpc/platforms/pseries/scanlog.c         |    1 +
 arch/s390/crypto/prng.c                          |    1 +
 arch/s390/hypfs/hypfs_diag.c                     |    1 +
 arch/s390/hypfs/hypfs_vm.c                       |    1 +
 arch/s390/hypfs/inode.c                          |    1 +
 arch/s390/kernel/debug.c                         |    1 +
 arch/sh/boards/mach-landisk/gio.c                |    1 +
 arch/sparc/kernel/apc.c                          |    1 +
 arch/sparc/kernel/mdesc.c                        |    1 +
 arch/tile/kernel/hardwall.c                      |    1 +
 arch/um/drivers/harddog_kern.c                   |    1 +
 arch/um/drivers/mconsole_kern.c                  |    1 +
 arch/um/drivers/mmapper_kern.c                   |    1 +
 arch/um/drivers/random.c                         |    1 +
 arch/x86/kernel/apm_32.c                         |    1 +
 arch/x86/kernel/cpu/mcheck/mce-severity.c        |    1 +
 arch/x86/kernel/cpu/mcheck/mce.c                 |    1 +
 arch/x86/kernel/kdebugfs.c                       |    1 +
 arch/x86/kernel/microcode_core.c                 |    1 +
 arch/x86/kernel/tlb_uv.c                         |    1 +
 arch/x86/xen/debugfs.c                           |    1 +
 block/bsg.c                                      |    1 +
 drivers/acpi/ec_sys.c                            |    1 +
 drivers/acpi/event.c                             |    1 +
 drivers/block/DAC960.c                           |    3 +-
 drivers/block/aoe/aoechr.c                       |    1 +
 drivers/block/paride/pg.c                        |    1 +
 drivers/block/paride/pt.c                        |    1 +
 drivers/block/pktcdvd.c                          |    1 +
 drivers/bluetooth/btmrvl_debugfs.c               |   10 ++++++
 drivers/bluetooth/hci_vhci.c                     |    1 +
 drivers/char/apm-emulation.c                     |    1 +
 drivers/char/bfin-otp.c                          |    1 +
 drivers/char/briq_panel.c                        |    1 +
 drivers/char/bsr.c                               |    1 +
 drivers/char/cs5535_gpio.c                       |    3 +-
 drivers/char/ds1302.c                            |    1 +
 drivers/char/ds1620.c                            |    1 +
 drivers/char/dsp56k.c                            |    1 +
 drivers/char/dtlk.c                              |    1 +
 drivers/char/genrtc.c                            |    1 +
 drivers/char/hw_random/core.c                    |    1 +
 drivers/char/ip2/ip2main.c                       |    1 +
 drivers/char/ipmi/ipmi_devintf.c                 |    1 +
 drivers/char/ipmi/ipmi_watchdog.c                |    1 +
 drivers/char/istallion.c                         |    1 +
 drivers/char/lp.c                                |    1 +
 drivers/char/mem.c                               |    3 ++
 drivers/char/misc.c                              |    1 +
 drivers/char/mmtimer.c                           |    1 +
 drivers/char/mspec.c                             |    9 ++++--
 drivers/char/mwave/mwavedd.c                     |    3 +-
 drivers/char/nwbutton.c                          |    1 +
 drivers/char/pc8736x_gpio.c                      |    1 +
 drivers/char/pcmcia/cm4000_cs.c                  |    1 +
 drivers/char/pcmcia/cm4040_cs.c                  |    1 +
 drivers/char/random.c                            |    2 +
 drivers/char/raw.c                               |    2 +
 drivers/char/rio/rio_linux.c                     |    1 +
 drivers/char/scx200_gpio.c                       |    1 +
 drivers/char/snsc.c                              |    1 +
 drivers/char/stallion.c                          |    1 +
 drivers/char/sx.c                                |    1 +
 drivers/char/sysrq.c                             |    1 +
 drivers/char/tb0219.c                            |    1 +
 drivers/char/tlclk.c                             |    1 +
 drivers/char/toshiba.c                           |    1 +
 drivers/char/uv_mmtimer.c                        |    1 +
 drivers/char/viotape.c                           |    1 +
 drivers/char/virtio_console.c                    |    3 ++
 drivers/char/xilinx_hwicap/xilinx_hwicap.c       |    1 +
 drivers/dma/coh901318.c                          |    1 +
 drivers/firewire/nosy.c                          |    1 +
 drivers/gpu/drm/drm_drv.c                        |    3 +-
 drivers/gpu/drm/i810/i810_dma.c                  |    1 +
 drivers/gpu/drm/i810/i810_drv.c                  |    1 +
 drivers/gpu/drm/i830/i830_dma.c                  |    1 +
 drivers/gpu/drm/i830/i830_drv.c                  |    1 +
 drivers/gpu/drm/i915/i915_debugfs.c              |    1 +
 drivers/gpu/drm/i915/i915_drv.c                  |    1 +
 drivers/gpu/drm/mga/mga_drv.c                    |    1 +
 drivers/gpu/drm/nouveau/nouveau_drv.c            |    1 +
 drivers/gpu/drm/r128/r128_drv.c                  |    1 +
 drivers/gpu/drm/radeon/radeon_drv.c              |    1 +
 drivers/gpu/drm/savage/savage_drv.c              |    1 +
 drivers/gpu/drm/sis/sis_drv.c                    |    1 +
 drivers/gpu/drm/tdfx/tdfx_drv.c                  |    1 +
 drivers/gpu/drm/via/via_drv.c                    |    1 +
 drivers/gpu/drm/vmwgfx/vmwgfx_drv.c              |    1 +
 drivers/gpu/vga/vgaarb.c                         |    1 +
 drivers/hid/hid-debug.c                          |    1 +
 drivers/hid/hid-roccat.c                         |    1 +
 drivers/hid/hidraw.c                             |    1 +
 drivers/hid/usbhid/hiddev.c                      |    1 +
 drivers/hwmon/asus_atk0110.c                     |    1 +
 drivers/ide/ide-tape.c                           |    1 +
 drivers/idle/i7300_idle.c                        |    1 +
 drivers/infiniband/hw/cxgb4/device.c             |    1 +
 drivers/infiniband/hw/ipath/ipath_diag.c         |    4 ++-
 drivers/infiniband/hw/ipath/ipath_file_ops.c     |    3 +-
 drivers/infiniband/hw/ipath/ipath_fs.c           |    3 ++
 drivers/infiniband/hw/qib/qib_diag.c             |    4 ++-
 drivers/infiniband/hw/qib/qib_file_ops.c         |    3 +-
 drivers/infiniband/hw/qib/qib_fs.c               |    1 +
 drivers/input/evdev.c                            |    3 +-
 drivers/input/input.c                            |    1 +
 drivers/input/joydev.c                           |    1 +
 drivers/input/misc/uinput.c                      |    1 +
 drivers/input/mousedev.c                         |    1 +
 drivers/input/serio/serio_raw.c                  |    1 +
 drivers/isdn/mISDN/timerdev.c                    |    1 +
 drivers/lguest/lguest_user.c                     |    1 +
 drivers/macintosh/ans-lcd.c                      |    1 +
 drivers/macintosh/via-pmu.c                      |    1 +
 drivers/md/dm-ioctl.c                            |    1 +
 drivers/media/IR/imon.c                          |    6 ++-
 drivers/media/IR/ir-lirc-codec.c                 |    1 +
 drivers/media/IR/lirc_dev.c                      |    3 ++
 drivers/media/dvb/bt8xx/dst_ca.c                 |    3 +-
 drivers/media/dvb/dvb-core/dmxdev.c              |    2 +
 drivers/media/dvb/dvb-core/dvb_ca_en50221.c      |    1 +
 drivers/media/dvb/dvb-core/dvb_frontend.c        |    3 +-
 drivers/media/dvb/dvb-core/dvb_net.c             |    1 +
 drivers/media/dvb/dvb-core/dvbdev.c              |    1 +
 drivers/media/dvb/firewire/firedtv-ci.c          |    1 +
 drivers/media/dvb/ttpci/av7110.c                 |    1 +
 drivers/media/dvb/ttpci/av7110_av.c              |    2 +
 drivers/media/dvb/ttpci/av7110_ca.c              |    1 +
 drivers/media/dvb/ttpci/av7110_ir.c              |    1 +
 drivers/mfd/ab3100-core.c                        |    1 +
 drivers/misc/hpilo.c                             |    1 +
 drivers/misc/ibmasm/ibmasmfs.c                   |    4 ++
 drivers/misc/iwmc3200top/debugfs.c               |    3 ++
 drivers/misc/lkdtm.c                             |    9 ++++++
 drivers/misc/phantom.c                           |    1 +
 drivers/misc/sgi-gru/grufile.c                   |    1 +
 drivers/mmc/core/debugfs.c                       |    1 +
 drivers/mtd/ubi/cdev.c                           |    1 +
 drivers/net/caif/caif_spi.c                      |    6 ++-
 drivers/net/cxgb4/cxgb4_main.c                   |    1 +
 drivers/net/ppp_generic.c                        |    3 +-
 drivers/net/wimax/i2400m/debugfs.c               |    2 +
 drivers/net/wireless/airo.c                      |   24 ++++++++++-----
 drivers/net/wireless/ath/ath5k/debug.c           |    7 ++++
 drivers/net/wireless/ath/ath9k/debug.c           |   33 ++++++++++++++-------
 drivers/net/wireless/ath/ath9k/htc_drv_main.c    |    9 ++++--
 drivers/net/wireless/b43/debugfs.c               |    1 +
 drivers/net/wireless/b43legacy/debugfs.c         |    1 +
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c       |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c        |    3 ++
 drivers/net/wireless/iwlwifi/iwl-debugfs.c       |    3 ++
 drivers/net/wireless/iwmc3200wifi/debugfs.c      |    4 ++
 drivers/net/wireless/iwmc3200wifi/sdio.c         |    1 +
 drivers/net/wireless/libertas/debugfs.c          |    2 +
 drivers/net/wireless/ray_cs.c                    |    2 +
 drivers/net/wireless/rt2x00/rt2x00debug.c        |    5 +++
 drivers/net/wireless/wl12xx/wl1251_debugfs.c     |    4 ++
 drivers/net/wireless/wl12xx/wl1271_debugfs.c     |    6 +++-
 drivers/oprofile/oprofile_files.c                |    8 ++++-
 drivers/oprofile/oprofilefs.c                    |    3 ++
 drivers/pci/pcie/aer/aer_inject.c                |    1 +
 drivers/platform/x86/sony-laptop.c               |    1 +
 drivers/rtc/rtc-m41t80.c                         |    1 +
 drivers/s390/block/dasd_eer.c                    |    1 +
 drivers/s390/char/fs3270.c                       |    1 +
 drivers/s390/char/monreader.c                    |    1 +
 drivers/s390/char/monwriter.c                    |    1 +
 drivers/s390/char/tape_char.c                    |    1 +
 drivers/s390/char/vmcp.c                         |    1 +
 drivers/s390/char/vmlogrdr.c                     |    1 +
 drivers/s390/char/vmwatchdog.c                   |    1 +
 drivers/s390/char/zcore.c                        |    2 +
 drivers/s390/cio/chsc_sch.c                      |    1 +
 drivers/s390/cio/css.c                           |    1 +
 drivers/s390/crypto/zcrypt_api.c                 |    3 +-
 drivers/s390/scsi/zfcp_cfdc.c                    |    3 +-
 drivers/sbus/char/display7seg.c                  |    1 +
 drivers/sbus/char/envctrl.c                      |    1 +
 drivers/scsi/3w-9xxx.c                           |    3 +-
 drivers/scsi/3w-sas.c                            |    3 +-
 drivers/scsi/3w-xxxx.c                           |    3 +-
 drivers/scsi/aacraid/linit.c                     |    1 +
 drivers/scsi/ch.c                                |    1 +
 drivers/scsi/dpt_i2o.c                           |    1 +
 drivers/scsi/gdth.c                              |    1 +
 drivers/scsi/megaraid.c                          |    1 +
 drivers/scsi/megaraid/megaraid_mm.c              |    1 +
 drivers/scsi/megaraid/megaraid_sas.c             |    1 +
 drivers/scsi/mpt2sas/mpt2sas_ctl.c               |    1 +
 drivers/scsi/osd/osd_uld.c                       |    1 +
 drivers/scsi/pmcraid.c                           |    1 +
 drivers/scsi/qla2xxx/qla_os.c                    |    1 +
 drivers/scsi/scsi_tgt_if.c                       |    1 +
 drivers/scsi/sg.c                                |    1 +
 drivers/serial/mfd.c                             |    2 +
 drivers/spi/dw_spi.c                             |    1 +
 drivers/spi/spidev.c                             |    1 +
 drivers/staging/batman-adv/bat_debugfs.c         |    1 +
 drivers/staging/batman-adv/icmp_socket.c         |    1 +
 drivers/staging/comedi/comedi_fops.c             |    1 +
 drivers/staging/crystalhd/crystalhd_lnx.c        |    1 +
 drivers/staging/dream/camera/msm_camera.c        |    3 ++
 drivers/staging/dream/pmem.c                     |    2 +
 drivers/staging/dream/qdsp5/adsp_driver.c        |    1 +
 drivers/staging/dream/qdsp5/audio_aac.c          |    1 +
 drivers/staging/dream/qdsp5/audio_amrnb.c        |    1 +
 drivers/staging/dream/qdsp5/audio_evrc.c         |    1 +
 drivers/staging/dream/qdsp5/audio_in.c           |    2 +
 drivers/staging/dream/qdsp5/audio_mp3.c          |    1 +
 drivers/staging/dream/qdsp5/audio_out.c          |    2 +
 drivers/staging/dream/qdsp5/audio_qcelp.c        |    1 +
 drivers/staging/dream/qdsp5/evlog.h              |    1 +
 drivers/staging/dream/qdsp5/snd.c                |    1 +
 drivers/staging/frontier/alphatrack.c            |    1 +
 drivers/staging/frontier/tranzport.c             |    1 +
 drivers/staging/iio/industrialio-core.c          |    1 +
 drivers/staging/iio/industrialio-ring.c          |    1 +
 drivers/staging/lirc/lirc_imon.c                 |    3 +-
 drivers/staging/lirc/lirc_it87.c                 |    1 +
 drivers/staging/lirc/lirc_sasem.c                |    1 +
 drivers/staging/lirc/lirc_serial.c               |    1 +
 drivers/staging/lirc/lirc_sir.c                  |    1 +
 drivers/staging/memrar/memrar_handler.c          |    1 +
 drivers/staging/panel/panel.c                    |    1 +
 drivers/staging/tidspbridge/rmgr/drv_interface.c |    1 +
 drivers/telephony/ixj.c                          |    3 +-
 drivers/telephony/phonedev.c                     |    1 +
 drivers/uio/uio.c                                |    1 +
 drivers/usb/class/cdc-wdm.c                      |    3 +-
 drivers/usb/class/usblp.c                        |    1 +
 drivers/usb/class/usbtmc.c                       |    1 +
 drivers/usb/core/file.c                          |    1 +
 drivers/usb/gadget/f_hid.c                       |    1 +
 drivers/usb/gadget/printer.c                     |    3 +-
 drivers/usb/host/ehci-dbg.c                      |    4 ++
 drivers/usb/host/ohci-dbg.c                      |    3 ++
 drivers/usb/image/mdc800.c                       |    1 +
 drivers/usb/misc/adutux.c                        |    1 +
 drivers/usb/misc/idmouse.c                       |    1 +
 drivers/usb/misc/iowarrior.c                     |    1 +
 drivers/usb/misc/ldusb.c                         |    1 +
 drivers/usb/misc/rio500.c                        |    1 +
 drivers/usb/misc/usblcd.c                        |    1 +
 drivers/usb/usb-skeleton.c                       |    1 +
 drivers/vhost/net.c                              |    1 +
 drivers/video/fbmem.c                            |    1 +
 drivers/video/mbx/mbxdebugfs.c                   |    6 ++++
 drivers/watchdog/ar7_wdt.c                       |    1 +
 drivers/watchdog/cpwd.c                          |    1 +
 drivers/watchdog/ep93xx_wdt.c                    |    1 +
 drivers/watchdog/omap_wdt.c                      |    1 +
 drivers/xen/evtchn.c                             |    1 +
 drivers/xen/xenfs/super.c                        |    1 +
 drivers/xen/xenfs/xenbus.c                       |    1 +
 fs/afs/mntpt.c                                   |    1 +
 fs/autofs4/dev-ioctl.c                           |    1 +
 fs/binfmt_misc.c                                 |    3 ++
 fs/btrfs/super.c                                 |    1 +
 fs/cachefiles/daemon.c                           |    1 +
 fs/char_dev.c                                    |    1 +
 fs/coda/pioctl.c                                 |    1 +
 fs/coda/psdev.c                                  |    1 +
 fs/debugfs/file.c                                |    3 ++
 fs/dlm/debug_fs.c                                |    3 +-
 fs/dlm/plock.c                                   |    3 +-
 fs/dlm/user.c                                    |    3 ++
 fs/ecryptfs/file.c                               |    1 +
 fs/ecryptfs/miscdev.c                            |    1 +
 fs/eventfd.c                                     |    1 +
 fs/eventpoll.c                                   |    3 +-
 fs/fifo.c                                        |    1 +
 fs/fuse/control.c                                |    4 ++
 fs/fuse/cuse.c                                   |    1 +
 fs/gfs2/file.c                                   |    2 +
 fs/hppfs/hppfs.c                                 |    1 +
 fs/hugetlbfs/inode.c                             |    1 +
 fs/logfs/dir.c                                   |    1 +
 fs/nfsd/nfsctl.c                                 |    1 +
 fs/no-block.c                                    |    1 +
 fs/notify/fanotify/fanotify_user.c               |    1 +
 fs/notify/inotify/inotify_user.c                 |    1 +
 fs/ntfs/file.c                                   |    3 +-
 fs/ocfs2/dlmfs/dlmfs.c                           |    1 +
 fs/ocfs2/stack_user.c                            |    1 +
 fs/proc/base.c                                   |    8 +++++
 fs/proc/proc_sysctl.c                            |    1 +
 fs/proc/root.c                                   |    1 +
 fs/proc/task_mmu.c                               |    1 +
 fs/read_write.c                                  |    5 +--
 fs/romfs/super.c                                 |    1 +
 fs/signalfd.c                                    |    1 +
 fs/squashfs/dir.c                                |    3 +-
 fs/timerfd.c                                     |    1 +
 fs/ubifs/debug.c                                 |    1 +
 include/linux/fs.h                               |    1 +
 ipc/mqueue.c                                     |    1 +
 ipc/shm.c                                        |    2 +
 kernel/configs.c                                 |    1 +
 kernel/gcov/fs.c                                 |    1 +
 kernel/kprobes.c                                 |    1 +
 kernel/pm_qos_params.c                           |    1 +
 kernel/profile.c                                 |    1 +
 kernel/trace/blktrace.c                          |    2 +
 kernel/trace/ftrace.c                            |    2 +
 kernel/trace/ring_buffer.c                       |    1 +
 kernel/trace/trace_events.c                      |    6 ++++
 kernel/trace/trace_stack.c                       |    1 +
 lib/dma-debug.c                                  |    1 +
 net/atm/proc.c                                   |    1 +
 net/dccp/probe.c                                 |    1 +
 net/ipv4/tcp_probe.c                             |    1 +
 net/irda/irnet/irnet_ppp.h                       |    3 +-
 net/mac80211/debugfs.c                           |   21 ++++++++++----
 net/mac80211/debugfs_key.c                       |    2 +
 net/mac80211/debugfs_netdev.c                    |    1 +
 net/mac80211/debugfs_sta.c                       |    2 +
 net/mac80211/rate.c                              |    1 +
 net/mac80211/rc80211_minstrel_debugfs.c          |    1 +
 net/mac80211/rc80211_minstrel_ht_debugfs.c       |    3 +-
 net/mac80211/rc80211_pid_debugfs.c               |    1 +
 net/netfilter/xt_recent.c                        |    1 +
 net/nonet.c                                      |    1 +
 net/rfkill/core.c                                |    1 +
 net/sctp/probe.c                                 |    1 +
 net/socket.c                                     |    1 +
 net/sunrpc/cache.c                               |    2 +
 net/wireless/debugfs.c                           |    2 +
 samples/kfifo/bytestream-example.c               |    1 +
 samples/kfifo/inttype-example.c                  |    1 +
 samples/kfifo/record-example.c                   |    1 +
 samples/tracepoints/tracepoint-sample.c          |    1 +
 security/apparmor/apparmorfs.c                   |    9 ++++--
 security/inode.c                                 |    1 +
 security/smack/smackfs.c                         |    5 +++
 sound/core/seq/oss/seq_oss.c                     |    1 +
 sound/core/sound.c                               |    3 +-
 sound/oss/msnd_pinnacle.c                        |    1 +
 sound/oss/sh_dac_audio.c                         |    1 +
 sound/soc/soc-core.c                             |    1 +
 sound/soc/soc-dapm.c                             |    1 +
 sound/sound_core.c                               |    1 +
 virt/kvm/kvm_main.c                              |    3 ++
 376 files changed, 628 insertions(+), 79 deletions(-)

Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: David Airlie <airlied-cv59FeDIM0c@public.gmane.org>
Cc: dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org
Cc: Jeremy Kerr <jk-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Cc: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Cc: Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
