From: Andi Kleen <ak@suse.de>
Subject: some bluetooth fixes
Date: Fri, 6 Feb 2004 05:00:42 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040206050042.20a2b3b0.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: marcel@holtmann.org, bluez-devel@lists.sourceforge.net, netdev@oss.sgi.com,
        viro@zenII.linux.org.uk
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


While reading bluetooth code I noticed some bugs and potential overflows.

Also I commented one ref-counting bug.

Patch against 2.6.2.

-Andi

diff -u linux-2.6.2-work32/net/bluetooth/rfcomm/tty.c-o linux-2.6.2-work32/net/bluetooth/rfcomm/tty.c
--- linux-2.6.2-work32/net/bluetooth/rfcomm/tty.c-o	2003-09-28 10:53:25.000000000 +0200
+++ linux-2.6.2-work32/net/bluetooth/rfcomm/tty.c	2004-02-06 04:58:28.000000000 +0100
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
+	if (size > (4*PAGE_SIZE)/sizeof(*di))
+		return -EINVAL;
 
 	if (!(dl = kmalloc(size, GFP_KERNEL)))
 		return -ENOMEM;
@@ -389,9 +389,9 @@
 	dl->dev_num = n;
 	size = sizeof(*dl) + n * sizeof(*di);
 
-	copy_to_user((void *) arg, dl, size);
+	err = copy_to_user((void *) arg, dl, size) ? -EFAULT : 0;
 	kfree(dl);
-	return 0;
+	return err;
 }
 
 static int rfcomm_get_dev_info(unsigned long arg)
@@ -549,8 +549,10 @@
 
 	BT_DBG("dev %p dst %s channel %d opened %d", dev, batostr(&dev->dst), dev->channel, dev->opened);
 
-	if (dev->opened++ != 0)
+	if (dev->opened++ != 0) {
+		rfcomm_dev_put(dev);
 		return 0;
+	}
 
 	dlc = dev->dlc;
 
@@ -563,8 +565,10 @@
 	set_bit(RFCOMM_TTY_ATTACHED, &dev->flags);
 
 	err = rfcomm_dlc_open(dlc, &dev->src, &dev->dst, dev->channel);
-	if (err < 0)
+	if (err < 0) { 
+		rfcomm_dev_put(dev);
 		return err;
+	}
 
 	/* Wait for DLC to connect */
 	add_wait_queue(&dev->wait, &wait);
diff -u linux-2.6.2-work32/net/bluetooth/cmtp/sock.c-o linux-2.6.2-work32/net/bluetooth/cmtp/sock.c
--- linux-2.6.2-work32/net/bluetooth/cmtp/sock.c-o	2004-02-05 08:09:54.000000000 +0100
+++ linux-2.6.2-work32/net/bluetooth/cmtp/sock.c	2004-02-05 14:57:57.000000000 +0100
@@ -87,8 +87,10 @@
 		if (!nsock)
 			return err;
 
