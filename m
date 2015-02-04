From: Takashi Iwai <tiwai@suse.de>
Subject: [PATCH] tun: Use static attribute groups for sysfs entries
Date: Wed,  4 Feb 2015 14:37:34 +0100
Message-ID: <1423057054-6889-1-git-send-email-tiwai@suse.de>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43800 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965247AbbBDNhq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2015 08:37:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of manual calls of device_create_file() and
device_remove_files(), assign the static attribute groups to netdev
groups array.  This simplifies the code and avoids the possible
races.

Signed-off-by: Takashi Iwai <tiwai@suse.de>
---
 drivers/net/tun.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 8c8dc16839a7..662516ed6104 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1566,6 +1566,17 @@ static DEVICE_ATTR(tun_flags, 0444, tun_show_flags, NULL);
 static DEVICE_ATTR(owner, 0444, tun_show_owner, NULL);
 static DEVICE_ATTR(group, 0444, tun_show_group, NULL);
 
+static struct attribute *tun_dev_attrs[] = {
+	&dev_attr_tun_flags.attr,
+	&dev_attr_owner.attr,
+	&dev_attr_group.attr,
+	NULL
+};
+
+static const struct attribute_group tun_attr_group = {
+	.attrs = tun_dev_attrs
+};
+
 static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 {
 	struct tun_struct *tun;
@@ -1646,6 +1657,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		dev_net_set(dev, net);
 		dev->rtnl_link_ops = &tun_link_ops;
 		dev->ifindex = tfile->ifindex;
+		dev->sysfs_groups[0] = &tun_attr_group;
 
 		tun = netdev_priv(dev);
 		tun->dev = dev;
@@ -1681,11 +1693,6 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		err = register_netdevice(tun->dev);
 		if (err < 0)
 			goto err_detach;
-
-		if (device_create_file(&tun->dev->dev, &dev_attr_tun_flags) ||
-		    device_create_file(&tun->dev->dev, &dev_attr_owner) ||
-		    device_create_file(&tun->dev->dev, &dev_attr_group))
-			pr_err("Failed to create tun sysfs files\n");
 	}
 
 	netif_carrier_on(tun->dev);
-- 
2.2.2
