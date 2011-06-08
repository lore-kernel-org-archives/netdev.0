From: Chetan Loke <loke.chetan@gmail.com>
Subject: [af-packet 0/2] Enhance af-packet to provide (near zero)lossless packet capture functionality.
Date: Tue,  7 Jun 2011 23:13:04 -0400
Message-ID: <1307502786-1396-1-git-send-email-loke.chetan@gmail.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, kaber@trash.net,
	johann.baudy@gnu-log.net, Chetan Loke <loke.chetan@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:57935 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751688Ab1FHDNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 23:13:25 -0400
Received: by vxi39 with SMTP id 39so65338vxi.19
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2011 20:13:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Please review the patchset. Any feedback is appreciated.

The patch set is intended to:
a) demonstrate the improvements
b) gather suggestions

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


Please don't shoot the patchset because of its size :).



Chetan Loke (2):

 include/linux/if_packet.h |  127 +++++++-
 net/packet/af_packet.c    |  878 ++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 957 insertions(+), 48 deletions(-)

-- 
1.7.5.2

