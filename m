From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tun driver use private linked list.
Date: Fri, 8 Aug 2003 11:34:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030808113404.0e9e1e6d.shemminger@osdl.org>
References: <200308051630.28552.bellucda@tiscali.it>
	<20030805090647.691daa7e.shemminger@osdl.org>
	<200308051910.55823.bellucda@tiscali.it>
	<20030807154524.4794ad45.shemminger@osdl.org>
	<20030807155901.49f1a424.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030807155901.49f1a424.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Less grotty version, applies over earlier patch.
	- keep a private list.  
	- fix debug format strings.
	- drop the name entry in the private data structure since it already
	  has a pointer to netdev that has name.

diff -Nru a/drivers/net/tun.c b/drivers/net/tun.c
--- a/drivers/net/tun.c	Fri Aug  8 11:26:07 2003
+++ b/drivers/net/tun.c	Fri Aug  8 11:26:07 2003
@@ -51,6 +51,8 @@
 
 /* Network device part of the driver */
 
+static LIST_HEAD(tun_dev_list);
+
 /* Net device open. */
 static int tun_net_open(struct net_device *dev)
 {
@@ -70,7 +72,7 @@
 {
 	struct tun_struct *tun = (struct tun_struct *)dev->priv;
 
-	DBG(KERN_INFO "%s: tun_net_xmit %d\n", tun->name, skb->len);
+	DBG(KERN_INFO "%s: tun_net_xmit %d\n", tun->dev->name, skb->len);
 
 	/* Drop packet if interface is not attached */
 	if (!tun->attached)
@@ -120,7 +122,7 @@
 {
 	struct tun_struct *tun = (struct tun_struct *)dev->priv;
    
-	DBG(KERN_INFO "%s: tun_net_init\n", tun->name);
+	DBG(KERN_INFO "%s: tun_net_init\n", tun->dev->name);
 
 	switch (tun->flags & TUN_TYPE_MASK) {
 	case TUN_TUN_DEV:
@@ -161,7 +163,7 @@
 	if (!tun)
 		return -EBADFD;
 
-	DBG(KERN_INFO "%s: tun_chr_poll\n", tun->name);
+	DBG(KERN_INFO "%s: tun_chr_poll\n", tun->dev->name);
 
 	poll_wait(file, &tun->read_wait, wait);
  
@@ -226,7 +228,7 @@
 	if (!tun)
 		return -EBADFD;
 
-	DBG(KERN_INFO "%s: tun_chr_write %d\n", tun->name, count);
+	DBG(KERN_INFO "%s: tun_chr_write %ld\n", tun->dev->name, count);
 
 	for (i = 0, len = 0; i < count; i++) {
 		if (verify_area(VERIFY_READ, iv[i].iov_base, iv[i].iov_len))
@@ -290,7 +292,7 @@
 	if (!tun)
 		return -EBADFD;
 
-	DBG(KERN_INFO "%s: tun_chr_read\n", tun->name);
+	DBG(KERN_INFO "%s: tun_chr_read\n", tun->dev->name);
 
 	for (i = 0, len = 0; i < count; i++) {
 		if (verify_area(VERIFY_WRITE, iv[i].iov_base, iv[i].iov_len))
@@ -350,7 +352,7 @@
 
 	tun->owner = -1;
 	dev->init = tun_net_init;
-	tun->name = dev->name;
+
 	SET_MODULE_OWNER(dev);
 	dev->open = tun_net_open;
 	dev->hard_start_xmit = tun_net_xmit;
@@ -359,27 +361,40 @@
 	dev->destructor = (void (*)(struct net_device *))kfree;
 }
 
+static struct tun_struct *tun_get_by_name(const char *name)
+{
+	struct tun_struct *tun;
+
+	ASSERT_RTNL();
+	list_for_each_entry(tun, &tun_dev_list, list) {
+		if (!strncmp(tun->dev->name, name, IFNAMSIZ))
+		    return tun;
+	}
+
+	return NULL;
+}
+
 static int tun_set_iff(struct file *file, struct ifreq *ifr)
 {
 	struct tun_struct *tun;
-	struct net_device *dev;
 	int err;
 
-	dev = __dev_get_by_name(ifr->ifr_name);
-	if (dev) {
-		/* Device exist */
-		tun = dev->priv;
-
-		if (dev->init != tun_net_init || tun->attached)
+	tun = tun_get_by_name(ifr->ifr_name);
+	if (tun) {
+		if (tun->attached)
 			return -EBUSY;
 
 		/* Check permissions */
-		if (tun->owner != -1)
-			if (current->euid != tun->owner && !capable(CAP_NET_ADMIN))
-				return -EPERM;
-	} else {
+		if (tun->owner != -1 &&
+		    current->euid != tun->owner && !capable(CAP_NET_ADMIN))
+			return -EPERM;
+	} 
+	else if (__dev_get_by_name(ifr->ifr_name)) 
+		return -EINVAL;
+	else {
 		char *name;
 		unsigned long flags = 0;
+		struct net_device *dev;
 
 		err = -EINVAL;
 
@@ -420,9 +435,10 @@
 			goto failed;
 		}
 	
+		list_add(&tun->list, &tun_dev_list);
 	}
 
-	DBG(KERN_INFO "%s: tun_set_iff\n", tun->name);
+	DBG(KERN_INFO "%s: tun_set_iff\n", tun->dev->name);
 
 	if (ifr->ifr_flags & IFF_NO_PI)
 		tun->flags |= TUN_NO_PI;
@@ -433,7 +449,7 @@
 	file->private_data = tun;
 	tun->attached = 1;
 
-	strcpy(ifr->ifr_name, tun->name);
+	strcpy(ifr->ifr_name, tun->dev->name);
 	return 0;
  failed:
 	return err;
@@ -466,7 +482,7 @@
 	if (!tun)
 		return -EBADFD;
 
-	DBG(KERN_INFO "%s: tun_chr_ioctl cmd %d\n", tun->name, cmd);
+	DBG(KERN_INFO "%s: tun_chr_ioctl cmd %d\n", tun->dev->name, cmd);
 
 	switch (cmd) {
 	case TUNSETNOCSUM:
@@ -477,7 +493,7 @@
 			tun->flags &= ~TUN_NOCHECKSUM;
 
 		DBG(KERN_INFO "%s: checksum %s\n",
-		    tun->name, arg ? "disabled" : "enabled");
+		    tun->dev->name, arg ? "disabled" : "enabled");
 		break;
 
 	case TUNSETPERSIST:
@@ -488,14 +504,14 @@
 			tun->flags &= ~TUN_PERSIST;
 
 		DBG(KERN_INFO "%s: persist %s\n",
-		    tun->name, arg ? "disabled" : "enabled");
+		    tun->dev->name, arg ? "disabled" : "enabled");
 		break;
 
 	case TUNSETOWNER:
 		/* Set owner of the device */
 		tun->owner = (uid_t) arg;
 
-		DBG(KERN_INFO "%s: owner set to %d\n", tun->owner);
+		DBG(KERN_INFO "%s: owner set to %d\n", tun->dev->name, tun->owner);
 		break;
 
 #ifdef TUN_DEBUG
@@ -519,7 +535,7 @@
 	if (!tun)
 		return -EBADFD;
 
-	DBG(KERN_INFO "%s: tun_chr_fasync %d\n", tun->name, on);
+	DBG(KERN_INFO "%s: tun_chr_fasync %d\n", tun->dev->name, on);
 
 	if ((ret = fasync_helper(fd, file, on, &tun->fasync)) < 0)
 		return ret; 
@@ -549,7 +565,7 @@
 	if (!tun)
 		return 0;
 
-	DBG(KERN_INFO "%s: tun_chr_close\n", tun->name);
+	DBG(KERN_INFO "%s: tun_chr_close\n", tun->dev->name);
 
 	tun_chr_fasync(-1, file, 0);
 
@@ -562,8 +578,10 @@
 	/* Drop read queue */
 	skb_queue_purge(&tun->readq);
 
-	if (!(tun->flags & TUN_PERSIST)) 
+	if (!(tun->flags & TUN_PERSIST)) {
+		list_del(&tun->list);
 		unregister_netdevice(tun->dev);
+	}
 
 	rtnl_unlock();
 
@@ -605,15 +623,14 @@
 
 void tun_cleanup(void)
 {
-	struct net_device *dev, *nxt;
+	struct tun_struct *tun, *nxt;
 
 	misc_deregister(&tun_miscdev);  
 
 	rtnl_lock();
-	for (dev = dev_base; dev; dev = nxt) {
-		nxt = dev->next;
-		if (dev->init == tun_net_init) 
-			unregister_netdevice(dev);
+	list_for_each_entry_safe(tun, nxt, &tun_dev_list, list) {
+		DBG(KERN_INFO "%s cleaned up\n", tun->dev->name);
+		unregister_netdevice(tun->dev);
 	}
 	rtnl_unlock();
 	
diff -Nru a/include/linux/if_tun.h b/include/linux/if_tun.h
--- a/include/linux/if_tun.h	Fri Aug  8 11:29:09 2003
+++ b/include/linux/if_tun.h	Fri Aug  8 11:29:09 2003
@@ -32,7 +32,7 @@
 #endif
 
 struct tun_struct {
-	char 			*name;
+	struct list_head        list;
 	unsigned long 		flags;
 	int			attached;
 	uid_t			owner;
