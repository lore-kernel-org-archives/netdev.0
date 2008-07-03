From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [RFC] support for IEEE 1588
Date: Fri, 4 Jul 2008 01:47:11 +0300
Message-ID: <200807040147.11148.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:1345 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755364AbYGCWtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 18:49:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi everybody,

IEEE 1588 Precision Time Protocol [1] requires hardware timestamping support 
for both RX and TX frames. It seems that in Linux we do not have the support 
required for this protocol to be implemented. 

Any feedback on the approach we are planing to take is greatly appreciated. We 
will follow with a patch at some point, but I just want to check with you 
gurus early, to avoid potential design flaws. If a patch is preferred for 
commenting on, then please ignore this and will come back later with the 
patch.

1. RX path
- add a new field in skb to keep the hardware stamp (hwstamp)
- add a new socket flag to enable RX stamping 
- add a new control message to retrieve the hwstamp from the skb to user-space 
application (for UDP and maybe PF_PACKET)

2. TX path - this is a bit more complicated since we need a new mechanism to 
wait for a packet transmission on wire, from users-space.
- add a new flag for the skb to request TX stamping
- add a new control message to propagate the TX stamping request from 
userspace to the skb
- when the driver will send the packet will get the stamp from the TX 
completion ring; the driver will then propagate the stamp either to
(a) the skb stamp field, or (b) some special structure - this to avoid keeping 
the skb around
- the special structure or the skb will be linked to a special queue in the 
socket and a POLLPRI event will be generated
- the application will use recvmsg and will receive a new control message 
which contains the timestamp from the socket special queue 

We will probably need to associate a cookie with each TX stamping control 
message which will be retrieve in the later control message, so that the 
application can match send packets with timestamps.

[1] http://ieee1588.nist.gov/tutorial-basic.pdf

Thanks,
tavi
