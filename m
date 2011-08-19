From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH] Proportional Rate Reduction for TCP.
Date: Fri, 19 Aug 2011 00:34:21 -0700
Message-ID: <CAB_+Fg4PdeHo_ErSbkjMJXKpH2LAzOvykDdDibvBUWTr1waphA@mail.gmail.com>
References: <1313134197-5082-1-git-send-email-nanditad@google.com>
	<alpine.DEB.2.00.1108121432240.12780@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Matt Mathis <mattmathis@google.com>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:39360 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297Ab1HSHeZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 03:34:25 -0400
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p7J7YNOI026717
	for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 00:34:23 -0700
Received: from gxk10 (gxk10.prod.google.com [10.202.11.10])
	by hpaq1.eem.corp.google.com with ESMTP id p7J7XVGV029185
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 00:34:22 -0700
Received: by gxk10 with SMTP id 10so2916556gxk.11
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 00:34:22 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1108121432240.12780@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 12, 2011 at 4:36 AM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
>
> > This patch implements Proportional Rate Reduction (PRR) for TCP.
> > PRR is an algorithm that determines TCP's sending rate in fast
> > recovery. PRR avoids excessive window reductions and aims for
> > the actual congestion window size at the end of recovery to be as
> > close as possible to the window determined by the congestion contro=
l
> > algorithm. PRR also improves accuracy of the amount of data sent
> > during loss recovery.
> >
> > The patch implements the recommended flavor of PRR called PRR-SSRB
> > (Proportional rate reduction with slow start reduction bound) and
> > replaces the existing rate halving algorithm. PRR improves upon the
> > existing Linux fast recovery under a number of conditions including=
:
> > =A0 1) burst losses where the losses implicitly reduce the amount o=
f
> > outstanding data (pipe) below the ssthresh value selected by the
> > congestion control algorithm and,
> > =A0 2) losses near the end of short flows where application runs ou=
t of
> > data to send.
> >
> > As an example, with the existing rate halving implementation a sing=
le
> > loss event can cause a connection carrying short Web transactions t=
o
> > go into the slow start mode after the recovery. This is because dur=
ing
> > recovery Linux pulls the congestion window down to packets_in_fligh=
t+1
> > on every ACK. A short Web response often runs out of new data to se=
nd
> > and its pipe reduces to zero by the end of recovery when all its pa=
ckets
> > are drained from the network. Subsequent HTTP responses using the s=
ame
> > connection will have to slow start to raise cwnd to ssthresh. PRR o=
n
> > the other hand aims for the cwnd to be as close as possible to ssth=
resh
> > by the end of recovery.
> >
> > A description of PRR and a discussion of its performance can be fou=
nd at
> > the following links:
> > - IETF Draft:
> > =A0 =A0 http://tools.ietf.org/html/draft-mathis-tcpm-proportional-r=
ate-reduction-01
> > - IETF Slides:
> > =A0 =A0 http://www.ietf.org/proceedings/80/slides/tcpm-6.pdf
> > =A0 =A0 http://tools.ietf.org/agenda/81/slides/tcpm-2.pdf
> > - Paper to appear in Internet Measurements Conference (IMC) 2011:
> > =A0 =A0 Improving TCP Loss Recovery
> > =A0 =A0 Nandita Dukkipati, Matt Mathis, Yuchung Cheng
> >
> > Signed-off-by: Nandita Dukkipati <nanditad@google.com>
> > ---
> > =A0include/linux/tcp.h =A0 | =A0 =A04 +++
> > =A0net/ipv4/tcp_input.c =A0| =A0 63 +++++++++++++++++++++++++++++++=
+++++++++++++----
> > =A0net/ipv4/tcp_output.c | =A0 =A07 ++++-
> > =A03 files changed, 67 insertions(+), 7 deletions(-)
> >
> > diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> > index 531ede8..dda4f2e1 100644
> > --- a/include/linux/tcp.h
> > +++ b/include/linux/tcp.h
> > @@ -379,6 +379,10 @@ struct tcp_sock {
> > =A0 =A0 =A0 u32 =A0 =A0 snd_cwnd_clamp; /* Do not allow snd_cwnd to=
 grow above this */
> > =A0 =A0 =A0 u32 =A0 =A0 snd_cwnd_used;
> > =A0 =A0 =A0 u32 =A0 =A0 snd_cwnd_stamp;
> > + =A0 =A0 u32 =A0 =A0 prr_cwnd; =A0 =A0 =A0 /* Congestion window at=
 start of Recovery. */
> > + =A0 =A0 u32 =A0 =A0 prr_delivered; =A0/* Number of newly delivere=
d packets to
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* rece=
iver in Recovery. */
> > + =A0 =A0 u32 =A0 =A0 prr_out; =A0 =A0 =A0 =A0/* Total number of pk=
ts sent during Recovery. */
> >
> > =A0 =A0 =A0 u32 =A0 =A0 rcv_wnd; =A0 =A0 =A0 =A0/* Current receiver=
 window =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> > =A0 =A0 =A0 u32 =A0 =A0 write_seq; =A0 =A0 =A0/* Tail(+1) of data h=
eld in tcp send buffer */
> > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > index ea0d218..601eff0 100644
> > --- a/net/ipv4/tcp_input.c
> > +++ b/net/ipv4/tcp_input.c
> > @@ -2830,9 +2830,14 @@ static int tcp_try_undo_loss(struct sock *sk=
)
> > =A0static inline void tcp_complete_cwr(struct sock *sk)
> > =A0{
> > =A0 =A0 =A0 struct tcp_sock *tp =3D tcp_sk(sk);
> > - =A0 =A0 /* Do not moderate cwnd if it's already undone in cwr or =
recovery */
> > - =A0 =A0 if (tp->undo_marker && tp->snd_cwnd > tp->snd_ssthresh) {
> > - =A0 =A0 =A0 =A0 =A0 =A0 tp->snd_cwnd =3D tp->snd_ssthresh;
> > +
> > + =A0 =A0 /* Do not moderate cwnd if it's already undone in cwr or =
recovery. */
> > + =A0 =A0 if (tp->undo_marker) {
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 if (inet_csk(sk)->icsk_ca_state =3D=3D TC=
P_CA_CWR)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->snd_cwnd =3D min(tp->=
snd_cwnd, tp->snd_ssthresh);
> > + =A0 =A0 =A0 =A0 =A0 =A0 else /* PRR */
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->snd_cwnd =3D tp->snd_=
ssthresh;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->snd_cwnd_stamp =3D tcp_time_stamp;
> > =A0 =A0 =A0 }
> > =A0 =A0 =A0 tcp_ca_event(sk, CA_EVENT_COMPLETE_CWR);
> > @@ -2950,6 +2955,39 @@ void tcp_simple_retransmit(struct sock *sk)
> > =A0}
> > =A0EXPORT_SYMBOL(tcp_simple_retransmit);
> >
> > +/* This function implements the PRR algorithm, specifcally the PRR=
-SSRB
> > + * (proportional rate reduction with slow start reduction bound) a=
s described in
> > + * http://www.ietf.org/id/draft-mathis-tcpm-proportional-rate-redu=
ction-01.txt.
> > + * It computes the number of packets to send (sndcnt) based on pac=
kets newly
> > + * delivered:
> > + * =A0 1) If the packets in flight is larger than ssthresh, PRR sp=
reads the
> > + * =A0 cwnd reductions across a full RTT.
> > + * =A0 2) If packets in flight is lower than ssthresh (such as due=
 to excess
> > + * =A0 losses and/or application stalls), do not perform any furth=
er cwnd
> > + * =A0 reductions, but instead slow start up to ssthresh.
> > + */
> > +static void tcp_update_cwnd_in_recovery(struct sock *sk, int pkts_=
delivered,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 int fast_rexmit, int flag)
> > +{
> > + =A0 =A0 struct tcp_sock *tp =3D tcp_sk(sk);
> > + =A0 =A0 int sndcnt =3D 0;
> > + =A0 =A0 int delta =3D tp->snd_ssthresh - tcp_packets_in_flight(tp=
);
> > +
> > + =A0 =A0 if (tcp_packets_in_flight(tp) > tp->snd_ssthresh) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 if (WARN_ON(!tp->prr_cwnd))
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->prr_cwnd =3D 1;
>
> Thanks, this made me to smile when I realized what kind of positive f=
eedback
> loop it would cause in a heavily congested environment :-). ...Perhap=
s any
> value below 2 * tp->snd_ssthresh isn't that safe safety relief valve =
here.
> ...Of course this condition isn't ever hit with the current code base=
 so
> no real harm being done regardless of the value.
>
> > + =A0 =A0 =A0 =A0 =A0 =A0 sndcnt =3D DIV_ROUND_UP(tp->prr_delivered=
 * tp->snd_ssthresh,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 tp->prr_cwnd) - tp->prr_out;
>
> What about very large windows ...overflow?

Addressed in patch v2.

> Due to not having lower bound here, the resulting window can end up b=
elow
> snd_ssthresh in one step if prr_delivered suddently jumps to a value =
that
> is above prr_cnwd?
>
> Also, snd_ssthresh and prr_cwnd are essentially constants over the
> whole recovery and yet divide is needed whole the time. ...And in pra=
ctically
> all cases the proportion will be 0.5 (except for the odd number produ=
ced
> off-by-one thing)?
>
> > + =A0 =A0 } else {
> > + =A0 =A0 =A0 =A0 =A0 =A0 sndcnt =3D min_t(int, delta,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0max_t(int,=
 tp->prr_delivered - tp->prr_out,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
pkts_delivered) + 1);
> > + =A0 =A0 }
> > +
> > + =A0 =A0 sndcnt =3D max(sndcnt, (fast_rexmit ? 1 : 0));
> > + =A0 =A0 tp->snd_cwnd =3D tcp_packets_in_flight(tp) + sndcnt;
> > +}
> > +
> > =A0/* Process an event, which can update packets-in-flight not triv=
ially.
> > =A0 * Main goal of this function is to calculate new estimate for l=
eft_out,
> > =A0 * taking into account both packets sitting in receiver's buffer=
 and
> > @@ -2961,7 +2999,8 @@ EXPORT_SYMBOL(tcp_simple_retransmit);
> > =A0 * It does _not_ decide what to send, it is made in function
> > =A0 * tcp_xmit_retransmit_queue().
> > =A0 */
> > -static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,=
 int flag)
