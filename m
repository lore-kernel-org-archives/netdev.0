From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 0/3] net: frag performance followup
Date: Wed, 27 Mar 2013 16:54:52 +0100
Message-ID: <20130327155238.15203.6688.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53739 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751360Ab3C0PzD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 11:55:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is a followup to my previously accepted fragmentation
patchset:
 http://thread.gmane.org/gmane.linux.network/257155

This patchset is not my entire patch queue, as I have left out the
patch I mentioned in:
 http://thread.gmane.org/gmane.linux.network/261924
 "RFC crap-patch [PATCH] net: Per CPU separate frag mem accounting"

Because I'm working on another "replacement" patch which removes the LRU
list, which I discussed with Eric Dumazet during Netfilter Workshop. I
have some preliminary results of that later in this mail.


I'm uncertain if this is net-next or net material?
(for now it's based on net-next on top of commit f5a03cf461)

Patch list:
 Patch-01: avoid several CPUs grabbing same frag queue during LRU evictor loop
 Patch-02: use the frag lru_lock to protect netns_frags.nqueues update
 Patch-03: frag queue per hash bucket locking
 (below not-included)
 Patch-XX: Try Impl. Eric's idea, no LRU and direct hash cleaning


Notice, I have changed the frag DoS generator script to be more
efficient/deadly.  Before it would only hit one RX queue, now its
sending packets causing multi-queue RX, due to "better" RX hashing.

Same test setup:
 Two 10G interfaces, on seperate NUMA nodes, are under-test, and uses
 Ethernet flow-control.  A third interface is used for generating the
 DoS attack (with trafgen).

Test types summary (netperf UDP_STREAM):
 Test-20G64K     == 2x10G with 65K fragments
 Test-20G3F      == 2x10G with 3x fragments (3*1472 bytes)
 Test-20G64K+DoS == Same as 20G64K with frag DoS
 Test-20G3F+DoS  == Same as 20G3F  with frag DoS
 Test-20G64K+MQ  == Same as 20G64K with Multi-Queue frag DoS
 Test-20G3F+MQ   == Same as 20G3F  with Multi-Queue frag DoS


Performance table summary (in Mbit/s):

 Test-type:  20G64K    20G3F    20G64K+DoS  20G3F+DoS  20G64K+MQ 20G3F+MQ
 ----------  -------   -------  ----------  ---------  --------  -------
  net-next:  18486.7   10723.2   3657.85     4560.64      99.9    189.1
  Patch-01:  18830.8   13388.4   4054.96     5377.27     127.9    433.4
  Patch-02:  18848.7   13230.1   4103.04     5310.36     130.0    440.2
  Patch-03:  18838.0   13490.5   4405.11     6814.72     196.6    461.6
  (below work-in-progress)
  Patch-XX:  18800.0   15698.4  10012.90    12039.00   4257.39   3305.8

After his patchset, the LRU list is the major bottleneck. As can also
be seen by my preliminary results of removing the LRU list.

---

Jesper Dangaard Brouer (3):
      net: frag queue per hash bucket locking
      net: use the frag lru_lock to protect netns_frags.nqueues update
      net: frag, avoid several CPUs grabbing same frag queue during LRU evictor loop


 include/net/inet_frag.h  |   11 +++++++-
 net/ipv4/inet_fragment.c |   65 +++++++++++++++++++++++++++++++++++-----------
 2 files changed, 60 insertions(+), 16 deletions(-)


--
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
