From: Fan Du <fan.du@intel.com>
Subject: [PATCH RFC] ipv4 tcp: Use fine granularity to increase probe_size for tcp pmtu
Date: Wed,  4 Feb 2015 16:10:32 +0800
Message-ID: <1423037432-13996-1-git-send-email-fan.du@intel.com>
Cc: jesse@nicira.com, pshelar@nicira.com, dev@openvswitch.org,
	fengyuleidian0615@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7161 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753786AbbBDIOl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2015 03:14:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A couple of month ago, I proposed a fix for over-MTU-sized vxlan
packet loss at link[1], neither by fragmenting the tunnelled vxlan
packet, nor pushing back PMTU ICMP need fragmented message is 
accepted by community. The upstream workaround is by adjusting
guest mtu smaller or host mtu bigger, or by making virtio driver
auto-tuned guest mtu(no consensus by now). Note, gre tunnel also
suffer the over-MTU-sized packet loss.

While For TCPv4 case, this issue could be solved by using
Packetization Layer Path MTU Discovery which is defined as [3] 
from commit: 5d424d5a674f ("[TCP]: MTU probing").

echo 1 > /proc/sys/net/ipv4/tcp_mtu_probing

One drawback of tcp level mtu probing is:The original strategy is
double mss_cache for each probe, this is way too aggressive for 
over-MTU-sized vxlan packet loss issue from the performance result.
Also, the probing is characterized by tcp retransmission, which usual
taking 6 seconds from the first drop packet to normal connectivity
recovery.

By incrementing 25% of original mss_cache each time, performance
boost from ~1.3Gbits/s(mss_cache 1024Bytes) to ~1.55Gbits/s(
mss_cache 1250Bytes), more generic theme could be used there for
other tunnel technology.

No sure why tcp level mtu probing got disabled by default, any
historic known issues or pitfalls?

[1]: http://www.spinics.net/lists/netdev/msg306502.html
[2]: http://www.ietf.org/rfc/rfc4821.txt

Signed-off-by: Fan Du <fan.du@intel.com>
---
 net/ipv4/tcp_output.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 20ab06b..ab7e46b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1856,9 +1856,11 @@ static int tcp_mtu_probe(struct sock *sk)
 	    tp->rx_opt.num_sacks || tp->rx_opt.dsack)
 		return -1;
 
-	/* Very simple search strategy: just double the MSS. */
+	/* Very simple search strategy:
+	 * Increment 25% of orignal MSS forward
+	 */
 	mss_now = tcp_current_mss(sk);
-	probe_size = 2 * tp->mss_cache;
+	probe_size = (tp->mss_cache + (tp->mss_cache >> 2));
 	size_needed = probe_size + (tp->reordering + 1) * tp->mss_cache;
 	if (probe_size > tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_high)) {
 		/* TODO: set timer for probe_converge_event */
-- 
1.7.1
