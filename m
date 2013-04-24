From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 0/4] net: frag patchset for fixing LRU scalability
	issue
Date: Wed, 24 Apr 2013 17:47:55 +0200
Message-ID: <20130424154624.16883.40974.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45028 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756190Ab3DXPsA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 11:48:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset replaces my prevous patchset:
  "net: frag code fixes and RFC for LRU removal"
  http://thread.gmane.org/gmane.linux.network/266323/

I have dropped the idea of doing "direct hash cleaning".  Instead I
have simply choosen to solve the global LRU list problem, by making
the LRU list be per CPU.


Patch-01: Revert "inet: limit length of fragment queue hash table bucket lists"
- Sorry this patch is broken and need to be reverted.
  I'll leave it up to Hannes for come up with a better solution,
  perhaps better IPv6 hashing for frag queues.

Patch-02: net: increase frag hash size
- Simply increase the hash size

Patch-03: net: avoid false perf interpretations in frag code
- The compiler make us misinterpret performance issues in the frag
  code, because its auto inlining functions.  This cause too many
  arguments between developers on the list.

Patch-04: net: frag LRU list per CPU
- Change the global LRU list to be per CPU instead.

Besides my usual 10G tests, I have also tested that a 512 Kbit/s
simulated link (with HTB) still works (with sending 3x UDP fragments)
under the DoS test 20G3F+MQ, which is sending approx 1Mpps on a
10Gbit/s NIC.  (And I have verified that the 512Kbit/s link gets the
right spacing between packets (23.6 ms)).

HTB setup:
 tc qdisc del dev eth63 root
 tc qdisc add dev eth63 root handle 1: htb default 1
 tc class add dev eth63 parent 1: classid 1:1 htb rate 512kbit ceil 512kbit burst 1600 cburst 1600

Patchset based on top of net-next commit 953c96e0d8 (v3.9-rc5-1145-g953c96e).

---
p.s. I have now reached 300 compiles on this git tree for my
frag-work, this work effort getting out of hand...

Jesper Dangaard Brouer (4):
      net: frag LRU list per CPU
      net: avoid false perf interpretations in frag code
      net: increase frag hash size
      Revert "inet: limit length of fragment queue hash table bucket lists"


 Documentation/networking/ip-sysctl.txt  |    2 -
 include/net/inet_frag.h                 |  120 ++++++++++++++++++-------------
 include/net/ipv6.h                      |    8 +-
 net/ipv4/inet_fragment.c                |   83 ++++++++++++---------
 net/ipv4/ip_fragment.c                  |   35 +++++----
 net/ipv6/netfilter/nf_conntrack_reasm.c |   14 ++--
 net/ipv6/reassembly.c                   |   10 +--
 7 files changed, 153 insertions(+), 119 deletions(-)


--
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
