From: Dave Young <hidave.darkstar@gmail.com>
Subject: Re: tty_register_device NULL pointer dereference in 2.6.31-rc4
Date: Sat, 1 Aug 2009 17:32:07 +0800
Message-ID: <20090801093207.GA2873@darkstar>
References: <4A6D91D7.6030204@hartkopp.net> <20090727140736.GA1864@darkstar> <4A705604.3040807@hartkopp.net> <a8e1da0907300215q3934da47g3676648e3b247af8@mail.gmail.com> <4A717083.5090101@hartkopp.net> <20090731093949.GA4867@darkstar> <a8e1da0907310310h483cedeeg433947d51345246c@mail.gmail.com> <4A72D373.7080802@hartkopp.net> <20090801031705.GA2817@darkstar> <4A740918.1040504@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-bluetooth@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.224]:28775 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbZHAJcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Aug 2009 05:32:17 -0400
Content-Disposition: inline
In-Reply-To: <4A740918.1040504@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 01, 2009 at 11:21:28AM +0200, Oliver Hartkopp wrote:
> 
> > --- linux-2.6.orig/include/net/bluetooth/rfcomm.h	2009-08-01 10:53:18.000000000 +0800
> > +++ linux-2.6/include/net/bluetooth/rfcomm.h	2009-08-01 10:55:29.000000000 +0800
> > @@ -355,7 +355,18 @@ struct rfcomm_dev_list_req {
> >  };
> >  
> >  int  rfcomm_dev_ioctl(struct sock *sk, unsigned int cmd, void __user *arg);
> > +
> > +#ifdef CONFIG_BT_RFCOMM_TTY
> >  int  rfcomm_init_ttys(void);
> >  void rfcomm_cleanup_ttys(void);
> > -
> > +#else
> > +static inline int rfcomm_init_ttys(void)
> > +{
> > +	return 0;
> > +}
> > +static inline int rfcomm_cleanup_ttys(void)
> > +{
> > +	return 0;
> > +}
> > +#endif
> 
> Just a minor thing:
> 
> Does rfcomm_cleanup_ttys() return 'int' or is it 'void' ?

Yes it should be void. Thanks for pointing out, here update the patch:
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


CC: Alan Cox <alan@lxorguk.ukuu.org.uk>
Reported-by: Oliver Hartkopp <oliver@hartkopp.net>
Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
--
include/net/bluetooth/rfcomm.h |   12 +++++++++++-
net/bluetooth/rfcomm/core.c    |   29 ++++++++++++++++++++---------
net/bluetooth/rfcomm/sock.c    |    2 +-
3 files changed, 32 insertions(+), 11 deletions(-)

--- linux-2.6.orig/include/net/bluetooth/rfcomm.h	2009-08-01 13:56:53.000000000 +0800
+++ linux-2.6/include/net/bluetooth/rfcomm.h	2009-08-01 17:24:59.000000000 +0800
@@ -355,7 +355,17 @@ struct rfcomm_dev_list_req {
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
+static inline void rfcomm_cleanup_ttys(void)
+{
+}
+#endif
 #endif /* __RFCOMM_H */
--- linux-2.6.orig/net/bluetooth/rfcomm/core.c	2009-08-01 13:56:53.000000000 +0800
+++ linux-2.6/net/bluetooth/rfcomm/core.c	2009-08-01 13:57:18.000000000 +0800
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
--- linux-2.6.orig/net/bluetooth/rfcomm/sock.c	2009-08-01 13:56:53.000000000 +0800
+++ linux-2.6/net/bluetooth/rfcomm/sock.c	2009-08-01 13:57:18.000000000 +0800
@@ -1132,7 +1132,7 @@ error:
 	return err;
 }
 
-void __exit rfcomm_cleanup_sockets(void)
+void rfcomm_cleanup_sockets(void)
 {
 	class_remove_file(bt_class, &class_attr_rfcomm);
 
