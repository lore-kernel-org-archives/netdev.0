From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH net-next] tun: Add ability to create tun device with given
 index
Date: Thu, 13 Jun 2013 14:04:54 +0400
Message-ID: <51B99946.3000703@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:39541 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755203Ab3FMKFE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jun 2013 06:05:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tun devices cannot be created with ifidex user wants, but it's
required by checkpoint-restore project.

Long time ago such ability was implemented for rtnl_ops-based
interface for creating links (9c7dafbf net: Allow to create links
with given ifindex), but the only API for creating and managing 
tuntap devices is ioctl-based and is evolving with adding new ones
(cde8b15f tuntap: add ioctl to attach or detach a file form tuntap
device).

Following that trend, here's how a new ioctl that sets the ifindex
for device, that _will_ be created by TUNSETIFF ioctl looks like.
So those who want a tuntap device with the ifindex I, should open
the tun device, call ioctl(fd, TUNSETIFINDEX, I), then call TUNSETIFF.
If setifindex is not called, then it will be generated as before.

Is it OK to extend ioctls with this, or should we rather switch the
whole tuntap driver on full-featured rtln-ops?

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index a344270..3f89f92 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -137,7 +137,10 @@ struct tun_file {
 	struct fasync_struct *fasync;
 	/* only used for fasnyc */
 	unsigned int flags;
-	u16 queue_index;
+	union {
+		u16 queue_index;
+		unsigned ifindex;
+	};
 	struct list_head next;
 	struct tun_struct *detached;
 };
@@ -1643,6 +1646,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 
 		dev_net_set(dev, net);
 		dev->rtnl_link_ops = &tun_link_ops;
+		dev->ifindex = tfile->ifindex;
 
 		tun = netdev_priv(dev);
 		tun->dev = dev;
@@ -1858,6 +1862,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	kgid_t group;
 	int sndbuf;
 	int vnet_hdr_sz;
+	unsigned ifindex;
 	int ret;
 
 	if (cmd == TUNSETIFF || cmd == TUNSETQUEUE || _IOC_TYPE(cmd) == 0x89) {
@@ -1892,6 +1897,19 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 			ret = -EFAULT;
 		goto unlock;
 	}
+	if (cmd == TUNSETIFINDEX) {
+		ret = -EPERM;
+		if (tun)
+			goto unlock;
+
+		ret = -EFAULT;
+		if (copy_from_user(&ifindex, argp, sizeof(ifindex)))
+			goto unlock;
+
+		ret = 0;
+		tfile->ifindex = ifindex;
+		goto unlock;
+	}
 
 	ret = -EBADFD;
 	if (!tun)
@@ -2140,6 +2158,7 @@ static int tun_chr_open(struct inode *inode, struct file * file)
 	rcu_assign_pointer(tfile->tun, NULL);
 	tfile->net = get_net(current->nsproxy->net_ns);
 	tfile->flags = 0;
+	tfile->ifindex = 0;
 
 	rcu_assign_pointer(tfile->socket.wq, &tfile->wq);
 	init_waitqueue_head(&tfile->wq.wait);
diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
index 82334f8..e5314cc 100644
--- a/include/uapi/linux/if_tun.h
+++ b/include/uapi/linux/if_tun.h
@@ -56,6 +56,7 @@
 #define TUNGETVNETHDRSZ _IOR('T', 215, int)
 #define TUNSETVNETHDRSZ _IOW('T', 216, int)
 #define TUNSETQUEUE  _IOW('T', 217, int)
+#define TUNSETIFINDEX	_IOW('T', 218, unsigned int)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
