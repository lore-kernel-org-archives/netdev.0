From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 4/5] tcp: allow undo from reordered DSACKs
Date: Tue, 22 Nov 2011 14:44:32 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1111221347290.31705@wel-95.cs.helsinki.fi>
References: <1321469885-10885-1-git-send-email-ncardwell@google.com> <1321469885-10885-4-git-send-email-ncardwell@google.com> <alpine.DEB.2.00.1111170715060.23028@melkinpaasi.cs.helsinki.fi>
 <CADVnQykNffEvpr5bnLiLyNGZiuhxx=5wxqFaZjC+Dk4mxe1Okw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-548910336-1321965873=:31705"
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37080 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752716Ab1KVMoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 07:44:34 -0500
In-Reply-To: <CADVnQykNffEvpr5bnLiLyNGZiuhxx=5wxqFaZjC+Dk4mxe1Okw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-548910336-1321965873=:31705
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 17 Nov 2011, Neal Cardwell wrote:

> On Thu, Nov 17, 2011 at 12:18 AM, Ilpo Järvinen
> <ilpo.jarvinen@helsinki.fi> wrote:
> > On Wed, 16 Nov 2011, Neal Cardwell wrote:
> >
> >> Previously, SACK-enabled connections hung around in TCP_CA_Disorder
> >> state while snd_una==high_seq, just waiting to accumulate DSACKs and
> >> hopefully undo a cwnd reduction. This could and did lead to the
> >> following unfortunate scenario: if some incoming ACKs advance snd_una
> >> beyond high_seq then we were setting undo_marker to 0 and moving to
> >> TCP_CA_Open, so if (due to reordering in the ACK return path) we
> >> shortly thereafter received a DSACK then we were no longer able to
> >> undo the cwnd reduction.
> >>
> >> The change: Simplify the congestion avoidance state machine by
> >> removing the behavior where SACK-enabled connections hung around in
> >> the TCP_CA_Disorder state just waiting for DSACKs. Instead, when
> >> snd_una advances to high_seq or beyond we typically move to
> >> TCP_CA_Open immediately and allow an undo in either TCP_CA_Open or
> >> TCP_CA_Disorder if we later receive enough DSACKs.
> >>
> >> Other patches in this series will provide other changes that are
> >> necessary to fully fix this problem.
> >>
> >> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> >> ---
> >>  net/ipv4/tcp_input.c |   15 ++-------------
> >>  1 files changed, 2 insertions(+), 13 deletions(-)
> >>
> >> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> >> index 751d390..a4efdd7 100644
> >> --- a/net/ipv4/tcp_input.c
> >> +++ b/net/ipv4/tcp_input.c
> >> @@ -2858,7 +2858,7 @@ static void tcp_try_keep_open(struct sock *sk)
> >>       struct tcp_sock *tp = tcp_sk(sk);
> >>       int state = TCP_CA_Open;
> >>
> >> -     if (tcp_left_out(tp) || tcp_any_retrans_done(sk) || tp->undo_marker)
> >> +     if (tcp_left_out(tp) || tcp_any_retrans_done(sk))
> >>               state = TCP_CA_Disorder;
> >>
> >>       if (inet_csk(sk)->icsk_ca_state != state) {
> >> @@ -3066,17 +3066,6 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
> >>                       }
> >>                       break;
> >>
> >> -             case TCP_CA_Disorder:
> >> -                     tcp_try_undo_dsack(sk);
> >> -                     if (!tp->undo_marker ||
> >> -                         /* For SACK case do not Open to allow to undo
> >> -                          * catching for all duplicate ACKs. */
> >> -                         tcp_is_reno(tp) || tp->snd_una != tp->high_seq) {
> >> -                             tp->undo_marker = 0;
> >> -                             tcp_set_ca_state(sk, TCP_CA_Open);
> >> -                     }
> >> -                     break;
> >> -
> >>               case TCP_CA_Recovery:
> >>                       if (tcp_is_reno(tp))
> >>                               tcp_reset_reno_sack(tp);
> >> @@ -3117,7 +3106,7 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
> >>                               tcp_add_reno_sack(sk);
> >>               }
> >>
> >> -             if (icsk->icsk_ca_state == TCP_CA_Disorder)
> >> +             if (icsk->icsk_ca_state <= TCP_CA_Disorder)
> >>                       tcp_try_undo_dsack(sk);
> >>
> >>               if (!tcp_time_to_recover(sk)) {
> >
> > How about extending Disorder state until second cumulative ACK that is
> > acking >= high_seq?
> 
> That would seem to add complexity but only provide a partial solution.

Right, I forgot the reordering.

> This proposed patch has the virtue of providing a general solution
> while simplifying the code a little.
>
> What are your concerns with this patch?

...I was thinking that if we go to the direction of removal of more and 
more CA_Disorder stuff we could just as well remove the whole state. But 
I've since that time convinced myself that the state itself is still 
necessary even if less action takes place in it after this patch.

Also, one (serious) word of caution! This change, by its extending of 
CA_Open state, is somewhat similar to what I made FRTO years ago, and 
managed to introduces subtle breaking to the state machine. Please check 
that the problem similar to what was fixed by 
a1c1f281b84a751fdb5ff919da3b09df7297619f does not reappear (possibly in 
some other form causing spurious undos). ...To me it seems that 
tcp_packet_delayed might be similarly confused after the given patch.

-- 
 i.
--8323329-548910336-1321965873=:31705--
