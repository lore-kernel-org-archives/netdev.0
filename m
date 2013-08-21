From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 4/4] tun: Get skfilter layout
Date: Wed, 21 Aug 2013 14:32:39 +0400
Message-ID: <52149747.8010208@parallels.com>
References: <521496EF.8090909@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:50159 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428Ab3HUKcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 06:32:41 -0400
In-Reply-To: <521496EF.8090909@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only thing we may have from tun device is the fprog, whic contains
the number of filter elements and a pointer to (user-space) memory
where the elements are. The program itself may not be available if the
device is persistent and detached.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 drivers/net/tun.c           |   10 ++++++++++
 include/uapi/linux/if_tun.h |    1 +
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 6acbdbc..60a1e93 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -2042,6 +2042,16 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		tun_detach_filter(tun, tun->numqueues);
 		break;
 
+	case TUNGETFILTER:
+		ret = -EINVAL;
+		if ((tun->flags & TUN_TYPE_MASK) != TUN_TAP_DEV)
+			break;
+		ret = -EFAULT;
+		if (copy_to_user(argp, &tun->fprog, sizeof(tun->fprog)))
+			break;
+		ret = 0;
+		break;
+
 	default:
 		ret = -EINVAL;
 		break;
diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
index cc127b2..e9502dd 100644
--- a/include/uapi/linux/if_tun.h
+++ b/include/uapi/linux/if_tun.h
@@ -57,6 +57,7 @@
 #define TUNSETVNETHDRSZ _IOW('T', 216, int)
 #define TUNSETQUEUE  _IOW('T', 217, int)
 #define TUNSETIFINDEX	_IOW('T', 218, unsigned int)
+#define TUNGETFILTER _IOR('T', 219, struct sock_fprog)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
-- 
1.7.6.5
