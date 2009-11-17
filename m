From: akpm@linux-foundation.org
Subject: [patch for 2.6.32? 2/2] hso: fix soft-lockup
Date: Tue, 17 Nov 2009 14:50:32 -0800
Message-ID: <200911172250.nAHMoW1k013162@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	antti.kaijanmaki@nomovok.com, greg@kroah.com,
	randy.dunlap@oracle.com, stable@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50125 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756601AbZKQWvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 17:51:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Antti Kaijanm=E4ki <antti.kaijanmaki@nomovok.com>

=46ix soft-lockup in hso.c which is triggered on SMP machine when
modem is removed while file descriptor(s) under /dev are still open:

  old version called kref_put() too early which resulted in destroying
  hso_serial and hso_device objects which were still used later on.

Signed-off-by: Antti Kaijanm=E4ki <antti.kaijanmaki@nomovok.com>
Cc: Greg KH <greg@kroah.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Randy Dunlap <randy.dunlap@oracle.com>
Cc: <stable@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/usb/hso.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff -puN drivers/net/usb/hso.c~hso-fix-soft-lockup drivers/net/usb/hso=
=2Ec
--- a/drivers/net/usb/hso.c~hso-fix-soft-lockup
+++ a/drivers/net/usb/hso.c
@@ -1363,7 +1363,7 @@ static void hso_serial_close(struct tty_
 	/* reset the rts and dtr */
 	/* do the actual close */
 	serial->open_count--;
-	kref_put(&serial->parent->ref, hso_serial_ref_free);
+
 	if (serial->open_count <=3D 0) {
 		serial->open_count =3D 0;
 		spin_lock_irq(&serial->serial_lock);
@@ -1383,6 +1383,8 @@ static void hso_serial_close(struct tty_
 		usb_autopm_put_interface(serial->parent->interface);
=20
 	mutex_unlock(&serial->parent->mutex);
+
+	kref_put(&serial->parent->ref, hso_serial_ref_free);
 }
=20
 /* close the requested serial port */
_
