From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH net-next 4/4] netns: bond: allow unprivileged users to control bond device
Date: Fri, 1 Feb 2013 10:31:00 +0800
Message-ID: <1359685860-29636-4-git-send-email-gaofeng@cn.fujitsu.com>
References: <1359685860-29636-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	ebiederm@xmission.com, serge@hallyn.com, pablo@netfilter.org,
	amwang@redhat.com, Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:3031 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754544Ab3BACap (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2013 21:30:45 -0500
In-Reply-To: <1359685860-29636-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

reduce the permission check of bond device's ioctl.
allow the userns root to control the bond device.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 drivers/net/bonding/bond_main.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b38c9bf..2239937 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3612,6 +3612,7 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 	struct ifslave k_sinfo;
 	struct ifslave __user *u_sinfo = NULL;
 	struct mii_ioctl_data *mii = NULL;
+	struct net *net;
 	int res = 0;
 
 	pr_debug("bond_ioctl: master=%s, cmd=%d\n", bond_dev->name, cmd);
@@ -3678,10 +3679,12 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 		break;
 	}
 
-	if (!capable(CAP_NET_ADMIN))
+	net = dev_net(bond_dev);
+
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
-	slave_dev = dev_get_by_name(dev_net(bond_dev), ifr->ifr_slave);
+	slave_dev = dev_get_by_name(net, ifr->ifr_slave);
 
 	pr_debug("slave_dev=%p:\n", slave_dev);
 
-- 
1.7.11.7
