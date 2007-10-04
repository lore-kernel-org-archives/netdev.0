From: TAKANO Ryousei <takano@axe-inc.co.jp>
Subject: [RFC][PATCH 2.6.23-rc9 0/2] detection of loss of retransmitted
 packets
Date: Thu, 04 Oct 2007 18:44:37 +0900 (JST)
Message-ID: <20071004.184437.07576505.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: y-kodama@aist.go.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:64897 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054AbXJDKRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 06:17:53 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

We found a performance problem which occurs in heavy packet loss
conditions. It seems there is a problem in detecting loss of 
retransmitted packets.

In the retransmission queue, status of sent packets are registered.
When a packet is retransmitted, it is so marked, and snd_nxt (sequence
number of the next new (non-retransmission) packet to be sent) at that
moment is registered as ack_seq. A retransmitted packet is lost if it 
is not SACKed, and its ack_seq is smaller than the sequence number of 
any SACKed packet.

An ACK packet can have up to three SACK blocks. A SACK block has a
"start sequence number (start_seq)" and an "end sequence number
(end_seq)" of received packets. In the current implementation of
tcp_sacktag_write_queue(), if an ACK packet has multiple SACK blocks,
the SACK blocks are sorted by the start_seq in an ascending order, and
processed in the order.  For scoreboarding packets in retransmission
queue, the queue is scanned from the the snd_una (the lowest sequence
number of not yet ACKed packets) to the end_seq of the SACK block. To
optimize the scanning process, the next SACK block is processed not
from the snd_una but from the end_seq of the previously processed SACK
block. In the current implementation, for detecting the loss of
retransmitted packets, the ack_seq of a retransmitted packet is
compared with the end_seq of each SACK block during the scoreboarding.
Therefore, a retransmitted packet which ack_seq is smaller than the
end_seq of the last SACK block but larger than that of the currently
being processed SACK block can not be detected as lost.
Such undetected loss may eventually cause an RTO and performance may 
be degraded.

PATCH #1 fixes this problem by comparing the the ack_seq with the
largest end_seq of the SACK blocks.

In addition, some of SACK blocks in an ACK packet may be already
reported in preceding ACK packets. PATCH #2 optimizes processing by
skipping such already reported SACK blocks. Usually, only the first
SACK block of an ACK packet is the new one to be processed. 
Therefore, in most cases, applying PATCH #2 also solves the problem. 
However, to ensure accurate processing in case there are multiple 
new SACK blocks in an ACK packet, PATCH #2 should be applied in 
conjunction with PATCH #1.

The experimental network is as follows:

Node A ----> Router -------> Delay -------> Node B
            (Policing rate:  emulator
   	     500Mbps)        (RTT: 20ms)

You can find the detail of our experimental setting at
http://projects.gtrc.aist.go.jp/gnet/sack-bug.html

We transferred 1 GByte of data from Node A to Node B for ten times. 
Here is the performance comparison of the cases with and without 
these patches.

	Ave. goodput	Ave. RTO
2.6.22	376 Mbps	26
PATCH#1	481 Mbps	0
PATCH#2	483 Mbps	0

In the vanilla kernel, several RTOs (TCPTimeouts + TCPSackRecoveryFail)
occur.  On the other hand, our patches eliminate RTOs and improve the
average goodput by 28%.

Any comments and ideas would be appreciated.

Regards,
Ryousei Takano
