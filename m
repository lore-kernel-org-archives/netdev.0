From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 0/7] bonding: get rid of bond->lock
Date: Tue,  9 Sep 2014 23:16:56 +0200
Message-ID: <1410297423-26624-1-git-send-email-nikolay@redhat.com>
Cc: hariprasad@chelsio.com, vfalico@gmail.com, j.vosburgh@gmail.com,
	andy@greyhouse.net, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48789 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751220AbaIIVRR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2014 17:17:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
This patch-set removes the last users of bond->lock and converts the places
that needed it for sync to use curr_slave_lock or RCU as appropriate.
I've run this with lockdep and have stress-tested it via loading/unloading
and enslaving/releasing in parallel while outputting bond's proc, I didn't
see any issues. Please pay special attention to the procfs change, I've
done about an hour of stress-testing on it and have checked that the event
that causes the bonding to delete its proc entry (NETDEV_UNREGISTER) is
called before ndo_uninit() and the freeing of the dev so any readers will
sync with that. Also ran sparse checks and there were no splats.

v2: Add patch 0001/cxgb4 bond->lock removal, RTNL should be held in the
    notifier call, the other patches are the same. Also tested with
    allmodconfig to make sure there're no more users of bond->lock.
Changes from the RFC:
 use RCU in procfs instead of RTNL since RTNL might lead to a deadlock with
 unloading and also is much slower. The bond destruction syncs with proc
 via the proc locks. There's one new patch that converts primary_slave to
 use RCU as it was necessary to fix a longstanding bugs in sysfs and
 procfs and to make it easy to migrate bond's procfs to RCU. And of course
 rebased on top of net-next current.

This is the first patch-set in a series that should simplify the bond's
locking requirements and will make it easier to define the locking
conditions necessary for the various paths. The goal is to rely on RTNL
and rcu alone, an extra lock would be needed in a few special cases that
would be documented very well.

Best regards,
 Nikolay Aleksandrov


Nikolay Aleksandrov (7):
  cxgb4: remove bond->lock
  bonding: 3ad: use curr_slave_lock instead of bond->lock
  bonding: alb: clean bond->lock
  bonding: convert primary_slave to use RCU
  bonding: procfs: clean bond->lock usage and use RCU
  bonding: options: remove bond->lock usage
  bonding: remove last users of bond->lock and bond->lock itself

 drivers/net/bonding/bond_3ad.c                  |  9 ++-
 drivers/net/bonding/bond_alb.c                  | 11 +--
 drivers/net/bonding/bond_main.c                 | 93 ++++++++-----------------
 drivers/net/bonding/bond_netlink.c              |  7 +-
 drivers/net/bonding/bond_options.c              | 27 ++-----
 drivers/net/bonding/bond_procfs.c               | 24 ++-----
 drivers/net/bonding/bond_sysfs.c                | 10 ++-
 drivers/net/bonding/bonding.h                   | 10 +--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  2 -
 9 files changed, 62 insertions(+), 131 deletions(-)

-- 
1.9.3
