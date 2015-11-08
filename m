From: Peter Hurley <peter@hurleysoftware.com>
Subject: [PATCH 0/4] Replace tty->closing
Date: Sun,  8 Nov 2015 17:02:49 -0500
Message-ID: <1447020173-32207-1-git-send-email-peter@hurleysoftware.com>
Cc: Jiri Slaby <jslaby@suse.cz>, linux-kernel@vger.kernel.org,
	linux-serial@vger.kernel.org, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Jesper Nilsson <jesper.nilsson@axis.com>,
	Mikael Starvik <starvik@axis.com>,
	Jiri Kosina <jikos@kernel.org>,
	David Sterba <dsterba@suse.com>,
	Mark Hounschell <markh@compro.net>,
	Peter Hurley <peter@hurleysoftware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Greg,

This series cleans up a messy and poorly documented mechanism required
at tty final close to prevent drivers from crashing after h/w shutdown.

Without special handling, N_TTY echoing will cause driver i/o requests
_after_ h/w shutdown, which typically crashes the driver. Currently,
the tty_struct::closing flag triggers this special handling. However,
this mechanism is error-prone and subject to driver misuse.

This series replaces tty->closing with a ldisc-specific interface,
tty_ldisc_closing(), and implements this interface for N_TTY.
For tty drivers which use tty_port_close_start(), this change eliminates
the last vestige of direct driver<->ldisc interaction. The few tty drivers
which open-code the close() method still use [1] tty_ldisc_closing() directly.

The tty driver is aware final close for the tty is commencing because the
tty->count == 1 in the close() method. On final close, the following is
also true:
1. port->count == 1. tty drivers which ref count the port, use the
   --port->count == 0 as a substitute condition for final close.
2. final close is occurring as a result of the last in-use file descriptor
   release. Consequently, there will be no read/poll/ioctl in-progress.
3. the line discipline instance will be stopped and destroyed immediately
   after the tty driver completes the close() method
4. the tty itself will be unrefed immediately after the line discipline
   instance is destroyed.

Thus, the ldisc and tty buffers need only be flushed once, as any data
received by the tty driver after the flush but before h/w shutdown will
be deleted when the line discipline instance is destroyed.
No new echoes will occur after the ldisc flush because the echo buffer
is also flushed and new input (which otherwise might generate echoes) is
ignored while closing. This series removes the extra tty_ldisc_flush()
being performed by most drivers after h/w shutdown.

Additionally, the ldisc closing state need not be reset since the line
discipline instance is being destroyed, so no interface is provided to reset
closing.


[1] tty drivers which open-code the close() method
drivers/staging/dgnc/dgnc_tty.c
drivers/staging/dgap/dgap.c
drivers/tty/hvc/hvsi.c
drivers/tty/serial/68328serial.c
drivers/tty/serial/crisv10.c
drivers/isdn/i4l/isdn_tty.c
drivers/s390/char/con3215.c


Regards,

Peter Hurley (4):
  tty: rocket: Remove private close_wait
  n_tty: Ignore all read data when closing
  tty: Abstract and encapsulate tty->closing behavior
  tty: Remove drivers' extra tty_ldisc_flush()

 drivers/char/pcmcia/synclink_cs.c |  3 ---
 drivers/isdn/i4l/isdn_tty.c       |  2 +-
 drivers/s390/char/con3215.c       |  3 +--
 drivers/staging/dgap/dgap.c       |  4 +---
 drivers/staging/dgnc/dgnc_tty.c   |  4 +---
 drivers/tty/amiserial.c           |  2 --
 drivers/tty/hvc/hvsi.c            |  2 +-
 drivers/tty/ipwireless/tty.c      |  1 -
 drivers/tty/n_tty.c               | 15 +++++++++++----
 drivers/tty/rocket.c              |  5 -----
 drivers/tty/rocket_int.h          |  1 -
 drivers/tty/serial/68328serial.c  |  3 +--
 drivers/tty/serial/crisv10.c      |  3 +--
 drivers/tty/serial/serial_core.c  |  3 ---
 drivers/tty/synclink.c            |  1 -
 drivers/tty/synclink_gt.c         |  1 -
 drivers/tty/synclinkmp.c          |  1 -
 drivers/tty/tty_ldisc.c           | 19 +++++++++++++++++++
 drivers/tty/tty_port.c            |  5 +----
 include/linux/tty.h               |  2 +-
 include/linux/tty_ldisc.h         |  9 +++++++++
 21 files changed, 48 insertions(+), 41 deletions(-)

-- 
2.6.3
