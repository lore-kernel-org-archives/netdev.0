From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: Re: [RFC] updated Patch to option HSO driver to the kernel
Date: Mon, 28 Apr 2008 13:53:17 +0300
Message-ID: <4815AC9D.7080009@teltonika.lt>
References: <20080417214719.GF17664@kroah.com> <480BE815.2000409@teltonika.lt> <480CB8C2.9090902@teltonika.lt> <480DA2CA.8090705@teltonika.lt> <480DED38.3080900@teltonika.lt> <480F3C41.10908@teltonika.lt> <4811CF33.8040007@teltonika.lt> <4811DA4F.30209@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010904000301080401020101"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4811DA4F.30209-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010904000301080401020101
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Incremental patch.
- fix bug with freeing locked mutex:

 > =========================
 > [ BUG: held lock freed! ]
 > -------------------------
 > modprobe/3829 is freeing memory ffff81002acb5948-ffff81002acb5a07, with
 > a lock still held there!
 >  (&mux->shared_int_lock){--..}, at: [<ffffffff88303234>]
 > hso_serial_ref_free+0x7a/0xce [hso]
 > 1 lock held by modprobe/3829:
 >  #0:  (&mux->shared_int_lock){--..}, at: [<ffffffff88303234>]
 > hso_serial_ref_free+0x7a/0xce [hso]

--------------010904000301080401020101
Content-Type: text/x-patch;
 name="hso_shared_int_free.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_shared_int_free.patch"

--- linux-2.6-hso-my/drivers/net/usb/hso.c.orig	2008-04-25 16:13:41.000000000 +0300
+++ linux-2.6-hso-my/drivers/net/usb/hso.c	2008-04-28 12:34:23.000000000 +0300
@@ -2210,7 +2210,8 @@ static void hso_free_serial_device(struc
 		mutex_lock(&serial->shared_int->shared_int_lock);
 		if (--serial->shared_int->ref_count == 0)
 			hso_free_shared_int(serial->shared_int);
-		mutex_unlock(&serial->shared_int->shared_int_lock);
+		else
+			mutex_unlock(&serial->shared_int->shared_int_lock);
 	}
 	kfree(serial);
 	hso_free_device(hso_dev);
@@ -2360,6 +2361,7 @@ static void hso_free_shared_int(struct h
 {
 	usb_free_urb(mux->shared_intr_urb);
 	kfree(mux->shared_intr_buf);
+	mutex_unlock(&mux->shared_int_lock);
 	kfree(mux);
 }
 

--------------010904000301080401020101--

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
