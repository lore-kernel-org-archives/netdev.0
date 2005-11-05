From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 00/25] reduce code in fs/compat_ioctl.c
Date: Sat, 05 Nov 2005 17:26:50 +0100
Message-ID: <20051105162650.620266000@b551138y.boeblingen.de.ibm.com>
Cc: video4linux-list@redhat.com, linux-parport@lists.infradead.org,
	zippel@linux-m68k.org, rmk+serial@arm.linux.org.uk,
	ext2-devel@lists.sourceforge.net, Kai.Makisara@kolumbus.fi,
	netdev@vger.kernel.org, linux-mtd@lists.infradead.org,
	bluez-devel@lists.sf.net, hpa@zytor.com, urban@teststation.com,
	samba-technical@lists.samba.org, Christoph Hellwig <hch@lst.de>,
	tim@cyberelk.net, chas@cmf.nrl.navy.mil, osst@riede.org,
	linux-usb-devel@lists.sourceforge.net, linux-scsi@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	reiserfs-dev@namesys.com, lm-sensors@lm-sensors.org,
	sfrench@samba.org, vandrove@vc.cvut.cz, gadio@netvision.net.il,
	linux-serial@vger.kernel.org, dgilbert@interlog.com,
	osst-users@lists.sourceforge.net, James.Bottomley@SteelEye.com,
	emoenke@gwdg.de, nathans@sgi.com, marcel@holtmann.org,
	schwidefsky@de.ibm.com, maxk@qualcomm.com,
	packet-writing@suse.com,
Return-path: <linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org>
To: linux-kernel@vger.kernel.org
List-Unsubscribe: <http://lists.infradead.org/mailman/listinfo/linux-mtd>,
	<mailto:linux-mtd-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mtd>
List-Post: <mailto:linux-mtd@lists.infradead.org>
List-Help: <mailto:linux-mtd-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mtd>,
	<mailto:linux-mtd-request@lists.infradead.org?subject=subscribe>
Sender: linux-mtd-bounces@lists.infradead.org
Errors-To: linux-mtd-bounces+gldm-linux-mtd-36=gmane.org+gldm-linux-mtd-36=gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Sünnavend 05 November 2005 00:51, Christoph Hellwig wrote:
> On Sat, Nov 05, 2005 at 12:10:46AM +0100, Arnd Bergmann wrote:
> >
> > BTW, I now have a set of 25 patches that moves all handlers from
> > fs/compat_ioctl.c over to the respective drivers and subsystems,
> > but I'm not sure how to best test that.
> > I intend to at least give it a test run on my Opteron for the whatever
> > ioctls I normally use, but the rest is just guesswork. Christoph,
> > can you review those patches?
> 
> I'm not sure moving everything from fs/compat_ioctl.c is a good idea.
> Everything that is just in a single driver or subsystem that has
> common ioctl code - sure.  else it doesn't make a lot of sense.

Ok, here is my full set of patches, let's see which ones are
sensible and which ones we are better off without.

Getting rid of fs/compat_ioctl.c completely could at least simplify
the compat_sys_ioctl() code a bit and would also make sure that
we only build the handlers into the kernel that can be used
potentially, which reduces the binary size.

The patch set is still largely untested, except for a single
compile test, but at least some of the patches are very simple,
so maybe I can get a quick ack or nack on them.

