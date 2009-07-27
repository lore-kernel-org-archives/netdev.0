From: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: tty_register_device NULL pointer dereference in 2.6.31-rc4
Date: Mon, 27 Jul 2009 17:59:05 +0800
Message-ID: <20090727095904.GA5442@darkstar>
References: <4A6AD807.6060706@hartkopp.net> <20090725115011.7ddf8d00@lxorguk.ukuu.org.uk> <1248520053.28545.156.camel@violet> <20090725131046.0f076f37@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090725131046.0f076f37-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 25, 2009 at 01:10:46PM +0100, Alan Cox wrote:
> > > tty_register_device appears to have been called with a NULL pointer. Not
> > > sure why however.
> > 
> > if that is the pointer for the struct device, then that used to be fine
> > in the past. Not all RFCOMM device have a parent when they are created.
> 
> The tty layer doesn't care about the struct device really. Nothing there
> has changed. The NULL passed appears to be the driver argument.

Agree with you, because in rfcomm_init, rfcomm thread run before tty initilized, the following patch may fix the problem. oliver, could you verify it it fix your problem?
---

rfcomm tty may be used before rfcomm_tty_driver initilized,

reporting in:
http://marc.info/?l=linux-bluetooth&m=124404919324542&w=2

make 3 changes:
1. remove #ifdef in rfcomm/core.c,
make it blank function when rfcomm tty not selected in rfcomm.h

2. tune the rfcomm_init error patch to ensure
tty driver initilized before any usage.

3. remove __exit for rfcomm_cleanup_sockets
because above change need call it in a __init function. 


CC: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Reported-by: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Signed-off-by: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
--
include/net/bluetooth/rfcomm.h |   13 ++++++++++++-
net/bluetooth/rfcomm/core.c    |   31 +++++++++++++++++++++----------
net/bluetooth/rfcomm/sock.c    |    2 +-
3 files changed, 34 insertions(+), 12 deletions(-)

--- linux-2.6.orig/include/net/bluetooth/rfcomm.h	2009-04-09 16:23:03.000000000 +0800
+++ linux-2.6/include/net/bluetooth/rfcomm.h	2009-07-27 17:14:43.000000000 +0800
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
--- linux-2.6.orig/net/bluetooth/rfcomm/core.c	2009-06-16 17:39:32.000000000 +0800
+++ linux-2.6/net/bluetooth/rfcomm/core.c	2009-07-27 17:24:27.000000000 +0800
@@ -2080,28 +2080,41 @@ static CLASS_ATTR(rfcomm_dlc, S_IRUGO, r
 /* ---- Initialization ---- */
 static int __init rfcomm_init(void)
 {
+	int ret;
+
 	l2cap_load();
 
+	ret = rfcomm_init_sockets();
+	if (ret)
+		goto out_sock;
+
+	ret = rfcomm_init_ttys();
+	if (ret)
+		goto out_tty;
+
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
-
 	BT_INFO("RFCOMM ver %s", VERSION);
 
 	return 0;
+
+out_thread:
+	hci_unregister_cb(&rfcomm_cb);
+out_tty:
+	rfcomm_cleanup_ttys();
+out_sock:
+	rfcomm_cleanup_sockets();
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
--- linux-2.6.orig/net/bluetooth/rfcomm/sock.c	2009-04-09 16:23:04.000000000 +0800
+++ linux-2.6/net/bluetooth/rfcomm/sock.c	2009-07-27 17:39:43.000000000 +0800
@@ -1132,7 +1132,7 @@ error:
 	return err;
 }
 
-void __exit rfcomm_cleanup_sockets(void)
+void rfcomm_cleanup_sockets(void)
 {
 	class_remove_file(bt_class, &class_attr_rfcomm);
 
