From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: some bluetooth fixes
Date: Sat, 07 Feb 2004 17:57:48 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1076173068.2670.4.camel@pegasus>
References: <20040206050042.20a2b3b0.ak@suse.de>
	 <1076079512.2806.40.camel@pegasus> <20040207032428.56ffbebc.ak@suse.de>
	 <1076152411.14418.73.camel@pegasus>  <20040207125723.391a1fcd.ak@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-khpDIt7H5QVmzre/GLkY"
Cc: bluez-devel@lists.sourceforge.net, netdev@oss.sgi.com,
        viro@zenII.linux.org.uk
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040207125723.391a1fcd.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-khpDIt7H5QVmzre/GLkY
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Andi,

> > I check this. Maybe we have more of them. What do you propose as max
> > size value for kmalloc? 2*PAGE_SIZE or 4*PAGE_SIZE?
> 
> What better fits the intended use case. I don't know how many objects are expected
> here. Smaller is better probably.

I now looked carefully through your patch and changed and added some
parts to better fit into. I also fixed another RFCOMM refcount bug.
Please review it, before I send it to Dave.

> If you want to handle more objects this way you should use seq_file instead.

The general plan is to move over to sysfs.

Regards

Marcel


--=-khpDIt7H5QVmzre/GLkY
Content-Disposition: attachment; filename=patch
Content-Type: text/x-patch; name=patch; charset=iso-8859-15
Content-Transfer-Encoding: 7bit

diff -Nru a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
--- a/net/bluetooth/hci_conn.c	Sat Feb  7 17:52:09 2004
+++ b/net/bluetooth/hci_conn.c	Sat Feb  7 17:52:09 2004
@@ -353,21 +353,24 @@
 	struct hci_conn_info *ci;
 	struct hci_dev *hdev;
 	struct list_head *p;
-	int n = 0, size;
+	int n = 0, size, err;
 
 	if (copy_from_user(&req, (void *) arg, sizeof(req)))
 		return -EFAULT;
 
-	if (!(hdev = hci_dev_get(req.dev_id)))
-		return -ENODEV;
-
-	size = req.conn_num * sizeof(struct hci_conn_info) + sizeof(req);
+	size = sizeof(req) + req.conn_num * sizeof(*ci);
 
-	if (verify_area(VERIFY_WRITE, (void *)arg, size))
-		return -EFAULT;
+	if (size > PAGE_SIZE * 2)
+		return -EINVAL;
 
 	if (!(cl = (void *) kmalloc(size, GFP_KERNEL)))
 		return -ENOMEM;
+
+	if (!(hdev = hci_dev_get(req.dev_id))) {
+		kfree(cl);
+		return -ENODEV;
+	}
+
 	ci = cl->conn_info;
 
 	hci_dev_lock_bh(hdev);
@@ -381,20 +384,21 @@
 		(ci + n)->out   = c->out;
 		(ci + n)->state = c->state;
 		(ci + n)->link_mode = c->link_mode;
-		n++;
+		if (++n >= req.conn_num)
+			break;
 	}
 	hci_dev_unlock_bh(hdev);
 
 	cl->dev_id = hdev->id;
 	cl->conn_num = n;
-	size = n * sizeof(struct hci_conn_info) + sizeof(req);
+	size = sizeof(req) + n * sizeof(*ci);
 
 	hci_dev_put(hdev);
 
-	copy_to_user((void *) arg, cl, size);
+	err = copy_to_user((void *) arg, cl, size);
 	kfree(cl);
 
-	return 0;
+	return err ? -EFAULT : 0;
 }
 
 int hci_get_conn_info(struct hci_dev *hdev, unsigned long arg)
@@ -407,9 +411,6 @@
 	if (copy_from_user(&req, (void *) arg, sizeof(req)))
 		return -EFAULT;
 
-	if (verify_area(VERIFY_WRITE, ptr, sizeof(ci)))
-		return -EFAULT;
-
 	hci_dev_lock_bh(hdev);
 	conn = hci_conn_hash_lookup_ba(hdev, req.type, &req.bdaddr);
 	if (conn) {
@@ -425,6 +426,5 @@
 	if (!conn)
 		return -ENOENT;
 
-	copy_to_user(ptr, &ci, sizeof(ci));
-	return 0;
+	return copy_to_user(ptr, &ci, sizeof(ci)) ? -EFAULT : 0;
 }