In general, I'm just moving over the handlers to the respective
subsystem without changing the logic, so the patch should not
have any effect on the ioctl operation itself, but it also
means that the handlers still use compat_alloc_user_space
or get_fs/set_fs when it's not really necessary.

	Arnd <><

 drivers/block/ioctl.c                       |  549 +++++
 drivers/block/loop.c                        |   76
 drivers/block/paride/pcd.c                  |    1
 drivers/block/paride/pd.c                   |    1
 drivers/block/paride/pt.c                   |    1
 drivers/block/pktcdvd.c                     |   20
 drivers/bluetooth/hci_ldisc.c               |   22
 drivers/cdrom/Makefile                      |    2
 drivers/cdrom/aztcd.c                       |    1
 drivers/cdrom/cdu31a.c                      |    1
 drivers/cdrom/cm206.c                       |    1
 drivers/cdrom/compat.c                      |  163 +
 drivers/cdrom/gscd.c                        |    1
 drivers/cdrom/mcdx.c                        |    1
 drivers/cdrom/optcd.c                       |    1
 drivers/cdrom/sbpcd.c                       |    1
 drivers/cdrom/sjcd.c                        |    1
 drivers/cdrom/sonycd535.c                   |    2
 drivers/char/Makefile                       |    1
 drivers/char/compat_mtio.c                  |   81
 drivers/char/ftape/zftape/zftape-init.c     |    1
 drivers/char/n_tty.c                        |    1
 drivers/char/raw.c                          |   91
 drivers/char/tty_io.c                       |  191 +
 drivers/char/viotape.c                      |    1
 drivers/char/vt.c                           |    3
 drivers/char/vt_ioctl.c                     |  195 +
 drivers/i2c/i2c-dev.c                       |  141 +
 drivers/ide/ide-cd.c                        |    1
 drivers/ide/ide-floppy.c                    |    1
 drivers/ide/ide-tape.c                      |    1
 drivers/media/radio/miropcm20-radio.c       |    1
 drivers/media/radio/radio-aimslab.c         |    1
 drivers/media/radio/radio-aztech.c          |    1
 drivers/media/radio/radio-cadet.c           |    1
 drivers/media/radio/radio-gemtek-pci.c      |    1
 drivers/media/radio/radio-gemtek.c          |    1
 drivers/media/radio/radio-maestro.c         |    1
 drivers/media/radio/radio-maxiradio.c       |    1
 drivers/media/radio/radio-rtrack2.c         |    1
 drivers/media/radio/radio-sf16fmi.c         |    1
 drivers/media/radio/radio-sf16fmr2.c        |    1
 drivers/media/radio/radio-terratec.c        |    1
 drivers/media/radio/radio-trust.c           |    1
 drivers/media/radio/radio-typhoon.c         |    1
 drivers/media/radio/radio-zoltrix.c         |    1
 drivers/media/video/Makefile                |    2
 drivers/media/video/arv.c                   |    1
 drivers/media/video/bttv-driver.c           |    1
 drivers/media/video/bw-qcam.c               |    1
 drivers/media/video/c-qcam.c                |    1
 drivers/media/video/compat_ioctl.c          |  318 +++
 drivers/media/video/cpia.c                  |    1
 drivers/media/video/cx88/cx88-video.c       |    2
 drivers/media/video/meye.c                  |    1
 drivers/media/video/pms.c                   |    1
 drivers/media/video/saa5249.c               |    1
 drivers/media/video/saa7134/saa7134-video.c |    2
 drivers/media/video/stradis.c               |    1
 drivers/media/video/w9966.c                 |    1
 drivers/media/video/zoran_driver.c          |    1
 drivers/media/video/zr36120.c               |    1
 drivers/mtd/mtdchar.c                       |   94
 drivers/net/ppp_generic.c                   |  179 +
 drivers/s390/char/tape_char.c               |    1
 drivers/scsi/osst.c                         |    2
 drivers/scsi/sg.c                           |  154 +
 drivers/scsi/sr.c                           |    1
 drivers/scsi/st.c                           |    2
 drivers/usb/core/devio.c                    |  139 +
 drivers/usb/media/dsbr100.c                 |    1
 drivers/usb/media/ov511.c                   |    1
 drivers/usb/media/pwc/pwc-if.c              |    1
 drivers/usb/media/se401.c                   |    1
 drivers/usb/media/stv680.c                  |    1
 drivers/usb/media/usbvideo.c                |    1
 drivers/usb/media/vicam.c                   |    1
 drivers/usb/media/w9968cf.c                 |    1
 drivers/video/fbmem.c                       |  147 +
 fs/autofs/root.c                            |   35
 fs/autofs4/root.c                           |   41
 fs/block_dev.c                              |   10
 fs/cifs/cifsfs.c                            |   10
 fs/cifs/cifsfs.h                            |    2
 fs/cifs/ioctl.c                             |   29
 fs/compat.c                                 |   27
 fs/compat_ioctl.c                           | 2918 ----------------------------
 fs/ext2/dir.c                               |    3
 fs/ext2/ext2.h                              |    1
 fs/ext2/file.c                              |    6
 fs/ext2/ioctl.c                             |   31
 fs/ext3/dir.c                               |    3
 fs/ext3/file.c                              |    3
 fs/ext3/ioctl.c                             |   66
 fs/fat/dir.c                                |   54
 fs/hfsplus/dir.c                            |    4
 fs/hfsplus/hfsplus_fs.h                     |    4
 fs/hfsplus/inode.c                          |    4
 fs/hfsplus/ioctl.c                          |   29
 fs/ncpfs/dir.c                              |    3
 fs/ncpfs/file.c                             |    4
 fs/ncpfs/ioctl.c                            |  241 ++
 fs/reiserfs/dir.c                           |    3
 fs/reiserfs/file.c                          |    4
 fs/reiserfs/ioctl.c                         |   36
 fs/smbfs/dir.c                              |    4
 fs/smbfs/file.c                             |    4
 fs/smbfs/ioctl.c                            |   16
 fs/smbfs/proto.h                            |    1
 fs/xfs/linux-2.6/xfs_ioctl32.c              |   15
 include/linux/cdrom.h                       |    2
 include/linux/compat_ioctl.h                |  387 ---
 include/linux/ext2_fs.h                     |    7
 include/linux/ext3_fs.h                     |    1
 include/linux/fs.h                          |    3
 include/linux/ioctl32.h                     |    2
 include/linux/mtio.h                        |   12
 include/linux/ncp_fs.h                      |    1
 include/linux/net.h                         |    2
 include/linux/reiserfs_fs.h                 |    9
 include/linux/socket.h                      |    4
 include/linux/tty.h                         |    2
 include/linux/tty_driver.h                  |    4
 include/linux/tty_ldisc.h                   |    2
 include/linux/videodev.h                    |    2
 include/net/sock.h                          |    9
 net/atm/common.h                            |    1
 net/atm/ioctl.c                             |  167 +
 net/atm/pvc.c                               |    3
 net/atm/svc.c                               |    3
 net/bluetooth/bnep/sock.c                   |    1
 net/bluetooth/cmtp/sock.c                   |    1
 net/bluetooth/hci_sock.c                    |    1
 net/bluetooth/hidp/sock.c                   |    1
 net/bluetooth/rfcomm/sock.c                 |    1
 net/compat.c                                | 1456 +++++++++----
 net/socket.c                                |    7
 137 files changed, 4527 insertions(+), 3807 deletions(-)


______________________________________________________
Linux MTD discussion mailing list
http://lists.infradead.org/mailman/listinfo/linux-mtd/
