From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: Possible double-free in the usbnet driver
Date: Mon, 07 Mar 2016 14:11:00 -0500 (EST)
Message-ID: <20160307.141100.1511700720120062677.davem@davemloft.net>
References: <1457193090.8935.7.camel@suse.com>
	<DBDB517D-E4A4-4422-AECE-52194FE2AED0@mork.no>
	<CA+55aFw43uKkUK-h=VMwXcb9NM+g2AdeB960kWb4YihmjQ8DRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bjorn-yOkvZcmFvRU@public.gmane.org, oneukum-IBi9RG/b67k@public.gmane.org, andreyknvl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, kcc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+55aFw43uKkUK-h=VMwXcb9NM+g2AdeB960kWb4YihmjQ8DRw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date: Mon, 7 Mar 2016 10:13:09 -0800

> On Sat, Mar 5, 2016 at 11:53 AM, Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:
>>
>>
>> Definitely.  The patch is so obviously correct that we can only wond=
er how it was possible to miss it it the first place :)
>>
>> Will take a look to see if we could do a better job cleaning up in o=
ther places.
>=20
> What should I do for 4.5? Will there be a pull request for this, or
> should I just commit my cdc_ncm_bind() patch directly?

Yes I plan to send you a pull request today with Oliver's fix.

Assuming this is what you guys are referring to:

commit 1666984c8625b3db19a9abc298931d35ab7bc64b
Author: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Date:   Mon Mar 7 11:31:10 2016 +0100

    usbnet: cleanup after bind() in probe()
   =20
    In case bind() works, but a later error forces bailing
    in probe() in error cases work and a timer may be scheduled.
    They must be killed. This fixes an error case related to
    the double free reported in
    http://www.spinics.net/lists/netdev/msg367669.html
    and needs to go on top of Linus' fix to cdc-ncm.
   =20
    Signed-off-by: Oliver Neukum <ONeukum-IBi9RG/b67k@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 0b0ba7e..1079812 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1769,6 +1769,13 @@ out3:
 	if (info->unbind)
 		info->unbind (dev, udev);
 out1:
+	/* subdrivers must undo all they did in bind() if they
+	 * fail it, but we may fail later and a deferred kevent
+	 * may trigger an error resubmitting itself and, worse,
+	 * schedule a timer. So we kill it all just in case.
+	 */
+	cancel_work_sync(&dev->kevent);
+	del_timer_sync(&dev->delay);
 	free_netdev(net);
 out:
 	return status;
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
