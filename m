From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 21 Dec 2011 19:31:55 -0500 (EST)
Message-ID: <20111221.193155.587569203649756776.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hopefully the last set of fixes for 3.2.x:

1) iwlwifi fixes that cure the regressions reported by Ted T'so and
   others, from Wey-Yi Guy, Johannes Berg, and Emmanuel Grumbach.

2) When we moved PMTU information to the inetpeer cache, we removed the
   periodic garbage collector, but this is still needed and without
   it we have regressions such as ARP entries sticking around forever
   (even after a routing cache flush).

   The GC scanner needs to run to see these routing cache entries with
   an out-dated generation count, so then can be unlinked, put, and
   that route's ARP table references dropped as well.

   From Eric Dumazet.

3) The flow cache potentially sleeps, but it can be called in the packe=
t
   path with SW interrupts disabled.  Add a deferred task that takes
   care of this in such situations.

4) The x86-64 BPF JIT has a branch target calculation error, fix from
   Markus K=F6tter.

5) SCTP Autoclose timeout overflow check is not correct, from Xi Wang.

6) SCTP accounts too much into receive buffer space used when estimatin=
g
   the receive window, fix from Thomas Graf.

7) R8169 programs wrong regiater and bit for MSI enable, from Fran=E7oi=
s Romieu.

8) LLC socket layer can reference SKB after sk_eat_skb() when putting t=
he
   socket address back to userspace.  Fix from Alex Juncu.

9) Add new device ID to ASIX driver, from Aurelien Jacobs.

10) ipconfig spins waiting for "link up" for a very long time even
    if no devices have actually been brough up and added the ipconfig's
    list of devices.  Fix from Gerlando Falauto.

11) When bluetooth L2CAP performs configuration, it potentially referen=
ces
    an uninitialized on-stack l2cap_conf_rfc struct, fix from Mat Marti=
neau.

12) Bluetooth RFCOMM forgets to kill session timer on last channel
    disconnect.

13) Revert bluetooth L2CAP connect establishment fix, it causes regress=
ions
    when talking to legacy devices.  From Gustavo F. Padovan.

14) Fix DMA channel locking in davinci-cpdma driver, from Ilya Yanok.

Please pull, thanks a lot!

The following changes since commit b9e26dfdad5a4f9cbdaacafac6998614cc9c=
41bc:

  Merge git://git.infradead.org/mtd-2.6 (2011-12-20 18:39:37 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Alex Juncu (1):
      llc: llc_cmsg_rcv was getting called after sk_eat_skb.

Aurelien Jacobs (1):
      asix: new device id

Dan Carpenter (1):
      nfc: signedness bug in __nci_request()

David S. Miller (1):
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless

Emmanuel Grumbach (1):
      iwlwifi: update SCD BC table for all SCD queues

Eric Dumazet (1):
      ipv4: reintroduce route cache garbage collector

Gerlando Falauto (1):
      net: have ipconfig not wait if no dev is available

Gustavo F. Padovan (1):
      Revert "Bluetooth: Revert: Fix L2CAP connection establishment"

Ilya Yanok (1):
      davinci-cpdma: fix locking issue in cpdma_chan_stop

Johannes Berg (1):
      iwlwifi: tx_sync only on PAN context

John W. Linville (3):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetoo=
th
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Markus K=F6tter (1):
      net: bpf_jit: fix an off-one bug in x86_64 cond jump target

Mat Martineau (2):
      Bluetooth: Prevent uninitialized data access in L2CAP configurati=
on
      Bluetooth: Clear RFCOMM session timer when disconnecting last cha=
nnel

Rajkumar Manoharan (1):
      ath9k: fix max phy rate at rate control init

Steffen Klassert (1):
      net: Add a flow_cache_flush_deferred function

Thomas Graf (1):
      sctp: Do not account for sizeof(struct sk_buff) in estimated rwnd

Wey-Yi Guy (2):
      iwlwifi: do not set the sequence control bit is not needed
      iwlwifi: allow to switch to HT40 if not associated

Xi Wang (1):
      sctp: fix incorrect overflow check on autoclose

Yogesh Ashok Powar (1):
      mwifiex: avoid double list_del in command cancel path

fran=E7ois romieu (1):
      r8169: fix Config2 MSIEnable bit setting.

 arch/x86/net/bpf_jit_comp.c                   |    4 +-
 drivers/net/ethernet/realtek/r8169.c          |   14 ++--
 drivers/net/ethernet/ti/davinci_cpdma.c       |    2 +
 drivers/net/usb/asix.c                        |    4 +
 drivers/net/wireless/ath/ath9k/rc.c           |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c   |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c     |    5 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c        |    6 ++
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c |    4 +-
 drivers/net/wireless/mwifiex/cmdevt.c         |    9 +--
 include/net/flow.h                            |    1 +
 include/net/sctp/structs.h                    |    4 +
 net/bluetooth/hci_conn.c                      |    2 +-
 net/bluetooth/l2cap_core.c                    |   12 +++-
 net/bluetooth/rfcomm/core.c                   |    1 +
 net/core/flow.c                               |   12 +++
 net/ipv4/ipconfig.c                           |    4 +
 net/ipv4/route.c                              |  107 +++++++++++++++++=
++++++++
 net/llc/af_llc.c                              |   14 +++-
 net/nfc/nci/core.c                            |    2 +-
 net/sctp/associola.c                          |    2 +-
 net/sctp/output.c                             |    8 +--
 net/sctp/outqueue.c                           |    6 +-
 net/sctp/protocol.c                           |    3 +
 net/sctp/socket.c                             |    2 -
 net/sctp/sysctl.c                             |   13 +++
 net/xfrm/xfrm_policy.c                        |   18 +++-
 27 files changed, 220 insertions(+), 47 deletions(-)
