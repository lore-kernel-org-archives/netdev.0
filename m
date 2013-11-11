From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v3 0/10] bonding: rebuild the lock use for bond monitor
Date: Mon, 11 Nov 2013 20:36:04 +0800
Message-ID: <5280CF34.20703@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:55068 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753314Ab3KKMgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 07:36:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now the bond slave list is not protected by bond lock, only by RTNL,
but the monitor still use the bond lock to protect the slave list,
it is useless, according to the Veaceslav's opinion, there were
three way to fix the protect problem:

1. add bond_master_upper_dev_link() and bond_upper_dev_unlink()
   in bond->lock, but it is unsafe to call call_netdevice_notifiers()
   in write lock.
2. remove unused bond->lock for monitor function, only use the exist
   rtnl lock(), it will take performance loss in fast path.
3. use RCU to protect the slave list, of course, performance is better,
   but in slow path, it is ignored.

obviously the solution 1 is not fit here, I will consider the 2 and 3
solution. My principle is simple, if in fast path, RCU is better,
otherwise in slow path, both is well, but according to the Jay Vosburgh's
opinion, the monitor will loss performace if use RTNL to protect the all
slave list, so remove the bond lock and replace with RCU.

The second problem is the curr_slave_lock for bond, it is too old and
unwanted in many place, because the curr_active_slave would only be
changed in 3 place:

1. enslave slave.
2. release slave.
3. change active slave.

all above were already holding bond lock, RTNL and curr_slave_lock
together, it is tedious and no need to add so mach lock, when change
the curr_active_slave, you have to hold the RTNL and curr_slave_lock
together, and when you read the curr_active_slave, RTNL or curr_slave_lock,
any one of them is no problem.

for the stability, I did not change the logic for the monitor,
all change is clear and simple, I have test the patch set for lockdep,
it work well and stability.

v2. accept the Jay Vosburgh's opinion, remove the RTNL and replace with RCU,
    also add some rcu function for bond use, so the patch set reach 10.

v3. accept the Nikolay Aleksandrov's opinion, remove no needed bond_has_slave_rcu(),
    add protection for several 3ad mode handler functions and current_arp_slave.
    rebuild the bond_first_slave_rcu(), make it more clear.

Best Regards
Ding Tianhong

Ding Tianhong (10):
  bonding: remove the no effect lock for bond_select_active_slave()
  bonding: rebuild the lock use for bond_mii_monitor()
  bonding: rebuild the lock use for bond_alb_monitor()
  bonding: rebuild the lock use for bond_loadbalance_arp_mon()
  bonding: create bond_first_slave_rcu()
  bonding: rebuild the lock use for bond_activebackup_arp_mon()
  bonding: rebuild the lock use for bond_3ad_state_machine_handler()
  bonding: remove unwanted lock for bond_option_active_slave_set()
  bonding: remove unwanted lock for bond enslave and release
  bonding: remove unwanted lock for bond_store_primaryxxx()

 drivers/net/bonding/bond_3ad.c     |  53 +++++++------
 drivers/net/bonding/bond_alb.c     |  34 +++------
 drivers/net/bonding/bond_main.c    | 147 ++++++++++++++++---------------------
 drivers/net/bonding/bond_options.c |   2 -
 drivers/net/bonding/bond_sysfs.c   |   4 -
 drivers/net/bonding/bonding.h      |   9 +++
 include/linux/netdevice.h          |  16 ++++
 net/core/dev.c                     |  16 ----
 8 files changed, 132 insertions(+), 149 deletions(-)

--
1.8.2.1
