From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 4/5] TTY: fix tty_wait_until_sent on 64-bit machines
Date: Wed,  4 Mar 2015 10:39:06 +0100
Message-ID: <1425461947-15888-5-git-send-email-johan@kernel.org>
References: <1425461947-15888-1-git-send-email-johan@kernel.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Peter Hurley <peter@hurleysoftware.com>,
	Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-serial@vger.kernel.org,
	netdev@vger.kernel.org,
	ZIV-Asier Llano Palacios <asier.llano@cgglobal.com>,
	Johan Hovold <johan@kernel.org>,
	stable <stable@vger.kernel.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425461947-15888-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix overflow bug in tty_wait_until_sent on 64-bit machines, where an
infinite timeout (0) would be passed to the underlying tty-driver's
wait_until_sent-operation as a negative timeout (-1), causing it to
return immediately.

This manifests itself for example as tcdrain() returning immediately,
drivers not honouring the drain flags when setting terminal attributes,
or even dropped data on close as a requested infinite closing-wait
timeout would be ignored.

The first symptom  was reported by Asier LLANO who noted that tcdrain()
returned prematurely when using the ftdi_sio usb-serial driver.

Fix this by passing 0 rather than MAX_SCHEDULE_TIMEOUT (LONG_MAX) to the
underlying tty driver.

Note that the serial-core wait_until_sent-implementation is not affected
by this bug due to a lucky chance (comparison to an unsigned maximum
timeout), and neither is the cyclades one that had an explicit check for
negative timeouts, but all other tty drivers appear to be affected.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable <stable@vger.kernel.org>	# v2.6.12
Reported-by: ZIV-Asier Llano Palacios <asier.llano@cgglobal.com>
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/tty/tty_ioctl.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/tty/tty_ioctl.c b/drivers/tty/tty_ioctl.c
index a5cf253b2544..89ae23ac9ae6 100644
--- a/drivers/tty/tty_ioctl.c
+++ b/drivers/tty/tty_ioctl.c
@@ -217,11 +217,17 @@ void tty_wait_until_sent(struct tty_struct *tty, long timeout)
 #endif
 	if (!timeout)
 		timeout = MAX_SCHEDULE_TIMEOUT;
+
 	if (wait_event_interruptible_timeout(tty->write_wait,
-			!tty_chars_in_buffer(tty), timeout) >= 0) {
-		if (tty->ops->wait_until_sent)
-			tty->ops->wait_until_sent(tty, timeout);
+			!tty_chars_in_buffer(tty), timeout) < 0) {
+		return;
 	}
+
+	if (timeout == MAX_SCHEDULE_TIMEOUT)
+		timeout = 0;
+
+	if (tty->ops->wait_until_sent)
+		tty->ops->wait_until_sent(tty, timeout);
 }
 EXPORT_SYMBOL(tty_wait_until_sent);
 
-- 
2.0.5
