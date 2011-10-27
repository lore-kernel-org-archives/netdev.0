From: Neil Horman <nhorman@tuxdriver.com>
Subject: Introduce FCLONE_SCRATCH skbs to reduce stack memory useage and napi jitter
Date: Thu, 27 Oct 2011 15:53:36 -0400
Message-ID: <1319745221-30880-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38377 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567Ab1J0TyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 15:54:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I had this idea awhile ago while I was looking at the receive path for multicast
frames.   The top of the mcast recieve path (in __udp4_lib_mcast_deliver, has a
loop in which we traverse a hash list linearly, looking for sockets that are
listening to a given multicast group.  For each matching socket we clone the skb
to enqueue it to the corresponding socket.  This creates two problems:

1) Application driven jitter in the receive path
   As you add processes that listen to the same multcast group, you increase the
number of iterations you have to preform in this loop, which can lead to
increases in the amount of time you spend processing each frame in softirq
context, expecially if you are memory constrained, and the skb_clone operation
has to call all the way back into the buddy allocator for more ram.  This can
lead to needlessly dropped frames as rx latency increases in the stack.

2) Increased memory usage
   As you increase the number of listeners to a multicast group, you directly
increase the number of times you clone and skb, putting increased memory
pressure on the system.

while neither of these problems is a huge concern, I thought it would be nice if
we could mitigate the effects of increased application instances on performance
in this area.  As such I came up with this patch set.  I created a new skb
fclone type called FCLONE_SCRATCH.  When available, it commandeers the
internally fragmented space of an skb data buffer and uses that to allocate
additional skbs during the clone operation. Since the skb->data area is
allocated with a kmalloc operation (and is therefore nominally a power of 2 in
size), and nominally network interfaces tend to have an mtu of around 1500
bytes, we typically can reclaim several hundred bytes of space at the end of an
skb (more if the incomming packet is not a full MTU in size).  This space, being
exclusively accessible to the softirq doing the reclaim, can be quickly accesed
without the need for additional locking, potntially providing lower jitter in
napi context per frame during a receive operation, as well as some memory
savings.

I'm still collecting stats on its performance, but I thought I would post now to
get some early reviews and feedback on it.

Thanks & Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
 
