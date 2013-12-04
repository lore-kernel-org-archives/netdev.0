From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net] bonding: add arp_ip_target checks when install the module
Date: Wed, 4 Dec 2013 18:59:31 +0800
Message-ID: <529F0B13.4050600@huawei.com>
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
Received: from szxga03-in.huawei.com ([119.145.14.66]:60668 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932071Ab3LDLAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 06:00:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I install the bonding with the wrong arp_ip_target,
just like arp_ip_target=500.500.500.500, the arp_ip_target
was transfored to 245.245.245.244 and stored in the ip
target success, it is uncorrect, so I add checks to avoid
adding wrong address.

The in4_pton() will set wrong ip address to 0.0.0.0 and
return 0, also use the micro IS_IP_TARGET_UNUSABLE_ADDRESS
to simplify the code.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a141f40..a48cfbb 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4157,9 +4157,9 @@ static int bond_check_params(struct bond_params *params)
 	     (arp_ip_count < BOND_MAX_ARP_TARGETS) && arp_ip_target[i]; i++) {
 		/* not complete check, but should be good enough to
 		   catch mistakes */
-		__be32 ip = in_aton(arp_ip_target[i]);
-		if (!isdigit(arp_ip_target[i][0]) || ip == 0 ||
-		    ip == htonl(INADDR_BROADCAST)) {
+		__be32 ip;
+		if (!in4_pton(arp_ip_target[i], -1, (u8 *)&ip, -1, NULL) ||
+		    IS_IP_TARGET_UNUSABLE_ADDRESS(ip)) {
 			pr_warning("Warning: bad arp_ip_target module parameter (%s), ARP monitoring will not be performed\n",
 				   arp_ip_target[i]);
 			arp_interval = 0;
-- 
1.7.12
