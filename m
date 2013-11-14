From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net v2] bonding: add ip checks when store ip target
Date: Thu, 14 Nov 2013 10:35:44 +0800
Message-ID: <52843700.2040509@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:64269 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581Ab3KNCgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 21:36:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I met a Bug when I add ip target with the wrong ip address:

echo +500.500.500.500 > /sys/class/net/bond0/bonding/arp_ip_target

the wrong ip address will transfor to 245.245.245.244 and add
to the ip target success, it is uncorrect, so I add checks to avoid
adding wrong address.

The in4_pton() will set wrong ip address to 0.0.0.0, it will return by
the next check and will not add to ip target.

Thanks for Veaceslav's opinion and make the code more simplify.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_sysfs.c | 19 ++++++-------------
 1 file changed, 6 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 25ef533..8dd34eb 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -611,15 +611,14 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 		return restart_syscall();
 
 	targets = bond->params.arp_targets;
-	newtarget = in_aton(buf + 1);
+	if (!in4_pton(buf + 1, -1, (u8 *)&newtarget, -1, NULL) ||
+			newtarget == 0) {
+		pr_err("%s: invalid ARP target %pI4 specified for addition\n",
+		       bond->dev->name, &newtarget);
+		goto out;
+	}
 	/* look for adds */
 	if (buf[0] == '+') {
-		if ((newtarget == 0) || (newtarget == htonl(INADDR_BROADCAST))) {
-			pr_err("%s: invalid ARP target %pI4 specified for addition\n",
-			       bond->dev->name, &newtarget);
-			goto out;
-		}
-
 		if (bond_get_targets_ip(targets, newtarget) != -1) { /* dup */
 			pr_err("%s: ARP target %pI4 is already present\n",
 			       bond->dev->name, &newtarget);
@@ -642,12 +641,6 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 		targets[ind] = newtarget;
 		write_unlock_bh(&bond->lock);
 	} else if (buf[0] == '-')	{
-		if ((newtarget == 0) || (newtarget == htonl(INADDR_BROADCAST))) {
-			pr_err("%s: invalid ARP target %pI4 specified for removal\n",
-			       bond->dev->name, &newtarget);
-			goto out;
-		}
-
 		ind = bond_get_targets_ip(targets, newtarget);
 		if (ind == -1) {
 			pr_err("%s: unable to remove nonexistent ARP target %pI4.\n",
-- 
1.7.12
