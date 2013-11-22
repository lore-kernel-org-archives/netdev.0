From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net v3] bonding: disable arp and enable mii monitoring when
 bond change to no uses arp mode
Date: Fri, 22 Nov 2013 22:28:43 +0800
Message-ID: <528F6A1B.70904@huawei.com>
References: <528710F7.7050207@huawei.com>	 <1384796682.4774.26.camel@dcbw.foobar.com>	 <20131118.154838.776189725378131169.davem@davemloft.net> <1384815032.4774.55.camel@dcbw.foobar.com> <528ACD8A.1010409@greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <fubar@us.ibm.com>, <nikolay@redhat.com>, <vfalico@redhat.com>,
	<netdev@vger.kernel.org>
To: Andy Gospodarek <andy@greyhouse.net>,
	Dan Williams <dcbw@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:13690 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755520Ab3KVOar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 09:30:47 -0500
In-Reply-To: <528ACD8A.1010409@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because the ARP monitoring is not support for 802.3ad, but I still
could change the mode to 802.3ad from ab mode while ARP monitoring
is running, it is incorrect.

So add a check for 802.3ad in bonding_store_mode to fix the problem,
and make a new macro BOND_NO_USES_ARP() to simplify the code.

v2: according to the Dan Williams's suggestion, bond mode is the most
    important bond option, it should override any of the other sub-options.
    So when the mode is changed, the conficting values should be cleared
    or reset, otherwise the user has to duplicate more operations to modify
    the logic. I disable the arp and enable mii monitoring when the bond mode
    is changed to AB, TB and 8023AD if the arp interval is true.

v3: according to the Nik's suggestion, the default value of miimon should need
    a name, there is several place to use it, and the bond_store_arp_interval()
    could use micro BOND_NO_USES_ARP to make the code more simpify.

Suggested-by: Dan Williams <dcbw@redhat.com>
Suggested-by: Nikolay Aleksandrov <nikolay@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c    |  4 ++--
 drivers/net/bonding/bond_options.c | 13 +++++++++----
 drivers/net/bonding/bond_sysfs.c   |  4 +---
 drivers/net/bonding/bonding.h      |  7 +++++++
 4 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 4dd5ee2..36eab0c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4110,7 +4110,7 @@ static int bond_check_params(struct bond_params *params)
 		if (!miimon) {
 			pr_warning("Warning: miimon must be specified, otherwise bonding will not detect link failure, speed and duplex which are essential for 802.3ad operation\n");
 			pr_warning("Forcing miimon to 100msec\n");
-			miimon = 100;
+			miimon = BOND_DEFAULT_MIIMON;
 		}
 	}
 
@@ -4147,7 +4147,7 @@ static int bond_check_params(struct bond_params *params)
 		if (!miimon) {
 			pr_warning("Warning: miimon must be specified, otherwise bonding will not detect link failure and link speed which are essential for TLB/ALB load balancing\n");
 			pr_warning("Forcing miimon to 100msec\n");
-			miimon = 100;
+			miimon = BOND_DEFAULT_MIIMON;
 		}
 	}
 
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 9a5223c..ea6f640 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -45,10 +45,15 @@ int bond_option_mode_set(struct bonding *bond, int mode)
 		return -EPERM;
 	}
 
-	if (BOND_MODE_IS_LB(mode) && bond->params.arp_interval) {
-		pr_err("%s: %s mode is incompatible with arp monitoring.\n",
-		       bond->dev->name, bond_mode_tbl[mode].modename);
-		return -EINVAL;
+	if (BOND_NO_USES_ARP(mode) && bond->params.arp_interval) {
+		pr_info("%s: %s mode is incompatible with arp monitoring, start mii monitoring\n",
+			bond->dev->name, bond_mode_tbl[mode].modename);
+		/* disable arp monitoring */
+		bond->params.arp_interval = 0;
+		/* set miimon to default value */
+		bond->params.miimon = BOND_DEFAULT_MIIMON;
+		pr_info("%s: Setting MII monitoring interval to %d.\n",
+			bond->dev->name, bond->params.miimon);
 	}
 
 	/* don't cache arp_validate between modes */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 0ec2a7e..abf5e10 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -523,9 +523,7 @@ static ssize_t bonding_store_arp_interval(struct device *d,
 		ret = -EINVAL;
 		goto out;
 	}
-	if (bond->params.mode == BOND_MODE_ALB ||
-	    bond->params.mode == BOND_MODE_TLB ||
-	    bond->params.mode == BOND_MODE_8023AD) {
+	if (BOND_NO_USES_ARP(bond->params.mode)) {
 		pr_info("%s: ARP monitoring cannot be used with ALB/TLB/802.3ad. Only MII monitoring is supported on %s.\n",
 			bond->dev->name, bond->dev->name);
 		ret = -EINVAL;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ca31286..a9f4f9f 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -35,6 +35,8 @@
 
 #define BOND_MAX_ARP_TARGETS	16
 
+#define BOND_DEFAULT_MIIMON	100
+
 #define IS_UP(dev)					   \
 	      ((((dev)->flags & IFF_UP) == IFF_UP)	&& \
 	       netif_running(dev)			&& \
@@ -55,6 +57,11 @@
 		 ((mode) == BOND_MODE_TLB)          ||	\
 		 ((mode) == BOND_MODE_ALB))
 
+#define BOND_NO_USES_ARP(mode)				\
+		(((mode) == BOND_MODE_8023AD)	||	\
+		 ((mode) == BOND_MODE_TLB)	||	\
+		 ((mode) == BOND_MODE_ALB))
+
 #define TX_QUEUE_OVERRIDE(mode)				\
 			(((mode) == BOND_MODE_ACTIVEBACKUP) ||	\
 			 ((mode) == BOND_MODE_ROUNDROBIN))
-- 
1.8.0