> > +static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int p=
kts_delivered, int flag)
> > =A0{
> > =A0 =A0 =A0 struct inet_connection_sock *icsk =3D inet_csk(sk);
> > =A0 =A0 =A0 struct tcp_sock *tp =3D tcp_sk(sk);
> > @@ -3111,13 +3150,17 @@ static void tcp_fastretrans_alert(struct so=
ck *sk, int pkts_acked, int flag)
> >
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->bytes_acked =3D 0;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->snd_cwnd_cnt =3D 0;
> > + =A0 =A0 =A0 =A0 =A0 =A0 tp->prr_cwnd =3D tp->snd_cwnd;
>
> prior_cwnd would make this variable about 1000 times easier to read
> without requiring some background.

Patch v2 changes this to prior_cwnd.

>
> While at it, I realized that there is some restore window place in th=
e
> generic code that assumes "prior_cwnd =3D=3D 2 * tp->snd_ssthresh" wh=
ich is
> not true with every single cc module.
>
> > + =A0 =A0 =A0 =A0 =A0 =A0 tp->prr_delivered =3D 0;
> > + =A0 =A0 =A0 =A0 =A0 =A0 tp->prr_out =3D 0;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_set_ca_state(sk, TCP_CA_Recovery);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 fast_rexmit =3D 1;
> > =A0 =A0 =A0 }
> >
> > =A0 =A0 =A0 if (do_lost || (tcp_is_fack(tp) && tcp_head_timedout(sk=
)))
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_update_scoreboard(sk, fast_rexmit);
> > - =A0 =A0 tcp_cwnd_down(sk, flag);
> > + =A0 =A0 tp->prr_delivered +=3D pkts_delivered;
>
> ...Is here a bug in the calculation if the recovery was triggered wit=
h
> _a cumulative ACK_ that had enough SACK blocks?
>
> > + =A0 =A0 tcp_update_cwnd_in_recovery(sk, pkts_delivered, fast_rexm=
it, flag);
> > =A0 =A0 =A0 tcp_xmit_retransmit_queue(sk);
> > =A0}
> >
> > @@ -3632,6 +3675,11 @@ static int tcp_ack(struct sock *sk, struct s=
k_buff *skb, int flag)
> > =A0 =A0 =A0 u32 prior_in_flight;
> > =A0 =A0 =A0 u32 prior_fackets;
> > =A0 =A0 =A0 int prior_packets;
> > + =A0 =A0 int prior_sacked =3D tp->sacked_out;
> > + =A0 =A0 /* pkts_delivered is number of packets newly cumulatively=
 acked or
> > + =A0 =A0 =A0* sacked on this ACK.
> > + =A0 =A0 =A0*/
> > + =A0 =A0 int pkts_delivered =3D 0;
>
> If you need a comment like that on variable declaration, maybe its na=
me
> could be more obvious, pkts_acked_sacked ?

