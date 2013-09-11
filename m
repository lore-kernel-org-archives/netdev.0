From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net V2] tuntap: correctly handle error in tun_set_iff()
Date: Wed, 11 Sep 2013 18:09:48 +0800
Message-ID: <1378894188-8015-1-git-send-email-jasowang@redhat.com>
Cc: wannes.rombouts@epitech.eu, Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit c8d68e6be1c3b242f1c598595830890b65cea64a
(tuntap: multiqueue support) only call free_netdev() on error in
tun_set_iff(). This causes several issues:

- memory of tun security were leaked
- use after free since the flow gc timer was not deleted and the tfile
  were not detached

This patch solves the above issues.

Reported-by: Wannes Rombouts <wannes.rombouts@epitech.eu>
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
- Changes from V1: shift 1 space for label err_free_netdev and keep
  commit log under 70 chars per line.
- The patch were needed for stable kernel 3.8+.
---
 drivers/net/tun.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index a639de8..807815f 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1641,11 +1641,11 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		INIT_LIST_HEAD(&tun->disabled);
 		err = tun_attach(tun, file, false);
 		if (err < 0)
-			goto err_free_dev;
+			goto err_free_flow;
 
 		err = register_netdevice(tun->dev);
 		if (err < 0)
-			goto err_free_dev;
+			goto err_detach;
 
 		if (device_create_file(&tun->dev->dev, &dev_attr_tun_flags) ||
 		    device_create_file(&tun->dev->dev, &dev_attr_owner) ||
@@ -1689,7 +1689,12 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 	strcpy(ifr->ifr_name, tun->dev->name);
 	return 0;
 
- err_free_dev:
+err_detach:
+	tun_detach_all(dev);
+err_free_flow:
+	tun_flow_uninit(tun);
+	security_tun_dev_free_security(tun->security);
+err_free_dev:
 	free_netdev(dev);
 	return err;
 }
-- 
1.7.1
