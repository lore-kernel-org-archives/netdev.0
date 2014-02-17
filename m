From: Tommie Gannert <tommie@gannert.se>
Subject: Re: [PATCHv2] irtty-sir.c: Do not set_termios() on irtty_close()
Date: Mon, 17 Feb 2014 20:46:04 +0000
Message-ID: <5302750C.6080407@gannert.se>
References: <52FC87B6.4070001@gannert.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52FC87B6.4070001@gannert.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tommie Gannert <tommie@gannert.se>

Issuing set_termios() from irtty_close() causes kernel Oops for
unplugged usb-serial devices.

Since no other tty_ldisc calls set_termios() on close and no tty driver
seem to check if tty->device_data is NULL or not on entry to set_termios(),
the only solution I can come up with is to remove the irtty_stop_receiver()
call, which only updates termios.

Signed-off-by: Tommie Gannert <tommie@gannert.se>

---
v2: Resend due to mail format issues. More Thunderbird settings applied.

I know very little of this code, and I'm not sure this is a good solution,
so here's some background:

I have a gadget using IrLAP over RS-232, and it's connected to a
USB-RS232 converter. I have udev rules to start/stop irattach on USB
connect/disconnect, but I see an oops if I simply disconnect the device
while irattach is still running:

Crash log:

[  631.791294] BUG: unable to handle kernel NULL pointer dereference at 0000000000000024
[  631.791390] IP: [<ffffffffa0c07e42>] ftdi_set_termios+0x42/0x670 [ftdi_sio]
...
[  631.793963]  [<ffffffffa0b7fba3>] serial_set_termios+0x43/0x90 [usbserial]
[  631.794031]  [<ffffffffa0c013ec>] irtty_close+0x10c/0x190 [irtty_sir]
[  631.794096]  [<ffffffff81356e88>] tty_ldisc_close.isra.1+0x38/0x50
[  631.794157]  [<ffffffff81356eb8>] tty_ldisc_kill+0x18/0x90
[  631.794209]  [<ffffffff81357894>] tty_ldisc_release+0x34/0x90
[  631.794266]  [<ffffffff8134fe00>] tty_release+0x470/0x600

There is a comment in irtty_close() speculating about potential problems
with usb-serial. I'm not sure if that comment belongs to sirdev_put_instance() or
the irtty_stop_receiver() call. I would guess both, so I let it be.

The effect of this is that /dev/ttyUSB* is still in use, and thus leaking
at least dev nodes. This is a minimal patch that solves that oops.
--- linux-3.12/drivers/net/irda/irtty-sir.c.orig	2014-02-12 21:36:46.132496089 +0000
+++ linux-3.12/drivers/net/irda/irtty-sir.c	2014-02-12 21:57:21.635843884 +0000
@@ -521,7 +521,6 @@ static void irtty_close(struct tty_struc
 	sirdev_put_instance(priv->dev);
 
 	/* Stop tty */
-	irtty_stop_receiver(tty, TRUE);
 	clear_bit(TTY_DO_WRITE_WAKEUP, &tty->flags);
 	if (tty->ops->stop)
 		tty->ops->stop(tty);
