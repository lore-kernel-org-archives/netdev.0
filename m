From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 20 Jul 2010 14:19:17 -0700 (PDT)
Message-ID: <20100720.141917.22550218.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46591
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932412Ab0GTVTB convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jul 2010 17:19:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Several really small fixes, as is customary this late in the -rc
series...

1) Three bluetooth fixes via Marcel Holtmann:
   a) Fix L2CAP state machine race, from Andrei Emeltchenko

   b) HCI conn security level must be reset after auth failure, from
      Johan Hedberg.

   c) Existng HCI connections need auth levels adjusted when
      constrained by new connection settings.  From Ville Tervo.

2) TX queue hash is set incorrectly in stacked device situations
   because of how we early orphan the socket from the SKB these
   days.  Fix, by remembering sk->sk_hash in skb->rxhash and using
   it later, from Eric Dumazet.

3) Neighbour ->cache_update header op is optional, check for NULL
   was missing in neigh_update_hhs() leading to OOPS with GRE
   tunnels.  Fix from Doug Kehn.

4) RFS Socket sk->sk_tx_queue_mapping is read asynchronously from it's
   setting.  Therefore doing two reads (one to analyze it's validity,
   a second to fetch the actual value) is racey.  Do it on one read
   to fix the problem.  From Tom Herbert.

5) Don't do vhost-net flushes with mutex held, otherwise we deadlock
   with workqueue.  From Michael S. Tsirkin.


6) Guest triggerable condition results in pr_err() log, change to
   pr_debug().  Also From Michael S. Tsirkin.

7) Multicast router code in ipv4 leaks SKB is fib lookup fails, fix
   from Ben Greear.

8) Initialize workqueue earlier in rt2x00 wireless to avoid access to
   uninitialized lock on probe failure.  From Stephen Boyd.

9) Dangling hypervisor VIO interrupt can wedge ibmveth device on close.
   Fix using explicit hypervisor call to disable it before the free.
   From Robert Jennings.

10) Mobile ipv6 routing header code checks wrong address, should look a=
t
    ipv6 header address not the one in the routing header.  From
    Arnaud Ebalard.

11) There are circumstances, that which we do not %100 understand yet b=
ut
    is proven by testing and experimentation, where we can call
    tcp_xmit_retransmit_queue() when the send queue of the socket is em=
pty.

    If this happens, we deref a NULL skb trying to look at SACK informa=
tion
    of the head skb.

    Just return immediately if ->packets_out is zero.

    From Ilpo J=E4rvinen.

12) Bridge netpoll support is buggy, but we were only able to fix the
    problem with a series of non-trivial changes in net-next-2.6 which
    are not appropriate this late in the -rc series.  Just disable
    netpoll support in bridging for 2.6.35, it'll be working fine in
    2.6.36

13) Phone SKB leak fix from R=E9mi Denis-Courmont.

14) 8168dp ID fix in r8169 driver from Francois Romieu.

15) Packet scheduler NAT module requires all ICMPs to have an IP
    header in their payload, this is not correct, only some ICMPs do.
    Fix from Changli Gao based upon a patch and analysis by Rodrigo
    Partearroyo Gonz=E1lez.

16) NET_DSA needs to depend upon NET_ETHERNET.  Based upon a report by
    Randy Dunlap.

17) Fix locking in the axnet_cs interrupt handler since it can be
    invoked by the watchdog too.  From Ken Kawasaki.

18) hostap driver must unconditionally set dev->base_addr during probe.
    From John W. Linville.

19) Fix crash in xfrm bundle lookup, it assumed template resolution alw=
ays
    results in constructed xfrms.  From Timo Ter=E4s.

20) tcp_splice_read() doesn't hit sock_rps_record_flow() but it needs t=
o.
    From Changli Gao.

Please pull, thanks a lot!

