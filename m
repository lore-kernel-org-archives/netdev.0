From: Antti =?ISO-8859-1?Q?Kaijanm=E4ki?= <antti.kaijanmaki@nomovok.com>
Subject: [PATCH] hso: fix soft-lockup
Date: Tue, 27 Oct 2009 16:26:56 +0200
Message-ID: <1256653616.3591.114.camel@nomovok.homedomain>
References: <1256200578.3057.113.camel@nomovok.homedomain>
	 <20091026171550.GA24910@kroah.com>
	 <1256585855.3591.52.camel@nomovok.homedomain>
	 <20091026194058.GA25263@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	stable@kernel.org, Jan Dumon <j.dumon@option.com>
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755342AbZJ0ObK@vger.kernel.org>
In-Reply-To: <20091026194058.GA25263@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-10-26 at 12:40 -0700, Greg KH wrote:
> Yes, that should be a new patch, especially as it would not be needed
> to fix older kernels for the original bug.
>=20
> So, care to send 2 patches?  The debug one isn't needed to be sent to
> the stable@kernel.org address.


=46ix soft-lockup in hso.c which is triggered on SMP machine when
modem is removed while file descriptor(s) under /dev are still open:

  old version called kref_put() too early which resulted in destroying
  hso_serial and hso_device objects which were still used later on.

Signed-off-by: Antti Kaijanm=C3=A4ki <antti.kaijanmaki@nomovok.com>
---
 drivers/net/usb/hso.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 746839b..43bc3fc 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -1363,7 +1363,7 @@ static void hso_serial_close(struct tty_struct *t=
ty, struct file *filp)
 	/* reset the rts and dtr */
 	/* do the actual close */
 	serial->open_count--;
-	kref_put(&serial->parent->ref, hso_serial_ref_free);
+
 	if (serial->open_count <=3D 0) {
 		serial->open_count =3D 0;
 		spin_lock_irq(&serial->serial_lock);
@@ -1383,6 +1383,8 @@ static void hso_serial_close(struct tty_struct *t=
ty, struct file *filp)
 		usb_autopm_put_interface(serial->parent->interface);
=20
 	mutex_unlock(&serial->parent->mutex);
+
+	kref_put(&serial->parent->ref, hso_serial_ref_free);
 }
=20
 /* close the requested serial port */
--=20
1.6.3.3
