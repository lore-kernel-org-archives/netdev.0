From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH 3/3] Revert Backoff [v3]: Calculate TCP's connection close
 threshold as a time value.
Date: Tue, 5 Jun 2012 10:42:21 -0700
Message-ID: <CAPshTCg8W0QxubvO_dWBsSOqvCEdBSWLKv3cNOvn=VbyqHA1zg@mail.gmail.com>
References: <4A950B82.1070807@tvk.rwth-aachen.de>
	<CAFbMe2Mu46N8kRrYkGzYRLuntEd2J9aO_d0Jw_y0gsQA4q-qHw@mail.gmail.com>
	<CAPshTCiFDUb3CVm-joJW_DRVS+C+_BjFO-Mt3uAwrCzVw8MsVg@mail.gmail.com>
	<1338832247.5299.4.camel@nexus>
	<CAPshTChwnEaMTOsofFDP0ZY8U3VCP2ZrtXjdhKG03rRsx7kryA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:34983 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754611Ab2FERmX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2012 13:42:23 -0400
Received: by lahd3 with SMTP id d3so3988781lah.19
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2012 10:42:21 -0700 (PDT)
In-Reply-To: <CAPshTChwnEaMTOsofFDP0ZY8U3VCP2ZrtXjdhKG03rRsx7kryA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 4, 2012 at 4:50 PM, Jerry Chu <hkchu@google.com> wrote:
> Hi Damian,
>
> On Mon, Jun 4, 2012 at 10:50 AM, Damian Lukowski
> <damian@tvk.rwth-aachen.de> wrote:
>> Hi Jerry,
>>
>> please verify, I understood you correctly.
>>
>> You have set TCP_RTO_MIN to a lower value, e.g. 0.002 seconds to imp=
rove
>> your internal low-latency traffic. Because of the improvement, R1
>> timeouts are triggered too fast for external high-RTT traffic. Is th=
at
>> correct?
>
> Correct.
>
>> If so, may I suggest to set tcp_retries1 to a higher value? For
>> TCP_RTO_MIN =3D=3D 0.002 and tcp_retries1 =3D=3D =A010, R1 will be c=
alculated to
>> approximately 4 seconds.
>
> I think hacking tcp_retries1 is the wrong solution. E.g., 10 retries =
may be too
> generous for those short RTT flows.
>
> I think the fundamental problem is - the ideal fix for your original =
RTO revert
> problem should've used the per-flow RTO to compute R1 & R2. But that
> computation may be too expensive so you used TCP_RTO_MIN as an
> approximation - not a good idea IMHO!

Just realized the correct fix of using the original, non-backoff per fl=
ow RTO is
not any more expensive than the current code through ilog2(). What's ne=
eded
is a new field "base_rto" to record the original RTO before backoff. I'=
m leaning
toward this more accurate fix now without any fudge because fudging alm=
ost
always causes bugs.

Any comment is welcome. I'm not sure in the existing code if it makes s=
ense
to apply the exponential backoff based computation to thin stream but i=
t's a
separate question so I won't touch it.

Jerry

