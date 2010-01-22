From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 00/31] CAPI: Major rework, tons of bug fixes
Date: Sat, 23 Jan 2010 00:03:26 +0100
Message-ID: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755397Ab0AVXNW@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

First of all sorry if I'm breaking the correct flow of ISDN patches, but
I'm under the impression that things currently get merged directly via
Dave, right?

This series can also be pulled from

	git://git.kiszka.org/linux-2.6.git capi

As one of the (presumably) few remaining users of an AVM FRITZ!Card DSL
v2.0, I originally just wanted to finally get that broken proprietary
driver into a more reliable state. But I actually ended up fixing also
wide parts of the in-kernel CAPI stack - a job that turned out to be
almost as "interesting" as hacking on that driver.

The major issue of the CAPI stack were incomplete or broken locking
schemes. That caused sporadic crashes, specifically during
setup/shutdown phases of connections, devices, or whatever dynamic
objects. But it also affected some code that was executed during normal
operation. I think I fixed most of those issue, at least all I found via
code inspection, lockdep runs, and testing. This series in production
use on my home gateway for two weeks now (under CONFIG_PREEMPT - the
original stack and driver code only worked acceptably under
CONFIG_PREEMPT_NONE). I also applied some cleanups, and polished the old
capifs a bit.

So the series concludes with removing the experimental tag from the CAPI
middleware, primarily the kernel's CAPI-speaking gate to user space
(eg. for use with Asterisk). There also patch to officially claim the
char major number 191 that CAPI (and likely only CAPI) used in the past
decade.

Note that, although I touched some small parts of it, I did _not_ fix
any locking issue of the capidrv, the interface to the legacy ISDN
stack. It is _surely_ broken in similar ways. But while it may also be
fixable, I rather decided that I'm going to invest a bit time in a
replacement of the last local user, isdnlog.

Looking forward to feedback,
Jan


PS: If anyone is interested in the fcdsl2 FRITZ!Card driver rework, you
can find the current version at

	git://git.kiszka.org/fcdsl2.git

Jan Kiszka (31):
  CAPI: Fix leaks in capifs_new_ncci
  CAPI: Sanitize capifs API
  CAPI: Eliminate capifs_root variable
  CAPI: Pin capifs instead of mounting it
  CAPI: Reduce chattiness during module loading/removal
  CAPI: Call a controller 'controller', not 'card'
  CAPI: Convert capi drivers rwlock into mutex
  CAPI: Rework capi_ctr_ready/down
  CAPI: Rework controller state notifier
  CAPI: Rework locking of controller data structures
  CAPI: Rework application locking
  CAPI: Reduce #ifdef mess around CONFIG_ISDN_CAPI_MIDDLEWARE
  CAPI: Convert capidev_list_lock into a mutex
  CAPI: Clean up capi_open/release
  CAPI: Rework locking of capidev members
  CAPI: Use non-atomic allocation during NCCI setup
  CAPI: Fix racy capi_read
  CAPI: Switch NCCI list to standard doubly linked list
  CAPI: Fix locking around glueing capiminor and capidev
  CAPI: Drop atomic ttyopencount
  CAPI: Remove useless checks for tty->driver_data or hung up state
  CAPI: Rework tty locking in RX and TX path of capiminor
  CAPI: Rename datahandle_queue -> ackqueue_entry
  CAPI: Use atomics for capiminor's datahandle and msgid
  CAPI: Drop capiminor's unused inbytes counter
  CAPI: Fix locking around capiminor's output queue
  CAPI: Clean up capiminor_*_ack
  CAPI: Drop handle_minor_send return value
  CAPI: Drop special controller lookup from capi20_put_message
  CAPI: Remove experimental tag from middleware feature
  CAPI: Officially claim char major 191

 Documentation/devices.txt      |    7 +-
 drivers/isdn/capi/Kconfig      |    3 +-
 drivers/isdn/capi/capi.c       |  937 ++++++++++++++++++----------------------
 drivers/isdn/capi/capidrv.c    |   48 +--
 drivers/isdn/capi/capifs.c     |  126 +++---
 drivers/isdn/capi/capifs.h     |   21 +-
 drivers/isdn/capi/kcapi.c      |  797 ++++++++++++++++++----------------
 drivers/isdn/capi/kcapi.h      |   12 +-
 drivers/isdn/capi/kcapi_proc.c |   41 +-
 include/linux/isdn/capilli.h   |    2 +-
 include/linux/kernelcapi.h     |   17 +-
 11 files changed, 1005 insertions(+), 1006 deletions(-)
