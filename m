From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH] bonding: set correct tx_queue_len for bond_dev
Date: Tue, 30 Jul 2013 15:20:42 +0800
Message-ID: <51F7694A.1060703@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:36462 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149Ab3G3HVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 03:21:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we set bandwidth on bond_dev with htb, it's not precise.
Because the length of skb_buff queue is bigger than sch->limit
whose value is 0, some packets are dropped.
This leads to bond device can't make full use of the bandwidth
and influence the accuracy.

With htb, sch->limit is set from bond_dev->tx_queue_len which
is initialized to 0 in bond_setup.

To fix this issue, set the bond_dev's tx_queue_len to slave_dev's.

Example:
tc qdisc add dev bond0 root handle 1: htb default 1
tc class add dev bond0 parent 1:0 classid 1:1 htb rate 1Gbit ceil 1Gbit
iperf -c host -t 30 -i 10

With old bonding:
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec   579 MBytes   486 Mbits/sec
[  3] 10.0-20.0 sec   604 MBytes   507 Mbits/sec
[  3] 20.0-30.0 sec   551 MBytes   462 Mbits/sec
[  3]  0.0-30.0 sec  1.69 GBytes   485 Mbits/sec

With new bonding:
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  1.11 GBytes   955 Mbits/sec
[  3] 10.0-20.0 sec  1.11 GBytes   955 Mbits/sec
[  3] 20.0-30.0 sec  1.11 GBytes   955 Mbits/sec
[  3]  0.0-30.0 sec  3.33 GBytes   955 Mbits/sec

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 drivers/net/bonding/bond_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index dbbea0e..2536426 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1860,6 +1860,12 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		goto err_dest_symlinks;
 	}
 
+	if (!bond_dev->tx_queue_len)
+		bond_dev->tx_queue_len = slave_dev->tx_queue_len;
+	else
+		bond_dev->tx_queue_len = min(slave_dev->tx_queue_len,
+				bond_dev->tx_queue_len);
+
 	pr_info("%s: enslaving %s as a%s interface with a%s link.\n",
 		bond_dev->name, slave_dev->name,
 		bond_is_active_slave(new_slave) ? "n active" : " backup",
-- 
1.7.12



.
