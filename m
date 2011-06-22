From: Chetan Loke <loke.chetan@gmail.com>
Subject: [PATCH v2 net-next af-packet 0/2] Enhance af-packet to provide (near zero)lossless packet capture functionality.
Date: Tue, 21 Jun 2011 22:10:48 -0400
Message-ID: <1308708650-25509-1-git-send-email-loke.chetan@gmail.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, joe@perches.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	linux-kernel@vger.kernel.org, Chetan Loke <loke.chetan@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Please review the patchset.

Changes from v1:

1) v1 was based on 2.6.38.9. v2 is rebased to net-next.
2) Aligned bdqc members, pr_err to WARN, sob email      (Joe Perches)
3) Added tp_padding                                     (Eric Dumazet)
4) Nuked useless ;) white space                         (Stephen H)
5) Use __u types in headers                             (Ben Hutchings)
6) Added field for creating private area             	(Chetan Loke)

This patch attempts to:
1)Improve network capture visibility by increasing packet density
2)Assist in analyzing multiple(aggregated) capture ports.

Benefits:
  B1) ~15-20% reduction in cpu-usage.
  B2) ~20% increase in packet capture rate.
  B3) ~2x  increase in packet density.
  B4) Port aggregation analysis.
  B5) Non static frame size to capture entire packet payload.

With the current af_packet->rx::mmap based approach, the element size
in the block needs to be statically configured. Nothing wrong with this
config/implementation. But the traffic profile cannot be known in advance.
And so it would be nice if that configuration wasn't static. Normally,
one would configure the element-size to be '2048' so that you can atleast
capture the entire 'MTU-size'.But if the traffic profile varies then we
would end up either i)wasting memory or ii) end up getting a sliced frame.
In other words the packet density will be much less in the first case.

--------------------
Performance results:
--------------------

Tpacket config(same on Physical/Virtual setup):
64 blocks(1MB block size)

**************
Physical setup
**************

pktgen: 64 byte traffic.

1G Intel
driver: igb
version: 2.1.0-k2
firmware-version: 3.19-0


Tpacket          V1                 V3
capture-rate     600K pps     720K pps
cpu usage        70%           53%
Drop-rate         7-10%        ~1%

**********************
Virtual Machine setup:
**********************

pktgen: 64 byte traffic,40M packets(clone_skb <40000000>)

Worker VMs(FC12):
3 VMs:VM0 .. VM2, each sending 40M packets.

probe-VM(FC15): 1-vCPU/512MB memory
running patched kernel


Tpacket          V1                       V3
capture-rate     700-800K pps        1M pps
cpu usage        50%                   ~30%
Drop-rate         9-10%                <1%


Plus, in the VM setup,V3 sees/captures around 5-10% more traffic than V1/V2.

------------
Enhancement:
------------
E1) Enhanced tpacket_rcv so that it can dump/copy the packets one after another.
E2) Also implemented basic timeout mechanism to close 'a' current block.
    That way, user-space won't be blocked forever on an idle link.
    This is a much needed feature while monitoring multiple ports.
    Look at 3) below.

-------------------------------
Why is such enhancement needed?
-------------------------------
1) Well, spin-waiting/polling on a per-packet basis to see if it's ready
   to be consumed does not scale while monitoring multiple ports.
   poll() is not performance friendly either.
2) Also, typically a user-space packet capture interface handles multiple
   packets to another user-space protocol-decoder.

   ----------------
   protocol-decoder
          T2
   ----------------
    =============
    ship pkts
    =============
           ^
           |
           v
   -----------------
   pkt-capture logic
           T1
   -----------------
   ================
     nic/sock IF
   ================
           ^
           |
           V

T1 and T2 are user-space threads. If the hand-off between T1 and T2
happens on a per-pkt basis then the solution does NOT scale.

However, one can argue that T1 can coalesce packets and then pass of a
single chunk to T2.But T1's packet consumption granularity is still at
an individual packet level and that is something that needs to be
addressed to avoid excessive polling.


3) Port aggregation analysis:
   Multiple ports are viewed/analyzed as one logical pipe.
   Example:
   3.1) up-stream    path can be tapped in eth1
   3.2) down-stream  path can be tapped in eth2
   3.3) Network TAP splits Rx/Tx paths and then feeds to eth1,eth2.

   If both eth1,eth2 need to be viewed as one logical channel,
   then that implies we need to timesort the packets as they come across
   eth1,eth2.

   3.4) But following issues further complicates the problem:
        3.4.1)What if one stream is bursty and other is flowing
              at line rate?
        3.4.2)How long do we wait before we can actually make a
              decision in the app-space and bail-out from the spin-wait?

   Solution:
   3.5) Once we receive a block from multiple ports,we can compare
        the timestamps from the block-descriptor and then easily time sort
        the packets and feed them to the decoders.

PS: The actual patch is ~744 lines of code. Rest ~220 lines are code comments.

sample user space code:
git://lolpcap.git.sourceforge.net/gitroot/lolpcap/lolpcap

Chetan Loke (2):

 include/linux/if_packet.h |  128 +++++++
 net/packet/af_packet.c    |  881 ++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 964 insertions(+), 45 deletions(-)

-- 
1.7.5.2
