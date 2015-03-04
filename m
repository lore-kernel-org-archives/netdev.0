From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 3/5] USB: serial: fix infinite wait_until_sent timeout
Date: Wed,  4 Mar 2015 10:39:05 +0100
Message-ID: <1425461947-15888-4-git-send-email-johan@kernel.org>
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

Make sure to handle an infinite timeout (0).

Note that wait_until_sent is currently never called with a 0-timeout
argument due to a bug in tty_wait_until_sent.

Fixes: dcf010503966 ("USB: serial: add generic wait_until_sent
implementation")
Cc: stable <stable@vger.kernel.org>	# v3.10

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/usb/serial/generic.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/usb/serial/generic.c b/drivers/usb/serial/generic.c
index ccf1df7c4b80..54e170dd3dad 100644
--- a/drivers/usb/serial/generic.c
+++ b/drivers/usb/serial/generic.c
@@ -258,7 +258,8 @@ void usb_serial_generic_wait_until_sent(struct tty_struct *tty, long timeout)
 	 * character or at least one jiffy.
 	 */
 	period = max_t(unsigned long, (10 * HZ / bps), 1);
-	period = min_t(unsigned long, period, timeout);
+	if (timeout)
+		period = min_t(unsigned long, period, timeout);
 
 	dev_dbg(&port->dev, "%s - timeout = %u ms, period = %u ms\n",
 					__func__, jiffies_to_msecs(timeout),
@@ -268,7 +269,7 @@ void usb_serial_generic_wait_until_sent(struct tty_struct *tty, long timeout)
 		schedule_timeout_interruptible(period);
 		if (signal_pending(current))
 			break;
-		if (time_after(jiffies, expire))
+		if (timeout && time_after(jiffies, expire))
 			break;
 	}
 }
-- 
2.0.5
