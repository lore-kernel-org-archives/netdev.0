From: Natale Patriciello <natale.patriciello@gmail.com>
Subject: [RFC PATCH v1 4/5] tcp: Add initial delay to allow data queueing
Date: Fri, 28 Jul 2017 21:59:18 +0200
Message-ID: <20170728195919.10099-5-natale.patriciello@gmail.com>
References: <20170728195919.10099-1-natale.patriciello@gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
        Ahmed Said <ahmed.said@uniroma2.it>,
        Natale Patriciello <natale.patriciello@gmail.com>,
        Francesco Zampognaro <zampognaro@ing.uniroma2.it>,
        Cesare Roseti <roseti@ing.uniroma2.it>
To: "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34187 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752876AbdG1UA7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 16:00:59 -0400
Received: by mail-wm0-f65.google.com with SMTP id x64so4267819wmg.1
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 13:00:58 -0700 (PDT)
In-Reply-To: <20170728195919.10099-1-natale.patriciello@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To be able to correctly send out data respecting the congestion control timing
requests, it is necessary to add a small delay at the beginning of the transfer.
It is necessary because, if there is no data in the TCP queue, the sending timer
is useless (and therefore not set). But, it can happen (especially at the
beginning) that an application can not appropriately fill the TCP queue,
therefore making the respect of the timing constraint set by the congestion
control impossible.

Signed-off-by: Natale Patriciello <natale.patriciello@gmail.com>
Tested-by: Ahmed Said <ahmed.said@uniroma2.it>
---
 net/ipv4/tcp_output.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 357b9cd5019e..febce533c0a0 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -64,6 +64,7 @@ int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 
 static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 			   int push_one, gfp_t gfp);
+static void __tcp_push_pending_frames_handler(unsigned long data);
 
 /* Account for new data that has been sent to the network. */
 static void tcp_event_new_data_sent(struct sock *sk, const struct sk_buff *skb)
@@ -1034,6 +1035,18 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	if (skb->len != tcp_header_size) {
 		tcp_event_data_sent(tp, sk);
 		tp->data_segs_out += tcp_skb_pcount(skb);
+	} else {
+		if (timer_pending(&tp->send_timer) == 0 &&
+		    (!(tcb->tcp_flags & TCPHDR_SYN))) {
+			/* Timer is not running, adding a bit of delay
+			 * to allow data to be queued.
+			 */
+			setup_timer(&tp->send_timer,
+				    __tcp_push_pending_frames_handler,
+				    (unsigned long)sk);
+			mod_timer(&tp->send_timer,
+				  jiffies + msecs_to_jiffies(5));
+		}
 	}
 
 	if (after(tcb->end_seq, tp->snd_nxt) || tcb->seq == tcb->end_seq)
-- 
2.13.2
