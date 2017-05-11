From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH v2] xen-netfront: avoid crashing on resume after a failure in talk_to_netback()
Date: Thu, 11 May 2017 13:58:06 +0200
Message-ID: <20170511115806.25322-1-vkuznets@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Boris Ostrovsky <boris.ostrovsky@oracle.com>,
        Juergen Gross <jgross@suse.com>,
        David Miller <davem@davemloft.net>
To: xen-devel@lists.xenproject.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unavoidable crashes in netfront_resume() and netback_changed() after a
previous fail in talk_to_netback() (e.g. when we fail to read MAC from
xenstore) were discovered. The failure path in talk_to_netback() does
unregister/free for netdev but we don't reset drvdata and we try accessing
it after resume.

Fix the bug by removing the whole xen device completely with
device_unregister(), this guarantees we won't have any calls into netfront
after a failure.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
Changes since v1: instead of cleaning drvdata and checking for it in
netfront_resume() and netback_changed() remove the device completely with
device_unregister() [David Miller]
---
 drivers/net/xen-netfront.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 6ffc482..7b61adb 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1934,8 +1934,7 @@ static int talk_to_netback(struct xenbus_device *dev,
 	xennet_disconnect_backend(info);
 	xennet_destroy_queues(info);
  out:
-	unregister_netdev(info->netdev);
-	xennet_free_netdev(info->netdev);
+	device_unregister(&dev->dev);
 	return err;
 }
 
-- 
2.9.3
