From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 7/7] net: mpls: Send netconf messages on device register and unregister
Date: Tue, 28 Mar 2017 14:28:07 -0700
Message-ID: <1490736487-16020-8-git-send-email-dsa@cumulusnetworks.com>
References: <1490736487-16020-1-git-send-email-dsa@cumulusnetworks.com>
Cc: nicolas.dichtel@6wind.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:35295 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754008AbdC1V2r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 17:28:47 -0400
Received: by mail-it0-f46.google.com with SMTP id y18so130332336itc.0
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 14:28:19 -0700 (PDT)
In-Reply-To: <1490736487-16020-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Send netconf notifications for MPLS when the device registers and
unregisters.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 313cd0a93a63..673f3d990b5c 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -1225,10 +1225,11 @@ static int mpls_dev_sysctl_register(struct net_device *dev,
 
 	snprintf(path, sizeof(path), "net/mpls/conf/%s", dev->name);
 
-	mdev->sysctl = register_net_sysctl(dev_net(dev), path, table);
+	mdev->sysctl = register_net_sysctl(net, path, table);
 	if (!mdev->sysctl)
 		goto free;
 
+	mpls_netconf_notify_devconf(net, RTM_NEWNETCONF, NETCONFA_ALL, mdev);
 	return 0;
 
 free:
@@ -1237,13 +1238,17 @@ static int mpls_dev_sysctl_register(struct net_device *dev,
 	return -ENOBUFS;
 }
 
-static void mpls_dev_sysctl_unregister(struct mpls_dev *mdev)
+static void mpls_dev_sysctl_unregister(struct net_device *dev,
+				       struct mpls_dev *mdev)
 {
+	struct net *net = dev_net(dev);
 	struct ctl_table *table;
 
 	table = mdev->sysctl->ctl_table_arg;
 	unregister_net_sysctl_table(mdev->sysctl);
 	kfree(table);
+
+	mpls_netconf_notify_devconf(net, RTM_DELNETCONF, 0, mdev);
 }
 
 static struct mpls_dev *mpls_add_dev(struct net_device *dev)
@@ -1269,11 +1274,12 @@ static struct mpls_dev *mpls_add_dev(struct net_device *dev)
 		u64_stats_init(&mpls_stats->syncp);
 	}
 
+	mdev->dev = dev;
+
 	err = mpls_dev_sysctl_register(dev, mdev);
 	if (err)
 		goto free;
 
-	mdev->dev = dev;
 	rcu_assign_pointer(dev->mpls_ptr, mdev);
 
 	return mdev;
@@ -1419,7 +1425,7 @@ static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
 		mpls_ifdown(dev, event);
 		mdev = mpls_dev_get(dev);
 		if (mdev) {
-			mpls_dev_sysctl_unregister(mdev);
+			mpls_dev_sysctl_unregister(dev, mdev);
 			RCU_INIT_POINTER(dev->mpls_ptr, NULL);
 			call_rcu(&mdev->rcu, mpls_dev_destroy_rcu);
 		}
@@ -1429,7 +1435,7 @@ static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
 		if (mdev) {
 			int err;
 
-			mpls_dev_sysctl_unregister(mdev);
+			mpls_dev_sysctl_unregister(dev, mdev);
 			err = mpls_dev_sysctl_register(dev, mdev);
 			if (err)
 				return notifier_from_errno(err);
-- 
2.1.4
