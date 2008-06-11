From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 10 Jun 2008 21:45:53 -0700 (PDT)
Message-ID: <20080610.214553.47775253.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56400
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751137AbYFKEpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 00:45:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Lots of small fixes:

1) The recvmsg() length check fixes for pppoe and pppol2tp

2) Several wired net driver bug fixes via Jeff Garzik's tree.

3) Wireless fixes from John Linville's tree.

4) TG3 bug fixes from Matt Carlson and the Broadcom crew.

5) Legacy applications are only provided an 8-bit field
   for the table ID, provide a fixed sentinal value to use
   when the table ID is larger than can fit in that 8-bit
   value.  From Krzysztof Piotr Oledzki.

6) Pavel Emelyanov noticed that ipv6 was using the hard-coded
   init namespace where a contextual one should be used instead.

7) pppoe needs to unshare the SKB before doing pskb_may_pull()
   otherwise it might modify a shared SKB.  From Herbert Xu

8) The DCCP folks noticed that request sockets did not initialize
   their ->opt and ->pktopts field early, so it is possible to try and
   destroy such an object with garbage in those pointers.  Initialize
   them to NULL in the constructor of the generic inet request socket
   layer to avoid this problem.  From Arnaldo Carvalho de Melo.

The only biggie left is the loopback stuck TCP connection problem Ingo
reported.  I'll try to have a resolution to this by the end of the
week.  It's looking like a revert will be the fix at this point.

Please pull, thanks a lot!

The following changes since commit 24b95685ffcdb3dc28f64b9e8af6ea3e8360fbc5:
  James Chapman (1):
        l2tp: Fix possible oops if transmitting or receiving when tunnel goes down

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Adrian Bunk (2):
      include/linux/ssb/ssb_driver_gige.h typo fix
      add missing lance_* exports

Akinobu Mita (1):
      isdn: use simple_read_from_buffer()

Al Viro (1):
      s2io iomem annotations

Alexey Dobriyan (1):
      isdn divas: fix proc creation

Arnaldo Carvalho de Melo (1):
      inet{6}_request_sock: Init ->opt and ->pktopts in the constructor

Assaf Krauss (2):
      mac80211: Fixing slow IBSS rejoin
      mac80211: Checking IBSS support while changing channel in ad-hoc mode

Ayaz Abdulla (1):
      forcedeth: msi interrupts

Ben Hutchings (1):
      sky2: Hold RTNL while calling dev_close()

Cornelia Huck (1):
      qeth: Use ccw_device_get_id().

Dan Williams (3):
      ipw2200: queue direct scans
      mac80211: send association event on IBSS create
      mac80211: decrease IBSS creation latency

David S. Miller (1):
      Merge branch 'davem-fixes' of master.kernel.org:/.../jgarzik/netdev-2.6

Frank Blaschka (3):
      qeth: layer 3 Oops in ip event handler
      qeth: reduce number of kernel messages
      qeth: start dev queue after tx drop error

Herbert Xu (2):
      net pppoe: Check packet length on all receive paths
      pppoe: Unshare skb before anything else

Holger Schurig (1):
      libertas: fix sleep confirmation

Ingo Molnar (1):
      irda: net/irda build fix: mcs7780

Jamal Hadi Salim (1):
      ipsec: pfkey should ignore events when no listeners

James Chapman (1):
      l2tp: Fix potential memory corruption in pppol2tp_recvmsg()

Jan-Bernd Themann (1):
      ehea: set mac address fix

Jay Cliburn (1):
      atl1: fix suspend regression

Jeff Kirsher (1):
      ixgbe: fix typo

Krzysztof Piotr Oledzki (1):
      net: Fix routing tables with id > 255 for legacy software

Marcin Slusarz (1):
      iwlwifi: fix oops in iwl3945_led_brightness_set

Mark McLoughlin (3):
      virtio_net: Fix skb->csum_start computation
      virtio: Fix typo in virtio_net_hdr comments
      virtio: virtio_net free transmit skbs in a timer

