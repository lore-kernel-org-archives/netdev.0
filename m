From: Dave Young <hidave.darkstar@gmail.com>
Subject: Re: [PATCH retry] bluetooth : add conn add/del workqueues to avoid
	connection fail
Date: Fri, 1 Feb 2008 09:24:41 +0800
Message-ID: <20080201012441.GA2924@darkstar.te-china.tietoenator.com>
References: <20080130022354.GA3132@darkstar.te-china.tietoenator.com> <20080131130930.GW15220@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marcel@holtmann.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, bluez-devel@lists.sf.net,
	netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:41959 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753713AbYBABSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 20:18:06 -0500
Received: by ug-out-1314.google.com with SMTP id z38so676940ugc.16
        for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 17:18:04 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080131130930.GW15220@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 31, 2008 at 02:09:30PM +0100, Jens Axboe wrote:
> On Wed, Jan 30 2008, Dave Young wrote:
> > 
> > The bluetooth hci_conn sysfs add/del executed in the default workqueue.
> > If the del_conn is executed after the new add_conn with same target,
> > add_conn will failed with warning of "same kobject name".
> > 
> > Here add btaddconn & btdelconn workqueues,
> > flush the btdelconn workqueue in the add_conn function to avoid the issue.
> > 
> > Signed-off-by: Dave Young <hidave.darkstar@gmail.com> 
> > 
> > ---
> > diff -upr a/net/bluetooth/hci_sysfs.c b/net/bluetooth/hci_sysfs.c
> > --- a/net/bluetooth/hci_sysfs.c	2008-01-30 10:14:27.000000000 +0800
> > +++ b/net/bluetooth/hci_sysfs.c	2008-01-30 10:14:14.000000000 +0800
> > @@ -12,6 +12,8 @@
> >  #undef  BT_DBG
> >  #define BT_DBG(D...)
> >  #endif
> > +static struct workqueue_struct *btaddconn;
> > +static struct workqueue_struct *btdelconn;
> >  
> >  static inline char *typetostr(int type)
> >  {
> > @@ -279,6 +281,7 @@ static void add_conn(struct work_struct 
> >  	struct hci_conn *conn = container_of(work, struct hci_conn, work);
> >  	int i;
> >  
> > +	flush_workqueue(btdelconn);
> >  	if (device_add(&conn->dev) < 0) {
> >  		BT_ERR("Failed to register connection device");
> >  		return;
> > @@ -313,6 +316,7 @@ void hci_conn_add_sysfs(struct hci_conn 
> >  
> >  	INIT_WORK(&conn->work, add_conn);
> >  
> > +	queue_work(btaddconn, &conn->work);
> >  	schedule_work(&conn->work);
> >  }
> 
> So you queue &conn->work on both btaddconn and keventd_wq?

My fault. Thanks for pointing out.

new patch as following (some fixes according to marcel's style as well)

---
[PATCH] bluetooth : add conn add/del workqueues to avoid connection fail

The bluetooth hci conn sysfs add/del executed in the default workqueue.
If the conn del function is executed after the new conn add function
with same bluetooth target address, the connection add will failed
and will warn about same kobject name.

Here add btaddconn & btdelconn workqueues,
flush the btdelconn workqueue in the add_conn function to avoid the issue.

Signed-off-by: Dave Young <hidave.darkstar@gmail.com> 

---
net/bluetooth/hci_sysfs.c |   52 ++++++++++++++++++++++++++++++++++++----------
1 file changed, 41 insertions(+), 11 deletions(-)

diff -upr a/net/bluetooth/hci_sysfs.c b/net/bluetooth/hci_sysfs.c
--- a/net/bluetooth/hci_sysfs.c	2008-02-01 09:18:40.000000000 +0800
+++ b/net/bluetooth/hci_sysfs.c	2008-02-01 09:18:40.000000000 +0800
@@ -12,6 +12,8 @@
 #undef  BT_DBG
 #define BT_DBG(D...)
 #endif
+static struct workqueue_struct *btaddconn;
+static struct workqueue_struct *btdelconn;
 
 static inline char *typetostr(int type)
 {
@@ -279,6 +281,8 @@ static void add_conn(struct work_struct 
 	struct hci_conn *conn = container_of(work, struct hci_conn, work);
 	int i;
 
+	flush_workqueue(btdelconn);
+
 	if (device_add(&conn->dev) < 0) {
 		BT_ERR("Failed to register connection device");
 		return;
@@ -313,7 +317,7 @@ void hci_conn_add_sysfs(struct hci_conn 
 
 	INIT_WORK(&conn->work, add_conn);
 
-	schedule_work(&conn->work);
+	queue_work(btaddconn, &conn->work);
 }
 
 static int __match_tty(struct device *dev, void *data)
@@ -349,7 +353,7 @@ void hci_conn_del_sysfs(struct hci_conn 
 
 	INIT_WORK(&conn->work, del_conn);
 
-	schedule_work(&conn->work);
+	queue_work(btdelconn, &conn->work);
 }
 
 int hci_register_sysfs(struct hci_dev *hdev)
@@ -398,28 +402,54 @@ int __init bt_sysfs_init(void)
 {
 	int err;
 
+	btaddconn = create_singlethread_workqueue("btaddconn");
+	if (!btaddconn) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	btdelconn = create_singlethread_workqueue("btdelconn");
+	if (!btdelconn) {
+		err = -ENOMEM;
+		goto out_del;
+	}
+
 	bt_platform = platform_device_register_simple("bluetooth", -1, NULL, 0);
-	if (IS_ERR(bt_platform))
-		return PTR_ERR(bt_platform);
+	if (IS_ERR(bt_platform)) {
+		err = PTR_ERR(bt_platform);
+		goto out_platform;
+	}
 
 	err = bus_register(&bt_bus);
-	if (err < 0) {
-		platform_device_unregister(bt_platform);
-		return err;
-	}
+	if (err < 0)
+		goto out_bus;
 
 	bt_class = class_create(THIS_MODULE, "bluetooth");
 	if (IS_ERR(bt_class)) {
-		bus_unregister(&bt_bus);
-		platform_device_unregister(bt_platform);
-		return PTR_ERR(bt_class);
+		err = PTR_ERR(bt_class);
+		goto out_class;
 	}
 
 	return 0;
+
+out_class:
+	bus_unregister(&bt_bus);
+out_bus:
+	platform_device_unregister(bt_platform);
+out_platform:
+	destroy_workqueue(btdelconn);
+out_del:
+	destroy_workqueue(btaddconn);
+out:
+	return err;
 }
 
 void bt_sysfs_cleanup(void)
 {
+	destroy_workqueue(btaddconn);
+
+	destroy_workqueue(btdelconn);
+
 	class_destroy(bt_class);
 
 	bus_unregister(&bt_bus);
