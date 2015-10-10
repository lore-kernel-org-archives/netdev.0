From: Peter Hurley <peter@hurleysoftware.com>
Subject: [PATCH 0/7] tty close cleanup
Date: Sat, 10 Oct 2015 16:00:50 -0400
Message-ID: <1444507257-7513-1-git-send-email-peter@hurleysoftware.com>
Cc: Jiri Slaby <jslaby@suse.cz>, Alan Cox <alan@linux.intel.com>,
	David Laight <David.Laight@aculab.com>,
	Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org,
	linux-serial@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Peter Hurley <peter@hurleysoftware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Greg,

This series is a redux of cleanup I originally submitted back in 2014;
the point is to remove the cruft which stems from dropping the tty lock
while waiting for output to drain before closing the tty.

Dropping the tty lock during close was added by "TTY: define
tty_wait_until_sent_from_close" to fix stalls on other parallel tty
operations while a tty was draining output while closing.

Since commit 89c8d91e31f2 ("tty: localise the lock") and commit
aa3cb814a8ef ("tty: Drop tty_mutex before tty reopen"), parallel tty
open/close/hangup on _other_ ttys no longer stall waiting for a tty
close to complete.

Continuing to hold the tty lock for the tty which is closing significantly
simplifies the state handling when opening a tty, since the tty cannot
have been closed concurrently. [Ideally, I would have liked to entirely
remove the TTY_CLOSING state flag, but unfortunately some older bit-rotting
drivers have co-opted it for dubious purposes].

In the previous series, David Laight had raised concerns about non-blocking
opens on the _same_ tty which is closing. However, as I pointed out in this
reply http://www.spinics.net/lists/linux-serial/msg14216.html, the outcome of
a parallel open while closing the same tty has not changed with this series,
since the existing code has blocked while ASYNC_CLOSING (and has done since at
least before 2.6.29).

I cc'd the commenters from the original series, Felipe Balbi for the gserial
usb gadget changes, and David Miller for the ISDN/IRDA changes.

Regards,

Peter Hurley (7):
  tty: Remove tty_wait_until_sent_from_close()
  tty: Remove ASYNC_CLOSING checks in open()/hangup() methods
  usb: gadget: gserial: Privatize close_wait
  tty: Remove tty_port::close_wait
  tty: r3964: Use tty->read_wait waitqueue
  tty: r3964: Replace/remove bogus tty lock use
  tty: Remove wait_event_interruptible_tty()

 drivers/char/pcmcia/synclink_cs.c      |  9 -------
 drivers/isdn/i4l/isdn_tty.c            |  2 +-
 drivers/tty/cyclades.c                 |  9 -------
 drivers/tty/hvc/hvc_console.c          |  2 +-
 drivers/tty/hvc/hvcs.c                 |  2 +-
 drivers/tty/n_r3964.c                  | 28 ++++++++++++---------
 drivers/tty/rocket.c                   | 13 ----------
 drivers/tty/serial/68328serial.c       |  1 -
 drivers/tty/serial/crisv10.c           | 34 +------------------------
 drivers/tty/serial/serial_core.c       |  1 -
 drivers/tty/synclink.c                 | 18 +++-----------
 drivers/tty/synclink_gt.c              | 14 ++---------
 drivers/tty/synclinkmp.c               | 14 ++---------
 drivers/tty/tty_port.c                 | 26 +++-----------------
 drivers/usb/gadget/function/u_serial.c |  6 +++--
 include/linux/n_r3964.h                |  8 +++---
 include/linux/tty.h                    | 45 ----------------------------------
 net/irda/ircomm/ircomm_tty.c           | 31 +----------------------
 18 files changed, 39 insertions(+), 224 deletions(-)

-- 
2.6.1
