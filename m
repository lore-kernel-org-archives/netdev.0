From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 0/3] Gianfar byte queue limits
Date: Sun, 18 Mar 2012 12:56:24 -0400
Message-ID: <1332089787-24086-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net, eric.dumazet@gmail.com, therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43531 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755350Ab2CRQ4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 12:56:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The BQL support here is unchanged from what I posted earlier as an
RFC[1] -- with the exception of the fact that I'm now happier with
the runtime testing vs. the simple "hey it boots" that I'd done
for the RFC.  Plus I added a couple trivial cleanup patches.

For testing, I made a couple spiders homeless by reviving an ancient
10baseT hub.  I connected an sbc8349 into that, and connected the
yellowing hub into a GigE 16port, which was also connected to the
recipient x86 box.

Gianfar saw the interface as follows:

fsl-gianfar e0024000.ethernet: eth0: mac: 00:a0:1e:a0:26:5a
fsl-gianfar e0024000.ethernet: eth0: Running with NAPI enabled
fsl-gianfar e0024000.ethernet: eth0: RX BD ring size for Q[0]: 256
fsl-gianfar e0024000.ethernet: eth0: TX BD ring size for Q[0]: 256
PHY: mdio@e0024520:19 - Link is Up - 10/Half

With the sbc8349 being diskless, I simply used an scp of /proc/kcore
to the connected x86 box as a rudimentary Tx heavy workload.

BQL data was collected by changing into the dir:

  /sys/devices/e0000000.soc8349/e0024000.ethernet/net/eth0/queues/tx-0/byte_queue_limits

and running the following:

  for i in * ; do echo -n $i": " ; cat $i ; done

Running with the defaults, data like below was typical:

hold_time: 1000
inflight: 4542
limit: 3456
limit_max: 1879048192
limit_min: 0

hold_time: 1000
inflight: 4542
limit: 3378
limit_max: 1879048192
limit_min: 0

i.e. 2 or 3 MTU sized packets in flight and the limit value lying
somewhere between those two values.

The interesting thing is that the interactive speed reported by scp
seemed somewhat erratic, ranging from ~450 to ~700kB/s. (This was
the only traffic on the old junk - perhaps expected oscillations such
as those seen in isolated ARED tests?)  Average speed for 100M was:

104857600 bytes (105 MB) copied, 172.616 s, 607 kB/s

Anyway, back to BQL testing; setting the values as follows:

hold_time: 1000
inflight: 1514
limit: 1400
limit_max: 1400
limit_min: 1000

had the effect of serializing the interface to a single packet, and
the crusty old hub seemed much happier with this arrangement, keeping
a constant speed and achieving the following on a 100MB Tx block:

104857600 bytes (105 MB) copied, 112.52 s, 932 kB/s

It might be interesting to know more about why the defaults suffer
the slowdown, but the hub could possibly be ancient spec violating
trash.  Definitely something that nobody would ever use for anything
today. (aside from contrived tests like this)

But it did give me an example of where I could see the effects of
changing the BQL settings, and I'm reasonably confident they are
working as expected.

Paul.
---

[1] http://lists.openwall.net/netdev/2012/01/06/64

Paul Gortmaker (3):
  gianfar: Add support for byte queue limits.
  gianfar: constify giant block of status descriptor strings
  gianfar: delete orphaned version strings and dead macros

 drivers/net/ethernet/freescale/gianfar.c         |   22 ++++++++++++++++------
 drivers/net/ethernet/freescale/gianfar.h         |    3 ---
 drivers/net/ethernet/freescale/gianfar_ethtool.c |    2 +-
 3 files changed, 17 insertions(+), 10 deletions(-)

-- 
1.7.9.1
