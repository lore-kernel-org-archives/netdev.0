From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH -next] netdevice zd1201: Use after free
Date: Thu, 18 Dec 2008 14:53:31 +0800
Message-ID: <4949F36B.7080707@cn.fujitsu.com>
References: <20081031182207.GD4310@tuxdriver.com> <1225478896-28987-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	NETDEV <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60865 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751064AbYLRGxp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2008 01:53:45 -0500
In-Reply-To: <1225478896-28987-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| commit 3d29b0c33d431ecc69ec778f8c236d382f59a85f
| Author: John W. Linville <linville@tuxdriver.com>
| Date:   Fri Oct 31 14:13:12 2008 -0400
| 
|     netdevice zd1201: Convert directly reference of netdev->priv to netdev_priv()
| 
|     We have some reasons to kill netdev->priv:
|     1. netdev->priv is equal to netdev_priv().
|     2. netdev_priv() wraps the calculation of netdev->priv's offset, obviously
|        netdev_priv() is more flexible than netdev->priv.
|     But we cann't kill netdev->priv, because so many drivers reference to it
|     directly.
| 
|     OK, becasue Dave S. Miller said, "every direct netdev->priv usage is a bug",
|     and I want to kill netdev->priv later, I decided to convert all the direct
|     reference of netdev->priv first.
| 
|     (Original patch posted by Wang Chen <wangchen@cn.fujitsu.com> w/ above
|     changelog but using dev->ml_priv.  That doesn't seem appropriate
|     to me for this driver, so I've revamped it to use netdev_priv()
|     instead. -- JWL)

This commit changed the allocation of netdev, but didn't change
the free method of it.
This causes "zd" be used after the memory, which is pointed by "zd", being
freed by free_netdev().

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
Cc: John W. Linville <linville@tuxdriver.com>
---
 drivers/net/wireless/zd1201.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index 3404807..b45c27d 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -1841,10 +1841,6 @@ static void zd1201_disconnect(struct usb_interface *interface)
 	if (!zd)
 		return;
 	usb_set_intfdata(interface, NULL);
-	if (zd->dev) {
-		unregister_netdev(zd->dev);
-		free_netdev(zd->dev);
-	}
 
 	hlist_for_each_entry_safe(frag, node, node2, &zd->fraglist, fnode) {
 		hlist_del_init(&frag->fnode);
@@ -1860,7 +1856,11 @@ static void zd1201_disconnect(struct usb_interface *interface)
 		usb_kill_urb(zd->rx_urb);
 		usb_free_urb(zd->rx_urb);
 	}
-	kfree(zd);
+
+	if (zd->dev) {
+		unregister_netdev(zd->dev);
+		free_netdev(zd->dev);
+	}
 }
 
 #ifdef CONFIG_PM
-- 
1.5.3.4