>
> The easiest solution I can see so far is to replace the check
>
> if (!inet_csk(sk)->icsk_retransmits)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
>
> at the beginning of retransmits_timed_out() with
>
> if (inet_csk(sk)->icsk_retransmits < boundary)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
>
> Best,
>
> Jerry
>
>>
>> Is that ok?
>>
>> Best regards
>> =A0Damian
>>
>> Am Freitag, den 01.06.2012, 15:58 -0700 schrieb Jerry Chu:
>>> > From: Damian Lukowski <damian@tvk.rwth-aachen.de>
>>> > Date: Wed, Aug 26, 2009 at 3:16 AM
>>> > Subject: [PATCH 3/3] Revert Backoff [v3]: Calculate TCP's connect=
ion close
>>> > threshold as a time value.
>>> > To: Netdev <netdev@vger.kernel.org>
>>> >
>>> >
>>> > RFC 1122 specifies two threshold values R1 and R2 for connection =
timeouts,
>>> > which may represent a number of allowed retransmissions or a time=
out value.
>>> > Currently linux uses sysctl_tcp_retries{1,2} to specify the thres=
holds
>>> > in number of allowed retransmissions.
>>> >
>>> > For any desired threshold R2 (by means of time) one can specify t=
cp_retries2
>>> > (by means of number of retransmissions) such that TCP will not ti=
me out
>>> > earlier than R2. This is the case, because the RTO schedule follo=
ws a fixed
>>> > pattern, namely exponential backoff.
>>> >
>>> > However, the RTO behaviour is not predictable any more if RTO bac=
koffs can
>>> > be
>>> > reverted, as it is the case in the draft
>>> > "Make TCP more Robust to Long Connectivity Disruptions"
>>> > (http://tools.ietf.org/html/draft-zimmermann-tcp-lcd).
>>> >
>>> > In the worst case TCP would time out a connection after 3.2 secon=
ds, if the
>>> > initial RTO equaled MIN_RTO and each backoff has been reverted.
>>> >
>>> > This patch introduces a function retransmits_timed_out(N),
>>> > which calculates the timeout of a TCP connection, assuming an ini=
tial
>>> > RTO of MIN_RTO and N unsuccessful, exponentially backed-off retra=
nsmissions.
>>> >
>>> > Whenever timeout decisions are made by comparing the retransmissi=
on counter
>>> > to some value N, this function can be used, instead.
>>> >
>>> > The meaning of tcp_retries2 will be changed, as many more RTO
>>> > retransmissions
>>> > can occur than the value indicates. However, it yields a timeout =
which is
>>> > similar to the one of an unpatched, exponentially backing off TCP=
 in the
>>> > same
>>> > scenario. As no application could rely on an RTO greater than MIN=
_RTO, there
>>> > should be no risk of a regression.
>>>
>>> This looks like a typical "fix one problem, introducing a few more"=
 patch :(.
>>> What do you mean by "no application could rely on an RTO greater th=
an
>>> MIN_RTO..."
>>> above? How can you make the assumption that RTO is not too far off
>>> from TCP_RTO_MIN?
>>>
>>> While you tried to address a problem where the retransmission count
>>> was high but the actual
>>> timeout duration was too short, have you considered the other case
>>> around, i.e., the timeout
>>> duration is long but the retransmission count is too short? This is
>>> exactly what's happening
>>> to us with your patch. We've much reduced TCP_RTO_MIN for our inter=
nal
>>> traffic, but not
>>> noticing your change has severely shortened the R1 & R2 recommended=
 by
>>> RFC1122 for our
>>> long haul traffic until now. In many cases R1 threshold was met upo=
n
>>> the first retrans timeout.
>>>
>>> I think retransmits_timed_out() should check against both time
>>> duration and retrans count
>>> (icsk_retransmits).
>>>
>>> Thought?
>>>
>>> Jerry
>>>
>>> >
>>> > Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
>>> > ---
>>> > =A0include/net/tcp.h =A0 =A0| =A0 18 ++++++++++++++++++
>>> > =A0net/ipv4/tcp_timer.c | =A0 11 +++++++----
>>> > =A02 files changed, 25 insertions(+), 4 deletions(-)
>>> >
>>> > diff --git a/include/net/tcp.h b/include/net/tcp.h
>>> > index c35b329..17d1a88 100644
>>> > --- a/include/net/tcp.h
>>> > +++ b/include/net/tcp.h
>>> > @@ -1247,6 +1247,24 @@ static inline struct sk_buff
>>> > *tcp_write_queue_prev(struct sock *sk, struct sk_bu
>>> > =A0#define tcp_for_write_queue_from_safe(skb, tmp, sk) =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
>>> > =A0 =A0 =A0 =A0skb_queue_walk_from_safe(&(sk)->sk_write_queue, sk=
b, tmp)
>>> >
>>> > +static inline bool retransmits_timed_out(const struct sock *sk,
>>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0unsigned int boundary)
>>> > +{
>>> > + =A0 =A0 =A0 int limit, K;
>>> > + =A0 =A0 =A0 if (!inet_csk(sk)->icsk_retransmits)
>>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
>>> > +
>>> > + =A0 =A0 =A0 K =3D ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
>>> > +
>>> > + =A0 =A0 =A0 if (boundary <=3D K)
>>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 limit =3D ((2 << boundary) - 1) * T=
CP_RTO_MIN;
>>> > + =A0 =A0 =A0 else
>>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 limit =3D ((2 << K) - 1) * TCP_RTO_=
MIN +
>>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (boundary - K) * TC=
P_RTO_MAX;
>>> > +
>>> > + =A0 =A0 =A0 return (tcp_time_stamp - tcp_sk(sk)->retrans_stamp)=
 >=3D limit;
>>> > +}
>>> > +
>>> > =A0static inline struct sk_buff *tcp_send_head(struct sock *sk)
>>> > =A0{
>>> > =A0 =A0 =A0 =A0return sk->sk_send_head;
>>> > diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
>>> > index a3ba494..2972d7b 100644
>>> > --- a/net/ipv4/tcp_timer.c
>>> > +++ b/net/ipv4/tcp_timer.c
>>> > @@ -137,13 +137,14 @@ static int tcp_write_timeout(struct sock *s=
k)
>>> > =A0{
>>> > =A0 =A0 =A0 =A0struct inet_connection_sock *icsk =3D inet_csk(sk)=
;
>>> > =A0 =A0 =A0 =A0int retry_until;
>>> > + =A0 =A0 =A0 bool do_reset;
>>> >
>>> > =A0 =A0 =A0 =A0if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SY=
N_RECV)) {
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (icsk->icsk_retransmits)
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dst_negative_advic=
e(&sk->sk_dst_cache);
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retry_until =3D icsk->icsk_syn_ret=
ries ? :
>>> > sysctl_tcp_syn_retries;
>>> > =A0 =A0 =A0 =A0} else {
>>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (icsk->icsk_retransmits >=3D sys=
ctl_tcp_retries1) {
>>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (retransmits_timed_out(sk, sysct=
l_tcp_retries1)) {
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Black hole dete=
ction */
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tcp_mtu_probing(ic=
sk, sk);
>>> >
>>> > @@ -155,13 +156,15 @@ static int tcp_write_timeout(struct sock *s=
k)
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const int alive =3D=
 (icsk->icsk_rto < TCP_RTO_MAX);
>>> >
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retry_until =3D tc=
p_orphan_retries(sk, alive);
>>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_reset =3D alive =
||
>>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0!retransmits_timed_out(sk, retry_until);
>>> >
>>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tcp_out_of_reso=
urces(sk, alive ||
>>> > icsk->icsk_retransmits < retry_until))
>>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tcp_out_of_reso=
urces(sk, do_reset))
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0re=
turn 1;
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>> > =A0 =A0 =A0 =A0}
>>> >
>>> > - =A0 =A0 =A0 if (icsk->icsk_retransmits >=3D retry_until) {
>>> > + =A0 =A0 =A0 if (retransmits_timed_out(sk, retry_until)) {
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Has it gone just too far? */
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tcp_write_err(sk);
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
>>> > @@ -385,7 +388,7 @@ void tcp_retransmit_timer(struct sock *sk)
>>> > =A0out_reset_timer:
>>> > =A0 =A0 =A0 =A0icsk->icsk_rto =3D min(icsk->icsk_rto << 1, TCP_RT=
O_MAX);
>>> > =A0 =A0 =A0 =A0inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, i=
csk->icsk_rto,
>>> > TCP_RTO_MAX);
>>> > - =A0 =A0 =A0 if (icsk->icsk_retransmits > sysctl_tcp_retries1)
>>> > + =A0 =A0 =A0 if (retransmits_timed_out(sk, sysctl_tcp_retries1 +=
 1))
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__sk_dst_reset(sk);
>>> >
>>> > =A0out:;
>>> > --
>>> > 1.6.3.3
>>> >
>>> > --
>>> > To unsubscribe from this list: send the line "unsubscribe netdev"=
 in
>>> > the body of a message to majordomo@vger.kernel.org
>>> > More majordomo info at =A0http://vger.kernel.org/majordomo-info.h=
tml
>>> >
>>
>>
