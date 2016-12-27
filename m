From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 27 Dec 2016 14:43:35 -0500 (EST)
Message-ID: <20161227.144335.114294403942295276.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46754 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932375AbcL0Tns (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 14:43:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Various ipvlan fixes from Eric Dumazet and Mahesh Bandewar.  The most
   important is to not assume the packet is RX just because the destination
   address matches that of the device.  Such an assumption causes problems
   when an interface is put into loopback mode.

2) If we retry when creating a new tc entry (because we dropped the
   RTNL mutex in order to load a module, for example) we end up with
   -EAGAIN and then loop trying to replay the request.  Problem is we
   didn't reset some state when looping back to the top like this, and
   if another thread meanwhile inserted the same tc entry we were
   trying to, we re-link it creating an enless loop in the tc chain.
   Fix from Daniel Borkmann.

3) There are two different WRITE bits in the MDIO address register for
   the stmmac chip, depending upon the chip variant.  Due to a bug we
   could set them both, fix from Hock Leong Kweh.

4) Fix mlx4 bug in XDP_TX handling, from Tariq Toukan.

Please pull, thanks a lot!

The following changes since commit 50b17cfb1917b207612327d354e9043dbcbde431:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-12-23 11:23:25 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 5799fc905930f866c7d32aaf81b31f8027297506:

  net: stmmac: fix incorrect bit set in gmac4 mdio addr register (2016-12-27 12:28:08 -0500)

----------------------------------------------------------------
Chun-Hao Lin (1):
      r8169: add support for RTL8168 series add-on card.

Daniel Borkmann (1):
      net, sched: fix soft lockup in tc_classify

Eric Dumazet (1):
      ipvlan: fix various issues in ipvlan_process_multicast()

Florian Fainelli (1):
      net: korina: Fix NAPI versus resources freeing

Haishuang Yan (1):
      ipv4: Namespaceify tcp_tw_reuse knob

Jason Wang (1):
      net: xdp: remove unused bfp_warn_invalid_xdp_buffer()

Jon Paul Maloy (1):
      tipc: don't send FIN message from connectionless socket

Kweh, Hock Leong (1):
      net: stmmac: fix incorrect bit set in gmac4 mdio addr register

Mahesh Bandewar (1):
      ipvlan: fix multicast processing

Tariq Toukan (1):
      net/mlx4_en: Fix user prio field in XDP forward

pravin shelar (1):
      openvswitch: upcall: Fix vlan handling.

 drivers/net/ethernet/korina.c                     |  8 ++++----
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |  3 ++-
 drivers/net/ethernet/realtek/r8169.c              |  1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |  4 +++-
 drivers/net/ipvlan/ipvlan.h                       |  5 +++++
 drivers/net/ipvlan/ipvlan_core.c                  | 60 ++++++++++++++++++++++++++++++++++++++----------------------
 drivers/net/ipvlan/ipvlan_main.c                  |  7 ++++++-
 include/linux/filter.h                            |  1 -
 include/net/netns/ipv4.h                          |  1 +
 include/net/tcp.h                                 |  1 -
 net/core/filter.c                                 |  6 ------
 net/ipv4/sysctl_net_ipv4.c                        | 14 +++++++-------
 net/ipv4/tcp_ipv4.c                               |  4 ++--
 net/openvswitch/datapath.c                        |  1 -
 net/openvswitch/flow.c                            | 54 +++++++++++++++++++++++++++---------------------------
 net/sched/cls_api.c                               |  4 +++-
 net/tipc/socket.c                                 | 24 +++++++++++++-----------
 17 files changed, 112 insertions(+), 86 deletions(-)
