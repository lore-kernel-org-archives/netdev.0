From: Andrew Morton <akpm@osdl.org>
Subject: register_netdevice return val fix
Date: Sat, 18 Oct 2003 19:00:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031018190014.60ad6344.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



If the driver's init function returns an error code (most likely -ENODEV),
register_netdevice will stomp on it and will always return -EIO.

You end up always getting an "Input/Output error" from modprobe, which is
confusing.

Fix register_netdevice() to return the init function's error code, if it
looks sane.



 net/core/dev.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff -puN net/core/dev.c~register_netdevice-retval-fix net/core/dev.c
--- 25/net/core/dev.c~register_netdevice-retval-fix	2003-10-18 18:50:52.000000000 -0700
+++ 25-akpm/net/core/dev.c	2003-10-18 18:51:39.000000000 -0700
@@ -2652,9 +2652,14 @@ int register_netdevice(struct net_device
 	dev->iflink = -1;
 
 	/* Init, if this function is available */
-	ret = -EIO;
-	if (dev->init && dev->init(dev))
-		goto out_err;
+	if (dev->init) {
+		ret = dev->init(dev);
+		if (ret) {
+			if (ret > 0)
+				ret = -EIO;
+			goto out_err;
+		}
+	}
 
 	dev->ifindex = dev_new_index();
 	if (dev->iflink == -1)

_
