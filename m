From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 0/2] net: introduce IFF_NO_QUEUE as successor of zero tx_queue_len
Date: Thu, 13 Aug 2015 19:01:05 +0200
Message-ID: <1439485268-20953-1-git-send-email-phil@nwl.cc>
Cc: brouer@redhat.com, alexei.starovoitov@gmail.com,
	davem@davemloft.net, fw@strlen.de, cwang@twopensource.com,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:42807 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752202AbbHMRBK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2015 13:01:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds a new private net_device flag indicating that a device may
(and probably should) be used without a queueing discipline attached to it.
This is already common practice for many virtual device types like e.g.
loopback, VLAN (802.1Q) or bridges (802.1D). The reason for this is that these
devices lack an underlying layer which could impose back pressure and therefore
making a TX queue necessary to not slow down senders.

Up to now, drivers being aware of the above applying to them set
dev->tx_queue_len to zero to indicate no qdisc should be attached to the
interface they drive and the kernel reacts upon this by assigning the noop
qdisc instead of the default pfifo_fast. This implicit agreement though leads
to an inconvenient situation once a user tries to attach a real qdisc to these
devices, as the formerly special tx_queue_len value becomes a regular one,
limiting the queue to zero packets and thus prevents any TX from happening. To
overcome this, practically all qdisc implementations intercept and sanitize the
malicious value.

With this series applied, drivers may signal the lack of need for a qdisc
without having to tamper with tx_queue_len, making fallbacks in qdiscs and
caveats in userspace unnecessary.

Upon upstream acceptance, this series will be followed up by a set of patches
converting device drivers, adding a warning so out-of-tree driver authors get
aware of this change and dropping all special handling of tx_queue_len in
net/sched/.

Phil Sutter (2):
  net: declare new net_device priv_flag IFF_NO_QUEUE
  net: sch_generic: react upon IFF_NO_QUEUE flag

 include/linux/netdevice.h | 3 +++
 net/sched/sch_generic.c   | 6 ++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

-- 
2.1.2
