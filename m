From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v2 01/10] Drivers: Staging: cxt1e1: use __dev_get_name instead of dev_get_name to find interfaces
Date: Wed, 15 Jan 2014 10:23:36 +0800
Message-ID: <1389752625-23189-2-git-send-email-ying.xue@windriver.com>
References: <1389752625-23189-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vfalico@redhat.com>, <john.r.fastabend@intel.com>,
	<stephen@networkplumber.org>, <antonio@meshcoding.com>,
	<dmitry.tarnyagin@lockless.no>, <socketcan@hartkopp.net>,
	<johannes@sipsolutions.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389752625-23189-1-git-send-email-ying.xue@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following call chain denotes that both do_reset() and do_del_chan()
are protected under rtnl_lock. If we use __dev_get_by_name() instead of
dev_get_by_name() to find interface handlers in them, this would help
us avoid to change interface reference counter.

dev_ioctl()
  rtnl_lock()
  dev_ifsioc()
    c4_ioctl()
      do_reset()
      do_del_chan()
  rtnl_unlock()

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 drivers/staging/cxt1e1/linux.c |   15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/cxt1e1/linux.c b/drivers/staging/cxt1e1/linux.c
index 9b48373..4a08e16 100644
--- a/drivers/staging/cxt1e1/linux.c
+++ b/drivers/staging/cxt1e1/linux.c
@@ -770,9 +770,9 @@ do_del_chan (struct net_device *musycc_dev, void *data)
     if (cp.channum > 999)
         return -EINVAL;
     snprintf (buf, sizeof(buf), CHANNAME "%d", cp.channum);
-    if (!(dev = dev_get_by_name (&init_net, buf)))
-        return -ENOENT;
-    dev_put (dev);
+	dev = __dev_get_by_name(&init_net, buf);
+	if (!dev)
+		return -ENODEV;
     ret = do_deluser (dev, 1);
     if (ret)
         return ret;
@@ -792,19 +792,18 @@ do_reset (struct net_device *musycc_dev, void *data)
         char        buf[sizeof (CHANNAME) + 3];
 
         sprintf (buf, CHANNAME "%d", i);
-        if (!(ndev = dev_get_by_name(&init_net, buf)))
-            continue;
+	ndev = __dev_get_by_name(&init_net, buf);
+	if (!ndev)
+		continue;
         priv = dev_to_hdlc (ndev)->priv;
 
         if ((unsigned long) (priv->ci) ==
             (unsigned long) (netdev_priv(musycc_dev)))
         {
             ndev->flags &= ~IFF_UP;
-            dev_put (ndev);
             netif_stop_queue (ndev);
             do_deluser (ndev, 1);
-        } else
-            dev_put (ndev);
+	}
     }
     return 0;
 }
-- 
1.7.9.5
