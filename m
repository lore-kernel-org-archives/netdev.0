From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Kernel connector - userspace <-> kernelspace "linker".
Date: Fri, 17 Sep 2004 11:13:25 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040917071325.GA6502@uganda.factory.vocord.ru>
References: <20040916200304.4fad9b6d@zanzibar.2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@oss.sgi.com, Evgeniy Polyakov <s0mbre@tservice.net.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <20040916200304.4fad9b6d@zanzibar.2ka.mipt.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Sep 16, 2004 at 08:03:04PM +0400, Evgeniy Polyakov wrote:
> Sorry for thread destruction, but I have not received you mail, 
> but see it in archive. I do beleive it is due to permanent glitch of 
> 2ka.mipt.ru SMTP server.
> 
> > I dont have time to evaluate the code right now - but will at the end of
> > day. Just trying to understand your concepts:
> >
> > Essentially you are building a unified messaging for
> > userspace-userpace(i.e IPC), userspace-kernel, kernel-kernel with each
> > component residing in whatever spot (kernel or userland)having a unique
> > name and Id. Is this correct?
> 
> Actually name and ID should be transformed to ID0 and ID1(they are callled
> idx and val and are u32 values, since I strongly object against any ASCII 
> based identificators( sigh, I am cunning - superio has such ids)).
> Since userspace can not register callback function, then it is not quite 
> fair to call it generic, but the idea is right.
> 
> > Clearly there could be name/Id conflicts etc. Are you addressing those? 
> 
> Hmm, u32+u32 - I do not beleive that it can conflict, but if they do, then
> first registered with given idx+val will pay the pipper and call the tune.
> Second call with the same parameters for register_callback() fill fail.
> 
> > Any event and filtering capability already in or planned? Example event
> > I want to be notified when module with name "sean paul" comes online and
> > filter will be "it has to have ID in the range of 0x200-0x400".
> 
> Such information does exist in connector driver and it _can_ be easily 
> obtained. I will call it feature request that fits the design 
> and will implement this today/tomorrow. :)
> 
> > I am still trying to wakeup but it does sound like a good idea to have a
> > generic messaging subsystem.
> 
> Good afternoon :).

kind of dmesg:

Notify group 1 for idx: 291-300
Notify group 1 for val: 1110-1119 1130-1139
Request was sent. Group=0x1.
+ + <6>Notifying group 1 with event 0 about 123.456.
+ + <6>Notifying group 1 with event 0 about 123.457.
+ + <6>Notifying group 1 with event 1 about 123.457.
+ + <6>Notifying group 1 with event 1 about 123.456.

0 - device added
1 - removed


Kind of patch...

* looking for johnpol@2ka.mipt.ru-2004/connector--main--0--patch-10 to compare with
* comparing to johnpol@2ka.mipt.ru-2004/connector--main--0--patch-10
M  cn_test.c
M  connector.c
M  connector.h
M  ucon.c

* modified files

--- orig/cn_test.c
+++ mod/cn_test.c
@@ -22,11 +22,13 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
+#include <linux/skbuff.h>
 
 #include "connector.h"
 
 static struct cb_id cn_test_id = { 0x123, 0x456 };
 static char cn_test_name[] = "cn_test";
+static struct sock *nls;
 
 void cn_test_callback(void *data)
 {
@@ -36,21 +38,112 @@
 	       __func__, msg->id.idx, msg->id.val, msg->len);
 }
 