The following changes since commit 2f7989efd4398d92b8adffce2e07dd043a08=
95fe:

  Merge master.kernel.org:/home/rmk/linux-2.6-arm (2010-07-14 17:28:13 =
-0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Andrei Emeltchenko (1):
      Bluetooth: Check L2CAP pending status before sending connect requ=
est

Arnaud Ebalard (1):
      IPv6: fix CoA check in RH2 input handler (mip6_rthdr_input())

Ben Greear (1):
      ipmr: Don't leak memory if fib lookup fails.

Changli Gao (2):
      act_nat: not all of the ICMP packets need an IP header payload
      rfs: call sock_rps_record_flow() in tcp_splice_read()

David S. Miller (4):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      dsa: Fix Kconfig dependencies.
      Merge branch 'vhost-net' of git://git.kernel.org/.../mst/vhost
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6

Doug Kehn (1):
      net/core: neighbour update Oops

Eric Dumazet (1):
      net: skb_tx_hash() fix relative to skb_orphan_try()

=46rancois Romieu (1):
      r8169: incorrect identifier for a 8168dp

Herbert Xu (1):
      bridge: Partially disable netpoll support

Ilpo J=E4rvinen (1):
      tcp: fix crash in tcp_xmit_retransmit_queue

Johan Hedberg (1):
      Bluetooth: Reset the security level after an authentication failu=
re

John W. Linville (1):
      hostap_pci: set dev->base_addr during probe

Ken Kawasaki (1):
      axnet_cs: use spin_lock_irqsave in ax_interrupt

Michael S. Tsirkin (2):
      vhost-net: avoid flush under lock
      vhost: avoid pr_err on condition guest can trigger

Rajkumar Manoharan (1):
      ath9k_htc: fix memory leak in ath9k_hif_usb_alloc_urbs

Reinette Chatre (1):
      iwlwifi: remove key information during device restart

Robert Jennings (1):
      ibmveth: lost IRQ while closing/opening device leads to service l=
oss

R=E9mi Denis-Courmont (1):
      Phonet: fix skb leak in pipe endpoint accept()

Stephen Boyd (1):
      rt2x00: Fix lockdep warning in rt2x00lib_probe_dev()

Timo Ter=E4s (1):
      xfrm: do not assume that template resolving always returns xfrms

Tom Herbert (1):
      net: fix problem in reading sock TX queue

Ville Tervo (1):
      Bluetooth: Update sec_level/auth_type for already existing connec=
tions

 drivers/net/ibmveth.c                    |    4 +++-
 drivers/net/pcmcia/axnet_cs.c            |    7 ++++---
 drivers/net/r8169.c                      |    2 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c |    8 ++++++--
 drivers/net/wireless/hostap/hostap_pci.c |    1 +
 drivers/net/wireless/iwlwifi/iwl-sta.h   |   11 +++++++++++
 drivers/net/wireless/rt2x00/rt2x00dev.c  |   10 +++++-----
 drivers/vhost/net.c                      |   13 +++++++++----
 include/net/sock.h                       |    7 +------
 net/bluetooth/hci_conn.c                 |    5 +++++
 net/bluetooth/hci_event.c                |    2 ++
 net/bluetooth/l2cap.c                    |   14 +++++++++++---
 net/bridge/br_device.c                   |    9 ---------
 net/bridge/br_forward.c                  |   23 +---------------------=
-
 net/core/dev.c                           |   20 +++++++++++++-------
 net/core/neighbour.c                     |    5 ++++-
 net/dsa/Kconfig                          |    2 +-
 net/ipv4/ipmr.c                          |    8 ++++++--
 net/ipv4/tcp.c                           |    1 +
 net/ipv4/tcp_output.c                    |    3 +++
 net/ipv6/mip6.c                          |    3 ++-
 net/phonet/pep.c                         |    1 +
 net/sched/act_nat.c                      |    5 ++++-
 net/xfrm/xfrm_policy.c                   |   15 +++++++++++++--
 24 files changed, 108 insertions(+), 71 deletions(-)
