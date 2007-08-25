From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 4/5] [TCP]: Discard fuzzy SACK blocks
Date: Sat, 25 Aug 2007 11:47:07 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0708251055400.16256@kivilampi-30.cs.helsinki.fi>
References: <1187615793583-git-send-email-ilpo.jarvinen@helsinki.fi>
 <118761579328-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11876157932029-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20070824.225529.43496742.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1627685441-1188029016=:16256"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45033 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761482AbXHYIrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2007 04:47:10 -0400
In-Reply-To: <20070824.225529.43496742.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0708251104010.16256@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1627685441-1188029016=:16256
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0708251104011.16256@kivilampi-30.cs.helsinki.fi>

On Fri, 24 Aug 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 20 Aug 2007 16:16:32 +0300
> 
> > SACK processing code has been a sort of russian roulette as no
> > validation of SACK blocks is previously attempted. Besides, it
> > is not very clear what all kinds of broken SACK blocks really
> > mean (e.g., one that has start and end sequence numbers
> > reversed). So now close the roulette once and for all.
> > 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> Thanks a lot for coding this up, I like it a lot, applied.
> 
> I have some minor worries about the D-SACK lower bound, but
> it's probably OK and I'm just being paranoid :-)

...Please tell what is your concern rather than hinting :-), or is it 
just a hunch?...

Elsewhere we do a similar checking anyway (I might eventually end up
dropping this check in dsack as duplicate due to other planned changes 
but it's necessary still as the validation is being done in the mainloop 
after check_dsack call):

        /* D-SACK for already forgotten data... Do dumb counting. */
        if (dup_sack &&
            !after(end_seq_0, prior_snd_una) &&
            after(end_seq_0, tp->undo_marker))
                tp->undo_retrans--;

...It's natural that due to HW duplication that we get DSACK below 
undo_marker when state <= CA_CWR. In general, they almost always mean 
exactly that, a HW duplication, so instead IMHO we should account them as 
DSACK lying bit in sack_ok and disable DSACK undos for that flow (similar 
case is !EVER_RETRANS skb gets DSACKed). In theory, it could be delayed 
rexmission or something but we've already lost our state already and 
cannot verify that, so choosing the conservative dsack-lying bit there 
seems fine and should even be right thing for majority of the cases 
anyway. I was planning to do something along those lines later...

The key problem here was (in the previous version that was in tcp-2.6), 
that the whole validation business becomes rather useless, if any invalid 
SACK blocks (those that really aren't DSACK but due to bug, malicious or 
whatever reason) below snd_una gets accepted as DSACK, that's basically 
the thing I wanted to avoid as it will be significant for the half of 
the seqno space... Now there's hopefully a bit smaller window for such
garbage... :-)

Key exits from tcp_is_sackblock_valid reside before those checks anyway, 
so they shouldn't be that problematic in performance wise either. ...I was 
thinking of adding unlikely to the latter checks but wasn't too sure if 
that's wise thing to do as malicious entity could push TCP to do them 
(basically at will), Comments?

One additional note: the mainloop operates anyway only in the seqno range 
above prior_snd_una (earlier skbs already being dropped), that can't ever 
be < undo_marker (so some of the DSACK checks are not yet strictly 
necessary but I wanted to do things right from the beginning as I might 
end up re-placing validation soo ;-)). ...So our discussion currently 
probably covers seqno range that is not going to have any significance at 
all... :-) 


Maybe my "Too old" comment deserves some additional explanation:

[PATCH] [TCP]: More verbose comment to DSACK validation

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8692d0b..cd187c6 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1070,7 +1070,10 @@ static int tcp_is_sackblock_valid(struct tcp_sock *tp, int is_dsack,
 	if (!before(start_seq, tp->undo_marker))
 		return 1;
 
-	/* Too old */
+	/* Too old (it no longer has any significance to TCP state though
+	 * it can be valid; for more complete explanation see comment above
+	 * and similar validation done in tcp_check_dsack())
+	 */
 	if (!after(end_seq, tp->undo_marker))
 		return 0;
 
-- 
1.5.0.6

---696243703-1627685441-1188029016=:16256--
