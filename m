From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 0/9] bonding: rebuild the lock use for bond monitor
Date: Wed, 6 Nov 2013 14:52:32 +0800
Message-ID: <5279E730.1080200@huawei.com>
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
Received: from szxga02-in.huawei.com ([119.145.14.65]:58821 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084Ab3KFGxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 01:53:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now the bond slave list is not protected by bond lock, only by RTNL,
but the monitor still use the bond lock to protect the slave list,
it is useless, there were three way to fix the protect problem:

1. add bond_master_upper_dev_link() and bond_upper_dev_unlink()
   in bond->lock, but it is unsafe to call call_netdevice_notifiers()
   in write lock.
2. remove unused bond->lock for monitor function, only use the exist
   rtnl lock(), it will take performance loss in fast path.
3. use RCU to protect the slave list, of course, performance is better,
   but in slow path, it is ignored.

obviously the solution 1 is not fit here, I will consider the 2 and 3
solution. My principle is simple, if in fast path, RCU is better,
otherwise in slow path, both is well, if RTNL is necessary for other
reason, no need to add RCU, if the RTNL is only used for slave list,
I will use RCU to instead of RTNL for performance.

the second problem is the curr_slave_lock for bond, it is too old and
unwanted in many place, because the curr_active_slave would only be
changed in 3 place:

1. enslave slave.
2. release slave.
3. change active slave.

all above were already holding bond lock, RTNL and curr_slave_lock
together, it is tedious and no need to add so mach lock, the RTNL 
is enough, when the other cpu to read the curr_active_slave
for parallel, RTNL or RCU is both well for it, so after the patch set,
I will recheck the curr_slave_lock and determane what to do for it,
this time, only for monitor work well.

for the stability, I did not change the logic for the monitor,
all change is clear and simple, I have test the patch set for lockdep,
it work well and stability.

Best Regards
Ding Tianhong

Ding Tianhong (9):
  bonding: remove the no effect lock for bond_select_active_slave()
  bonding: rebuild the lock use for bond_mii_monitor()
  bonding: rebuild the lock use for bond_alb_monitor()
  bonding: rebuild the lock use for bond_loadbalance_arp_mon()
  bonding: rebuild the lock use for bond_activebackup_arp_mon()
  bonding: use RTNL instead of bond lock for
    bond_3ad_state_machine_handler()
  bonding: remove unwanted lock for bond_option_active_slave_set()
  bonding: remove unwanted lock for bond enslave and release
  bonding: remove unwanted lock for bond_store_primary_xxx()

 drivers/net/bonding/bond_3ad.c     |  15 ++--
 drivers/net/bonding/bond_alb.c     |  55 +++----------
 drivers/net/bonding/bond_main.c    | 160 +++++++++----------------------------
 drivers/net/bonding/bond_options.c |   4 -
 drivers/net/bonding/bond_sysfs.c   |   8 --
 5 files changed, 53 insertions(+), 189 deletions(-)

-- 
1.8.2.1
