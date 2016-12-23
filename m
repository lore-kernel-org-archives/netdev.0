From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 23 Dec 2016 14:20:30 -0500 (EST)
Message-ID: <20161223.142030.1841058391180636034.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) We have to be careful to not try and place a checksum after the end
   of a rawv6 packet, fix from Dave Jones with help from Hannes Frederic
   Sowa.

2) Missing memory barriers in tcp_tasklet_func() lead to crashes, from
   Eric Dumazet.

3) Several bug fixes for the new XDP support in virtio_net, from Jason
   Wang.

4) Increase headroom in RX skbs in be2net driver to accomodate
   encapsulations such as geneve.  From Kalesh A P.

5) Fix SKB frag unmapping on TX in mvpp2, from Thomas Petazzoni.

6) Pre-pulling UDP headers created a regression in RECVORIGDSTADDR
   socket option support, from Willem de Bruijn.

7) UID based routing added a potential OOPS in ip_do_redirect() when we
   see an SKB without a socket attached.  We just need it for the network
   namespace which we can get from skb->dev instead.  Fix from Lorenzo
   Colitti.

Please pull, thanks a lot!

The following changes since commit ba6d973f78eb62ffebb32f6ef3334fc9a3b33d22:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-12-20 15:48:34 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 1636098c46ac52c7fec384fe629144e8e03487b1:

  sctp: fix recovering from 0 win with small data chunks (2016-12-23 14:01:35 -0500)

----------------------------------------------------------------
Arend Van Spriel (2):
      brcmfmac: fix memory leak in brcmf_cfg80211_attach()
      brcmfmac: fix uninitialized field in scheduled scan ssid configuration

Ben Greear (1):
      ath10k: free host-mem with DMA_BIRECTIONAL flag

Colin Ian King (1):
      net: fddi: skfp: use %p format specifier for addresses rather than %x

Dave Jones (1):
      ipv6: handle -EFAULT from skb_copy_bits

David S. Miller (4):
      Merge tag 'wireless-drivers-for-davem-2016-12-22' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge branch 'cls_flower-act_tunnel_key-fixes'
      Merge branch 'mlxsw-router-fixes'
      Merge branch 'virtio-net-xdp-fixes'

Eric Dumazet (1):
      tcp: add a missing barrier in tcp_tasklet_func()

Heiko Stübner (1):
      net: ethernet: stmmac: dwmac-rk: make clk enablement first in powerup

Ido Schimmel (3):
      neigh: Send netevent after marking neigh as dead
      mlxsw: spectrum_router: Don't reflect dead neighs
      mlxsw: spectrum_router: Correctly remove nexthop groups

Jason Wang (9):
      virtio-net: remove the warning before XDP linearizing
      virtio-net: correctly xmit linearized page on XDP_TX
      virtio-net: fix page miscount during XDP linearizing
      virtio-net: correctly handle XDP_PASS for linearized packets
      virtio-net: unbreak csumed packets for XDP_PASS
      virtio-net: make rx buf size estimation works for XDP
      virtio-net: forbid XDP when VIRTIO_NET_F_GUEST_UFO is support
      virtio-net: remove big packet XDP codes
      virtio-net: XDP support for small buffers

Kalesh A P (1):
      be2net: Increase skb headroom size to 256 bytes

Larry Finger (1):
      rtlwifi: Fix kernel oops introduced with commit e49656147359

Lorenzo Colitti (1):
      net: ipv4: Don't crash if passing a null sk to ip_do_redirect.

Marcelo Ricardo Leitner (2):
      sctp: do not loose window information if in rwnd_over
      sctp: fix recovering from 0 win with small data chunks

Or Gerlitz (2):
      net/sched: act_tunnel_key: Fix setting UDP dst port in metadata under IPv6
      net/sched: cls_flower: Mandate mask when matching on flags

Thomas Petazzoni (1):
      net: mvpp2: fix dma unmapping of TX buffers for fragments

Tobias Klausmann (1):
      ath9k: do not return early to fix rcu unlocking

Willem de Bruijn (1):
      inet: fix IP(V6)_RECVORIGDSTADDR for udp sockets

jpinto (1):
      stmmac: CSR clock configuration fix

 drivers/net/ethernet/emulex/benet/be.h                      |   2 +-
 drivers/net/ethernet/marvell/mvpp2.c                        |  59 ++++++++++++++++++++++---------------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c       |  13 +++++++---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c              |   8 +++---
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c        |   2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c         |   2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c           |   8 +++---
 drivers/net/fddi/skfp/hwmtm.c                               |  12 ++++-----
 drivers/net/fddi/skfp/pmf.c                                 |   2 +-
 drivers/net/fddi/skfp/smt.c                                 |   2 +-
 drivers/net/virtio_net.c                                    | 172 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---------------------------------------------------
 drivers/net/wireless/ath/ath10k/wmi.c                       |   2 +-
 drivers/net/wireless/ath/ath9k/xmit.c                       |   2 +-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c |   7 ++++--
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/pno.c      |   1 +
 drivers/net/wireless/realtek/rtlwifi/core.c                 |   3 ++-
 net/core/neighbour.c                                        |   1 +
 net/ipv4/ip_sockglue.c                                      |   2 +-
 net/ipv4/route.c                                            |   3 ++-
 net/ipv4/tcp_output.c                                       |   1 +
 net/ipv6/datagram.c                                         |   2 +-
 net/ipv6/raw.c                                              |   6 ++++-
 net/sched/act_tunnel_key.c                                  |   4 +--
 net/sched/cls_flower.c                                      |  23 +++++++++--------
 net/sctp/associola.c                                        |   4 +--
 25 files changed, 197 insertions(+), 146 deletions(-)
