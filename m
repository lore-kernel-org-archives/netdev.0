From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 15 Apr 2014 22:47:55 -0400 (EDT)
Message-ID: <20140415.224755.163520246125289648.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix BPF filter validation of netlink attribute accesses, from
   Mathias Kruase.

2) Netfilter conntrack generation seqcount not initialized properly,
   from Andrey Vagin.

3) Fix comparison mask computation on big-endian in nft_cmp_fast(),
   from Patrick McHardy.

4) Properly limit MTU over ipv6, from Eric Dumazet.

5) Fix seccomp system call argument population on 32-bit,
   from Daniel Borkmann.

6) skb_network_protocol() should not use hard-coded ETH_HLEN, instead
   skb->mac_len needs to be used.  From Vlad Yasevich.

7) We have several cases of using socket based communications to
   implement a tunnel.  For example, some tunnels are encapsulations
   over UDP so we use an internal kernel UDP socket to do the
   transmits.

   These tunnels should behave just like other software devices and
   pass the packets on down to the next layer.

   Most importantly we want the top-level socket (f.e. TCP) that
   created the traffic to be charged for the SKB memory.

   However, once you get into the IP output path, we have code that
   assumed that whatever was attached to skb->sk is an IP socket.

   To keep the top-level socket being charged for the SKB memory,
   whilst satisfying the needs of the IP output path, we now pass in
   an explicit 'sk' argument.

   From Eric Dumazet.

8) ping_init_sock() leaks group info, from Xiaoming Wang.

Please pull, thanks a lot.

The following changes since commit 321d03c86732e45f5f33ad0db5b68e2e1364acb9:

  Merge branch 'misc' of git://git.kernel.org/pub/scm/linux/kernel/git/mmarek/kbuild (2014-04-12 18:22:27 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 6f1d7210376727d090e04b8635e6dda4d7eb7b0c:

  cxgb4: use the correct max size for firmware flash (2014-04-15 15:50:02 -0400)

----------------------------------------------------------------
Alexander Aring (2):
      at86rf230: remove check if AVDD settled
      at86rf230: fix __at86rf230_read_subreg function

Alexander Gordeev (1):
      qlcnic: Fix MSI-X initialization code

Amir Vadai (1):
      net/mlx4_core: Defer VF initialization till PF is fully initialized

Andrey Vagin (2):
      netfilter: nf_conntrack: flush net_gre->keymap_list only from gre helper
      netfilter: nf_conntrack: initialize net.ct.generation

Daniel Borkmann (3):
      seccomp: fix populating a0-a5 syscall args in 32-bit x86 BPF
      net: filter: seccomp: fix wrong decoding of BPF_S_ANC_SECCOMP_LD_W
      Revert "net: sctp: Fix a_rwnd/rwnd management to reflect real state of the receiver's buffer"

Daniel J Blueman (1):
      bnx2: Don't build unused suspend/resume functions not enabled

David S. Miller (3):
      Merge branch 'be2net'
      Merge branch 'qlcnic'
      Merge git://git.kernel.org/.../pablo/nf

Eric Dumazet (3):
      ipv6: Limit mtu to 65575 bytes
      ipv4: add a sock pointer to ip_queue_xmit()
      ipv4: add a sock pointer to dst->output() path.

Jean Delvare (1):
      net: cadence: Add architecture dependencies

Jitendra Kalsaria (2):
      qlcnic: Fix PVID configuration on eSwitch port.
      qlcnic: Fix QLogic application/driver interface for virtual NIC configuration

Julian Anastasov (1):
      ipv4: return valid RTA_IIF on ip route get

Kalesh AP (1):
      be2net: Fix invocation of be_close() after be_clear()

Li, Zhen-Hua (1):
      driver/net: cosa driver uses udelay incorrectly

Manish Chopra (1):
      qlcnic: Do not disable SR-IOV when VFs are assigned to VMs

Mathias Krause (1):
      filter: prevent nla extensions to peek beyond the end of the message

Nicolas Dichtel (1):
      ip6_gre: don't allow to remove the fb_tunnel_dev

Patrick McHardy (1):
      netfilter: nf_tables: fix nft_cmp_fast failure on big endian for size < 4

Shahed Shaikh (1):
      qlcnic: Fix max ring count calculation

Steve Wise (2):
      cxgb4: Save the correct mac addr for hw-loopback connections in the L2T
      cxgb4: use the correct max size for firmware flash

