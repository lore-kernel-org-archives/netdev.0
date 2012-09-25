From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 25 Sep 2012 17:07:30 -0400 (EDT)
Message-ID: <20120925.170730.2111864347678863617.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Eric Dumazet discovered and fixed what turned out to be a family of
   bugs.  These functions were using pskb_may_pull() which might need
   to reallocate the linear SKB data buffer, but the callers were not
   expecting this possibility.  The callers have cached pointers to
   the packet header areas, and would need to reload them if we were
   to continue using pskb_may_pull().

   So they could end up reading garbage.

   It's easier to just change these RAW4/RAW6/MIP6 routines to use
   skb_header_pointer() instead of pskb_may_pull(), which won't
   modify the linear SKB data area.

2) Dave Jone's syscall spammer caught a case where a non-TCP socket
   can call down into the TCP keepalive code.  The case basically
   involves creating a raw socket with sk_protocol =3D=3D IPPROTO_TCP,
   then calling setsockopt(sock_fd, SO_KEEPALIVE, ...)

   Fixed by Eric Dumazet.

3) Bluetooth devices do not get configured properly while being
   powered on, resulting in always using legacy pairing instead
   of SSP.  Fix from Andrzej Kaczmarek.

4) Bluetooth cancels delayed work erroneously, put stricter
   checks in place.  From Andrei Emeltchenko.

5) Fix deadlock between cfg80211_mutex and reg_regdb_search_mutex
   in cfg80211, from Luis R. Rodriguez.

6) Fix interrupt double release in iwlwifi, from Emmanuel Grumbach.

7) Missing module license in bcm87xx driver, from Peter Huewe.

8) Team driver can lose port changed events when adding devices to a
   team, fix from Jiri Pirko.

9) Fix endless loop when trying ot unregister PPPOE device in
   zombie state, from Xiaodong Xu.

10) batman-adv layer needs to set MAC address of software device
    earlier, otherwise we call tt_local_add with it uninitialized.

11) Fix handling of KSZ8021 PHYs, it's matched currently by KS8051
    but that doesn't program the device properly.  From Marek
    Vasut.

Please pull, thanks a lot!

The following changes since commit abef3bd71029b80ec1bdd6c6244b5b0b99f5=
6633:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2012-0=
9-21 14:32:55 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 96af69ea2a83d292238bdba20e4508ee967cf8cb=
:

  ipv6: mip6: fix mip6_mh_filter() (2012-09-25 16:04:44 -0400)

----------------------------------------------------------------
Andrei Emeltchenko (1):
      Bluetooth: Fix freeing uninitialized delayed works

Andrzej Kaczmarek (2):
      Bluetooth: mgmt: Fix enabling SSP while powered off
      Bluetooth: mgmt: Fix enabling LE while powered off

David S. Miller (2):
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/l=
inux-merge

Def (1):
      batman-adv: Fix change mac address of soft iface.

Emmanuel Grumbach (1):
      iwlwifi: don't double free the interrupt in failure path

Eric Dumazet (4):
      ipv4: raw: fix icmp_filter()
      net: guard tcp_set_keepalive() to tcp sockets
      ipv6: raw: fix icmpv6_filter()
      ipv6: mip6: fix mip6_mh_filter()

Jiri Pirko (1):
      team: send port changed when added

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Linus L=FCssing (1):
      batman-adv: Fix symmetry check / route flapping in multi interfac=
e setups

Luis R. Rodriguez (1):
      cfg80211: fix possible circular lock on reg_regdb_search()

Marek Vasut (3):
      phy/micrel: Implement support for KSZ8021
      phy/micrel: Rename KS80xx to KSZ80xx
      phy/micrel: Add missing header to micrel_phy.h

Peter H=FCwe (1):
      net/phy/bcm87xx: Add MODULE_LICENSE("GPL") to GPL driver

Vinicius Costa Gomes (1):
      Bluetooth: Fix not removing power_off delayed work

Xiaodong Xu (1):
      pppoe: drop PPPOX_ZOMBIEs in pppoe_release

 arch/arm/mach-mxs/mach-mxs.c              |  2 +-
 drivers/net/phy/bcm87xx.c                 |  2 ++
 drivers/net/phy/micrel.c                  | 45 +++++++++++++++++++++++=
+++++++++++++---------
 drivers/net/ppp/pppoe.c                   |  2 +-
 drivers/net/team/team.c                   | 32 +++++++++++++++++++++++=
+--------
 drivers/net/wireless/iwlwifi/pcie/trans.c |  1 +
 include/linux/micrel_phy.h                | 19 ++++++++++++++++---
 net/batman-adv/bat_iv_ogm.c               | 13 +++++++------
 net/batman-adv/soft-interface.c           |  7 +++++--
 net/bluetooth/hci_core.c                  |  2 ++
 net/bluetooth/l2cap_core.c                |  2 +-
 net/bluetooth/mgmt.c                      | 16 ++++++++++++++++
 net/core/sock.c                           |  3 ++-
 net/ipv4/raw.c                            | 14 ++++++++------
 net/ipv6/mip6.c                           | 20 +++++++++++---------
 net/ipv6/raw.c                            | 21 ++++++++++-----------
 net/wireless/reg.c                        | 12 +++++++++---
 17 files changed, 152 insertions(+), 61 deletions(-)
