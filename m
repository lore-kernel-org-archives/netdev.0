From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH 1/2] [TCP]: MTUprobe: receiver window & data available
 checks fixed
Date: Thu, 22 Nov 2007 15:11:35 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711221420110.2613@kivilampi-30.cs.helsinki.fi>
References: <11956608882424-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11956608882602-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20071122092729.GA7897@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1031373873-1195735157=:2613"
Cc: John Heffner <jheffner@psc.edu>, Netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43990 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055AbXKVNLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2007 08:11:38 -0500
In-Reply-To: <20071122092729.GA7897@gondor.apana.org.au>
Content-ID: <Pine.LNX.4.64.0711221440410.2613@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1031373873-1195735157=:2613
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0711221440411.2613@kivilampi-30.cs.helsinki.fi>

On Thu, 22 Nov 2007, Herbert Xu wrote:

> On Wed, Nov 21, 2007 at 06:01:27PM +0200, Ilpo Järvinen wrote:
> >
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> Thanks for the patch Ilpo!
>
> I've just got a couple small questions.

...Thanks for actually commenting it. :-)

> > @@ -1307,6 +1308,7 @@ static int tcp_mtu_probe(struct sock *sk)
> >  	/* Very simple search strategy: just double the MSS. */
> >  	mss_now = tcp_current_mss(sk, 0);
> >  	probe_size = 2*tp->mss_cache;
> > +	size_needed = probe_size + (tp->reordering + 1) * mss_now;
> 
> Should we use mss_now here or mss_cache? It would seem that an
> over-estimate would be safer than an under-estimate.

You're right, it's definately better that way... New version below, I
just tweaked that line inline :-).

> Also should that be Tcprexmtthresh segments at the current MTU
> or the probed MTU?

...We'll be using current MTU sized packets except for the probe until
the probe has succeeded, only from that point onward will the new packets 
will be sent with the larger MTU. If the probe succeeds, all reservations 
we made here are no longer meaningful or necessary anyway. The point is to 
detect failure by having fast recovery triggered by the current MTU sized 
packets that follow the probe, that's because we "know" that those smaller 
packets are not going to be dropped by the path even though an oversize 
probe would be.


-- 
 i.


--

[PATCH 1/2] [TCP]: MTUprobe: receiver window & data available checks fixed

It seems that the checked range for receiver window check should
begin from the first rather than from the last skb that is going
to be included to the probe. And that can be achieved without
reference to skbs at all, snd_nxt and write_seq provides the
correct seqno already. Plus, it SHOULD account packets that are
necessary to trigger fast retransmit [RFC4821].

Location of snd_wnd < probe_size/size_needed check is bogus
because it will cause the other if() match as well (due to
snd_nxt >= snd_una invariant).

Removed dead obvious comment.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |   17 ++++++++---------
 1 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 30d6737..ff22ce8 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1289,6 +1289,7 @@ static int tcp_mtu_probe(struct sock *sk)
 	struct sk_buff *skb, *nskb, *next;
 	int len;
 	int probe_size;
+	int size_needed;
 	unsigned int pif;
 	int copy;
 	int mss_now;
@@ -1307,6 +1308,7 @@ static int tcp_mtu_probe(struct sock *sk)
 	/* Very simple search strategy: just double the MSS. */
 	mss_now = tcp_current_mss(sk, 0);
 	probe_size = 2*tp->mss_cache;
+	size_needed = probe_size + (tp->reordering + 1) * tp->mss_cache;
 	if (probe_size > tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_high)) {
 		/* TODO: set timer for probe_converge_event */
 		return -1;
@@ -1316,18 +1318,15 @@ static int tcp_mtu_probe(struct sock *sk)
 	len = 0;
 	if ((skb = tcp_send_head(sk)) == NULL)
 		return -1;
-	while ((len += skb->len) < probe_size && !tcp_skb_is_last(sk, skb))
+	while ((len += skb->len) < size_needed && !tcp_skb_is_last(sk, skb))
 		skb = tcp_write_queue_next(sk, skb);
-	if (len < probe_size)
+	if (len < size_needed)
 		return -1;
 
-	/* Receive window check. */
-	if (after(TCP_SKB_CB(skb)->seq + probe_size, tp->snd_una + tp->snd_wnd)) {
-		if (tp->snd_wnd < probe_size)
-			return -1;
-		else
-			return 0;
-	}
+	if (tp->snd_wnd < size_needed)
+		return -1;
+	if (after(tp->snd_nxt + size_needed, tp->snd_una + tp->snd_wnd))
+		return 0;
 
 	/* Do we need to wait to drain cwnd? */
 	pif = tcp_packets_in_flight(tp);
-- 
1.5.0.6

---696243703-1031373873-1195735157=:2613--
