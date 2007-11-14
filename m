From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Re : Oops preceded by WARNING: at net/ipv4/tcp_input.c:1571
 tcp_remove_reno_sacks()
Date: Wed, 14 Nov 2007 15:32:58 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711141245050.23382@kivilampi-30.cs.helsinki.fi>
References: <902344.71635.qm@web26211.mail.ukl.yahoo.com>
 <Pine.LNX.4.64.0711111216170.12719@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0711132321340.3997@kivilampi-30.cs.helsinki.fi>
 <20071113.210431.141662500.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1596936201-1195037220=:23382"
Cc: guichaz@yahoo.fr, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49706 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753049AbXKNNdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 08:33:00 -0500
In-Reply-To: <20071113.210431.141662500.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0711141521390.16864@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1596936201-1195037220=:23382
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0711141521391.16864@kivilampi-30.cs.helsinki.fi>

On Tue, 13 Nov 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Tue, 13 Nov 2007 23:35:39 +0200 (EET)
> 
> > [PATCH] [TCP] FRTO: Plug potential LOST-bit leak
> > 
> > It might be possible that, in some extreme scenario that
> > I just cannot now construct in my mind, end_seq <=
> > frto_highmark check does not match causing the lost_out
> > and LOST bits become out-of-sync due to clearing and
> > recounting in the loop.
> > 
> > This may fix LOST-bit leak reported by Chazarain Guillaume
> > <guichaz@yahoo.fr>.
> > 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> This patch looks correct to me, so I added it to net-2.6
> 
> Chazarain please let us know if it does indeed cure your
> problem.

Ok, now after one night more, I think I know what it was, this
indeed "cured" it (and IMHO we can leave it there too).

...But here's a fix that very well explains why the frto_highmark
check could give a bit strange results :-).

--
[PATCH] [TCP] FRTO: Clear frto_highmark only after process_frto that uses it

I broke this in commit 3de96471bd7fb76406e975ef6387abe3a0698149.
tcp_process_frto should always see a valid frto_highmark. An
invalid frto_highmark (zero) is very likely what ultimately
caused a seqno compare in tcp_frto_enter_loss to do the wrong
leading to the LOST-bit leak.

Having LOST-bits integry ensured like done after commit
23aeeec365dcf8bc87fae44c533e50d0bb4f23cc won't hurt. It may
still be useful in some other, possibly legimate, scenario.

Reported by Chazarain Guillaume <guichaz@yahoo.fr>.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3f126ec..0f0c1c9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3113,11 +3113,11 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 	/* See if we can take anything off of the retransmit queue. */
 	flag |= tcp_clean_rtx_queue(sk, &seq_rtt, prior_fackets);
 
+	if (tp->frto_counter)
+		frto_cwnd = tcp_process_frto(sk, flag);
 	/* Guarantee sacktag reordering detection against wrap-arounds */
 	if (before(tp->frto_highmark, tp->snd_una))
 		tp->frto_highmark = 0;
-	if (tp->frto_counter)
-		frto_cwnd = tcp_process_frto(sk, flag);
 
 	if (tcp_ack_is_dubious(sk, flag)) {
 		/* Advance CWND, if state allows this. */
-- 
1.5.0.6

---696243703-1596936201-1195037220=:23382--
