From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 14 Jul 2009 12:27:04 -0700 (PDT)
Message-ID: <20090714.122704.21107059.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756074AbZGNT1D@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) When Stephen Hemminger and others converted all of our net drivers
   to netdev_ops, some methods for setting MTU and the MAC address
   got lost in ethernet drivers.  This was an oversight and a regression,
   and Ben Hutchings did a complete audit and fixed up all of the
   cases where this happened.

   I did a bunch of builds to try and make sure this is clean and
   won't hiccup the build even by accident.

2) GRE tunnel misinterprets ECN bits as a tunnel configuration setting.
   Fix from Andreas Jaggi.

3) Two socket crash regression fixes from Eric Dumazet.

   a) The RCU hash table changes don't work properly if the socket
      allocation code just writes the socket refcnt explicitly to
      some value, we have to use inc/dec just like other transient
      references to that RCU freed memory might be doing.

    b) The socket refcount increment/decrement abatement changes made
       in the merge window forgot to remove two stray sock_put() operations
       in ip_push_pending_frames() and friends.

3) skb->dst cannot be released before transmit in SIT driver, regression
   fixes by Sascha Hlusiak.

4) phy_device code forgets to release mutex in error path, from
   Jiri Slaby.

5) atlx driver tests MCAST flag twice, it means to test the UCAST
   flag instead.  Fix from Roel Kluin.

6) NET_IP_ALIGN comment fixup from Tobias Klauser.

7) IGB driver doesn't build with gcc-3.4.x, due to inline functions
   being called before their definition.  Fix from Eric Dumazet.

8) Locking fix in TTY based networking drivers, from Ralf Baechle.

The regression count for networking seems pretty low at this point,
although there appears to be a few naggling wireless driver issues
to sort out still.  Hopefully John Linville and co. can sort those
out soon.

Please pull, thanks a lot!

The following changes since commit 6847e154e3cd74fca6084124c097980a7634285a:
  Linus Torvalds (1):
        Linux 2.6.31-rc3

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Andreas Jaggi (1):
      gre: fix ToS/DiffServ inherit bug

Ben Hutchings (2):
      netdev: restore MAC address set and validate operations
      netdev: restore MTU change operation

Dongdong Deng (1):
      drivers/net: using spin_lock_irqsave() in net_send_packet()

Eric Dumazet (3):
      net: sk_prot_alloc() should not blindly overwrite memory
      net: ip_push_pending_frames() fix
      igb: gcc-3.4.6 fix

Jiri Slaby (1):
      NET: phy_device, fix lock imbalance

Ralf Baechle (1):
      NET: Fix locking issues in PPP, 6pack, mkiss and strip line disciplines.

Sascha Hlusiak (1):
      sit: fix regression: do not release skb->dst before xmit

Tobias Klauser (1):
      skbuff.h: Fix comment for NET_IP_ALIGN

roel kluin (1):
      atlx: duplicate testing of MCAST flag

 drivers/net/8139too.c               |    1 +
 drivers/net/arm/ixp4xx_eth.c        |    4 +-
 drivers/net/atlx/atl2.c             |    2 +-
 drivers/net/cs89x0.c                |    7 ++-
 drivers/net/ehea/ehea_main.c        |    2 +
 drivers/net/fec.c                   |    1 +
 drivers/net/gianfar.c               |    2 +
 drivers/net/hamradio/6pack.c        |   10 +++--
 drivers/net/hamradio/mkiss.c        |   41 +++++++++++--------
 drivers/net/igb/igb_main.c          |   77 +++++++++++++++++------------------
 drivers/net/isa-skeleton.c          |    5 +-
 drivers/net/phy/phy_device.c        |    4 +-
 drivers/net/plip.c                  |    3 +
 drivers/net/ppp_async.c             |   11 +++--
 drivers/net/ppp_synctty.c           |   11 +++--
 drivers/net/ps3_gelic_net.c         |    1 +
 drivers/net/ps3_gelic_wireless.c    |    1 +
 drivers/net/smc91x.c                |    1 +
 drivers/net/smsc911x.c              |    1 +
 drivers/net/sunvnet.c               |    2 +
 drivers/net/usb/kaweth.c            |    3 +
 drivers/net/usb/pegasus.c           |    3 +
 drivers/net/via-rhine.c             |    1 +
 drivers/net/wireless/orinoco/main.c |    3 +-
 drivers/net/wireless/strip.c        |   39 +++++++++++-------
 include/linux/skbuff.h              |    4 +-
 net/core/sock.c                     |   19 ++++++++-
 net/ipv4/ip_gre.c                   |    4 +-
 net/ipv4/ip_output.c                |    1 -
 net/ipv6/ip6_output.c               |    1 -
 net/ipv6/sit.c                      |    1 +
 31 files changed, 165 insertions(+), 101 deletions(-)