+static int cn_test_want_notify(void)
+{
+	struct cn_ctl_msg *ctl;
+	struct cn_notify_req *req;
+	struct cn_msg *msg = NULL;
+	int size, size0;
+	struct sk_buff *skb;
+	struct nlmsghdr *nlh;
+	u32 group = 1;
+
+	size0 = sizeof(*msg) + sizeof(*ctl) + 3*sizeof(*req);
+	
+	size = NLMSG_SPACE(size0);
+
+	skb = alloc_skb(size, GFP_ATOMIC);
+	if (!skb) {
+		printk(KERN_ERR "Failed to allocate new skb with size=%u.\n", size);
+
+		return -ENOMEM;
+	}
+
+	nlh = NLMSG_PUT(skb, 0, 0x123, NLMSG_DONE, size - sizeof(*nlh));
+
+	msg = (struct cn_msg *)NLMSG_DATA(nlh);
+
+	memset(msg, 0, size0);
+
+	msg->id.idx 	= -1;
+	msg->id.val 	= -1;
+	msg->seq 	= 0x123;
+	msg->ack 	= 0x345;
+	msg->len 	= size0 - sizeof(*msg);
+
+	ctl = (struct cn_ctl_msg *)(msg + 1);
+
+	ctl->idx_notify_num 	= 1;
+	ctl->val_notify_num 	= 2;
+	ctl->group		= group;
+
+	req = (struct cn_notify_req *)(ctl + 1);
+
+	/*
+	 * Idx.
+	 */
+	req->first = cn_test_id.idx;
+	req->range = 10;
+
+	/*
+	 * Val 0.
+	 */
+	req++;
+	req->first = cn_test_id.val;
+	req->range = 10;
+	
+	/*
+	 * Val 1.
+	 */
+	req++;
+	req->first = cn_test_id.val + 20;
+	req->range = 10;
+	
+	NETLINK_CB(skb).dst_groups = ctl->group;
+	//netlink_broadcast(nls, skb, 0, ctl->group, GFP_ATOMIC);
+	netlink_unicast(nls, skb, 0, 0);
+
+	printk(KERN_INFO "Request was sent. Group=0x%x.\n", group);
+		
+	return 0;
+
+nlmsg_failure:
+	printk(KERN_ERR "Failed to send %u.%u\n", msg->seq, msg->ack);
+	kfree_skb(skb);
+	return -EINVAL;
+}
+
 static int cn_test_init(void)
 {
 	int err;
+	
+	nls = netlink_kernel_create(NETLINK_NFLOG, NULL);
+	if (!nls) {
+		printk(KERN_ERR "Failed to create new netlink socket(%u).\n", NETLINK_NFLOG);
+		return -EIO;
+	}
+
+	err = cn_test_want_notify();
+	if (err)
+		goto err_out;
 
 	err = cn_add_callback(&cn_test_id, cn_test_name, cn_test_callback);
 	if (err)
-		return err;
+		goto err_out;
 	cn_test_id.val++;
 	err = cn_add_callback(&cn_test_id, cn_test_name, cn_test_callback);
 	if (err) {
 		cn_del_callback(&cn_test_id);
-		return err;
+		goto err_out;
 	}
 
 	return 0;
+
+err_out:
+	if (nls->sk_socket)
+		sock_release(nls->sk_socket);
+
+	return err;
 }
 
 static void cn_test_fini(void)
@@ -58,6 +151,8 @@
 	cn_del_callback(&cn_test_id);
 	cn_test_id.val--;
 	cn_del_callback(&cn_test_id);
+	if (nls->sk_socket)
+		sock_release(nls->sk_socket);
 }
 
 module_init(cn_test_init);


--- orig/connector.c
+++ mod/connector.c
@@ -36,9 +36,17 @@
 MODULE_DESCRIPTION("Generic userspace <-> kernelspace connector.");
 
 static int unit = NETLINK_NFLOG;
+static u32 cn_idx = -1;
+static u32 cn_val = -1;
+
 module_param(unit, int, 0);
+module_param(cn_idx, uint, 0);
+module_param(cn_val, uint, 0);
+
+spinlock_t notify_lock = SPIN_LOCK_UNLOCKED;
+static LIST_HEAD(notify_list);
 
-struct cn_dev cdev;
+static struct cn_dev cdev;
 
 /*
  * msg->seq and msg->ack are used to determine message genealogy.
@@ -59,7 +67,7 @@
  * then it is new message.
  *
  */
