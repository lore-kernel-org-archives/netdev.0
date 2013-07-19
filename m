From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 18 Jul 2013 19:35:09 -0700 (PDT)
Message-ID: <20130718.193509.1259783040844404673.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A couple interesting SKB fragment handling fixes, please the usual
small bits here and there:

1) Fix 64-bit divide build failure on 32-bit platforms in mlx5, from
   Tim Gardner.

2) Get rid of a stupid reimplementation on "%*phC" in our sysfs MAC
   address printing helper.

3) Fix NETIF_F_SG capability advertisement in hyperv driver, if the
   device can't do checksumming offloads then it shouldn't say it can
   do SG either.  From Haiyang Zhang.

4) bgmac needs to depend on PHYLIB, from Hauke Mehrtens.

5) Don't leak DMA mappings on mapping failures, from Neil Horman.

6) We need to reset the transport header of SKBs in ipv4 before we
   attempt to perform early socket demux, just like ipv6 does.  From
   Eric Dumazet.

7) Add missing locking on vxlan device removal, from Stephen
   Hemminger.

8) xen-netfront has to make two passes over an SKB to prepare it for
   transfer.  One pass calculates the number of slots needed, the
   second massages the SKB and fills the slots.  Unfortunately, the
   first pass doesn't calculate the number of slots properly so we can
   end up trying to build a MAX_SKB_FRAGS + 1 SKB which doesn't work
   out so well.  Fix from Jan Beulich with help and discussion with
   several others.

9) Fix a similar problem in tun and macvtap, which have to split up
   scatter-gather elements at PAGE_SIZE boundaries.  Don't do zerocopy
   if it would result in a > MAX_SKB_FRAGS skb.  Fixes from Jason
   Wang.

10) On receive, once we've decoded the VLAN state completely, clear
    skb->vlan_tci.  Otherwise demuxed tunnels underneath can trigger
    the VLAN code again, corrupting the packet.  Fix from Eric
    Dumazet.

Please pull, thanks a lot!

The following changes since commit 47188d39b5deeebf41f87a02af1b3935866364cf:

  Merge tag 'ext4_for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4 (2013-07-14 21:47:51 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 3e3aac497513c669e1c62c71e1d552ea85c1d974:

  vlan: fix a race in egress prio management (2013-07-18 13:07:13 -0700)

----------------------------------------------------------------
Daniel Baluta (1):
      ndisc: bool initializations should use true and false

David S. Miller (1):
      net: Fix sysfs_format_mac() code duplication.

Dragos Foianu (2):
      ethtool: fixed trailing statements in ethtool
      net/irda: fixed style issues in irlan_eth

Eric Dumazet (3):
      ipv4: set transport header earlier
      vlan: mask vlan prio bits
      vlan: fix a race in egress prio management

Haiyang Zhang (1):
      hyperv: Fix the NETIF_F_SG flag setting in netvsc

Hauke Mehrtens (1):
      bgmac: add dependency to phylib

Jan Beulich (1):
      xen-netfront: pull on receive skb may need to happen earlier

Jason Wang (4):
      macvtap: fix the missing ret value of TUNSETQUEUE
      macvtap: do not assume 802.1Q when send vlan packets
      tuntap: do not zerocopy if iov needs more pages than MAX_SKB_FRAGS
      macvtap: do not zerocopy if iov needs more pages than MAX_SKB_FRAGS

Neil Horman (1):
      atl1e: unmap partially mapped skb on dma error and free skb

Paolo Valente (1):
      pkt_sched: sch_qfq: remove a source of high packet delay/jitter

Sarveshwar Bandi (1):
      be2net: Fix to avoid hardware workaround when not needed

Tim Gardner (1):
      mlx5 core: Fix __udivdi3 when compiling for 32 bit arches

stephen hemminger (1):
      vxlan: add necessary locking on device removal

 drivers/net/ethernet/atheros/atl1e/atl1e_main.c   | 24 ++++++++++++++++++-
 drivers/net/ethernet/broadcom/Kconfig             |  1 +
 drivers/net/ethernet/emulex/benet/be_main.c       | 14 +++++++----
 drivers/net/ethernet/mellanox/mlx5/core/debugfs.c |  2 +-
 drivers/net/hyperv/netvsc_drv.c                   |  4 ++--
 drivers/net/macvtap.c                             | 65 ++++++++++++++++++++++++++++++---------------------
 drivers/net/tun.c                                 | 62 ++++++++++++++++++++++++++++++-------------------
 drivers/net/vxlan.c                               |  6 +++++
 drivers/net/xen-netfront.c                        | 31 +++++++++++--------------
 include/linux/if_vlan.h                           |  3 +--
 net/8021q/vlan_core.c                             |  2 +-
 net/8021q/vlan_dev.c                              |  7 ++++++
 net/core/dev.c                                    | 11 +++++++--
 net/core/ethtool.c                                | 30 ++++++++++++++++--------
 net/ethernet/eth.c                                | 21 +----------------
 net/ipv4/ip_input.c                               |  7 +++---
 net/ipv6/ndisc.c                                  |  6 ++---
 net/irda/irlan/irlan_eth.c                        | 31 +++++++++++--------------
 net/sched/sch_qfq.c                               | 85 ++++++++++++++++++++++++++++++++++++++++++++-----------------------
 19 files changed, 248 insertions(+), 164 deletions(-)
