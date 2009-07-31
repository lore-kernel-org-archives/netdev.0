From: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: tty_register_device NULL pointer dereference in 2.6.31-rc4
Date: Fri, 31 Jul 2009 17:39:50 +0800
Message-ID: <20090731093949.GA4867@darkstar>
References: <20090725115011.7ddf8d00@lxorguk.ukuu.org.uk> <1248520053.28545.156.camel@violet> <20090725131046.0f076f37@lxorguk.ukuu.org.uk> <20090727095904.GA5442@darkstar> <4A6D8BA3.3030601@hartkopp.net> <4A6D91D7.6030204@hartkopp.net> <20090727140736.GA1864@darkstar> <4A705604.3040807@hartkopp.net> <a8e1da0907300215q3934da47g3676648e3b247af8@mail.gmail.com> <4A717083.5090101@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A717083.5090101-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 30, 2009 at 12:05:55PM +0200, Oliver Hartkopp wrote:
> Dave Young wrote:
> > On Wed, Jul 29, 2009 at 10:00 PM, Oliver Hartkopp<oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org> wrote:
> >> Hi Dave,
> >>
> >> i got it again - even with your patch (that's why it's 2.6.31-rc4-dirty in the
> >> attached screenshot).
> > 
> > Weird, the oops occurs between sock init and tty init routines. Could
> > you tell your bluez version and your configuration?
> > 
> 
> No problem:

Thanks.

It's still reasonable, after rfcomm sock layer initialized, userspace do sock ioctl callback but tty layer was not initilized yet at this time.

Could you confirm it by applying following debug patch on top of my previous patch? if you get more oops with it then above reason will be right.

--- linux-2.6.orig/net/bluetooth/rfcomm/core.c	2009-07-31 17:14:07.000000000 +0800
+++ linux-2.6/net/bluetooth/rfcomm/core.c	2009-07-31 17:30:39.000000000 +0800
@@ -36,6 +36,7 @@
 #include <linux/net.h>
 #include <linux/mutex.h>
 #include <linux/kthread.h>
+#include <linux/nmi.h>
 
 #include <net/sock.h>
 #include <asm/uaccess.h>
@@ -2080,7 +2081,7 @@ static CLASS_ATTR(rfcomm_dlc, S_IRUGO, r
 /* ---- Initialization ---- */
 static int __init rfcomm_init(void)
 {
-	int ret;
+	int ret, i;
 
 	l2cap_load();
 
@@ -2088,6 +2089,12 @@ static int __init rfcomm_init(void)
 	if (ret)
 		goto out_sock;
 
+	/* delay 5 seconds to trigger the tty bug */
+	for (i = 0; i < 50; i++) {
+		touch_nmi_watchdog();
+		mdelay(100);
+	}
+
 	ret = rfcomm_init_ttys();
 	if (ret)
 		goto out_tty;
