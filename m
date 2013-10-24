From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 0/5] bonding: patchset for rcu use in bonding
Date: Thu, 24 Oct 2013 11:08:35 +0800
Message-ID: <52688F33.30904@huawei.com>
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
Received: from szxga02-in.huawei.com ([119.145.14.65]:37770 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753041Ab3JXDJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 23:09:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

The slave list will add and del by bond_master_upper_dev_link() and bond_upper_dev_unlink(),
which will call call_netdevice_notifiers(), even it is safe to call it in write bond lock now,
but we can't sure that whether it is safe later, because other drivers may deal NETDEV_CHANGEUPPER
in sleep way, so I didn't admit move the bond_upper_dev_unlink() in write bond lock.

now the bond_for_each_slave only protect by rtnl_lock(), maybe use bond_for_each_slave_rcu is a good
way to protect slave list for bond, but as a system slow path, it is no need to transform bond_for_each_slave()
to bond_for_each_slave_rcu() in slow path, so in the patchset, I will remove the unused read bond lock
for monitor function, maybe it is a better way, I will wait to accept any relay for it.

Thanks for the Veaceslav Falico opinion.

v2: add and modify commit for patchset and patch, it will be the first step for the whole patchset.

Ding Tianhong (5):
  bonding: remove bond read lock for bond_mii_monitor()
  bonding: remove bond read lock for bond_alb_monitor()
  bonding: remove bond read lock for bond_loadbalance_arp_mon()
  bonding: remove bond read lock for bond_activebackup_arp_mon()
  bonding: remove bond read lock for bond_3ad_state_machine_handler()

 drivers/net/bonding/bond_3ad.c  |   9 ++--
 drivers/net/bonding/bond_alb.c  |  20 ++------
 drivers/net/bonding/bond_main.c | 100 +++++++++++++---------------------------
 3 files changed, 40 insertions(+), 89 deletions(-)

-- 
1.8.2.1
