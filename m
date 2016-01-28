From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net v2 0/4] net: add and use rx_nohandler stat counter
Date: Thu, 28 Jan 2016 10:49:44 -0500
Message-ID: <1453996188-29965-1-git-send-email-jarod@redhat.com>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tom Herbert <tom@herbertland.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453489882-57948-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The network core tries to keep track of dropped packets, but some packets
you wouldn't really call dropped, so much as intentionally ignored, under
certain circumstances. One such case is that of bonding and team device
slaves that are currently inactive. Their respective rx_handler functions
return RX_HANDLER_EXACT (the only places in the kernel that return that),
which ends up tracking into the network core's __netif_receive_skb_core()
function's drop path, with no pt_prev set. On a noisy network, this can
result in a very rapidly incrementing rx_dropped counter, not only on the
inactive slave(s), but also on the master device, such as the following:

$ cat /proc/net/dev
Inter-|   Receive                                                |  Transmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
  p7p1: 14783346  140430    0 140428    0     0          0      2040      680       8    0    0    0     0       0          0
  p7p2: 14805198  140648    0    0    0     0          0      2034        0       0    0    0    0     0       0          0
 bond0: 53365248  532798    0 421160    0     0          0    115151     2040      24    0    0    0     0       0          0
    lo:    5420      54    0    0    0     0          0         0     5420      54    0    0    0     0       0          0
  p5p1: 19292195  196197    0 140368    0     0          0     56564      680       8    0    0    0     0       0          0
  p5p2: 19289707  196171    0 140364    0     0          0     56547      680       8    0    0    0     0       0          0
   em3: 20996626  158214    0    0    0     0          0       383        0       0    0    0    0     0       0          0
   em2: 14065122  138462    0    0    0     0          0       310        0       0    0    0    0     0       0          0
   em1: 14063162  138440    0    0    0     0          0       308        0       0    0    0    0     0       0          0
   em4: 21050830  158729    0    0    0     0          0       385    71662     469    0    0    0     0       0          0
   ib0:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0          0

In this scenario, p5p1, p5p2 and p7p1 are all inactive slaves in an
active-backup bond0, and you can see that all three have high drop counts,
with the master bond0 showing a tally of all three.

I know that this was previously discussed some here:

    http://www.spinics.net/lists/netdev/msg226341.html

It seems additional counters never came to fruition, so this is a first
attempt at creating one of them, so that we stop calling these drops,
which for users monitoring rx_dropped, causes great alarm, and renders the
counter much less useful for them.

This adds a sysfs statistics node and makes the counter available via
netlink.

Additionally, I'm not certain if this set qualifies for net, or if it
should be put aside and resubmitted for net-next after 4.5 is put to
bed, but I do have users who consider this an important bugfix.

Jarod Wilson (4):
  net/core: relax BUILD_BUG_ON in netdev_stats_to_stats64
  net: add rx_nohandler stat counter
  team: track sum of rx_nohandler for all slaves
  bond: track sum of rx_nohandler for all slaves

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@mellanox.com>
CC: Daniel Borkmann <daniel@iogearbox.net>
CC: Tom Herbert <tom@herbertland.com>
CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <gospo@cumulusnetworks.com>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>

 drivers/net/bonding/bond_main.c |  1 +
 drivers/net/team/team.c         | 10 +++++++---
 include/linux/if_team.h         |  1 +
 include/linux/netdevice.h       |  3 +++
 include/uapi/linux/if_link.h    |  4 ++++
 net/core/dev.c                  | 19 ++++++++++++++-----
 net/core/net-sysfs.c            |  2 ++
 net/core/rtnetlink.c            |  2 ++
 8 files changed, 34 insertions(+), 8 deletions(-)

-- 
1.8.3.1
