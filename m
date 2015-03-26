From: Jonathan Davies <jonathan.davies@citrix.com>
Subject: [PATCH RFC] tcp: Allow sk_wmem_alloc to exceed sysctl_tcp_limit_output_bytes
Date: Thu, 26 Mar 2015 16:46:53 +0000
Message-ID: <1427388414-31077-1-git-send-email-jonathan.davies@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jonathan Davies <jonathan.davies@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	"David Vrabel" <david.vrabel@citrix.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:34387 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362AbbCZQsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 12:48:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Network drivers with slow TX completion can experience poor network transmit
throughput, limited by hitting the sk_wmem_alloc limit check in tcp_write_xmit.
The limit is 128 KB (by default), which means we are limited to two 64 KB skbs
in-flight. This has been observed to limit transmit throughput with xen-netfront
because its TX completion can be relatively slow compared to physical NIC
drivers.

There have been several modifications to the calculation of the sk_wmem_alloc
limit in the past. Here is a brief history:

 * Since TSQ was introduced, the queue size limit was
       sysctl_tcp_limit_output_bytes.

 * Commit c9eeec26 ("tcp: TSQ can use a dynamic limit") made the limit
       max(skb->truesize, sk->sk_pacing_rate >> 10).
   This allows more packets in-flight according to the estimated rate.

 * Commit 98e09386 ("tcp: tsq: restore minimal amount of queueing") made the
   limit
       max_t(unsigned int, sysctl_tcp_limit_output_bytes,
                           sk->sk_pacing_rate >> 10).
   This ensures at least sysctl_tcp_limit_output_bytes in flight but allowed
   more if rate estimation shows this to be worthwhile.

 * Commit 605ad7f1 ("tcp: refine TSO autosizing") made the limit
       min_t(u32, max(2 * skb->truesize, sk->sk_pacing_rate >> 10),
                  sysctl_tcp_limit_output_bytes).
   This meant that the limit can never exceed sysctl_tcp_limit_output_bytes,
   regardless of what rate estimation suggests. It's not clear from the commit
   message why this significant change was justified, changing
   sysctl_tcp_limit_output_bytes from being a lower bound to an upper bound.

This patch restores the behaviour that allows the limit to grow above
sysctl_tcp_limit_output_bytes according to the rate estimation.

This has been measured to improve xen-netfront throughput from a domU to dom0
from 5.5 Gb/s to 8.0 Gb/s. Or, in the case of transmitting from one domU to
another (on the same host), throughput rose from 2.8 Gb/s to 8.0 Gb/s. In the
latter case, TX completion is especially slow, explaining the large improvement.
These values were measured against 4.0-rc5 using "iperf -c <ip> -i 1" using
CentOS 7.0 VM(s) on Citrix XenServer 6.5 on a Dell R730 host with a pair of Xeon
E5-2650 v3 CPUs.

Fixes: 605ad7f184b6 ("tcp: refine TSO autosizing")
Signed-off-by: Jonathan Davies <jonathan.davies@citrix.com>
---
 net/ipv4/tcp_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1db253e..3a49af8 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2052,7 +2052,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		 * One example is wifi aggregation (802.11 AMPDU)
 		 */
 		limit = max(2 * skb->truesize, sk->sk_pacing_rate >> 10);
-		limit = min_t(u32, limit, sysctl_tcp_limit_output_bytes);
+		limit = max_t(u32, limit, sysctl_tcp_limit_output_bytes);
 
 		if (atomic_read(&sk->sk_wmem_alloc) > limit) {
 			set_bit(TSQ_THROTTLED, &tp->tsq_flags);
-- 
1.9.1