Sucheta Chakraborty (2):
      qlcnic: Fix panic due to uninitialzed delayed_work struct in use.
      qlcnic: Fix to send INIT_NIC_FUNC as first mailbox.

Thomas Petazzoni (1):
      Revert "net: mvneta: fix usage as a module on RGMII configurations"

Vasundhara Volam (1):
      be2net: Fix to reap TX compls till HW doesn't respond for some time

Vlad Yasevich (1):
      net: Start with correct mac_len in skb_network_protocol

Wang, Xiaoming (1):
      net: ipv4: current group_info should be put after using.

Wei Yang (1):
      net/mlx4_core: Preserve pci_dev_data after __mlx4_remove_one()

 drivers/net/ethernet/broadcom/bnx2.c                  |   2 +-
 drivers/net/ethernet/cadence/Kconfig                  |   6 +-
 drivers/net/ethernet/chelsio/cxgb4/l2t.c              |   4 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c            |   2 +-
 drivers/net/ethernet/emulex/benet/be.h                |   1 +
 drivers/net/ethernet/emulex/benet/be_main.c           |  17 +++--
 drivers/net/ethernet/marvell/mvneta.c                 |  41 ++++++++++---
 drivers/net/ethernet/mellanox/mlx4/main.c             | 181 +++++++++++++++++++++++++++++++-----------------------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h             |   1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c |  21 ++++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c       |   3 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c       |   2 -
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c      |  33 +++++-----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c  |  10 +++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c     |  31 +++++-----
 drivers/net/ieee802154/at86rf230.c                    |  10 +--
 drivers/net/vxlan.c                                   |   4 +-
 drivers/net/wan/cosa.c                                |   4 --
 include/linux/filter.h                                |   1 -
 include/linux/netfilter/nf_conntrack_proto_gre.h      |   1 -
 include/net/dst.h                                     |  14 ++++-
 include/net/inet6_connection_sock.h                   |   2 +-
 include/net/inet_connection_sock.h                    |   2 +-
 include/net/ip.h                                      |  13 ++--
 include/net/ip6_route.h                               |   5 ++
 include/net/ip_tunnels.h                              |   2 +-
 include/net/ipv6.h                                    |   2 +-
 include/net/netfilter/nf_tables_core.h                |  10 +++
 include/net/sctp/structs.h                            |  14 ++++-
 include/net/xfrm.h                                    |   6 +-
 kernel/seccomp.c                                      |  17 +++--
 net/core/dev.c                                        |   2 +-
 net/core/dst.c                                        |  15 +++--
 net/core/filter.c                                     |   9 ++-
 net/dccp/output.c                                     |   2 +-
 net/decnet/dn_route.c                                 |  16 ++++-
 net/ipv4/ip_output.c                                  |  16 ++---
 net/ipv4/ip_tunnel.c                                  |   2 +-
 net/ipv4/ip_tunnel_core.c                             |   4 +-
 net/ipv4/ping.c                                       |  15 +++--
 net/ipv4/route.c                                      |   6 +-
 net/ipv4/tcp_output.c                                 |   2 +-
 net/ipv4/xfrm4_output.c                               |   2 +-
 net/ipv6/inet6_connection_sock.c                      |   3 +-
 net/ipv6/ip6_gre.c                                    |  10 +++
 net/ipv6/ip6_output.c                                 |   2 +-
 net/ipv6/route.c                                      |  19 +++---
 net/ipv6/sit.c                                        |   5 +-
 net/ipv6/xfrm6_output.c                               |   2 +-
 net/l2tp/l2tp_core.c                                  |   4 +-
 net/l2tp/l2tp_ip.c                                    |   2 +-
 net/netfilter/nf_conntrack_core.c                     |   1 +
 net/netfilter/nf_conntrack_pptp.c                     |  20 +-----
 net/netfilter/nf_conntrack_proto_gre.c                |   3 +-
 net/netfilter/nf_tables_core.c                        |   3 +-
 net/netfilter/nft_cmp.c                               |   2 +-
 net/openvswitch/vport-gre.c                           |   2 +-
 net/sctp/associola.c                                  |  82 ++++++++++++++++++++-----
 net/sctp/protocol.c                                   |   2 +-
 net/sctp/sm_statefuns.c                               |   2 +-
 net/sctp/socket.c                                     |   6 ++
 net/sctp/ulpevent.c                                   |   8 +--
 net/xfrm/xfrm_policy.c                                |   2 +-
 63 files changed, 454 insertions(+), 279 deletions(-)
