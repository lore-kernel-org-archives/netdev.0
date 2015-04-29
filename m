From: Pai <vpai@akamai.com>
Subject: [PATCH] Fix Kernel Panic in bonding driver debugfs file: rlb_hash_table
Date: Wed, 29 Apr 2015 14:24:23 -0400
Message-ID: <E1YnWel-0004R7-1o@bos-lpqrs.kendall.corp.akamai.com>
To: "Jay Vosburgh" <j.vosburgh@gmail.com>,
	"Veaceslav Falico" <vfalico@gmail.com>,
	"Andy Gospodarek" <andy@greyhouse.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, "Vishwanath Pai" <vpai@akamai.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a Kernel Panic in bonding driver debugfs file: rlb_hash_table.

$> modprobe bonding mode=6
$> cat /sys/kernel/debug/bonding/bond0/rlb_hash_table

This will crash the kernel. The struct alb_bond_info is initialized only when
the bonding interface is initialized (ip link set bond0 up) and not at the time
it is allocated. If we try to read the table before that, it'll result in a 
kernel panic.

The patch applies against both net and net-next

Signed-off-by: Vishwanath Pai <vpai@akamai.com>
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 089a402..806892a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4510,6 +4510,8 @@ unsigned int bond_get_num_tx_queues(void)
 int bond_create(struct net *net, const char *name)
 {
 	struct net_device *bond_dev;
+	struct bonding *bond;
+	struct alb_bond_info *bond_info;
 	int res;
 
 	rtnl_lock();
@@ -4523,6 +4525,14 @@ int bond_create(struct net *net, const char *name)
 		return -ENOMEM;
 	}
 
+	/*
+	 * Initialize rx_hashtbl_used_head to RLB_NULL_INDEX.
+	 * It is set to 0 by default which is wrong.
+	 */
+	bond = netdev_priv(bond_dev);
+	bond_info = &(BOND_ALB_INFO(bond));
+	bond_info->rx_hashtbl_used_head = RLB_NULL_INDEX;
+
 	dev_net_set(bond_dev, net);
 	bond_dev->rtnl_link_ops = &bond_link_ops;
 
