From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net] bonding: add ip checks when store ip target
Date: Tue, 12 Nov 2013 19:25:24 +0800
Message-ID: <52821024.6050607@huawei.com>
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
Received: from szxga01-in.huawei.com ([119.145.14.64]:41283 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328Ab3KLL0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 06:26:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I met a Bug when I add ip target with the wrong ip address:

echo +500.500.500.500 > /sys/class/net/bond0/bonding/arp_ip_target

the wrong ip address will transfor to 245.245.245.244 and add
to the ip target success, it is uncorrect, so I add checks to avoid
adding wrong address.

The in4_pton() will set wrong ip address to 0.0.0.0, it will return by
the next check and will not add to ip target.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_sysfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 4838a97..5b7bf37 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -612,7 +612,7 @@ static ssize_t bonding_store_arp_targets(struct device *d,
                return restart_syscall();

        targets = bond->params.arp_targets;
-       newtarget = in_aton(buf + 1);
+       in4_pton(buf + 1, strlen(buf) - 1, (u8 *)&newtarget, -1, NULL);
        /* look for adds */
        if (buf[0] == '+') {
                if ((newtarget == 0) || (newtarget == htonl(INADDR_BROADCAST))) {
--
1.8.2.1
