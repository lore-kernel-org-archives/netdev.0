From: Michal Kubecek <mkubecek@suse.cz>
Subject: tcp: multiple ssthresh reductions before all packets are
 retransmitted
Date: Mon, 16 Jun 2014 17:35:15 +0200
Message-ID: <20140616153515.GA4907@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33320 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752199AbaFPPfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2014 11:35:17 -0400
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
	by mx2.suse.de (Postfix) with ESMTP id 97D8BAD18
	for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 15:35:15 +0000 (UTC)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

while investigating a problem with TCP loss recovery, I noticed that if
large window is lost and another loss happens before the recovery is
finished, ssthresh can drop to very low values. This is especially
harmful with Reno congestion control where cwnd growth in congestion
avoidance phase is linear and rather slow. This is 100% reproducible
on older (3.0) kernels but I was able to reproduce it on 3.15 as well.

RFC 5681 says that ssthresh reduction in response to RTO should be done
only once and should not be repeated until all packets from the first
loss are retransmitted. RFC 6582 (as well as its predecessor RFC 3782)
is even more specific and says that when loss is detected, one should
mark current SND.NXT and ssthresh shouldn't be reduced again due to
a loss until SND.UNA reaches this remembered value.

Linux implementation does exactly that but in TCP_CA_Loss state,
tcp_enter_loss() also takes icsk_retransmits into account:

	/* Reduce ssthresh if it has not yet been made inside this window. */
	if (icsk->icsk_ca_state <= TCP_CA_Disorder ||
	    !after(tp->high_seq, tp->snd_una) ||
	    (icsk->icsk_ca_state == TCP_CA_Loss && !icsk->icsk_retransmits)) {
		new_recovery = true;
		tp->prior_ssthresh = tcp_current_ssthresh(sk);
		tp->snd_ssthresh = icsk->icsk_ca_ops->ssthresh(sk);
		tcp_ca_event(sk, CA_EVENT_LOSS);
	}

This seems correct as icsk_retransmits is supposed to mean "we still
have packets to retransmit". But icsk_retransmits is reset in
tcp_process_loss() if one of two conditions is satisfied:

	bool recovered = !before(tp->snd_una, tp->high_seq);
...
	if (recovered) {
		/* F-RTO RFC5682 sec 3.1 step 2.a and 1st part of step 3.a */
		icsk->icsk_retransmits = 0;
		tcp_try_undo_recovery(sk);
		return;
	}
	if (flag & FLAG_DATA_ACKED)
		icsk->icsk_retransmits = 0;

First part implements the condition from RFC. But the second part can
reset icsk_retransmits much earlier than all previously lost data are
retransmitted so that ssthresh can be reduced more than once.

The first is recent and comes from commits ab42d9ee3 ("tcp: refactor
CA_Loss state processing") and e33099f96 ("tcp: implement RFC5682
F-RTO"). Second test is much older and predates the start of git tree.

I believe this code is actually wrong and we should remove those two
lines:

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 40661fc..f534723 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2710,8 +2710,6 @@ static void tcp_process_loss(struct sock *sk, int flag, bool is_dupack)
 		tcp_try_undo_recovery(sk);
 		return;
 	}
-	if (flag & FLAG_DATA_ACKED)
-		icsk->icsk_retransmits = 0;
 	if (tcp_is_reno(tp)) {
 		/* A Reno DUPACK means new data in F-RTO step 2.b above are
 		 * delivered. Lower inflight to clock out (re)tranmissions.

But as I don't know where do they come from, I can't be sure they don't
serve some purpose so I wanted to ask first if someone knows the logic
behind them.

Thanks in advance,
Michal Kubecek
