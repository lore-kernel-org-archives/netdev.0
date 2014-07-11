From: Olivier Sobrie <olivier@sobrie.be>
Subject: [PATCH v2 2/2] hso: fix deadlock when receiving bursts of data
Date: Fri, 11 Jul 2014 15:05:35 +0200
Message-ID: <1405083935-31268-1-git-send-email-olivier@sobrie.be>
References: <1404723967-24245-2-git-send-email-olivier@sobrie.be>
Cc: linux-kernel@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>,
	David Miller <davem@davemloft.net>,
	David Laight <David.Laight@ACULAB.COM>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Dan Williams <dcbw@redhat.com>, Jan Dumon <j.dumon@option.com>
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404723967-24245-2-git-send-email-olivier@sobrie.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the module sends bursts of data, sometimes a deadlock happens in
the hso driver when the tty buffer doesn't get the chance to be flushed
quickly enough.

Remove the endless while loop in function put_rxbuf_data() which is
called by the urb completion handler.
If there isn't enough room in the tty buffer, discards all the data
received in the URB.

Cc: David Miller <davem@davemloft.net>
Cc: David Laight <David.Laight@ACULAB.COM>
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Cc: Dan Williams <dcbw@redhat.com>
Cc: Jan Dumon <j.dumon@option.com>
Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
---
Changes in v2:
 - remove the unthrottle timer added in the previous patch version
 - drop entire rx urb data if there is not enough space in tty buffer
 - remove variable curr_rx_urb_offset from hso_serial structure

 drivers/net/usb/hso.c |   38 +++++++++++++++++---------------------
 1 file changed, 17 insertions(+), 21 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 9ca2b41..a4272ed 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -258,7 +258,6 @@ struct hso_serial {
 	 * so as not to drop characters on the floor.
 	 */
 	int  curr_rx_urb_idx;
-	u16  curr_rx_urb_offset;
 	u8   rx_urb_filled[MAX_RX_URBS];
 	struct tasklet_struct unthrottle_tasklet;
 };
@@ -2001,8 +2000,7 @@ static void ctrl_callback(struct urb *urb)
 static int put_rxbuf_data(struct urb *urb, struct hso_serial *serial)
 {
 	struct tty_struct *tty;
-	int write_length_remaining = 0;
-	int curr_write_len;
+	int count;
 
 	/* Sanity check */
 	if (urb == NULL || serial == NULL) {
@@ -2012,29 +2010,28 @@ static int put_rxbuf_data(struct urb *urb, struct hso_serial *serial)
 
 	tty = tty_port_tty_get(&serial->port);
 
+	if (tty && test_bit(TTY_THROTTLED, &tty->flags)) {
+		tty_kref_put(tty);
+		return -1;
+	}
+
 	/* Push data to tty */
-	write_length_remaining = urb->actual_length -
-		serial->curr_rx_urb_offset;
 	D1("data to push to tty");
-	while (write_length_remaining) {
-		if (tty && test_bit(TTY_THROTTLED, &tty->flags)) {
-			tty_kref_put(tty);
-			return -1;
-		}
-		curr_write_len = tty_insert_flip_string(&serial->port,
-			urb->transfer_buffer + serial->curr_rx_urb_offset,
-			write_length_remaining);
-		serial->curr_rx_urb_offset += curr_write_len;
-		write_length_remaining -= curr_write_len;
+	count = tty_buffer_request_room(&serial->port, urb->actual_length);
+	if (count >= urb->actual_length) {
+		tty_insert_flip_string(&serial->port, urb->transfer_buffer,
+				       urb->actual_length);
 		tty_flip_buffer_push(&serial->port);
+	} else {
+		dev_warn(&serial->parent->usb->dev,
+			 "dropping data, %d bytes lost\n", urb->actual_length);
 	}
+
 	tty_kref_put(tty);
 
-	if (write_length_remaining == 0) {
-		serial->curr_rx_urb_offset = 0;
-		serial->rx_urb_filled[hso_urb_to_index(serial, urb)] = 0;
-	}
-	return write_length_remaining;
+	serial->rx_urb_filled[hso_urb_to_index(serial, urb)] = 0;
+
+	return 0;
 }
 
 
@@ -2205,7 +2202,6 @@ static int hso_stop_serial_device(struct hso_device *hso_dev)
 		}
 	}
 	serial->curr_rx_urb_idx = 0;
-	serial->curr_rx_urb_offset = 0;
 
 	if (serial->tx_urb)
 		usb_kill_urb(serial->tx_urb);
-- 
1.7.9.5
