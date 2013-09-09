From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 0/26] bonding: use neighbours instead of own lists
Date: Mon,  9 Sep 2013 22:16:18 +0200
Message-ID: <1378757804-3159-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Dimitris Michailidis <dm@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64633 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755943Ab3IIUQg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Sep 2013 16:16:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(David, feel free to drop the whole patchset - I know that the window is
closed and I'm quite sure that it's not the last version, and even if it is
- I'll easily re-submit it. Sorry for the mess :-/)

Hi,

RFC -> v1:
I've added proper, consistent naming for all variables/functions, uninlined
some helpers to get better backtraces, just in case (overhead is minimal,
no hot paths), rearranged patches for better review, dropped bondings
->prev and bond_for_each_slave_continue() functionality - to be able to
RCUify it easier, and renamed slave_* sysfs links to lower_* sysfs links to
maintain upper/lower naming. I've also dropped, thanks to bonding cleanup,
some heavy and ugly/intrusive patches.

I'm sending it as early as possible, because it's quite a big patchset and
some of the approaches I've chosen are not really easy/straightforward.
It's, however, quite heavily tested already and works fine.

I'm sending it to gather any feedback possible.

This patchset introduces all the needed infrastructure, on top of current
adjacent lists, to be able to remove bond's slave_list/slave->list. The
overhead in memory/CPU is minimal, and after the patchset bonding can rely
on its slave-related functions, given the proper locking. I've done some
netperf benchmarks on a vm, and the delta was about 0.1gbps for 35gbps as a
whole, so no speed fluctuations.

It also automatically creates lower/upper and master symlinks in dev's
sysfs directory.

The current version works ok, as first tests have shown. I'm testing it
further, if anything comes up - I'll update.

Here is a short description of each (group):

51317ce net: add adj_list to save only neighbours
417ade0 net: add RCU variant to search for netdev_adjacent link
1f6ae72 net: uninline netdev neighbour functions
6b80fc6 net: add netdev_adjacent->private and allow to use it
		Preparations to be able to use the new lists.

7e83095 bonding: populate neighbour's private on enslave
		Make bonding set ->private on enslave.

21fdd60 bonding: modify bond_get_slave_by_dev() to use neighbours
		First use of ->private.

5d2fcb1 net: add for_each iterators through neighbour lower link's private
		Creates the standard for_each macro of 'slaves'.

315572a bonding: remove bond_for_each_slave_reverse()
		Drop the useless (and heavy to modify) macro.

4bf68d6 bonding: make bond_for_each_slave() use lower neighbour's private
		Modify the main iterator.

063b9f6 bonding: use bond_for_each_slave() in bond_uninit()
		Small cleanup - to avoid using the slave_list directly.

13368ec bonding: rework bond_3ad_xmit_xor() to use bond_for_each_slave() only
2c89a38 bonding: rework rlb_next_rx_slave() to use bond_for_each_slave()
6f3049b bonding: rework bond_find_best_slave() to use bond_for_each_slave()
d0b1930 bonding: rework bond_ab_arp_probe() to use bond_for_each_slave()
29aac7d bonding: remove unused bond_for_each_slave_from()
		Remove bond_for_each_slave_from() - it's almost impossible
		to correctly use it under RCU - and it's not really needed
		- some functions even become cleaner and some small bugs
		fixed.

17fd9e8 bonding: add bond_has_slaves() and use it
98d90f5 bonding: convert bond_has_slaves() to use the neighbour list
		Convert list emptiness checking to use neighbour list.

c6df10c net: add a possibility to get private from netdev_adjacent->list
5bdebae bonding: convert first/last slave logic to use neighbours
		Start using ->private directly for first/last slaves.

231db0b bonding: remove bond_prev_slave()
		Cleanup - easier to RCUify in the future.

3a32d8d net: add a function to get the next private
0a275bf bonding: use neighbours for bond_next_slave()
		Convert next_slave() to use neighbours.

0a39ab2 bonding: remove slave lists
		Finally.

ea3f071 net: expose the master link to sysfs, and remove it from bond
71cc99e vlan: link the upper neighbour only after registering
ecc2a4c net: create sysfs symlinks for neighbour devices
		Create sysfs links.

Thanks in advance.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: Dimitris Michailidis <dm@chelsio.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Patrick McHardy <kaber@trash.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

---
 drivers/net/bonding/bond_3ad.c                  |  54 +--
 drivers/net/bonding/bond_alb.c                  |  81 +++--
 drivers/net/bonding/bond_alb.h                  |   4 +-
 drivers/net/bonding/bond_main.c                 | 296 +++++++--------
 drivers/net/bonding/bond_procfs.c               |   5 +-
 drivers/net/bonding/bond_sysfs.c                |  62 +---
 drivers/net/bonding/bonding.h                   |  74 ++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   3 +-
 include/linux/netdevice.h                       |  57 ++-
 net/8021q/vlan.c                                |  14 +-
 net/core/dev.c                                  | 458 +++++++++++++++++++-----
 11 files changed, 703 insertions(+), 405 deletions(-)