-		if (nsock->sk->sk_state != BT_CONNECTED)
+		if (nsock->sk->sk_state != BT_CONNECTED) { 
+			fput(nsock->file);
 			return -EBADFD;
+		}
 
 		err = cmtp_add_connection(&ca, nsock);
 		if (!err) {
diff -u linux-2.6.2-work32/net/bluetooth/hci_sock.c-o linux-2.6.2-work32/net/bluetooth/hci_sock.c
--- linux-2.6.2-work32/net/bluetooth/hci_sock.c-o	2004-02-05 08:09:54.000000000 +0100
+++ linux-2.6.2-work32/net/bluetooth/hci_sock.c	2004-02-05 14:57:59.000000000 +0100
@@ -392,6 +392,8 @@
 
 	skb->pkt_type = *((unsigned char *) skb->data);
 	skb_pull(skb, 1);
+	/* AK: looks broken. Who guarantees that hdev doesn't go away while
+	   the skb is queued ? */
 	skb->dev = (void *) hdev;
 
 	if (skb->pkt_type == HCI_COMMAND_PKT) {
diff -u linux-2.6.2-work32/net/bluetooth/hci_conn.c-o linux-2.6.2-work32/net/bluetooth/hci_conn.c
--- linux-2.6.2-work32/net/bluetooth/hci_conn.c-o	2004-02-05 08:09:54.000000000 +0100
+++ linux-2.6.2-work32/net/bluetooth/hci_conn.c	2004-02-05 15:06:10.000000000 +0100
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
+	if (req.conn_num >= (2*PAGE_SIZE)/sizeof(struct hci_conn_info))
+		return -EINVAL; 
 
 	size = req.conn_num * sizeof(struct hci_conn_info) + sizeof(req);
 
-	if (verify_area(VERIFY_WRITE, (void *)arg, size))
-		return -EFAULT;
-
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
@@ -375,6 +378,9 @@
 		register struct hci_conn *c;
 		c = list_entry(p, struct hci_conn, list);
 
+		if (n >= req.conn_num) 
+			break;
+
 		bacpy(&(ci + n)->bdaddr, &c->dst);
 		(ci + n)->handle = c->handle;
 		(ci + n)->type  = c->type;
@@ -391,10 +397,10 @@
 
 	hci_dev_put(hdev);
 
-	copy_to_user((void *) arg, cl, size);
+	err = copy_to_user((void *) arg, cl, size) ? -EFAULT : 0; 
 	kfree(cl);
 
-	return 0;
+	return err;
 }
 
 int hci_get_conn_info(struct hci_dev *hdev, unsigned long arg)
@@ -407,9 +413,6 @@
 	if (copy_from_user(&req, (void *) arg, sizeof(req)))
 		return -EFAULT;
 
-	if (verify_area(VERIFY_WRITE, ptr, sizeof(ci)))
-		return -EFAULT;
-
 	hci_dev_lock_bh(hdev);
 	conn = hci_conn_hash_lookup_ba(hdev, req.type, &req.bdaddr);
 	if (conn) {
@@ -425,6 +428,5 @@
 	if (!conn)
 		return -ENOENT;
 
-	copy_to_user(ptr, &ci, sizeof(ci));
-	return 0;
+	return copy_to_user(ptr, &ci, sizeof(ci)) ? -EFAULT : 0;
 }
diff -u linux-2.6.2-work32/net/bluetooth/hci_core.c-o linux-2.6.2-work32/net/bluetooth/hci_core.c
--- linux-2.6.2-work32/net/bluetooth/hci_core.c-o	2004-02-05 08:09:54.000000000 +0100
+++ linux-2.6.2-work32/net/bluetooth/hci_core.c	2004-02-05 15:01:46.000000000 +0100
@@ -715,18 +715,16 @@
 	struct list_head *p;
 	int n = 0, size;
 	__u16 dev_num;
-
+	int err;
+	
 	if (get_user(dev_num, (__u16 *) arg))
 		return -EFAULT;
 
-	if (!dev_num)
+	if (!dev_num || dev_num >= (4*PAGE_SIZE)/sizeof(*dr))
 		return -EINVAL;
 	
 	size = dev_num * sizeof(*dr) + sizeof(*dl);
 
-	if (verify_area(VERIFY_WRITE, (void *) arg, size))
-		return -EFAULT;
-
 	if (!(dl = kmalloc(size, GFP_KERNEL)))
 		return -ENOMEM;
 	dr = dl->dev_req;
@@ -745,10 +743,10 @@
 	dl->dev_num = n;
 	size = n * sizeof(*dr) + sizeof(*dl);
 
-	copy_to_user((void *) arg, dl, size);
+	err = copy_to_user((void *) arg, dl, size);
 	kfree(dl);
 
-	return 0;
+	return err ? -EFAULT : 0;
 }
 
 int hci_get_dev_info(unsigned long arg)
