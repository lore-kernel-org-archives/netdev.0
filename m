From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 0/9]: tcp-2.6 patchset
Date: Tue, 29 May 2007 23:58:39 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705292335080.23565@kivilampi-30.cs.helsinki.fi>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20070526.164418.115928217.davem@davemloft.net>
 <Pine.LNX.4.64.0705271039060.2532@kivilampi-30.cs.helsinki.fi>
 <20070527.021104.74747736.davem@davemloft.net>
 <Pine.LNX.4.64.0705271319310.2663@kivilampi-30.cs.helsinki.fi>
 <20070527140430.GA30299@galon.ev-en.org> <Pine.LNX.4.64.0705271933440.2832@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0705281253340.14736@kivilampi-30.cs.helsinki.fi>
 <20070529091415.03a14216@freepuppy> <Pine.LNX.4.64.0705292150390.23565@kivilampi-30.cs.helsinki.fi>
 <20070529131951.1d9a5b84@freepuppy>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-2106044594-1180472319=:23565"
Cc: Baruch Even <baruch@ev-en.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33962 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759048AbXE2U6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2007 16:58:43 -0400
In-Reply-To: <20070529131951.1d9a5b84@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-2106044594-1180472319=:23565
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 29 May 2007, Stephen Hemminger wrote:

> On Tue, 29 May 2007 23:07:00 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > On Tue, 29 May 2007, Stephen Hemminger wrote:
> > 
> > > Since we don't invoke congestion control modules until after the SYN
> > > handshake this is not a problem.
> > 
> > Just curious, do you mean that cc modules cannot measure, e.g., initial
> > RTT through this mechanism (though they could do that in init() cb then
> > I suppose)... Or do you mean that they are called already for the ACK
> > that completes the SYN handshake and therefore its skb is being cleaned 
> > from the queue right now (this is the case I above refer to)? 
> > In the first case the decrementer code is NOP. If the latter, then it
> > is just interface specification question, i.e., if SYNs are treated as 
> > zero or one in num_acked for the pkts_acked callback (I have no opinion
> > on this but was just trying to make sure cc modules get what they
> > expect :-)). 
> 
> We don't switch a socket out of Reno until after the initial handshake.

...It's still not very clear to me what exactly your "after" means (both 
here and in your earlier description), i.e., whether clean_rtx_queue call 
that cleans SYN skb from the queue happens before or after the switch out 
of reno or not... If I understand the code correctly, this specific 
clean_rtx_queue call happens after "your after" but I could be 
misunderstanding the current 3-way handshake code. :-)

> As an interface, it makes sense to keep the API with the SYN counting
> as a packet.

Ok, this one answers the remaining question concerning the patch, here
is it without the decrementer for SYN case (which IMHO wasn't very 
beautiful looking anyway :-)).

Dave, please consider this to net-2.6. It could be a stable candidate 
as well, haven't tested yet if it applies cleanly to stable:


[PATCH] [TCP]: Fix GSO ignorance of pkts_acked arg (cong.cntrl modules)

The code used to ignore GSO completely, passing either way too
small or zero pkts_acked when GSO skb or part of it got ACKed.
In addition, there is no need to calculate the value in the loop
but simple arithmetics after the loop is sufficient. Pkts_acked
callback of congestion control modules include SYN as a packet
for now on.

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

---696243703-2106044594-1180472319=:23565--
