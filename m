From: Arnd Bergmann <arnd@arndb.de>
Subject: [RFC 00/20] Proposal for remaining BKL users
Date: Tue, 25 Jan 2011 23:22:54 +0100
Message-ID: <1295994174-5043-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: autofs@linux.kernel.org, linux-cifs@vger.kernel.org,
	linux-x25@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-fsdevel@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/dri-devel>,
	<mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Sender: dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org
Errors-To: dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org
List-Id: netdev.vger.kernel.org

I've gone through all the code in the kernel that
uses the big kernel lock and come up with a solution
that seems at least half-reasonable for each of them.

The decisions are somewhat arbitrary, but here is
what I'd suggest we do:

* Remove in 2.6.39:
   i830, autofs3, smbfs

* Move to staging now, kill in 2.6.41 (or later):
   appletalk, hpfs

* Work around in an ugly way, but keep alive:
   * ufs, ipx, i810, cx25721

* Fix properly:
   * usbip, go7007, adfs, x25

Some of the patches are rather tricky and I haven't
really done much proper testing, so I'd much prefer
the maintainers to pick up the patches and do the
necessary testing where possible, or even come up
with a better solution.

Arnd Bergmann (20):
  drm/i810: remove the BKL
  drm: remove i830 driver
  staging/usbip: convert to kthread
  staging/cx25721: serialize access to devlist
  staging/go7007: remove the BKL
  staging: Remove autofs3
  staging: remove smbfs
  adfs: remove the big kernel lock
  hpfs: rename big kernel lock to hpfs_lock
  hpfs: replace BKL with a global mutex
  hpfs: move to drivers/staging
  x25: remove the BKL
  appletalk: move to staging
  staging/appletalk: remove the BKL
  ufs: remove the BKL
  ipx: remove the BKL
  tracing: don't trace the BKL
  rtmutex-tester: remove BKL tests
  drivers: remove extraneous includes of smp_lock.h
  BKL: That's all, folks

 MAINTAINERS                                        |   11 +-
 drivers/gpu/drm/Kconfig                            |   47 +-
 drivers/gpu/drm/Makefile                           |    1 -
 drivers/gpu/drm/i810/i810_dma.c                    |   18 +-
 drivers/gpu/drm/i810/i810_drv.c                    |    6 +-
 drivers/gpu/drm/i830/Makefile                      |    8 -
 drivers/gpu/drm/i830/i830_dma.c                    | 1560 ---------
 drivers/gpu/drm/i830/i830_drv.c                    |  107 -
 drivers/gpu/drm/i830/i830_drv.h                    |  295 --
 drivers/gpu/drm/i830/i830_irq.c                    |  186 --
 drivers/net/Makefile                               |    1 -
 drivers/net/appletalk/Makefile                     |    7 -
 drivers/scsi/megaraid/megaraid_sas_fp.c            |    1 -
 drivers/scsi/megaraid/megaraid_sas_fusion.c        |    1 -
 drivers/staging/Kconfig                            |    8 +-
 drivers/staging/Makefile                           |    4 +-
 drivers/{net => staging}/appletalk/Kconfig         |    1 -
 {net => drivers/staging}/appletalk/Makefile        |    7 +-
 {net => drivers/staging}/appletalk/aarp.c          |    2 +-
 .../linux => drivers/staging/appletalk}/atalk.h    |    0
 {net => drivers/staging}/appletalk/atalk_proc.c    |    2 +-
 drivers/{net => staging}/appletalk/cops.c          |    2 +-
 drivers/{net => staging}/appletalk/cops.h          |    0
 drivers/{net => staging}/appletalk/cops_ffdrv.h    |    0
 drivers/{net => staging}/appletalk/cops_ltdrv.h    |    0
 {net => drivers/staging}/appletalk/ddp.c           |   44 +-
 {net => drivers/staging}/appletalk/dev.c           |    0
 drivers/{net => staging}/appletalk/ipddp.c         |    2 +-
 drivers/{net => staging}/appletalk/ipddp.h         |    0
 drivers/{net => staging}/appletalk/ltpc.c          |    2 +-
 drivers/{net => staging}/appletalk/ltpc.h          |    0
 .../staging}/appletalk/sysctl_net_atalk.c          |    2 +-
 drivers/staging/autofs/Kconfig                     |   22 -
 drivers/staging/autofs/Makefile                    |    7 -
 drivers/staging/autofs/TODO                        |    8 -
 drivers/staging/autofs/autofs_i.h                  |  165 -
 drivers/staging/autofs/dirhash.c                   |  260 --
 drivers/staging/autofs/init.c                      |   52 -
 drivers/staging/autofs/inode.c                     |  288 --
 drivers/staging/autofs/root.c                      |  648 ----
 drivers/staging/autofs/symlink.c                   |   26 -
 drivers/staging/autofs/waitq.c                     |  205 --
 drivers/staging/cx25821/Kconfig                    |    1 -
 drivers/staging/cx25821/cx25821-alsa.c             |    2 +
 drivers/staging/cx25821/cx25821-core.c             |   16 +-
 drivers/staging/cx25821/cx25821-video.c            |    9 +-
 drivers/staging/cx25821/cx25821.h                  |    3 +-
 drivers/staging/easycap/easycap.h                  |    1 -
 drivers/staging/easycap/easycap_ioctl.c            |    1 -
 drivers/staging/go7007/Kconfig                     |    1 -
 drivers/staging/go7007/s2250-loader.c              |    3 -
 {fs => drivers/staging}/hpfs/Kconfig               |    5 +-
 {fs => drivers/staging}/hpfs/Makefile              |    0
 drivers/staging/hpfs/TODO                          |    5 +
 {fs => drivers/staging}/hpfs/alloc.c               |    0
 {fs => drivers/staging}/hpfs/anode.c               |    0
 {fs => drivers/staging}/hpfs/buffer.c              |    0
 {fs => drivers/staging}/hpfs/dentry.c              |    0
 {fs => drivers/staging}/hpfs/dir.c                 |   23 +-
 {fs => drivers/staging}/hpfs/dnode.c               |    0
 {fs => drivers/staging}/hpfs/ea.c                  |    0
 {fs => drivers/staging}/hpfs/file.c                |    9 +-
 {fs => drivers/staging}/hpfs/hpfs.h                |    0
 {fs => drivers/staging}/hpfs/hpfs_fn.h             |   36 +
 {fs => drivers/staging}/hpfs/inode.c               |    9 +-
 {fs => drivers/staging}/hpfs/map.c                 |    0
 {fs => drivers/staging}/hpfs/name.c                |    0
 {fs => drivers/staging}/hpfs/namei.c               |   49 +-
 {fs => drivers/staging}/hpfs/super.c               |   21 +-
 drivers/staging/smbfs/Kconfig                      |   56 -
 drivers/staging/smbfs/Makefile                     |   18 -
 drivers/staging/smbfs/TODO                         |    8 -
 drivers/staging/smbfs/cache.c                      |  208 --
 drivers/staging/smbfs/dir.c                        |  699 ----
 drivers/staging/smbfs/file.c                       |  456 ---
 drivers/staging/smbfs/getopt.c                     |   64 -
 drivers/staging/smbfs/getopt.h                     |   14 -
 drivers/staging/smbfs/inode.c                      |  854 -----
 drivers/staging/smbfs/ioctl.c                      |   68 -
 drivers/staging/smbfs/proc.c                       | 3502 --------------------
 drivers/staging/smbfs/proto.h                      |   89 -
 drivers/staging/smbfs/request.c                    |  817 -----
 drivers/staging/smbfs/request.h                    |   70 -
 drivers/staging/smbfs/smb.h                        |  118 -
 drivers/staging/smbfs/smb_debug.h                  |   34 -
 drivers/staging/smbfs/smb_fs.h                     |  153 -
 drivers/staging/smbfs/smb_fs_i.h                   |   37 -
 drivers/staging/smbfs/smb_fs_sb.h                  |  100 -
 drivers/staging/smbfs/smb_mount.h                  |   65 -
 drivers/staging/smbfs/smbfs.txt                    |    8 -
 drivers/staging/smbfs/smbiod.c                     |  343 --
 drivers/staging/smbfs/smbno.h                      |  363 --
 drivers/staging/smbfs/sock.c                       |  385 ---
 drivers/staging/smbfs/symlink.c                    |   67 -
 drivers/staging/usbip/Kconfig                      |    2 +-
 drivers/staging/usbip/stub.h                       |    4 +-
 drivers/staging/usbip/stub_dev.c                   |   13 +-
 drivers/staging/usbip/stub_rx.c                    |   13 +-
 drivers/staging/usbip/stub_tx.c                    |   14 +-
 drivers/staging/usbip/usbip_common.c               |  105 -
 drivers/staging/usbip/usbip_common.h               |   20 +-
 drivers/staging/usbip/usbip_event.c                |   31 +-
 drivers/staging/usbip/vhci.h                       |    4 +-
 drivers/staging/usbip/vhci_hcd.c                   |   10 +-
 drivers/staging/usbip/vhci_rx.c                    |   16 +-
 drivers/staging/usbip/vhci_sysfs.c                 |    9 +-
 drivers/staging/usbip/vhci_tx.c                    |   14 +-
 drivers/target/target_core_device.c                |    1 -
 drivers/target/target_core_fabric_lib.c            |    1 -
 drivers/target/target_core_file.c                  |    1 -
 drivers/target/target_core_hba.c                   |    1 -
 drivers/target/target_core_iblock.c                |    1 -
 drivers/target/target_core_pscsi.c                 |    1 -
 drivers/target/target_core_rd.c                    |    1 -
 drivers/target/target_core_tpg.c                   |    1 -
 drivers/target/target_core_transport.c             |    1 -
 drivers/tty/n_hdlc.c                               |    1 -
 drivers/tty/n_r3964.c                              |    1 -
 drivers/tty/pty.c                                  |    1 -
 drivers/tty/tty_io.c                               |    1 -
 drivers/tty/tty_ldisc.c                            |    2 -
 drivers/tty/vt/selection.c                         |    1 -
 drivers/tty/vt/vc_screen.c                         |    1 -
 drivers/tty/vt/vt.c                                |    1 -
 drivers/tty/vt/vt_ioctl.c                          |    1 -
 fs/Kconfig                                         |    1 -
 fs/Makefile                                        |    1 -
 fs/adfs/Kconfig                                    |    1 -
 fs/adfs/dir.c                                      |    6 -
 fs/adfs/inode.c                                    |    6 -
 fs/adfs/super.c                                    |   13 +-
 fs/compat_ioctl.c                                  |    1 -
 fs/ufs/Kconfig                                     |    1 -
 fs/ufs/inode.c                                     |   78 +-
 fs/ufs/namei.c                                     |   35 +-
 fs/ufs/super.c                                     |   55 +-
 fs/ufs/truncate.c                                  |    5 +-
 fs/ufs/ufs.h                                       |    6 +-
 include/drm/Kbuild                                 |    1 -
 include/drm/i830_drm.h                             |  342 --
 include/linux/Kbuild                               |    1 -
 include/linux/hardirq.h                            |    9 +-
 include/linux/smp_lock.h                           |   65 -
 include/trace/events/bkl.h                         |   61 -
 init/Kconfig                                       |    5 -
 kernel/rtmutex-tester.c                            |   39 +-
 kernel/sched.c                                     |    7 -
 lib/Makefile                                       |    1 -
 lib/kernel_lock.c                                  |  143 -
 net/Kconfig                                        |    1 -
 net/Makefile                                       |    1 -
 net/ipx/Kconfig                                    |    1 -
 net/ipx/af_ipx.c                                   |   52 +-
 net/socket.c                                       |    1 -
 net/x25/Kconfig                                    |    1 -
 net/x25/af_x25.c                                   |   61 +-
 net/x25/x25_out.c                                  |    7 +-
 157 files changed, 356 insertions(+), 13722 deletions(-)
 delete mode 100644 drivers/gpu/drm/i830/Makefile
 delete mode 100644 drivers/gpu/drm/i830/i830_dma.c
 delete mode 100644 drivers/gpu/drm/i830/i830_drv.c
 delete mode 100644 drivers/gpu/drm/i830/i830_drv.h
 delete mode 100644 drivers/gpu/drm/i830/i830_irq.c
 delete mode 100644 drivers/net/appletalk/Makefile
 rename drivers/{net => staging}/appletalk/Kconfig (98%)
 rename {net => drivers/staging}/appletalk/Makefile (56%)
 rename {net => drivers/staging}/appletalk/aarp.c (99%)
 rename {include/linux => drivers/staging/appletalk}/atalk.h (100%)
 rename {net => drivers/staging}/appletalk/atalk_proc.c (99%)
 rename drivers/{net => staging}/appletalk/cops.c (99%)
 rename drivers/{net => staging}/appletalk/cops.h (100%)
 rename drivers/{net => staging}/appletalk/cops_ffdrv.h (100%)
 rename drivers/{net => staging}/appletalk/cops_ltdrv.h (100%)
 rename {net => drivers/staging}/appletalk/ddp.c (98%)
 rename {net => drivers/staging}/appletalk/dev.c (100%)
 rename drivers/{net => staging}/appletalk/ipddp.c (99%)
 rename drivers/{net => staging}/appletalk/ipddp.h (100%)
 rename drivers/{net => staging}/appletalk/ltpc.c (99%)
 rename drivers/{net => staging}/appletalk/ltpc.h (100%)
 rename {net => drivers/staging}/appletalk/sysctl_net_atalk.c (98%)
 delete mode 100644 drivers/staging/autofs/Kconfig
 delete mode 100644 drivers/staging/autofs/Makefile
 delete mode 100644 drivers/staging/autofs/TODO
 delete mode 100644 drivers/staging/autofs/autofs_i.h
 delete mode 100644 drivers/staging/autofs/dirhash.c
 delete mode 100644 drivers/staging/autofs/init.c
 delete mode 100644 drivers/staging/autofs/inode.c
 delete mode 100644 drivers/staging/autofs/root.c
 delete mode 100644 drivers/staging/autofs/symlink.c
 delete mode 100644 drivers/staging/autofs/waitq.c
 rename {fs => drivers/staging}/hpfs/Kconfig (80%)
 rename {fs => drivers/staging}/hpfs/Makefile (100%)
 create mode 100644 drivers/staging/hpfs/TODO
 rename {fs => drivers/staging}/hpfs/alloc.c (100%)
 rename {fs => drivers/staging}/hpfs/anode.c (100%)
 rename {fs => drivers/staging}/hpfs/buffer.c (100%)
 rename {fs => drivers/staging}/hpfs/dentry.c (100%)
 rename {fs => drivers/staging}/hpfs/dir.c (97%)
 rename {fs => drivers/staging}/hpfs/dnode.c (100%)
 rename {fs => drivers/staging}/hpfs/ea.c (100%)
 rename {fs => drivers/staging}/hpfs/file.c (97%)
 rename {fs => drivers/staging}/hpfs/hpfs.h (100%)
 rename {fs => drivers/staging}/hpfs/hpfs_fn.h (91%)
 rename {fs => drivers/staging}/hpfs/inode.c (98%)
 rename {fs => drivers/staging}/hpfs/map.c (100%)
 rename {fs => drivers/staging}/hpfs/name.c (100%)
 rename {fs => drivers/staging}/hpfs/namei.c (96%)
 rename {fs => drivers/staging}/hpfs/super.c (98%)
 delete mode 100644 drivers/staging/smbfs/Kconfig
 delete mode 100644 drivers/staging/smbfs/Makefile
 delete mode 100644 drivers/staging/smbfs/TODO
 delete mode 100644 drivers/staging/smbfs/cache.c
 delete mode 100644 drivers/staging/smbfs/dir.c
 delete mode 100644 drivers/staging/smbfs/file.c
 delete mode 100644 drivers/staging/smbfs/getopt.c
 delete mode 100644 drivers/staging/smbfs/getopt.h
 delete mode 100644 drivers/staging/smbfs/inode.c
 delete mode 100644 drivers/staging/smbfs/ioctl.c
 delete mode 100644 drivers/staging/smbfs/proc.c
 delete mode 100644 drivers/staging/smbfs/proto.h
 delete mode 100644 drivers/staging/smbfs/request.c
 delete mode 100644 drivers/staging/smbfs/request.h
 delete mode 100644 drivers/staging/smbfs/smb.h
 delete mode 100644 drivers/staging/smbfs/smb_debug.h
 delete mode 100644 drivers/staging/smbfs/smb_fs.h
 delete mode 100644 drivers/staging/smbfs/smb_fs_i.h
 delete mode 100644 drivers/staging/smbfs/smb_fs_sb.h
 delete mode 100644 drivers/staging/smbfs/smb_mount.h
 delete mode 100644 drivers/staging/smbfs/smbfs.txt
 delete mode 100644 drivers/staging/smbfs/smbiod.c
 delete mode 100644 drivers/staging/smbfs/smbno.h
 delete mode 100644 drivers/staging/smbfs/sock.c
 delete mode 100644 drivers/staging/smbfs/symlink.c
 delete mode 100644 include/drm/i830_drm.h
 delete mode 100644 include/linux/smp_lock.h
 delete mode 100644 include/trace/events/bkl.h
 delete mode 100644 lib/kernel_lock.c

[re-sent to mailing lists, due to overly long
 Cc list getting rejected by vger]

Cc: autofs@linux.kernel.org
Cc: dri-devel@lists.freedesktop.org
Cc: linux-cifs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-x25@vger.kernel.org
Cc: netdev@vger.kernel.org
