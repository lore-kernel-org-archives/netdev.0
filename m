From: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: tty_register_device NULL pointer dereference in 2.6.31-rc4
Date: Sat, 1 Aug 2009 11:17:05 +0800
Message-ID: <20090801031705.GA2817@darkstar>
References: <20090727095904.GA5442@darkstar> <4A6D8BA3.3030601@hartkopp.net> <4A6D91D7.6030204@hartkopp.net> <20090727140736.GA1864@darkstar> <4A705604.3040807@hartkopp.net> <a8e1da0907300215q3934da47g3676648e3b247af8@mail.gmail.com> <4A717083.5090101@hartkopp.net> <20090731093949.GA4867@darkstar> <a8e1da0907310310h483cedeeg433947d51345246c@mail.gmail.com> <4A72D373.7080802@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A72D373.7080802-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 31, 2009 at 01:20:19PM +0200, Oliver Hartkopp wrote:
> Dave Young wrote:
> > On Fri, Jul 31, 2009 at 5:39 PM, Dave Young<hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> >> On Thu, Jul 30, 2009 at 12:05:55PM +0200, Oliver Hartkopp wrote:
> >>> Dave Young wrote:
> >>>> On Wed, Jul 29, 2009 at 10:00 PM, Oliver Hartkopp<oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org> wrote:
> >>>>> Hi Dave,
> >>>>>
> >>>>> i got it again - even with your patch (that's why it's 2.6.31-rc4-dirty in the
> >>>>> attached screenshot).
> >>>> Weird, the oops occurs between sock init and tty init routines. Could
> >>>> you tell your bluez version and your configuration?
> >>>>
> >>> No problem:
> >> Thanks.
> >>
> >> It's still reasonable, after rfcomm sock layer initialized, userspace do sock ioctl callback but tty layer was not initilized yet at this time.
> >>
> >> Could you confirm it by applying following debug patch on top of my previous patch? if you get more oops with it then above reason will be right.
> >>
> >> --- linux-2.6.orig/net/bluetooth/rfcomm/core.c  2009-07-31 17:14:07.000000000 +0800
> >> +++ linux-2.6/net/bluetooth/rfcomm/core.c       2009-07-31 17:30:39.000000000 +0800
> >> @@ -36,6 +36,7 @@
> >>  #include <linux/net.h>
> >>  #include <linux/mutex.h>
> >>  #include <linux/kthread.h>
> >> +#include <linux/nmi.h>
> >>
> >>  #include <net/sock.h>
> >>  #include <asm/uaccess.h>
> >> @@ -2080,7 +2081,7 @@ static CLASS_ATTR(rfcomm_dlc, S_IRUGO, r
> >>  /* ---- Initialization ---- */
> >>  static int __init rfcomm_init(void)
> >>  {
> >> -       int ret;
> >> +       int ret, i;
> >>
> >>        l2cap_load();
> >>
> >> @@ -2088,6 +2089,12 @@ static int __init rfcomm_init(void)
> >>        if (ret)
> >>                goto out_sock;
> >>
> >> +       /* delay 5 seconds to trigger the tty bug */
> >> +       for (i = 0; i < 50; i++) {
> >> +               touch_nmi_watchdog();
> >> +               mdelay(100);
> > 
> > Hi, for this case, msleep is better, you can just replace the above
> > two lines with msleep(100)
> > 
> 
> Hi Dave,
> 
> applied this patch and replaced mdelay(100) with msleep(100).
> 
> I got two crashes and three proper boots.
> 
> The crashes look like the formerly posted screenshots.
> When it boots properly i can see the delay in the boot process.
> 
> Does this help?

Yes, I think so.

Please unapply the before two patch, try the following v2 patch instead.
Changes from v1: fixes 'goto' path again, make tty init before sock init.

Thanks.
---

rfcomm tty may be used before rfcomm_tty_driver initilized,
The problem is that now socket layer init before tty layer, if userspace
program do socket callback right here then oops will happen.

reporting in:
http://marc.info/?l=linux-bluetooth&m=124404919324542&w=2

make 3 changes:
1. remove #ifdef in rfcomm/core.c,
make it blank function when rfcomm tty not selected in rfcomm.h

2. tune the rfcomm_init error patch to ensure
tty driver initilized before rfcomm socket usage.

3. remove __exit for rfcomm_cleanup_sockets
because above change need call it in a __init function. 


CC: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Reported-by: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Signed-off-by: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
--
include/net/bluetooth/rfcomm.h |   13 ++++++++++++-
net/bluetooth/rfcomm/core.c    |   29 ++++++++++++++++++++---------
net/bluetooth/rfcomm/sock.c    |    2 +-
3 files changed, 33 insertions(+), 11 deletions(-)

--- linux-2.6.orig/include/net/bluetooth/rfcomm.h	2009-08-01 10:53:18.000000000 +0800
+++ linux-2.6/include/net/bluetooth/rfcomm.h	2009-08-01 10:55:29.000000000 +0800
@@ -355,7 +355,18 @@ struct rfcomm_dev_list_req {
 };
 
 int  rfcomm_dev_ioctl(struct sock *sk, unsigned int cmd, void __user *arg);
+
+#ifdef CONFIG_BT_RFCOMM_TTY
 int  rfcomm_init_ttys(void);
 void rfcomm_cleanup_ttys(void);
-
+#else
+static inline int rfcomm_init_ttys(void)
+{
+	return 0;
+}
+static inline int rfcomm_cleanup_ttys(void)
+{
+	return 0;
+}
+#endif
 #endif /* __RFCOMM_H */
--- linux-2.6.orig/net/bluetooth/rfcomm/core.c	2009-08-01 10:53:18.000000000 +0800
+++ linux-2.6/net/bluetooth/rfcomm/core.c	2009-08-01 11:03:24.000000000 +0800
@@ -2080,28 +2080,41 @@ static CLASS_ATTR(rfcomm_dlc, S_IRUGO, r
 /* ---- Initialization ---- */
 static int __init rfcomm_init(void)
 {
+	int ret;
+
 	l2cap_load();
 
 	hci_register_cb(&rfcomm_cb);
 
 	rfcomm_thread = kthread_run(rfcomm_run, NULL, "krfcommd");
 	if (IS_ERR(rfcomm_thread)) {
-		hci_unregister_cb(&rfcomm_cb);
-		return PTR_ERR(rfcomm_thread);
+		ret = PTR_ERR(rfcomm_thread);
+		goto out_thread;
 	}
 
 	if (class_create_file(bt_class, &class_attr_rfcomm_dlc) < 0)
 		BT_ERR("Failed to create RFCOMM info file");
 
-	rfcomm_init_sockets();
-
-#ifdef CONFIG_BT_RFCOMM_TTY
-	rfcomm_init_ttys();
-#endif
+	ret = rfcomm_init_ttys();
+	if (ret)
+		goto out_tty;
+
+	ret = rfcomm_init_sockets();
+	if (ret)
+		goto out_sock;
 
 	BT_INFO("RFCOMM ver %s", VERSION);
 
 	return 0;
+
+out_sock:
+	rfcomm_cleanup_ttys();
+out_tty:
+	kthread_stop(rfcomm_thread);
+out_thread:
+	hci_unregister_cb(&rfcomm_cb);
+
+	return ret;
 }
 
 static void __exit rfcomm_exit(void)
@@ -2112,9 +2125,7 @@ static void __exit rfcomm_exit(void)
 
 	kthread_stop(rfcomm_thread);
 
-#ifdef CONFIG_BT_RFCOMM_TTY
 	rfcomm_cleanup_ttys();
-#endif
 
 	rfcomm_cleanup_sockets();
 }
--- linux-2.6.orig/net/bluetooth/rfcomm/sock.c	2009-08-01 10:53:18.000000000 +0800
+++ linux-2.6/net/bluetooth/rfcomm/sock.c	2009-08-01 10:55:29.000000000 +0800
@@ -1132,7 +1132,7 @@ error:
 	return err;
 }
 
-void __exit rfcomm_cleanup_sockets(void)
+void rfcomm_cleanup_sockets(void)
 {
 	class_remove_file(bt_class, &class_attr_rfcomm);
 
