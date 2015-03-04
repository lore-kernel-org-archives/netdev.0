From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 5/5] TTY: fix tty_wait_until_sent maximum timeout
Date: Wed,  4 Mar 2015 10:39:07 +0100
Message-ID: <1425461947-15888-6-git-send-email-johan@kernel.org>
References: <1425461947-15888-1-git-send-email-johan@kernel.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Peter Hurley <peter@hurleysoftware.com>,
	Alan Cox <alan@linux.intel.com>, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-serial@vger.kernel.org,
	netdev@vger.kernel.org,
	ZIV-Asier Llano Palacios <asier.llano@cgglobal.com>,
	Johan Hovold <johan@kernel.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425461947-15888-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently tty_wait_until_sent may take up to twice as long as the
requested timeout while waiting for driver and hardware buffers to
drain.

Fix this by taking the remaining number of jiffies after waiting for
driver buffers to drain into account so that the timeout actually
becomes a maximum timeout as it is documented to be.

Note that this specifically implies tighter timings when closing a port
as a consequence of actually honouring the port closing-wait setting
for drivers relying on tty_wait_until_sent_from_close (e.g. via
tty_port_close_start).

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/tty/tty_ioctl.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/tty/tty_ioctl.c b/drivers/tty/tty_ioctl.c
index 89ae23ac9ae6..632fc8152061 100644
--- a/drivers/tty/tty_ioctl.c
+++ b/drivers/tty/tty_ioctl.c
@@ -218,10 +218,10 @@ void tty_wait_until_sent(struct tty_struct *tty, long timeout)
 	if (!timeout)
 		timeout = MAX_SCHEDULE_TIMEOUT;
 
-	if (wait_event_interruptible_timeout(tty->write_wait,
-			!tty_chars_in_buffer(tty), timeout) < 0) {
+	timeout = wait_event_interruptible_timeout(tty->write_wait,
+			!tty_chars_in_buffer(tty), timeout);
+	if (timeout <= 0)
 		return;
-	}
 
 	if (timeout == MAX_SCHEDULE_TIMEOUT)
 		timeout = 0;
-- 
2.0.5
