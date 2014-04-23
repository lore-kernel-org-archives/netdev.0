From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH 0/2] Fix macvtap checksum errors in bridge mode
Date: Wed, 23 Apr 2014 12:51:39 -0400
Message-ID: <1398271901-32534-1-git-send-email-vyasevic@redhat.com>
Cc: daniel.lezcano@free.fr, nightnord@gmail.com, kaber@trash.net,
	eric.dumazet@gmail.com, mst@redhat.com, jasowang@redhat.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23074 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755806AbaDWQwC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 12:52:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following is a problematic configuration:

 VM1: virtio-net device connected to macvtap0@eth0
 VM2: e1000 device connect to macvtap1@eth0

The problem is is that virtio-net supports checksum offloading
and thus sends the packets to the host with CHECKSUM_PARTIAL set.
On the other hand, e1000 does not support any acceleration.

For small TCP packets (and this includes the 3-way handshake),
e1000 end up receiving packets that only have a partial checksum
set.  This causes TCP to fail checksum validation and to drop
packets.  As a result tcp connections can not be established.

The following 2 patches resolve this issue. The first patch adds
a check to the non-gso code path to see if the checksum needs to
be computed.  The second patch reverts an old commit that set
ip_summed to CHECKSUM_UNNECESSARY.  Proper checksum update is
necessary under certain circumstances.

I wend through the old thread
  http://comments.gmane.org/gmane.linux.kernel.containers.lxc.general/1459
and tried the reproducers listed there, but could not cause
invalid checksum to trigger with this series.
Daniel and Andrian, if you have the time please try this patch
set to see if you still see the old checksum issues.

Vlad Yasevich (2):
  mactap: Fix checksum errors for non-gso packets in bridge mode
  Revert "macvlan : fix checksums error when we are in bridge mode"

 drivers/net/macvlan.c | 3 ---
 drivers/net/macvtap.c | 7 +++++++
 2 files changed, 7 insertions(+), 3 deletions(-)

-- 
1.9.0
