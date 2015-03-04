From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 1/5] net: irda: fix wait_until_sent poll timeout
Date: Wed,  4 Mar 2015 10:39:03 +0100
Message-ID: <1425461947-15888-2-git-send-email-johan@kernel.org>
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

In case an infinite timeout (0) is requested, the irda wait_until_sent
implementation would use a zero poll timeout rather than the default
200ms.

Note that wait_until_sent is currently never called with a 0-timeout
argument due to a bug in tty_wait_until_sent.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable <stable@vger.kernel.org>	# v2.6.12
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 net/irda/ircomm/ircomm_tty.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index 40695b9751c1..4efe486baee6 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -798,7 +798,9 @@ static void ircomm_tty_wait_until_sent(struct tty_struct *tty, int timeout)
 	orig_jiffies = jiffies;
 
 	/* Set poll time to 200 ms */
-	poll_time = IRDA_MIN(timeout, msecs_to_jiffies(200));
+	poll_time = msecs_to_jiffies(200);
+	if (timeout)
+		poll_time = min_t(unsigned long, timeout, poll_time);
 
 	spin_lock_irqsave(&self->spinlock, flags);
 	while (self->tx_skb && self->tx_skb->len) {
-- 
2.0.5
