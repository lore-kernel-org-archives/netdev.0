From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 02 Sep 2008 20:42:19 -0700 (PDT)
Message-ID: <20080902.204219.55462484.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55629
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755330AbYICDm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 23:42:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) IPV6 RAW socket code should use NET_RX_DROP when dropping packets
   which have no receivers, from Yang Hongyang.

2) linux/mroute.h usability by userspace was inadvertantly broken.

3) Users of xfrm_bundle_create() should not make NULL checks, as
   this function returns PTR_ERR values.  From Julien Brunel.

4) More packet scheduler qdisc locking fixes from Jarek Poplawski.
   After dev_deactivate() has run, we should be locking ->qdisc_sleeping
   not ->qdisc.

5) It's possible to try and take xfrm_state_lock recursively and
   deadlock in some circumstances.  This happens after a commit that
   went into 2.6.25, so I'll queue this up for -stable too.

   Fix by making sure we do xfrm_state_put() calls without the lock
   held.

6) If you set the MTU of an interface below 68, IPV4 is disabled
   for that interface.  That's fine, but no matter what you do,
   even increasing the MTU back to 68 or larger will not make the
   interface usable by IPV4 again.  You'll have to completely destroy
   and recreate the device by reloading the module or similar.

   Fix by doing the proper re-enabling when the MTU size becomes
   large enough again.

   Fix from Breno Leitao.

7) Wireless driver fixes via John Linville:

   a) Bogus BUILD_BUG_On in rt2x00, from Boaz Harrosh
   b) Orinoco driver sets multicast incorrectly because is uses the
      wrong mc_count value.  It was loading unitialized data into
      the multicast part of the card.  From David Kilroy.
   c) iwlwifi erroneously uses GFP_DMA which will depleat the GFP_DMA
      pool unnecessarily and cause failures.
   d) mac80211 debugfs code was abusing a union and corrupting the
      value.  Non-union it to fix the problem, from Jouni Malinen.
   e) Inverted usage of FLAG_INIT_DONE bit in iwlwifi apm_stop(), from
      Mohamed Abbas.
   f) Incorrect encryption key usage in ath9k driver, fix from Senthil Balasubramanian
   g) ath9k again, does local_bh_enable() with hard IRQs disabled, also from
      Senthil Balasubramanian
   h) Some iwlwifi chips come up with INTX_DISABLED set, by the bios or something
      else, explicitly clear it to fix non-working interrupts on some systems.
      From Tomas Winkler.
   i) iwlwifi can't load firmware correctly on 64-bit systems because the high
      32-bits of the DMA address was not loaded properly, also from Tomas Winkler.

Please pull, thanks a lot!

The following changes since commit d97240552cd98c4b07322f30f66fd9c3ba4171de:
  Vlad Yasevich (1):
        sctp: fix random memory dereference with SCTP_HMAC_IDENT option.

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Adrian Bunk (1):
      wireless/libertas/if_cs.c: fix memory leaks

Boaz Harrosh (1):
      rt2x00: Compiler warning unmasked by fix of BUILD_BUG_ON

Breno Leitao (1):
      ipv: Re-enable IP when MTU > 68

David Kilroy (1):
      orinoco: Multicast to the specified addresses

David S. Miller (2):
      net: Unbreak userspace usage of linux/mroute.h
      ipsec: Fix deadlock in xfrm_state management.

Florian Mickler (1):
      net/wireless/Kconfig: clarify the description for CONFIG_WIRELESS_EXT_SYSFS

Jarek Poplawski (1):
      pkt_sched: Fix locking of qdisc_root with qdisc_root_sleeping_lock()

John W. Linville (1):
      iwlwifi: do not use GFP_DMA in iwl_tx_queue_init

Jouni Malinen (1):
      mac80211: Fix debugfs union misuse and pointer corruption

Julien Brunel (1):
      net/xfrm: Use an IS_ERR test rather than a NULL test

Mohamed Abbas (1):
      iwlwifi: fix apm_stop (wrong bit polarity for FLAG_INIT_DONE)

Senthil Balasubramanian (2):
      ath9k: Incorrect key used when group and pairwise ciphers are different.
      ath9: Fix ath_rx_flush_tid() for IRQs disabled kernel warning message.

Tomas Winkler (2):
      iwlwifi: workaround interrupt handling no some platforms
      iwlwifi: fix 64bit platform firmware loading

Yang Hongyang (1):
      ipv6: When we droped a packet, we should return NET_RX_DROP instead of 0

 drivers/net/wireless/ath9k/hw.c         |    8 +++---
 drivers/net/wireless/ath9k/main.c       |    6 +++-
 drivers/net/wireless/ath9k/recv.c       |    5 ++-
 drivers/net/wireless/iwlwifi/iwl-4965.c |    4 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c |   14 +++++-------
 drivers/net/wireless/iwlwifi/iwl-agn.c  |    8 +++++++
 drivers/net/wireless/iwlwifi/iwl-fh.h   |    1 +
 drivers/net/wireless/iwlwifi/iwl-tx.c   |    2 +-
 drivers/net/wireless/libertas/if_cs.c   |   13 ++---------
 drivers/net/wireless/orinoco.c          |   10 ++++++--
 drivers/net/wireless/rt2x00/rt2x00reg.h |    5 +--
 include/linux/Kbuild                    |    1 -
 include/linux/mroute.h                  |    2 +-
 include/linux/mroute6.h                 |    1 +
 include/linux/pim.h                     |   18 -----------------
 net/ipv4/devinet.c                      |   15 +++++++++++--
 net/ipv6/raw.c                          |    6 ++--
 net/mac80211/debugfs_key.c              |    6 ++--
 net/mac80211/ieee80211_i.h              |    4 ++-
 net/sched/cls_api.c                     |    2 +-
 net/sched/cls_route.c                   |    2 +-
 net/sched/sch_api.c                     |    8 +++---
 net/sched/sch_cbq.c                     |    2 +-
 net/sched/sch_htb.c                     |    4 +-
 net/sched/sch_netem.c                   |    2 +-
 net/sched/sch_teql.c                    |    2 +-
 net/wireless/Kconfig                    |    3 +-
 net/xfrm/xfrm_policy.c                  |    6 +---
 net/xfrm/xfrm_state.c                   |   32 ++++++++++++++++++++++--------
 29 files changed, 102 insertions(+), 90 deletions(-)