diff -Nru a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
--- a/net/bluetooth/hci_core.c	Sat Feb  7 17:52:09 2004
+++ b/net/bluetooth/hci_core.c	Sat Feb  7 17:52:09 2004
@@ -716,7 +716,7 @@
 	struct hci_dev_list_req *dl;
 	struct hci_dev_req *dr;
 	struct list_head *p;
-	int n = 0, size;
+	int n = 0, size, err;
 	__u16 dev_num;
 
 	if (get_user(dev_num, (__u16 *) arg))
@@ -724,14 +724,15 @@
 
 	if (!dev_num)
 		return -EINVAL;
-	
-	size = dev_num * sizeof(*dr) + sizeof(*dl);
 
-	if (verify_area(VERIFY_WRITE, (void *) arg, size))
-		return -EFAULT;
+	size = sizeof(*dl) + dev_num * sizeof(*dr);
+
+	if (size > PAGE_SIZE * 2)
+		return -EINVAL;
 
 	if (!(dl = kmalloc(size, GFP_KERNEL)))
 		return -ENOMEM;
+
 	dr = dl->dev_req;
 
 	read_lock_bh(&hci_dev_list_lock);
@@ -746,12 +747,12 @@
 	read_unlock_bh(&hci_dev_list_lock);
 
 	dl->dev_num = n;
-	size = n * sizeof(*dr) + sizeof(*dl);
+	size = sizeof(*dl) + n * sizeof(*dr);
 
-	copy_to_user((void *) arg, dl, size);
+	err = copy_to_user((void *) arg, dl, size);
 	kfree(dl);
 
-	return 0;
+	return err ? -EFAULT : 0;
 }
 
 int hci_get_dev_info(unsigned long arg)
diff -Nru a/net/bluetooth/rfcomm/tty.c b/net/bluetooth/rfcomm/tty.c
--- a/net/bluetooth/rfcomm/tty.c	Sat Feb  7 17:52:09 2004
+++ b/net/bluetooth/rfcomm/tty.c	Sat Feb  7 17:52:09 2004
@@ -349,7 +349,7 @@
 	struct rfcomm_dev_list_req *dl;
 	struct rfcomm_dev_info *di;
 	struct list_head *p;
-	int n = 0, size;
+	int n = 0, size, err;
 	u16 dev_num;
 
 	BT_DBG("");
@@ -362,8 +362,8 @@
 
 	size = sizeof(*dl) + dev_num * sizeof(*di);
 
-	if (verify_area(VERIFY_WRITE, (void *)arg, size))
-		return -EFAULT;
+	if (size > PAGE_SIZE * 4)
+		return -EINVAL;
 
 	if (!(dl = kmalloc(size, GFP_KERNEL)))
 		return -ENOMEM;
@@ -389,9 +389,10 @@
 	dl->dev_num = n;
 	size = sizeof(*dl) + n * sizeof(*di);
 
-	copy_to_user((void *) arg, dl, size);
+	err = copy_to_user((void *) arg, dl, size);
 	kfree(dl);
-	return 0;
+
+	return err ? -EFAULT : 0;
 }
 
 static int rfcomm_get_dev_info(unsigned long arg)
@@ -563,8 +564,10 @@
 	set_bit(RFCOMM_TTY_ATTACHED, &dev->flags);
 
 	err = rfcomm_dlc_open(dlc, &dev->src, &dev->dst, dev->channel);
-	if (err < 0)
+	if (err < 0) {
+		rfcomm_dev_put(dev);
 		return err;
+	}
 
 	/* Wait for DLC to connect */
 	add_wait_queue(&dev->wait, &wait);
@@ -588,6 +591,9 @@
 	}
 	set_current_state(TASK_RUNNING);
 	remove_wait_queue(&dev->wait, &wait);
+
+	if (err < 0)
+		rfcomm_dev_put(dev);
 
 	return err;
 }

--=-khpDIt7H5QVmzre/GLkY--