Changed this to newly_acked_sacked as per your suggestion.

>
> > =A0 =A0 =A0 int frto_cwnd =3D 0;
> >
> > =A0 =A0 =A0 /* If the ack is older than previous acks
> > @@ -3703,6 +3751,9 @@ static int tcp_ack(struct sock *sk, struct sk=
_buff *skb, int flag)
> > =A0 =A0 =A0 /* See if we can take anything off of the retransmit qu=
eue. */
> > =A0 =A0 =A0 flag |=3D tcp_clean_rtx_queue(sk, prior_fackets, prior_=
snd_una);
> > + =A0 =A0 pkts_delivered =3D (prior_packets - prior_sacked) -
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(tp->packets_out - tp-=
>sacked_out);
> > +
> > =A0 =A0 =A0 if (tp->frto_counter)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 frto_cwnd =3D tcp_process_frto(sk, flag=
);
> > =A0 =A0 =A0 /* Guarantee sacktag reordering detection against wrap-=
arounds */
> > @@ -3715,7 +3766,7 @@ static int tcp_ack(struct sock *sk, struct sk=
_buff *skb, int flag)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_may_raise_cwnd(sk, flag))
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_cong_avoid(sk, ack,=
 prior_in_flight);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_fastretrans_alert(sk, prior_packets=
 - tp->packets_out,
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 flag);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 pkts_delivered, flag);
> > =A0 =A0 =A0 } else {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((flag & FLAG_DATA_ACKED) && !frto_c=
wnd)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_cong_avoid(sk, ack,=
 prior_in_flight);
> > diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> > index 882e0b0..ca50408 100644
> > --- a/net/ipv4/tcp_output.c
> > +++ b/net/ipv4/tcp_output.c
> > @@ -1796,11 +1796,13 @@ static int tcp_write_xmit(struct sock *sk, =
unsigned int mss_now, int nonagle,
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_event_new_data_sent(sk, skb);
> >
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_minshall_update(tp, mss_now, skb);
> > - =A0 =A0 =A0 =A0 =A0 =A0 sent_pkts++;
> > + =A0 =A0 =A0 =A0 =A0 =A0 sent_pkts +=3D tcp_skb_pcount(skb);
> >
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (push_one)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > =A0 =A0 =A0 }
> > + =A0 =A0 if (inet_csk(sk)->icsk_ca_state =3D=3D TCP_CA_Recovery)
> > + =A0 =A0 =A0 =A0 =A0 =A0 tp->prr_out +=3D sent_pkts;
>
> Is there some harm done if you get rid of the conditionality?
>
> > =A0 =A0 =A0 if (likely(sent_pkts)) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_cwnd_validate(sk);
> > @@ -2294,6 +2296,9 @@ begin_fwd:
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 NET_INC_STATS_BH(sock_net(sk), mib_idx)=
;
> >
> > + =A0 =A0 =A0 =A0 =A0 =A0 if (inet_csk(sk)->icsk_ca_state =3D=3D TC=
P_CA_Recovery)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->prr_out +=3D tcp_skb_=
pcount(skb);
> > +
>
> ...same here?

No harm done if the condition is removed in either of these case.
However, letting the condition remain for now for ease of readability.

>
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb =3D=3D tcp_write_queue_head(sk)=
)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_csk_reset_xmit_tim=
er(sk, ICSK_TIME_RETRANS,
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_csk(sk)->icsk_rto,
>
> Besides the points above, I'm not convinced that we really need all t=
he
> across-packet state that is present, some relevant values should be
> available before we do any ACK processing (in-flight, cwnd, and more
> importantly, the difference between them). ...But I haven't yet
> convinced myself of anything particular.
>
> --
> =A0i.
