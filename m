From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net] tcp: Fix SOF_TIMESTAMPING_TX_ACK when handling dup acks
Date: Mon, 18 Apr 2016 15:39:53 -0700
Message-ID: <1461019193-3034571-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:39277 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751164AbcDRWj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 18:39:56 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u3IMd5ce002726
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:39:55 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 22d1yjthbr-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:39:55 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.103.99.97) with ESMTP	id
 7808cdae05b611e690fd0002c9931860-88efcc50 for <netdev@vger.kernel.org>;	Mon,
 18 Apr 2016 15:39:53 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Assuming SOF_TIMESTAMPING_TX_ACK is on. When dup acks are received,
it could incorrectly think that a skb has already
been acked and queue a SCM_TSTAMP_ACK cmsg to the
sk->sk_error_queue.

In tcp_ack_tstamp(), it checks
'between(shinfo->tskey, prior_snd_una, tcp_sk(sk)->snd_una - 1)'.
If prior_snd_una == tcp_sk(sk)->snd_una like the following packetdrill
script, between() returns true but the tskey is actually not acked.
e.g. try between(3, 2, 1).

The fix is to replace between() with one before() and one !before().
By doing this, the -1 offset on the tcp_sk(sk)->snd_una can also be
removed.

A packetdrill script is used to reproduce the dup ack scenario.
Due to the lacking cmsg support in packetdrill (may be I
cannot find it),  a BPF prog is used to kprobe to
sock_queue_err_skb() and print out the value of
serr->ee.ee_data.

Both the packetdrill and the bcc BPF script is attached at the end of
this commit message.

BPF Output Before Fix:
~~~~~~
      <...>-2056  [001] d.s.   433.927987: : ee_data:1459  #incorrect
packetdrill-2056  [001] d.s.   433.929563: : ee_data:1459  #incorrect
packetdrill-2056  [001] d.s.   433.930765: : ee_data:1459  #incorrect
packetdrill-2056  [001] d.s.   434.028177: : ee_data:1459
packetdrill-2056  [001] d.s.   434.029686: : ee_data:14599

BPF Output After Fix:
~~~~~~
      <...>-2049  [000] d.s.   113.517039: : ee_data:1459
      <...>-2049  [000] d.s.   113.517253: : ee_data:14599

BCC BPF Script:
~~~~~~
#!/usr/bin/env python

from __future__ import print_function
from bcc import BPF

bpf_text = """
#include <uapi/linux/ptrace.h>
#include <net/sock.h>
#include <bcc/proto.h>
#include <linux/errqueue.h>

#ifdef memset
#undef memset
#endif

int trace_err_skb(struct pt_regs *ctx)
{
	struct sk_buff *skb = (struct sk_buff *)ctx->si;
	struct sock *sk = (struct sock *)ctx->di;
	struct sock_exterr_skb *serr;
	u32 ee_data = 0;

	if (!sk || !skb)
		return 0;

	serr = SKB_EXT_ERR(skb);
	bpf_probe_read(&ee_data, sizeof(ee_data), &serr->ee.ee_data);
	bpf_trace_printk("ee_data:%u\\n", ee_data);

	return 0;
};
"""

b = BPF(text=bpf_text)
b.attach_kprobe(event="sock_queue_err_skb", fn_name="trace_err_skb")
print("Attached to kprobe")
b.trace_print()

Packetdrill Script:
~~~~~~
+0 `sysctl -q -w net.ipv4.tcp_min_tso_segs=10`
+0 `sysctl -q -w net.ipv4.tcp_no_metrics_save=1`
+0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
+0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
+0 bind(3, ..., ...) = 0
+0 listen(3, 1) = 0

0.100 < S 0:0(0) win 32792 <mss 1460,sackOK,nop,nop,nop,wscale 7>
0.100 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 7>
0.200 < . 1:1(0) ack 1 win 257
0.200 accept(3, ..., ...) = 4
+0 setsockopt(4, SOL_TCP, TCP_NODELAY, [1], 4) = 0

+0 setsockopt(4, SOL_SOCKET, 37, [2688], 4) = 0
0.200 write(4, ..., 1460) = 1460
0.200 write(4, ..., 13140) = 13140

0.200 > P. 1:1461(1460) ack 1
0.200 > . 1461:8761(7300) ack 1
0.200 > P. 8761:14601(5840) ack 1

0.300 < . 1:1(0) ack 1 win 257 <sack 1461:2921,nop,nop>
0.300 < . 1:1(0) ack 1 win 257 <sack 1461:4381,nop,nop>
0.300 < . 1:1(0) ack 1 win 257 <sack 1461:5841,nop,nop>
0.300 > P. 1:1461(1460) ack 1
0.400 < . 1:1(0) ack 14601 win 257

0.400 close(4) = 0
0.400 > F. 14601:14601(0) ack 1
0.500 < F. 1:1(0) ack 14602 win 257
0.500 > . 14602:14602(0) ack 2

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e6e65f7..0edb071 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3098,7 +3098,8 @@ static void tcp_ack_tstamp(struct sock *sk, struct sk_buff *skb,
 
 	shinfo = skb_shinfo(skb);
 	if ((shinfo->tx_flags & SKBTX_ACK_TSTAMP) &&
-	    between(shinfo->tskey, prior_snd_una, tcp_sk(sk)->snd_una - 1))
+	    !before(shinfo->tskey, prior_snd_una) &&
+	    before(shinfo->tskey, tcp_sk(sk)->snd_una))
 		__skb_tstamp_tx(skb, NULL, sk, SCM_TSTAMP_ACK);
 }
 
-- 
2.5.1