Matt Carlson (4):
      tg3: Fix 5714S / 5715S / 5780S link failures
      tg3: Fix a flags typo
      tg3: Fix 5761 WOL
      tg3: Update version to 3.92.1

Michael Buesch (1):
      zd1211rw: Fix data padding for QoS

Pavel Emelyanov (1):
      ipv6 netns: init net is used to set bindv6only for new sock

Peter Tiedemann (1):
      qeth: Prepare-function to call s390dbf was wrong

Pradeep Singh Rautela (1):
      drivers/atm/eni.h: remove unused macro KERNEL_OFFSET

Rami Rosen (1):
      ipv4: Remove unused declaration from include/net/tcp.h.

Rusty Russell (1):
      virtio: use callback on empty in virtio_net

Steve Hodgson (1):
      sfc: Recover from RX queue flush failure

 drivers/atm/eni.h                           |    1 -
 drivers/isdn/hardware/eicon/divasmain.c     |    1 -
 drivers/isdn/hardware/eicon/divasproc.c     |    4 +-
 drivers/isdn/hysdn/hysdn_procconf.c         |   29 ++---
 drivers/net/7990.c                          |    6 +-
 drivers/net/atlx/atl1.c                     |   17 ---
 drivers/net/ehea/ehea_main.c                |   16 ++-
 drivers/net/forcedeth.c                     |   20 +++
 drivers/net/irda/Kconfig                    |    1 +
 drivers/net/ixgbe/ixgbe_82598.c             |    4 +-
 drivers/net/pppoe.c                         |   37 +++---
 drivers/net/pppol2tp.c                      |   20 ++--
 drivers/net/s2io.c                          |   10 +-
 drivers/net/sfc/falcon.c                    |    4 +-
 drivers/net/sky2.c                          |    2 +
 drivers/net/tg3.c                           |   33 +++++-
 drivers/net/virtio_net.c                    |   52 +++++++-
 drivers/net/wireless/ipw2200.c              |  176 +++++++++++++--------------
 drivers/net/wireless/ipw2200.h              |    6 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.c |    5 +-
 drivers/net/wireless/libertas/cmd.c         |    5 +-
 drivers/net/wireless/libertas/main.c        |    2 +-
 drivers/net/wireless/zd1211rw/zd_mac.c      |    2 +-
 drivers/s390/net/qeth_core_main.c           |   49 +++-----
 drivers/s390/net/qeth_core_offl.c           |    6 +-
 drivers/s390/net/qeth_core_sys.c            |   12 --
 drivers/s390/net/qeth_l2_main.c             |   41 +++----
 drivers/s390/net/qeth_l3_main.c             |   75 ++++--------
 drivers/s390/net/qeth_l3_sys.c              |   24 ----
 include/linux/ipv6.h                        |    4 +-
 include/linux/rtnetlink.h                   |    1 +
 include/linux/ssb/ssb_driver_gige.h         |    2 +-
 include/linux/virtio_net.h                  |    2 +-
 include/net/inet_sock.h                     |   10 ++
 include/net/tcp.h                           |    1 -
 net/dccp/ipv4.c                             |    3 +-
 net/dccp/ipv6.c                             |    1 -
 net/ipv4/fib_semantics.c                    |    5 +-
 net/ipv4/syncookies.c                       |    3 +-
 net/ipv4/tcp_ipv4.c                         |    2 +-
 net/ipv6/af_inet6.c                         |    2 +-
 net/ipv6/syncookies.c                       |    1 -
 net/ipv6/tcp_ipv6.c                         |    1 -
 net/key/af_key.c                            |    3 +
 net/mac80211/ieee80211_i.h                  |    2 +-
 net/mac80211/main.c                         |    1 +
 net/mac80211/mlme.c                         |   18 ++--
 net/mac80211/wext.c                         |   15 ++-
 48 files changed, 367 insertions(+), 370 deletions(-)
