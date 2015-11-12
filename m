From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH] ip_tunnel: disable preemption when updating per-cpu tstats
Date: Thu, 12 Nov 2015 16:30:12 +0100
Message-ID: <1447342212-5543-1-git-send-email-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, tgraf@suug.ch,
	Tom Herbert <tom@herbertland.com>,
	Jiri Benc <jbenc@redhat.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drivers like vxlan use the recently introduced
udp_tunnel_xmit_skb/udp_tunnel6_xmit_skb APIs. udp_tunnel6_xmit_skb
makes use of ip6tunnel_xmit, and ip6tunnel_xmit, after sending the
packet, updates the struct stats using the usual
u64_stats_update_begin/end calls on this_cpu_ptr(dev->tstats).
udp_tunnel_xmit_skb makes use of iptunnel_xmit, which doesn't touch
tstats, so drivers like vxlan, immediately after, call
iptunnel_xmit_stats, which does the same thing - calls
u64_stats_update_begin/end on this_cpu_ptr(dev->tstats).

While vxlan is probably fine (I don't know?), calling a similar function
from, say, an unbound workqueue, on a fully preemptable kernel causes
real issues:

[  188.434537] BUG: using smp_processor_id() in preemptible [00000000] code: kworker/u8:0/6
[  188.435579] caller is debug_smp_processor_id+0x17/0x20
[  188.435583] CPU: 0 PID: 6 Comm: kworker/u8:0 Not tainted 4.2.6 #2
[  188.435607] Call Trace:
[  188.435611]  [<ffffffff8234e936>] dump_stack+0x4f/0x7b
[  188.435615]  [<ffffffff81915f3d>] check_preemption_disabled+0x19d/0x1c0
[  188.435619]  [<ffffffff81915f77>] debug_smp_processor_id+0x17/0x20

The solution would be to protect the whole
this_cpu_ptr(dev->tstats)/u64_stats_update_begin/end blocks with
disabling preemption and then reenabling it.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
 include/net/ip6_tunnel.h | 5 ++++-
 include/net/ip_tunnels.h | 6 ++++--
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index fa915fa..67dc00d 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -90,11 +90,14 @@ static inline void ip6tunnel_xmit(struct sock *sk, struct sk_buff *skb,
 	err = ip6_local_out_sk(sk, skb);
 
 	if (net_xmit_eval(err) == 0) {
-		struct pcpu_sw_netstats *tstats = this_cpu_ptr(dev->tstats);
+		struct pcpu_sw_netstats *tstats;
+		preempt_disable();
+		tstats = this_cpu_ptr(dev->tstats);
 		u64_stats_update_begin(&tstats->syncp);
 		tstats->tx_bytes += pkt_len;
 		tstats->tx_packets++;
 		u64_stats_update_end(&tstats->syncp);
+		preempt_enable();
 	} else {
 		stats->tx_errors++;
 		stats->tx_aborted_errors++;
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index f6dafec..6544955 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -287,12 +287,14 @@ static inline void iptunnel_xmit_stats(int err,
 				       struct pcpu_sw_netstats __percpu *stats)
 {
 	if (err > 0) {
-		struct pcpu_sw_netstats *tstats = this_cpu_ptr(stats);
-
+		struct pcpu_sw_netstats *tstats;
+		preempt_disable();
+		tstats = this_cpu_ptr(stats);
 		u64_stats_update_begin(&tstats->syncp);
 		tstats->tx_bytes += err;
 		tstats->tx_packets++;
 		u64_stats_update_end(&tstats->syncp);
+		preempt_enable();
 	} else if (err < 0) {
 		err_stats->tx_errors++;
 		err_stats->tx_aborted_errors++;
-- 
2.6.2
