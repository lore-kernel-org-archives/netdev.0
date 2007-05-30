From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP]: Fix GSO ignorance of pkts_acked arg (cong.cntrl
 modules)
Date: Wed, 30 May 2007 12:10:06 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705301206130.14736@kivilampi-30.cs.helsinki.fi>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20070526.164418.115928217.davem@davemloft.net>
 <Pine.LNX.4.64.0705271039060.2532@kivilampi-30.cs.helsinki.fi>
 <20070527.021104.74747736.davem@davemloft.net>
 <Pine.LNX.4.64.0705271319310.2663@kivilampi-30.cs.helsinki.fi>
 <20070527140430.GA30299@galon.ev-en.org> <Pine.LNX.4.64.0705271933440.2832@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0705281253340.14736@kivilampi-30.cs.helsinki.fi>
 <20070529091415.03a14216@freepuppy> <Pine.LNX.4.64.0705292150390.23565@kivilampi-30.cs.helsinki.fi>
 <20070529131951.1d9a5b84@freepuppy> <Pine.LNX.4.64.0705292335080.23565@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-305175560-1180516206=:14736"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52290 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbXE3JKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 05:10:09 -0400
In-Reply-To: <Pine.LNX.4.64.0705292335080.23565@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-305175560-1180516206=:14736
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 29 May 2007, Ilpo Järvinen wrote:

> [PATCH] [TCP]: Fix GSO ignorance of pkts_acked arg (cong.cntrl modules)
> 
> The code used to ignore GSO completely, passing either way too
> small or zero pkts_acked when GSO skb or part of it got ACKed.
> In addition, there is no need to calculate the value in the loop
> but simple arithmetics after the loop is sufficient. Pkts_acked
> callback of congestion control modules include SYN as a packet
> for now on.

Based on feedback from Stephen, I changed the commit msg bit
clearer, the patch remains the same.

[PATCH] [TCP]: Fix GSO ignorance of pkts_acked arg (cong.cntrl modules)

The code used to ignore GSO completely, passing either way too
small or zero pkts_acked when GSO skb or part of it got ACKed.
In addition, there is no need to calculate the value in the loop
but simple arithmetics after the loop is sufficient. There is
no need to handle SYN case specially because congestion control
modules are not yet initialized when FLAG_SYN_ACKED is set.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 38cb25b..74683d8 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2407,8 +2407,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, __s32 *seq_rtt_p)
 	struct sk_buff *skb;
 	__u32 now = tcp_time_stamp;
 	int acked = 0;
+	int prior_packets = tp->packets_out;
 	__s32 seq_rtt = -1;
-	u32 pkts_acked = 0;
 	ktime_t last_ackt = ktime_set(0,0);
 
 	while ((skb = tcp_write_queue_head(sk)) &&
@@ -2437,7 +2437,6 @@ static int tcp_clean_rtx_queue(struct sock *sk, __s32 *seq_rtt_p)
 		 */
 		if (!(scb->flags & TCPCB_FLAG_SYN)) {
 			acked |= FLAG_DATA_ACKED;
-			++pkts_acked;
 		} else {
 			acked |= FLAG_SYN_ACKED;
 			tp->retrans_stamp = 0;
@@ -2481,6 +2480,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, __s32 *seq_rtt_p)
 	}
 
 	if (acked&FLAG_ACKED) {
+		u32 pkts_acked = prior_packets - tp->packets_out;
 		const struct tcp_congestion_ops *ca_ops
 			= inet_csk(sk)->icsk_ca_ops;
 
-- 
1.5.0.6

---696243703-305175560-1180516206=:14736--
