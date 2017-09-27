From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 2/3] tun: introduce ioctls to set and get steering policies
Date: Wed, 27 Sep 2017 16:23:56 +0800
Message-ID: <1506500637-13881-3-git-send-email-jasowang@redhat.com>
References: <1506500637-13881-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506500637-13881-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces new ioctl for change packet steering policy for
tun. Only automatic flow steering is supported, more policies will
come.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c           | 35 ++++++++++++++++++++++++++++++++++-
 include/uapi/linux/if_tun.h |  7 +++++++
 2 files changed, 41 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index de83e72..1106521 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -122,7 +122,8 @@ do {								\
 #define TUN_VNET_BE     0x40000000
 
 #define TUN_FEATURES (IFF_NO_PI | IFF_ONE_QUEUE | IFF_VNET_HDR | \
-		      IFF_MULTI_QUEUE | IFF_NAPI | IFF_NAPI_FRAGS)
+		      IFF_MULTI_QUEUE | IFF_NAPI | IFF_NAPI_FRAGS | \
+		      IFF_MULTI_STEERING)
 
 #define GOODCOPY_LEN 128
 
@@ -2506,6 +2507,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	unsigned int ifindex;
 	int le;
 	int ret;
+	unsigned int steering;
 
 	if (cmd == TUNSETIFF || cmd == TUNSETQUEUE || _IOC_TYPE(cmd) == SOCK_IOC_TYPE) {
 		if (copy_from_user(&ifr, argp, ifreq_len))
@@ -2764,6 +2766,37 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		ret = 0;
 		break;
 
+	case TUNSETSTEERING:
+		ret = -EFAULT;
+		if (copy_from_user(&steering, argp, sizeof(steering)))
+			break;
+		ret = 0;
+		switch (steering) {
+		case TUN_STEERING_AUTOMQ:
+			tun->steering_ops = &tun_automq_ops;
+			break;
+		default:
+			ret = -EFAULT;
+		}
+		break;
+
+	case TUNGETSTEERING:
+		ret = 0;
+		if (tun->steering_ops == &tun_automq_ops)
+			steering = TUN_STEERING_AUTOMQ;
+		else
+			BUG();
+		if (copy_to_user(argp, &steering, sizeof(steering)))
+			ret = -EFAULT;
+		break;
+
+	case TUNGETSTEERINGFEATURES:
+		ret = 0;
+		steering = TUN_STEERING_AUTOMQ;
+		if (copy_to_user(argp, &steering, sizeof(steering)))
+			ret = -EFAULT;
+		break;
+
 	default:
 		ret = -EINVAL;
 		break;
diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
index 365ade5..109760e 100644
--- a/include/uapi/linux/if_tun.h
+++ b/include/uapi/linux/if_tun.h
@@ -56,6 +56,9 @@
  */
 #define TUNSETVNETBE _IOW('T', 222, int)
 #define TUNGETVNETBE _IOR('T', 223, int)
+#define TUNSETSTEERING _IOW('T', 224, unsigned int)
+#define TUNGETSTEERING _IOR('T', 225, unsigned int)
+#define TUNGETSTEERINGFEATURES _IOR('T', 226, unsigned int)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
@@ -70,6 +73,8 @@
 #define IFF_MULTI_QUEUE 0x0100
 #define IFF_ATTACH_QUEUE 0x0200
 #define IFF_DETACH_QUEUE 0x0400
+#define IFF_MULTI_STEERING 0x2000
+
 /* read-only flag */
 #define IFF_PERSIST	0x0800
 #define IFF_NOFILTER	0x1000
@@ -106,4 +111,6 @@ struct tun_filter {
 	__u8   addr[0][ETH_ALEN];
 };
 
+#define TUN_STEERING_AUTOMQ 0x01 /* Automatic flow steering */
+
 #endif /* _UAPI__IF_TUN_H */
-- 
2.7.4
