From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v1 00/49] USB: prepare for enabling irq in complete()
Date: Sun, 18 Aug 2013 00:24:25 +0800
Message-ID: <1376756714-25479-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-input-owner@vger.kernel.org>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

As we are going to run URB->complete() in tasklet context[1][2], and
hard interrupt may be enabled when running URB completion handler[3],
so we might need to disable interrupt when acquiring one lock in
the completion handler for the below reasons:

- URB->complete() holds a subsystem wide lock which may be acquired
in another hard irq context, and the subsystem wide lock is acquired
by spin_lock()/read_lock()/write_lock() in complete()

- URB->complete() holds a private lock with spin_lock()/read_lock()/write_lock()
but driver may export APIs to make other drivers acquire the same private
lock in its interrupt handler.

For the sake of safety and making the change simple, this patch set
converts all spin_lock()/read_lock()/write_lock() in completion handler
path into their irqsave version mechanically.

But if you are sure the above two cases do not happen in your driver,
please let me know and I can drop the unnecessary change.

Also if you find some conversions are missed, also please let me know so
that I can add it in the next round.


[1], USB: URB documentation: claim complete() will be run with IRQs enabled
https://git.kernel.org/cgit/linux/kernel/git/gregkh/usb.git/commit/?h=usb-next&id=85721d45261c4be684730c7509a59daa6cda30d8

[2], USB: HCD: support giveback of URB in tasklet context
https://git.kernel.org/cgit/linux/kernel/git/gregkh/usb.git/commit/?h=usb-next&id=94dfd7edfd5c9b605caf7b562de7a813d216e011

[3], http://marc.info/?l=linux-usb&m=137286330626363&w=2

V1:
	- rename patchset title
	- add missed changes on 'usb_skeleon and usb sg lib'
	- remove several sound usb drivers which have been done via sound tree
	- some patch style fix
	- replace snd_pcm_stream_lock with snd_pcm_stream_lock_irqsave for related
	a/v drivers

Cc: linux-input@vger.kernel.org
Cc: linux-bluetooth@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-wireless@vger.kernel.org
Cc: linux-media@vger.kernel.org
Cc: alsa-devel@alsa-project.org

 drivers/bluetooth/bfusb.c                     |   12 ++++----
 drivers/bluetooth/btusb.c                     |    5 ++--
 drivers/hid/usbhid/hid-core.c                 |    5 ++--
 drivers/input/misc/cm109.c                    |   10 ++++---
 drivers/isdn/hardware/mISDN/hfcsusb.c         |   36 ++++++++++++-----------
 drivers/media/dvb-core/dvb_demux.c            |   17 +++++++----
 drivers/media/usb/cx231xx/cx231xx-audio.c     |   10 ++++---
 drivers/media/usb/cx231xx/cx231xx-core.c      |   10 ++++---
 drivers/media/usb/cx231xx/cx231xx-vbi.c       |    5 ++--
 drivers/media/usb/em28xx/em28xx-audio.c       |    5 ++--
 drivers/media/usb/em28xx/em28xx-core.c        |    5 ++--
 drivers/media/usb/sn9c102/sn9c102_core.c      |    7 +++--
 drivers/media/usb/tlg2300/pd-alsa.c           |    5 ++--
 drivers/media/usb/tlg2300/pd-video.c          |    5 ++--
 drivers/media/usb/tm6000/tm6000-video.c       |    5 ++--
 drivers/net/usb/cdc-phonet.c                  |    5 ++--
 drivers/net/usb/hso.c                         |   38 ++++++++++++++-----------
 drivers/net/usb/kaweth.c                      |    7 +++--
 drivers/net/usb/rtl8150.c                     |    5 ++--
 drivers/net/wireless/ath/ath9k/hif_usb.c      |   29 ++++++++++---------
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c |    9 +++---
 drivers/net/wireless/ath/ath9k/wmi.c          |   11 +++----
 drivers/net/wireless/ath/carl9170/rx.c        |    5 ++--
 drivers/net/wireless/libertas/if_usb.c        |    5 ++--
 drivers/net/wireless/libertas_tf/if_usb.c     |    6 ++--
 drivers/net/wireless/zd1211rw/zd_usb.c        |   21 ++++++++------
 drivers/staging/bcm/InterfaceRx.c             |    5 ++--
 drivers/staging/btmtk_usb/btmtk_usb.c         |    5 ++--
 drivers/staging/ced1401/usb1401.c             |   35 ++++++++++++-----------
 drivers/staging/vt6656/usbpipe.c              |    9 +++---
 drivers/usb/class/cdc-wdm.c                   |   16 +++++++----
 drivers/usb/class/usblp.c                     |   10 ++++---
 drivers/usb/core/devio.c                      |    5 ++--
 drivers/usb/core/message.c                    |    5 ++--
 drivers/usb/misc/adutux.c                     |   10 ++++---
 drivers/usb/misc/iowarrior.c                  |    5 ++--
 drivers/usb/misc/ldusb.c                      |    7 +++--
 drivers/usb/misc/legousbtower.c               |    6 ++--
 drivers/usb/misc/usbtest.c                    |   10 ++++---
 drivers/usb/misc/uss720.c                     |    7 ++++-
 drivers/usb/serial/cyberjack.c                |   15 ++++++----
 drivers/usb/serial/digi_acceleport.c          |   23 ++++++++-------
 drivers/usb/serial/io_edgeport.c              |   14 +++++----
 drivers/usb/serial/io_ti.c                    |    5 ++--
 drivers/usb/serial/mos7720.c                  |    5 ++--
 drivers/usb/serial/mos7840.c                  |    5 ++--
 drivers/usb/serial/quatech2.c                 |    5 ++--
 drivers/usb/serial/sierra.c                   |    9 +++---
 drivers/usb/serial/symbolserial.c             |    5 ++--
 drivers/usb/serial/ti_usb_3410_5052.c         |    9 +++---
 drivers/usb/serial/usb_wwan.c                 |    5 ++--
 drivers/usb/usb-skeleton.c                    |   11 ++++---
 sound/usb/caiaq/audio.c                       |    5 ++--
 sound/usb/midi.c                              |    5 ++--
 54 files changed, 318 insertions(+), 221 deletions(-)


Thanks,
--
Ming Lei

