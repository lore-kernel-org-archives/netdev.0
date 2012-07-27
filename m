From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH] tcp: perform DMA to userspace only if there is a task waiting
 for it
Date: Fri, 27 Jul 2012 16:05:06 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1207271556320.11375@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jiri Bohac <jbohac@suse.cz>
To: Chris Leech <christopher.leech@intel.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42136 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751303Ab2G0OFO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2012 10:05:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Back in 2006, commit 1a2449a87b ("[I/OAT]: TCP recv offload to I/OAT") 
added support for receive offloading to IOAT dma engine if available.

The code in tcp_rcv_established() tries to perform early DMA copy if 
applicable. It however does so without checking whether the userspace task 
is actually expecting the data in the buffer.

This is not a problem under normal circumstances, but there is a corner 
case where this doesn't work -- and that's when MSG_TRUNC flag to 
recvmsg() is used.

If the IOAT dma engine is not used, the code properly checks whether there 
is a valid ucopy.task and the socket is owned by userspace, but misses the 
check in the dmaengine case.

This problem can be observed in real trivially -- for example 'tbench' is 
a good reproducer, as it makes a heavy use of MSG_TRUNC. On systems 
utilizing IOAT, you will soon find tbench waiting indefinitely in 
sk_wait_data(), as the data have already been early-copied in 
tcp_rcv_established() using dma engine.

This patch introduces the same check we are performing in the simple iovec 
copy case to the IOAT case as well. It fixes the indefinite 
recvmsg(MSG_TRUNC) hangs.

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 net/ipv4/tcp_input.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3e07a64..f8059f9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5475,7 +5475,10 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			if (tp->copied_seq == tp->rcv_nxt &&
 			    len - tcp_header_len <= tp->ucopy.len) {
 #ifdef CONFIG_NET_DMA
-				if (tcp_dma_try_early_copy(sk, skb, tcp_header_len)) {
+				if (tp->ucopy.task == current &&
+						sock_owned_by_user(sk) &&
+						tcp_dma_try_early_copy(sk,
+							skb, tcp_header_len)) {
 					copied_early = 1;
 					eaten = 1;
 				}
-- 
Jiri Kosina
SUSE Labs
