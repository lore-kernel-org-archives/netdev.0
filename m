From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 16 May 2012 16:09:19 -0400 (EDT)
Message-ID: <20120516.160919.903281511407092115.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) ptp_pch driver build broke during this merge window due to missing
   slab.h header, fix from Geery Uytterhoeven.

2) If ipset passes in a bogus hash table size we crash because the
   size is not validated properly.  Compounding this, gcc-4.7 can
   miscompile ipset such that even when the user specifies legitimate
   parameters the tool passes in an out-of-range size to the kernel.

   Fix from Jozsef Kadlecsik.

3) Users have reported that the netdev watchdog can trigger with pch_gbe
   devices, and it turns out this is happening because of races in the TX
   path of the driver leading to the transmitter hanging.  Fix from
   Eric Dumazet, reported and tested by Andy Cress.

4) Novatel USB551L devices match the generic class entries for the
   cdc ethernet USB driver, but they don't work because they have
   generic descriptors and thus need FLAG_WWAN to function properly.

   Add the necessary ID table entry to fix this, from Dan Williams.

5) A recursive locking fix in the USBNET driver added a new problem,
   in that packet list traversal is now racy and we can thus access
   unlinked SKBs and crash.

   Avoid this situation by adding some extra state tracking, from
   Ming Lei.

6) The rtlwifi conversion to asynchronous firmware loading is racy,
   fix by reordering the probe procedure.  From Larry Finger.

   Fixes: https://bugzilla.kernel.org/show_bug.cgi?id=43187

7) Fix regressions with bluetooth keyboards by notifying userland
   properly when the security level changes, from Gustavo Padovan.

8) Bluetooth needs to make sure device connected events are emitted
   before other kinds of events, otherwise userspace will think there
   is no baseband link yet and therefore abort the sockets associated
   with that connection.

   From Johan Hedberg.

There is more verbiage about the rtlwifi and 2 bluetooth fixes in
the wireless merge commit.

Please pull, thanks a lot.

The following changes since commit 568b44559d7ca269d367e694c74eb4436e7e3ccf:

  mn10300/CPU hotplug: Add missing call to notify_cpu_starting() (2012-05-15 18:16:57 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Dan Williams (1):
      cdc_ether: add Novatel USB551L device IDs for FLAG_WWAN

David S. Miller (1):
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wireless

Eric Dumazet (1):
      pch_gbe: fix transmit races

Geert Uytterhoeven (1):
      ptp_pch: Add missing #include <linux/slab.h>

Gustavo Padovan (1):
      Bluetooth: notify userspace of security level change

Johan Hedberg (1):
      Bluetooth: mgmt: Fix device_connected sending order

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Jozsef Kadlecsik (1):
      netfilter: ipset: fix hash size checking in kernel

Larry Finger (1):
      rtlwifi: fix for race condition when firmware is cached

Ming Lei (1):
      usbnet: fix skb traversing races during unlink(v2)

 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |    2 -
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   25 ++++-----
 drivers/net/usb/cdc_ether.c                        |   16 ++++++
 drivers/net/usb/usbnet.c                           |   54 ++++++++++++++------
 drivers/net/wireless/rtlwifi/pci.c                 |   16 +++---
 drivers/net/wireless/rtlwifi/usb.c                 |   10 ++--
 drivers/ptp/ptp_pch.c                              |    1 +
 include/linux/netfilter/ipset/ip_set_ahash.h       |   16 ++++++
 include/linux/usb/usbnet.h                         |    3 +-
 include/net/bluetooth/bluetooth.h                  |    1 +
 net/bluetooth/af_bluetooth.c                       |    2 +-
 net/bluetooth/hci_core.c                           |    8 +++
 net/bluetooth/hci_event.c                          |   11 +++-
 net/bluetooth/l2cap_core.c                         |    5 ++
 net/bluetooth/l2cap_sock.c                         |   12 +++--
 net/netfilter/ipset/ip_set_hash_ip.c               |   10 +++-
 net/netfilter/ipset/ip_set_hash_ipport.c           |   10 +++-
 net/netfilter/ipset/ip_set_hash_ipportip.c         |   10 +++-
 net/netfilter/ipset/ip_set_hash_ipportnet.c        |   10 +++-
 net/netfilter/ipset/ip_set_hash_net.c              |   10 +++-
 net/netfilter/ipset/ip_set_hash_netiface.c         |   10 +++-
 net/netfilter/ipset/ip_set_hash_netport.c          |   10 +++-
 22 files changed, 178 insertions(+), 74 deletions(-)
