From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 28 May 2010 04:07:39 -0700 (PDT)
Message-ID: <20100528.040739.212703844.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Several fixes including the one for the bootup failure Ingo reported
yesterday:

1) Network cgroup needs to initialize classid properly when module
   is absent, fix from Herbert Xu.

2) GRO packets unconditionally dropped in ipv6 forwarding path, oops,
   also from Herbert Xu.

3) {un,}lock_sock_bh() is busted, it needs to properly arbitrate
   between user context lockers and async ones.  From Eric Dumazet.

   Fixes sk->sk_forward_alloc WARN_ON() reported by Anton Blanchard.

4) When __neigh_event_send() does __skb_queue_tail() it needs to force
   a reference to the skb->dst using skb_dst_force().  Fix from Eric
   Dumazet.

   Fixes a bootup failure reported by Ingo Molnar.

5) Several "if (x == NULL) x->foo" style NULL deref fixes from Julia
   Lawall.

6) Broadcom CNIC driver memory context init fix from Michael Chan.

7) FEC driver hangs on interface down because of improper PHY
   programming, fix from Bryan Wu.

8) Two vf_port/vfinfo netlink bug fixes from Scott Feldman:
   a) vf_port dump overruns netlink SKBs
   b) vfinfo blobs are sized incorrectly

9) Increase be2net POST timeout for EEH recovery, from Sathya Perla.

10) be2net ended up with the erroneous:

	while (...) {
	} while (...);

    after some recent changes, fix.  From Sarveshwar Bandi.

11) Array index limit check in __ip{,6}mr_fill_mroute() is off by one,
    fix from Dan Carpenter.

12) ll_temac fixes (interrupt validity fix, checksum offloading bugs)
    from Brian Hill.

13) IUCV protocol fails to release spinlock on memory allocation
    failure, from Julia Lawall.

14) VHOST fixes via Michael S. Tsirkin:
    a) vhost_set_ring index check is off by one, from Krishna Kumar.
    b) VHOST makes user copy return value checks wrongly, from Takuya Yoshikawa.
    c) leak on memory_access_ok() failure, also from Takuya Yoshikawa.

15) New netfilter xt_tee module needs to use skb_dst_drop() instead of
    the now verbotten dst_release(skb_dst(skb)).  From Eric Dumazet.

Please pull, thanks a lot!

The following changes since commit 63a6440326e4cd01d6a663069208a0e68e9b833f:
  Linus Torvalds (1):
        Merge git://git.kernel.org/.../pkl/squashfs-linus

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Brian Hill (2):
      net: ll_temac: fix interrupt bug when interrupt 0 is used
      net: ll_temac: fix checksum offload logic

Bryan Wu (1):
      netdev/fec: fix ifconfig eth0 down hang issue

Dan Carpenter (2):
      ipmr: off by one in __ipmr_fill_mroute()
      sctp: dubious bitfields in sctp_transport

Eric Dumazet (3):
      net: fix lock_sock_bh/unlock_sock_bh
      net: fix __neigh_event_send()
      xt_tee: use skb_dst_drop()

Herbert Xu (2):
      cls_cgroup: Initialise classid when module is absent
      ipv6: Add GSO support on forwarding path

Julia Lawall (3):
      net/iucv: Add missing spin_unlock
      drivers/net/hamradio: Eliminate a NULL pointer dereference
      drivers/net: Eliminate a NULL pointer dereference

Krishna Kumar (1):
      vhost: Fix host panic if ioctl called with wrong index

Michael Chan (1):
      cnic: Fix context memory init. on 5709.

Sarveshwar Bandi (1):
      be2net: Patch removes redundant while statement in loop.

Sathya Perla (1):
      be2net: increase POST timeout for EEH recovery

Scott Feldman (2):
      netlink: bug fix: don't overrun skbs on vf_port dump
      netlink: bug fix: wrong size was calculated for vfinfo list blob

Takuya Yoshikawa (3):
      vhost: fix to check the return value of copy_to/from_user() correctly
      vhost-net: fix to check the return value of copy_to/from_user() correctly
      vhost: fix the memory leak which will happen when memory_access_ok fails

 drivers/net/3c507.c         |    3 +-
 drivers/net/benet/be_cmds.c |    2 +-
 drivers/net/benet/be_main.c |    2 +-
 drivers/net/cnic.c          |   10 ++----
 drivers/net/cnic_if.h       |    4 +-
 drivers/net/fec.c           |   28 ++++++++------
 drivers/net/hamradio/yam.c  |    3 +-
 drivers/net/ll_temac.h      |    5 +++
 drivers/net/ll_temac_main.c |   84 ++++++++++++++++++++++++++++++-------------
 drivers/vhost/net.c         |   14 ++++----
 drivers/vhost/vhost.c       |   57 ++++++++++++++++-------------
 include/net/cls_cgroup.h    |    2 +-
 include/net/sctp/structs.h  |    2 +-
 include/net/sock.h          |   20 +++++++---
 net/core/datagram.c         |    6 ++-
 net/core/neighbour.c        |    1 +
 net/core/rtnetlink.c        |   26 ++++++++------
 net/core/sock.c             |   33 +++++++++++++++++
 net/ipv4/ipmr.c             |    2 +-
 net/ipv4/udp.c              |   14 ++++---
 net/ipv6/ip6_output.c       |    2 +-
 net/ipv6/ip6mr.c            |    2 +-
 net/ipv6/udp.c              |    5 ++-
 net/iucv/af_iucv.c          |    2 +-
 net/netfilter/xt_TEE.c      |    4 +-
 25 files changed, 214 insertions(+), 119 deletions(-)
