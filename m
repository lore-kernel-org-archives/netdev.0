From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 08 Sep 2008 14:32:49 -0700 (PDT)
Message-ID: <20080908.143249.172785876.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38045
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753317AbYIHVdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 17:33:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) nf_conntrack_sip has a local variable marked static
   unintentionally, for a function callable in parallel by
   multiple threads this is very bad.  Fix from Alexey Dobriyan.

2) GRE conntrack module's keymap list has bad locking leading to OOPS.
   Fix by Alexey Dobriyan.

3) GRE conntrack module kfree()'s list head member of structure instead
   of structure itself, yikes...  Fixed by Alexey Dobriyan.

4) Potential remote exploit issue, IRC conntrack module blindly parses
   strings in protocol packets assuming there is zero termination
   there somewhere.  We likely hit a zero byte anyways in the post
   skb->data area since thats where skb_shared_info() sits, but that
   is not something to rely upon at all.  Fix from Patrick McHardy.

5) Denys Fedoryshchenko reports that his interfaces generally wedge
   after some time, and this has happened since early 2.6.27-rcX
   releases.  Jarek Poplawski figured out that when net_tx_action()
   races with dev_deactivate() the __QDISC_STATE_SCHED bit is left
   set, and this causes dev_deactivate() to loop forever in a sleeping
   state bit test.

6) Timewait socket handling under namespaces can lead to an OOPS
   simply because we don't purge the timewait sockets attached to that
   namespace from the hash tables when the namespace goes down.
   Reproducer for the OOPS included in the commit message.  Fix from
   Daniel Lezcano.

7) Reported excessive ksoftirqd cpu utilization was tracked down to
   allowing bridge hello timers smaller than 1 second, fixed by
   Stephen Hemminger.

Please pull, thanks a lot!

The following changes since commit fca1287a3a9246d4facc27a0a455fada18fd1164:
  David S. Miller (1):
        Merge branch 'davem-fixes' of master.kernel.org:/.../jgarzik/netdev-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexey Dobriyan (3):
      netfilter: nf_conntrack_sip: de-static helper pointers
      netfilter: nf_conntrack_gre: more locking around keymap list
      netfilter: nf_conntrack_gre: nf_ct_gre_keymap_flush() fixlet

Daniel Lezcano (1):
      netns : fix kernel panic in timewait socket destruction

Jarek Poplawski (1):
      pkt_sched: Fix qdisc state in net_tx_action()

Patrick McHardy (1):
      netfilter: nf_conntrack_irc: make sure string is terminated before calling simple_strtoul

Stephen Hemminger (1):
      bridge: don't allow setting hello time to zero

 include/net/inet_timewait_sock.h       |    3 ++
 net/bridge/br_ioctl.c                  |    8 ++++++-
 net/bridge/br_sysfs_br.c               |   26 ++++++++++++++++-------
 net/core/dev.c                         |    7 +++++-
 net/ipv4/inet_timewait_sock.c          |   35 ++++++++++++++++++++++++++++++++
 net/ipv4/tcp_ipv4.c                    |    1 +
 net/ipv6/tcp_ipv6.c                    |    1 +
 net/netfilter/nf_conntrack_irc.c       |   10 +++++++++
 net/netfilter/nf_conntrack_proto_gre.c |   14 ++++++++----
 net/netfilter/nf_conntrack_sip.c       |    6 +++-
 10 files changed, 94 insertions(+), 17 deletions(-)
