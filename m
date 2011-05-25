From: chetan loke <loke.chetan@gmail.com>
Subject: [RFC 00/01]af_packet: Enhance network capture visibility
Date: Wed, 25 May 2011 19:02:39 -0400
Message-ID: <BANLkTi=jR1MCO=DRP8vD+C9BMkam08sb4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, loke.chetan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f173.google.com ([209.85.212.173]:38706 "EHLO
	mail-px0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752869Ab1EYXCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 19:02:39 -0400
Received: by pxi16 with SMTP id 16so86325pxi.4
        for <netdev@vger.kernel.org>; Wed, 25 May 2011 16:02:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Please review the RFC/patchset. Any feedback is appreciated.

The patch set is not complete and is intended to:
a) demonstrate the improvements
b) gather suggestions

This patch attempts to i) improve network capture visibility by
increasing packet density ii) assist in analyzing multiple(aggregated)
capture ports.

With the current af_packet->rx::mmap based approach, the element size
in the block needs to be statically configured. Nothing wrong with
this config/implementation. But the traffic profile
cannot be known in advance. And so it would be nice if that
configuration wasn't static. Normally, one would configure the
element-size to be '2048' so that you can atleast capture the entire
'MTU-size'.
But if the traffic profile varies then we would end up either
i)wasting memory or ii) end up getting a sliced frame. In other words
the packet density will be much less in the first case.

Enhancement:
E1) Enhance tpacket_rcv so that it can dump/copy the packets one after another.
E2) Also implement basic timeout mechanism to close 'a' current
block.That way, user-space won't be blocked forever on an idle link.
This is a much needed feature while monitoring multiple ports.
      Look at 3) below.

Why is such enhancement needed?
1) Well, spin-waiting/polling on a per-packet basis to see if it's
ready to be consumed does not scale while monitoring multiple ports.
poll() is not performance friendly either.
2) Also, typically a user-space packet capture interface handles
multiple packets to another user-space protocol-decoder.

   ----------------
   protocol-decoder
          T2
   ----------------
    ========
      ship pkts
    ========
	   ^
	   |
	   v
   -----------------
   pkt-capture logic
           T1
   -----------------
   ================
	 nic/adp/sock IF
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


3) Port aggregation:
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
   3.5) Once we receive a block from multiple ports, then we can
compare the timestamps from the block-descriptor and then easily sort
the packets and feed the pointers to the decoders.


------------------------------
Performance results:
------------------------------

Setup:
S1)Ran 3 pktgen sessions from 3 worker VMs(VM0-VM2).
S2)Each pktgen session was configured to send 40Million, 64byte packets.
S3)Ran patched kernel on the probe-VM(VM3).
S4)rx-mmap application code:
   BLOCK_SIZE: 1MB
   FRAME_SIZE: 2048 bytes
   NUM_BLOCKS: 64

Note: TPACKET_V3 doesn't really care about FRAME_SIZE.
      But the code was untouched to ensure minimal disruption.

Numbers from VM3(tpacket_stats):

Case P1) TPACKET_V0[V1](existing model):

recieved 84909875 packets, dropped 5760817
Pkts seen by the app:79149058


Case P2) TPACKET_V3(enhanced model):
recieved 102562944 packets, dropped 2 plug_q_cnt 12
Pkts seen by the app:102562942

PS:plug_q_cnt is interpreted as "The tpacket_rcv code got blocked only
12 times during the entire capture process.Blocked implies, user-space
process took some time to catch up."
	
Note: In both the cases,VM3 should have seen ~120 Million packets. But
notice it only sees around 90-100M pkts. The hypervisor is dropping
~30%-20% of the traffic.We can ignore this because in non-virtual
world, there could be limitations on the host side too.


Summary:

A) In P2) notice how the VM keeps up and so it now has more visibility
than the P1) case.
So,
  A.1] P2) almost always has around 10%-20% higher visibility than P1.
  A.2] P2) almost always captures ~98-99% of the traffic as seen by the kernel.
  A.3] P1) on the other hand drops anywhere around ~7-10% traffic.
  A.4] P1) also has 10%-20% lower visibility because
         i) it loses frames due to the static frame size format
         ii) has to poll/spin-wait for a single packet.


  Regards
  Chetan Loke
