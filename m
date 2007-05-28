From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 0/9]: tcp-2.6 patchset
Date: Mon, 28 May 2007 13:27:03 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705281253340.14736@kivilampi-30.cs.helsinki.fi>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20070526.164418.115928217.davem@davemloft.net>
 <Pine.LNX.4.64.0705271039060.2532@kivilampi-30.cs.helsinki.fi>
 <20070527.021104.74747736.davem@davemloft.net>
 <Pine.LNX.4.64.0705271319310.2663@kivilampi-30.cs.helsinki.fi>
 <20070527140430.GA30299@galon.ev-en.org> <Pine.LNX.4.64.0705271933440.2832@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1438804588-1180348023=:14736"
Cc: Baruch Even <baruch@ev-en.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36766 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751476AbXE1K1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2007 06:27:07 -0400
In-Reply-To: <Pine.LNX.4.64.0705271933440.2832@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1438804588-1180348023=:14736
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Sun, 27 May 2007, Ilpo Järvinen wrote:

> On Sun, 27 May 2007, Baruch Even wrote:
> 
> > * Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi> [070527 14:16]:
> > > 
> > > Thus, my original question basically culminates in this: should cc
> > > modules be passed number of packets acked or number of skbs acked?
> > > ...The latter makes no sense to me unless the value is intented to
> > > be interpreted as number of timestamps acked or something along those 
> > > lines. ...I briefly tried looking up for documentation for cc module 
> > > interface but didn't find anything useful about this, and thus asked in 
> > > the first place...
> > 
> > At least the htcp module that I wrote assumes that the number is actual
> > number of tcp packets so GSO should be considered.
> 
> Thanks for the info! It is what I suspected... ...I'll write a patch for 
> it tomorrow against net-2.6... Dave, beware that it will partially 
> overlap with the changes made in the patch 8, so you might choose to put 
> the patch 8 on hold until this issue is first resolved...
> 
> > The consequences of this bug are not too large but it does make all
> > congestion control algorithms a lot less aggressive. On my machines GSO
> > is disabled by default (e1000 at 100mbps & Tigon3 @ 1Gbps).
> 
> Agreed, that's my impression too. However, some algorithms do things
> like > 0 checks for it, so it might disturb their dynamics even more
> than in the "too small value" cases...

Hmm, there seems to be another case that I'm not too sure of...
Please check the alternative I choose for SYN handling below...

...hmm... While exploring this SYN thingie, I noticed that commit 
164891aadf1721fca4dce473bb0e0998181537c6 drops !FLAG_RETRANS_DATA_ACKED 
check from rtt_sample call (when combining it with pkts_acked call).
I hope that's intentional?!? ...the commit message didn't say anything 
about it nor was anything in cc modules changed to accomodate that.


[PATCH] [TCP]: Fix GSO ignorance of pkts_acked arg (cong.cntrl modules)

The code used to ignore GSO completely, passing either way too
small or zero pkts_acked when GSO skb or part of it got ACKed.
In addition, there is no need to calculate the value in the loop
but simple arithmetics after the loop is sufficient.

It is not very clear how SYN segments should be handled, so I
choose to follow the previous implementation in this respect.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 38cb25b..7dfaabb 100644
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
@@ -2481,9 +2480,13 @@ static int tcp_clean_rtx_queue(struct sock *sk, __s32 *seq_rtt_p)
 	}
 
 	if (acked&FLAG_ACKED) {
+		u32 pkts_acked = prior_packets - tp->packets_out;
 		const struct tcp_congestion_ops *ca_ops
 			= inet_csk(sk)->icsk_ca_ops;
 
+		if (acked & FLAG_SYN_ACKED)
+			pkts_acked--;
+
 		tcp_ack_update_rtt(sk, acked, seq_rtt);
 		tcp_ack_packets_out(sk);
 
-- 
1.5.0.6

---696243703-1438804588-1180348023=:14736--
