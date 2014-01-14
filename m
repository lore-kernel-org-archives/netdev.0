From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 01/10] Drivers: Staging: cxt1e1: use __dev_get_name instead of dev_get_name to find interfaces
Date: Tue, 14 Jan 2014 15:41:00 +0800
Message-ID: <1389685269-18600-2-git-send-email-ying.xue@windriver.com>
References: <1389685269-18600-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vfalico@redhat.com>, <john.r.fastabend@intel.com>,
	<stephen@networkplumber.org>, <antonio@meshcoding.com>,
	<dmitry.tarnyagin@lockless.no>, <socketcan@hartkopp.net>,
	<johannes@sipsolutions.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:41284 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbaANHlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 02:41:52 -0500
In-Reply-To: <1389685269-18600-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
