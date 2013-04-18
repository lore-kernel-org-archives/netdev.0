From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 0/3] net: frag code fixes and RFC for LRU removal
Date: Thu, 18 Apr 2013 23:37:10 +0200
Message-ID: <20130418213637.14296.43143.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19602 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751781Ab3DRVem (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 17:34:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is mostly fixes I discovered while working on removing
the LRU system, which is almost done (included as a RFC patch-03), but
I wanted to push these patches for review first.

Patch-01: net: fix race bug in fragmentation create code
- Is a race fix that is only visible with patch-02 in place.

Patch-02: net: fix enforcing of fragment queue hash list depth
- Fixes unfortunately effect of Hannes hash depth limit, but is also
  part of the direct hash cleaning strategy, which is needed before we
  can remove the LRU list cleaning system

Patch-03: net: remove fragmentation LRU list system
- This patch is BROKEN do not apply, RFC only.
  I have a bug in inet_frag_cleanup_netns().

Patchset based on top of net-next commit 953c96e0d8 (v3.9-rc5-1145-g953c96e).

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
 net-next:   17417.4   11376.5   3853.43     6170.56     174.8    402.9
 patch-01:   17337.1   11541.4   3803.89     6041.52     171.6    416.1
 patch-02:   16674.7   11113.8   3806.43     7892.50     405.5    759.3
(below, work-in-progress removing LRU system, hash clean only)
 patch-03:   19108.1   13369.2   9923.58    10235.10    1547.2   1795.5

---

Jesper Dangaard Brouer (3):
      net: remove fragmentation LRU list system
      net: fix enforcing of fragment queue hash list depth
      net: fix race bug in fragmentation create code


 include/net/inet_frag.h                 |   45 ++++-----
 include/net/ipv6.h                      |    2 
 net/ipv4/inet_fragment.c                |  150 +++++++++++++++++++------------
 net/ipv4/ip_fragment.c                  |   32 ++-----
 net/ipv6/netfilter/nf_conntrack_reasm.c |   10 --
 net/ipv6/reassembly.c                   |   23 +++--
 6 files changed, 138 insertions(+), 124 deletions(-)


--
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
