From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next] tuntap: attach queue 0 before registering netdevice
Date: Mon,  3 Dec 2012 11:19:45 +0800
Message-ID: <1354504785-13036-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jslaby@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We attach queue 0 after registering netdevice currently. This leads to call
netif_set_real_num_{tx|rx}_queues() after registering the netdevice. Since we
allow tun/tap has a maximum of 1024 queues, this may lead a huge number of
uevents to be injected to userspace since we create 2048 kobjects and then
remove 2046. Solve this problem by attaching queue 0 and set the real number of
queues before registering netdevice.

Reported-by: Jiri Slaby <jslaby@suse.cz>
Tested-by: Jiri Slaby <jslaby@suse.cz>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index b44d7b7..cc3f878 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -492,9 +492,6 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
 
 	tun_set_real_num_queues(tun);
 
-	if (tun->numqueues == 1)
-		netif_carrier_on(tun->dev);
-
 	/* device is allowed to go away first, so no need to hold extra
 	 * refcnt.
 	 */
@@ -1611,6 +1608,10 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 			TUN_USER_FEATURES;
 		dev->features = dev->hw_features;
 
+		err = tun_attach(tun, file);
+		if (err < 0)
+			goto err_free_dev;
+
 		err = register_netdevice(tun->dev);
 		if (err < 0)
 			goto err_free_dev;
@@ -1620,9 +1621,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		    device_create_file(&tun->dev->dev, &dev_attr_group))
 			pr_err("Failed to create tun sysfs files\n");
 
-		err = tun_attach(tun, file);
-		if (err < 0)
-			goto err_free_dev;
+		netif_carrier_on(tun->dev);
 	}
 
 	tun_debug(KERN_INFO, tun, "tun_set_iff\n");
-- 
1.7.1
