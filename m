From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 2/6] tuntap: categorize ioctl
Date: Mon, 25 Jun 2012 19:59:19 +0800
Message-ID: <1340625563-9300-3-git-send-email-jasowang@redhat.com>
References: <20120625060830.6765.27584.stgit@amd-6168-8-1.englab.nay.redhat.com>
Cc: shemminger@vyatta.com, edumazet@google.com,
	Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, akong@redhat.com, habanero@linux.vnet.ibm.com,
	tahm@linux.vnet.ibm.com, haixiao@juniper.net,
	jwhan@filewood.snu.ac.kr, ernesto.martin@viasat.com,
	mashirle@us.ibm.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, krkumar2@in.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120625060830.6765.27584.stgit@amd-6168-8-1.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As we've moved socket related structure to file->private_data, we can optimizes
the ioctls that only touch socket out of tun_chr_ioctl() as it don't need hold
rtnl lock.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |   52 ++++++++++++++++++++++++++++++++++------------------
 1 files changed, 34 insertions(+), 18 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 1f27789..8233b0a 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1248,10 +1248,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	struct tun_file *tfile = file->private_data;
 	struct tun_struct *tun;
 	void __user* argp = (void __user*)arg;
-	struct sock_fprog fprog;
 	struct ifreq ifr;
-	int sndbuf;
-	int vnet_hdr_sz;
 	int ret;
 
 	if (cmd == TUNSETIFF || _IOC_TYPE(cmd) == 0x89)
@@ -1356,14 +1353,6 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		ret = set_offload(tun, arg);
 		break;
 
-	case TUNSETTXFILTER:
-		/* Can be set only for TAPs */
-		ret = -EINVAL;
-		if ((tfile->flags & TUN_TYPE_MASK) != TUN_TAP_DEV)
-			break;
-		ret = update_filter(&tfile->txflt, (void __user *)arg);
-		break;
-
 	case SIOCGIFHWADDR:
 		/* Get hw address */
 		memcpy(ifr.ifr_hwaddr.sa_data, tun->dev->dev_addr, ETH_ALEN);
@@ -1380,6 +1369,37 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		ret = dev_set_mac_address(tun->dev, &ifr.ifr_hwaddr);
 		break;
 
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+unlock:
+	rtnl_unlock();
+	if (tun)
+		tun_put(tun);
+	return ret;
+}
+
+static long __tun_socket_ioctl(struct file *file, unsigned int cmd,
+			       unsigned long arg, int ifreq_len)
+{
+	struct tun_file *tfile = file->private_data;
+	void __user *argp = (void __user *)arg;
+	struct sock_fprog fprog;
+	int sndbuf;
+	int vnet_hdr_sz;
+	int ret = 0;
+
+	switch (cmd) {
+	case TUNSETTXFILTER:
+		/* Can be set only for TAPs */
+		ret = -EINVAL;
+		if ((tfile->flags & TUN_TYPE_MASK) != TUN_TAP_DEV)
+			break;
+		ret = update_filter(&tfile->txflt, (void __user *)arg);
+		break;
+
 	case TUNGETSNDBUF:
 		sndbuf = tfile->socket.sk->sk_sndbuf;
 		if (copy_to_user(argp, &sndbuf, sizeof(sndbuf)))
@@ -1435,21 +1455,17 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		break;
 
 	default:
-		ret = -EINVAL;
+		ret = __tun_chr_ioctl(file, cmd, arg, ifreq_len);
 		break;
 	}
 
-unlock:
-	rtnl_unlock();
-	if (tun)
-		tun_put(tun);
 	return ret;
 }
 
 static long tun_chr_ioctl(struct file *file,
 			  unsigned int cmd, unsigned long arg)
 {
-	return __tun_chr_ioctl(file, cmd, arg, sizeof (struct ifreq));
+	return __tun_socket_ioctl(file, cmd, arg, sizeof(struct ifreq));
 }
 
 #ifdef CONFIG_COMPAT
@@ -1477,7 +1493,7 @@ static long tun_chr_compat_ioctl(struct file *file,
 	 * driver are compatible though, we don't need to convert the
 	 * contents.
 	 */
-	return __tun_chr_ioctl(file, cmd, arg, sizeof(struct compat_ifreq));
+	return __tun_socket_ioctl(file, cmd, arg, sizeof(struct compat_ifreq));
 }
 #endif /* CONFIG_COMPAT */
 
-- 
1.7.1
