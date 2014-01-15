From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v2 02/10] bonding: use __dev_get_by_name instead of dev_get_by_name to find interface
Date: Wed, 15 Jan 2014 10:23:37 +0800
Message-ID: <1389752625-23189-3-git-send-email-ying.xue@windriver.com>
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

The following call chain indicates that bond_do_ioctl() is protected
under rtnl_lock. If we use __dev_get_by_name() instead of
dev_get_by_name() to find interface handler in it, this would
help us avoid to change reference counter of interface once.

dev_ioctl()
  rtnl_lock()
  dev_ifsioc()
    bond_do_ioctl()
  rtnl_unlock()

Additionally we also change the coding style in bond_do_ioctl(),
letting it more readable for us.

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |   49 ++++++++++++++++++---------------------
 1 file changed, 23 insertions(+), 26 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7069b84..f2fe6cb 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3213,37 +3213,34 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
-	slave_dev = dev_get_by_name(net, ifr->ifr_slave);
+	slave_dev = __dev_get_by_name(net, ifr->ifr_slave);
 
 	pr_debug("slave_dev=%p:\n", slave_dev);
 
 	if (!slave_dev)
-		res = -ENODEV;
-	else {
-		pr_debug("slave_dev->name=%s:\n", slave_dev->name);
-		switch (cmd) {
-		case BOND_ENSLAVE_OLD:
-		case SIOCBONDENSLAVE:
-			res = bond_enslave(bond_dev, slave_dev);
-			break;
-		case BOND_RELEASE_OLD:
-		case SIOCBONDRELEASE:
-			res = bond_release(bond_dev, slave_dev);
-			break;
-		case BOND_SETHWADDR_OLD:
-		case SIOCBONDSETHWADDR:
-			bond_set_dev_addr(bond_dev, slave_dev);
-			res = 0;
-			break;
-		case BOND_CHANGE_ACTIVE_OLD:
-		case SIOCBONDCHANGEACTIVE:
-			res = bond_option_active_slave_set(bond, slave_dev);
-			break;
-		default:
-			res = -EOPNOTSUPP;
-		}
+		return -ENODEV;
 
-		dev_put(slave_dev);
+	pr_debug("slave_dev->name=%s:\n", slave_dev->name);
+	switch (cmd) {
+	case BOND_ENSLAVE_OLD:
+	case SIOCBONDENSLAVE:
+		res = bond_enslave(bond_dev, slave_dev);
+		break;
+	case BOND_RELEASE_OLD:
+	case SIOCBONDRELEASE:
+		res = bond_release(bond_dev, slave_dev);
+		break;
+	case BOND_SETHWADDR_OLD:
+	case SIOCBONDSETHWADDR:
+		bond_set_dev_addr(bond_dev, slave_dev);
+		res = 0;
+		break;
+	case BOND_CHANGE_ACTIVE_OLD:
+	case SIOCBONDCHANGEACTIVE:
+		res = bond_option_active_slave_set(bond, slave_dev);
+		break;
+	default:
+		res = -EOPNOTSUPP;
 	}
 
 	return res;
-- 
1.7.9.5