-void cn_netlink_send(struct cn_msg *msg)
+void cn_netlink_send(struct cn_msg *msg, u32 __groups)
 {
 	struct cn_callback_entry *n, *__cbq;
 	unsigned int size;
@@ -70,20 +78,25 @@
 	u32 groups = 0;
 	int found = 0;
 
-	spin_lock(&dev->cbdev->queue_lock);
-	list_for_each_entry_safe(__cbq, n, &dev->cbdev->queue_list, callback_entry) {
-		if (cn_cb_equal(&__cbq->cb->id, &msg->id)) {
-			found = 1;
-			groups = __cbq->group;
+	if (!__groups)
+	{
+		spin_lock(&dev->cbdev->queue_lock);
+		list_for_each_entry_safe(__cbq, n, &dev->cbdev->queue_list, callback_entry) {
+			if (cn_cb_equal(&__cbq->cb->id, &msg->id)) {
+				found = 1;
+				groups = __cbq->group;
+			}
 		}
-	}
-	spin_unlock(&dev->cbdev->queue_lock);
+		spin_unlock(&dev->cbdev->queue_lock);
 
-	if (!found) {
-		printk(KERN_ERR "Failed to find multicast netlink group for callback[0x%x.0x%x]. seq=%u\n",
-		       msg->id.idx, msg->id.val, msg->seq);
-		return;
+		if (!found) {
+			printk(KERN_ERR "Failed to find multicast netlink group for callback[0x%x.0x%x]. seq=%u\n",
+			       msg->id.idx, msg->id.val, msg->seq);
+			return;
+		}
 	}
+	else
+		groups = __groups;
 
 	size = NLMSG_SPACE(sizeof(*msg) + msg->len);
 
@@ -147,6 +160,15 @@
 	seq = nlh->nlmsg_seq;
 	group = NETLINK_CB((skb)).groups;
 	msg = (struct cn_msg *)NLMSG_DATA(nlh);
+
+	if (msg->len != nlh->nlmsg_len - sizeof(*msg) - sizeof(*nlh))
+	{
+		printk(KERN_ERR "skb does not have enough length: requested msg->len=%u[%u], nlh->nlmsg_len=%u[%u], skb->len=%u[must be %u].\n", 
+				msg->len, NLMSG_SPACE(msg->len), 
+				nlh->nlmsg_len, nlh->nlmsg_len - sizeof(*nlh),
+				skb->len, msg->len + sizeof(*msg));
+		return -EINVAL;
+	}
 #if 0
 	printk(KERN_INFO "pid=%u, uid=%u, seq=%u, group=%u.\n",
 	       pid, uid, seq, group);
@@ -188,7 +210,7 @@
 
 		err = __cn_rx_skb(skb, nlh);
 		if (err) {
-			if (err < 0)
+			if (err < 0 && (nlh->nlmsg_flags & NLM_F_ACK))
 				netlink_ack(skb, nlh, -err);
 			kfree_skb(skb);
 			break;
@@ -210,6 +232,59 @@
 		cn_rx_skb(skb);
 }
 
+static void cn_notify(struct cb_id *id, u32 notify_event)
+{
+	struct cn_ctl_entry *ent;
+
+	spin_lock(&notify_lock);
+	list_for_each_entry(ent, &notify_list, notify_entry)
+	{
+		int i;
+		struct cn_notify_req *req;
+		struct cn_ctl_msg *ctl = ent->msg;
+		int a, b;
+
+		a = b = 0;
+		
+		req = (struct cn_notify_req *)ctl->data;
+		for (i=0; i<ctl->idx_notify_num; ++i, ++req)
+		{
+			if (id->idx >= req->first && id->idx < req->first + req->range)
+			{
+				printk("+ ");
+				a = 1;
+				break;
+			}
+		}
+		
+		for (i=0; i<ctl->val_notify_num; ++i, ++req)
+		{
+			if (id->val >= req->first && id->val < req->first + req->range)
+			{
+				printk("+ ");
+				b = 1;
+				break;
+			}
+		}
+
+		if (a && b)
+		{
+			struct cn_msg m;
+			
+			printk(KERN_INFO "Notifying group %x with event %u about %x.%x.\n", 
+					ctl->group, notify_event, 
+					id->idx, id->val);
+
+			memset(&m, 0, sizeof(m));
+			m.ack = notify_event;
+
+			memcpy(&m.id, id, sizeof(m.id));
+			cn_netlink_send(&m, ctl->group);
+		}
+	}
+	spin_unlock(&notify_lock);
+}
+
 int cn_add_callback(struct cb_id *id, char *name, void (*callback) (void *))
 {
 	int err;
@@ -237,6 +312,8 @@
 		kfree(cb);
 		return err;
 	}
+			
+	cn_notify(id, 0);
 
 	return 0;
 }
@@ -249,16 +326,85 @@
 	list_for_each_entry_safe(__cbq, n, &dev->cbdev->queue_list, callback_entry) {
 		if (cn_cb_equal(&__cbq->cb->id, id)) {
 			cn_queue_del_callback(dev->cbdev, __cbq->cb);
+			cn_notify(id, 1);
 			break;
 		}
 	}
 }
 
+static void cn_callback(void * data)
+{
+	struct cn_msg *msg = (struct cn_msg *)data;
+	struct cn_ctl_msg *ctl;
+	struct cn_ctl_entry *ent;
+	u32 size;
+ 
+	if (msg->len < sizeof(*ctl))
+	{
+		printk(KERN_ERR "Wrong connector request size %u, must be >= %u.\n", 
+				msg->len, sizeof(*ctl));
+		return;
+	}
+	
+	ctl = (struct cn_ctl_msg *)msg->data;
+
+	size = sizeof(*ctl) + (ctl->idx_notify_num + ctl->val_notify_num)*sizeof(struct cn_notify_req);
+
+	if (msg->len != size)
+	{
+		printk(KERN_ERR "Wrong connector request size %u, must be == %u.\n", 
+				msg->len, size);
+		return;
+	}
+
+	size += sizeof(*ent);
+
+	ent = kmalloc(size, GFP_ATOMIC);
+	if (!ent)
+	{
+		printk(KERN_ERR "Failed to allocate %d bytes for new notify entry.\n", size);
+		return;
+	}
+
+	memset(ent, 0, size);
+
+	ent->msg = (struct cn_ctl_msg *)(ent + 1);
+
+	memcpy(ent->msg, ctl, size - sizeof(*ent));
+
+	spin_lock(&notify_lock);
+	list_add(&ent->notify_entry, &notify_list);
+	spin_unlock(&notify_lock);
+
+	{
+		int i;
+		struct cn_notify_req *req;
+	
+		printk("Notify group %x for idx: ", ctl->group);
+
+		req = (struct cn_notify_req *)ctl->data;
+		for (i=0; i<ctl->idx_notify_num; ++i, ++req)
+		{
+			printk("%u-%u ", req->first, req->first+req->range-1);
+		}
+		
+		printk("\nNotify group %x for val: ", ctl->group);
+
+		for (i=0; i<ctl->val_notify_num; ++i, ++req)
+		{
+			printk("%u-%u ", req->first, req->first+req->range-1);
+		}
+		printk("\n");
+	}
+}
+
 static int cn_init(void)
 {
 	struct cn_dev *dev = &cdev;
 
 	dev->input = cn_input;
+	dev->id.idx = cn_idx;
+	dev->id.val = cn_val;
 
 	dev->nls = netlink_kernel_create(unit, dev->input);
 	if (!dev->nls) {
@@ -274,13 +420,14 @@
 		return -EINVAL;
 	}
 
-	return 0;
+	return cn_add_callback(&dev->id, "connector", &cn_callback);
 }
 
 static void cn_fini(void)
 {
 	struct cn_dev *dev = &cdev;
 
+	cn_del_callback(&dev->id);
 	cn_queue_free_dev(dev->cbdev);
 	if (dev->nls->sk_socket)
 		sock_release(dev->nls->sk_socket);


--- orig/connector.h
+++ mod/connector.h
@@ -37,12 +37,34 @@
 	__u8			data[0];
 };
 
+struct cn_notify_req
+{
+	__u32			first;
+	__u32			range;
+};
+
+struct cn_ctl_msg
+{
+	__u32			idx_notify_num;
+	__u32			val_notify_num;
+	__u32			group;
+	__u8			data[0];
+};
+
 #ifdef __KERNEL__
 
 #include <net/sock.h>
 
+struct cn_ctl_entry
+{
+	struct list_head	notify_entry;
+	struct cn_ctl_msg	*msg;
+};
+
 struct cn_dev
 {
+	struct cb_id 		id;
+
 	u32			seq, groups;
 	struct sock 		*nls;
 	void 			(*input)(struct sock *sk, int len);
@@ -52,7 +74,7 @@
 
 int cn_add_callback(struct cb_id *, char *, void (* callback)(void *));
 void cn_del_callback(struct cb_id *);
-void cn_netlink_send(struct cn_msg *);
+void cn_netlink_send(struct cn_msg *, u32);
 
 #endif /* __KERNEL__ */
 #endif /* __CONNECTOR_H */


--- orig/ucon.c
+++ mod/ucon.c
@@ -118,8 +118,7 @@
 	l_local.nl_groups = 1;
 	l_local.nl_pid = getpid();
 
-	if (bind(s, (struct sockaddr *)&l_local, sizeof(struct sockaddr_nl)) ==
-	    -1) {
+	if (bind(s, (struct sockaddr *)&l_local, sizeof(struct sockaddr_nl)) == -1) {
 		perror("bind");
 		close(s);
 		return -1;




> 
> cheers,
> jamal 
> 
> 	Evgeniy Polyakov
> 
> Only failure makes us experts. -- Theo de Raadt

-- 
Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
--
	Evgeniy Polyakov ( s0mbre )

Crash is better than data corruption. -- Artur Grabowski
