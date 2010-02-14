From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 2/2] tun: socket filter support
Date: Sun, 14 Feb 2010 13:01:10 +0200
Message-ID: <20100214110110.GC30182@redhat.com>
References: <cover.1266144917.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Paul Moore <paul.moore@hp.com>,
	David Woodhouse <David.Woodhouse@intel.com>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44273 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758420Ab0BNLFw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Feb 2010 06:05:52 -0500
Content-Disposition: inline
In-Reply-To: <cover.1266144917.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds Linux Socket Filter support to
tun driver.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/tun.c      |   26 ++++++++++++++++++++++++++
 include/linux/if_tun.h |    3 +++
 2 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 5adb3d1..ce1efa4 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -61,6 +61,7 @@
 #include <linux/crc32.h>
 #include <linux/nsproxy.h>
 #include <linux/virtio_net.h>
+#include <linux/rcupdate.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
@@ -366,6 +367,10 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!check_filter(&tun->txflt, skb))
 		goto drop;
 
+	if (tun->socket.sk->sk_filter &&
+	    sk_filter(tun->socket.sk, skb))
+		goto drop;
+
 	if (skb_queue_len(&tun->socket.sk->sk_receive_queue) >= dev->tx_queue_len) {
 		if (!(tun->flags & TUN_ONE_QUEUE)) {
 			/* Normal queueing mode. */
@@ -1162,6 +1167,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	struct tun_file *tfile = file->private_data;
 	struct tun_struct *tun;
 	void __user* argp = (void __user*)arg;
+	struct sock_fprog fprog;
 	struct ifreq ifr;
 	int sndbuf;
 	int ret;
@@ -1309,6 +1315,26 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		tun->socket.sk->sk_sndbuf = sndbuf;
 		break;
 
+	case TUNATTACHFILTER:
+		/* Can be set only for TAPs */
+		ret = -EINVAL;
+		if ((tun->flags & TUN_TYPE_MASK) != TUN_TAP_DEV)
+			break;
+		ret = -EFAULT;
+		if (copy_from_user(&fprog, argp, sizeof(fprog)))
+			break;
+
+		ret = sk_attach_filter(&fprog, tun->socket.sk);
+		break;
+
+	case TUNDETACHFILTER:
+		/* Can be set only for TAPs */
+		ret = -EINVAL;
+		if ((tun->flags & TUN_TYPE_MASK) != TUN_TAP_DEV)
+			break;
+		ret = sk_detach_filter(tun->socket.sk);
+		break;
+
 	default:
 		ret = -EINVAL;
 		break;
diff --git a/include/linux/if_tun.h b/include/linux/if_tun.h
index 404abe0..1350a24 100644
--- a/include/linux/if_tun.h
+++ b/include/linux/if_tun.h
@@ -18,6 +18,7 @@
 
 #include <linux/types.h>
 #include <linux/if_ether.h>
+#include <linux/filter.h>
 
 /* Read queue size */
 #define TUN_READQ_SIZE	500
@@ -48,6 +49,8 @@
 #define TUNGETIFF      _IOR('T', 210, unsigned int)
 #define TUNGETSNDBUF   _IOR('T', 211, int)
 #define TUNSETSNDBUF   _IOW('T', 212, int)
+#define TUNATTACHFILTER _IOW('T', 213, struct sock_fprog)
+#define TUNDETACHFILTER _IOW('T', 214, struct sock_fprog)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
-- 
1.6.6.144.g5c3af
