From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 3/4] tun: Allow to skip filter on attach
Date: Mon, 19 Aug 2013 19:10:21 +0400
Message-ID: <5212355D.8010305@parallels.com>
References: <52123515.3060507@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:53460 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980Ab3HSPKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 11:10:23 -0400
In-Reply-To: <52123515.3060507@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's a small problem with sk-filters on tun devices. Consider
an application doing this sequence of steps:

fd = open("/dev/net/tun");
ioctl(fd, TUNSETIFF, { .ifr_name = "tun0" });
ioctl(fd, TUNATTACHFILTER, &my_filter);
ioctl(fd, TUNSETPERSIST, 1);
close(fd);

At that point the tun0 will remain in the system and will keep in
mind that there should be a socket filter at address '&my_filter'.

If after that we do

fd = open("/dev/net/tun");
ioctl(fd, TUNSETIFF, { .ifr_name = "tun0" });

we most likely receive the -EFAULT error, since tun_attach() would
try to connect the filter back. But (!) if we provide a filter at
address &my_filter, then tun0 will be created and the "new" filter
would be attached, but application may not know about that.

This may create certain problems to anyone using tun-s, but it's
critical problem for c/r -- if we meet a persistent tun device
with a filter in mind, we will not be able to attach to it to dump
its state (flags, owner, address, vnethdr size, etc.).

The proposal is to allow to attach to tun device (with TUNSETIFF)
w/o attaching the filter to the tun-file's socket. After this
attach app may e.g clean the device by dropping the filter, it
doesn't want to have one, or (in case of c/r) get information
about the device with tun ioctls.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 drivers/net/tun.c           |   12 +++++++-----
 include/uapi/linux/if_tun.h |    1 +
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 167222f..8bfc1ce 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -501,7 +501,7 @@ static void tun_detach_all(struct net_device *dev)
 		module_put(THIS_MODULE);
 }
 
-static int tun_attach(struct tun_struct *tun, struct file *file)
+static int tun_attach(struct tun_struct *tun, struct file *file, bool skip_filter)
 {
 	struct tun_file *tfile = file->private_data;
 	int err;
@@ -526,7 +526,7 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
 	err = 0;
 
 	/* Re-attach the filter to presist device */
-	if (tun->filter_attached == true) {
+	if (!skip_filter && (tun->filter_attached == true)) {
 		err = sk_attach_filter(&tun->fprog, tfile->socket.sk);
 		if (!err)
 			goto out;
@@ -1557,7 +1557,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		if (err < 0)
 			return err;
 
-		err = tun_attach(tun, file);
+		err = tun_attach(tun, file, ifr->ifr_flags & IFF_NOFILTER);
 		if (err < 0)
 			return err;
 
@@ -1631,7 +1631,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		dev->vlan_features = dev->features;
 
 		INIT_LIST_HEAD(&tun->disabled);
-		err = tun_attach(tun, file);
+		err = tun_attach(tun, file, false);
 		if (err < 0)
 			goto err_free_dev;
 
@@ -1795,7 +1795,7 @@ static int tun_set_queue(struct file *file, struct ifreq *ifr)
 		ret = security_tun_dev_attach_queue(tun->security);
 		if (ret < 0)
 			goto unlock;
-		ret = tun_attach(tun, file);
+		ret = tun_attach(tun, file, false);
 	} else if (ifr->ifr_flags & IFF_DETACH_QUEUE) {
 		tun = rtnl_dereference(tfile->tun);
 		if (!tun || !(tun->flags & TUN_TAP_MQ) || tfile->detached)
@@ -1883,6 +1883,8 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 
 		if (tfile->detached)
 			ifr.ifr_flags |= IFF_DETACH_QUEUE;
+		if (!tfile->socket.sk->sk_filter)
+			ifr.ifr_flags |= IFF_NOFILTER;
 
 		if (copy_to_user(argp, &ifr, ifreq_len))
 			ret = -EFAULT;
diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
index c58d023..cc127b2 100644
--- a/include/uapi/linux/if_tun.h
+++ b/include/uapi/linux/if_tun.h
@@ -71,6 +71,7 @@
 #define IFF_DETACH_QUEUE 0x0400
 /* read-only flag */
 #define IFF_PERSIST	0x0800
+#define IFF_NOFILTER	0x1000
 
 /* Socket options */
 #define TUN_TX_TIMESTAMP 1
-- 
1.7.6.5
