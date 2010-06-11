From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 11 Jun 2010 13:05:56 -0700 (PDT)
Message-ID: <20100611.130556.98884894.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) As alluded to in the previous networking pull, for correct
   operation r8169 needs a post-mdio-read delay just as it needs one
   for post-mdio-write.  From Timo Ter=E4s.

2) 8139 driver's NAPI completion is racy, the sequence for completing
   a NAPI poll should be:

	napi_complete()
	reenable_interrupts(dev);

   But these driver bits had the ordering reversed.  If the race is
   triggered, NAPI can be left disabled forever and therefore no
   more RX packets will be received until a down/up of the device.

3) When a multiqueue device is plumbed into a non-multiqueue-capable
   SW layer (bonding, bridging, etc.) we print a warning about the RX
   queue selection being "out of range", which is not very useful
   since we are aware of this issue.  All it does is spam the log and
   make life difficult for the user.  Only print the message in cases
   where there is real trouble.

   From Tim Gardner.

4) LXT973 phy support from Richard Cochran.

5) CAIF protocol has tests like:

	if (!x > y)

   which are clearly bogus, fixes from Dan Carpenter.

6) HW timestamping support broke RX on some gianfar chips, turn the
   feature off for now until we can understand the issue better.  From
   Anton Vorontsov.

7) IPV6 icmp bumps wrong stat counters due to typos in a 2.6.35 change,
   fix from Eric Dumazet.

8) When a hw accelerated VLAN interface is hooked up to a bond, the
   packet dropping behavior for inactive bonding slaves erroneously
   changes compared to what happens with all other kinds of devices.

   Fix by tracking whether the packet should be dropped inside of the
   SKB so layers can communicate that they've done the bonding check
   already.  Fix from John Fastabend.

9) Packet rate estimator lacks sufficient SMP locking.  The basic
   assumption was that the RTNL would be held when estimators are
   created or destroyed, but that doesn't happen in some cases, in
   particular the xt_RATEEST netfilter module does not do this.

   Adding RTNL to those spots is non-trivial and would actually cause
   more problems than it would fix.  So add a new spinlock to protect
   the critical insert/delete/search operations.

   Fix from Eric Dumazet.

10) pktgen miscalculates inter-packet delays, basically the old calcula=
tion
    was:

	wait_until(next_time);
	now =3D get_time();
	state->next_time =3D now + state->delay;

    we fix it to be:

	wait_until(next_time);
	state->next_time =3D next_time + state->delay;

    From Daniel Turull.

11) Missing endianness conversion in firmware header field in wimax dri=
ver,
    from Inaky Perez-Gonzalez.

Please pull, thanks a lot!

The following changes since commit 7908a9e5fc3f9a679b1777ed231a03636c06=
8446:
  Linus Torvalds (1):
        Merge branch 'kvm-updates/2.6.35' of git://git.kernel.org/pub/s=
cm/virt/kvm/kvm

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Anton Vorontsov (1):
      gianfar: Revive the driver for eTSEC devices (disable timestampin=
g)

Dan Carpenter (1):
      caif: fix a couple range checks

Daniel Turull (1):
      pktgen: Fix accuracy of inter-packet delay.

David S. Miller (2):
      Merge branch 'num_rx_queues' of git://kernel.ubuntu.com/rtg/net-2=
=2E6
      Merge branch 'wimax-2.6.35.y' of git://git.kernel.org/.../inaky/w=
imax

Eric Dumazet (2):
      ipv6: fix ICMP6_MIB_OUTERRORS
      pkt_sched: gen_estimator: add a new lock

=46igo.zhang (1):
      net8139: fix a race at the end of NAPI

Inaky Perez-Gonzalez (1):
      wimax/i2400m: fix missing endian correction read in fw loader

John Fastabend (1):
      net: deliver skbs on inactive slaves to exact matches

Richard Cochran (1):
      phylib: Add support for the LXT973 phy.

Tim Gardner (1):
      net: Print num_rx_queues imbalance warning only when there are al=
located queues

Timo Ter=E4s (1):
      r8169: fix mdio_read and update mdio_write according to hw specs

 drivers/net/8139cp.c          |    2 +-
 drivers/net/8139too.c         |    2 +-
 drivers/net/gianfar.c         |    3 +-
 drivers/net/phy/lxt.c         |   51 +++++++++++++++++++++++++++++++++=
+++++++-
 drivers/net/r8169.c           |   12 +++++++--
 drivers/net/wimax/i2400m/fw.c |    2 +-
 include/linux/skbuff.h        |    5 +++-
 net/8021q/vlan_core.c         |    4 +-
 net/caif/cfrfml.c             |    2 +-
 net/caif/cfveil.c             |    2 +-
 net/core/dev.c                |   25 +++++++++++++------
 net/core/gen_estimator.c      |   15 +++++++++--
 net/core/pktgen.c             |    2 +-
 net/ipv6/icmp.c               |    4 +-
 14 files changed, 103 insertions(+), 28 deletions(-)
