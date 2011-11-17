From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 4/5] tcp: allow undo from reordered DSACKs
Date: Thu, 17 Nov 2011 15:49:55 -0500
Message-ID: <CADVnQykNffEvpr5bnLiLyNGZiuhxx=5wxqFaZjC+Dk4mxe1Okw@mail.gmail.com>
References: <1321469885-10885-1-git-send-email-ncardwell@google.com>
	<1321469885-10885-4-git-send-email-ncardwell@google.com>
	<alpine.DEB.2.00.1111170715060.23028@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:61695 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774Ab1KQUt4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 15:49:56 -0500
Received: by ggnb2 with SMTP id b2so1617608ggn.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 12:49:56 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1111170715060.23028@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 17, 2011 at 12:18 AM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
> On Wed, 16 Nov 2011, Neal Cardwell wrote:
>
>> Previously, SACK-enabled connections hung around in TCP_CA_Disorder
>> state while snd_una=3D=3Dhigh_seq, just waiting to accumulate DSACKs=
 and
>> hopefully undo a cwnd reduction. This could and did lead to the
>> following unfortunate scenario: if some incoming ACKs advance snd_un=
a
>> beyond high_seq then we were setting undo_marker to 0 and moving to
>> TCP_CA_Open, so if (due to reordering in the ACK return path) we
>> shortly thereafter received a DSACK then we were no longer able to
>> undo the cwnd reduction.
>>
>> The change: Simplify the congestion avoidance state machine by
>> removing the behavior where SACK-enabled connections hung around in
>> the TCP_CA_Disorder state just waiting for DSACKs. Instead, when
>> snd_una advances to high_seq or beyond we typically move to
>> TCP_CA_Open immediately and allow an undo in either TCP_CA_Open or
>> TCP_CA_Disorder if we later receive enough DSACKs.
>>
>> Other patches in this series will provide other changes that are
>> necessary to fully fix this problem.
>>
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
>> ---
>> =A0net/ipv4/tcp_input.c | =A0 15 ++-------------
>> =A01 files changed, 2 insertions(+), 13 deletions(-)
>>
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index 751d390..a4efdd7 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -2858,7 +2858,7 @@ static void tcp_try_keep_open(struct sock *sk)
>> =A0 =A0 =A0 struct tcp_sock *tp =3D tcp_sk(sk);
>> =A0 =A0 =A0 int state =3D TCP_CA_Open;
>>
>> - =A0 =A0 if (tcp_left_out(tp) || tcp_any_retrans_done(sk) || tp->un=
do_marker)
>> + =A0 =A0 if (tcp_left_out(tp) || tcp_any_retrans_done(sk))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 state =3D TCP_CA_Disorder;
>>
>> =A0 =A0 =A0 if (inet_csk(sk)->icsk_ca_state !=3D state) {
>> @@ -3066,17 +3066,6 @@ static void tcp_fastretrans_alert(struct sock=
 *sk, int pkts_acked,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 case TCP_CA_Disorder:
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_try_undo_dsack(sk);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!tp->undo_marker ||
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* For SACK case d=
o not Open to allow to undo
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* catching for =
all duplicate ACKs. */
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_is_reno(tp) ||=
 tp->snd_una !=3D tp->high_seq) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->undo_m=
arker =3D 0;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_set_ca=
_state(sk, TCP_CA_Open);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> -
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 case TCP_CA_Recovery:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tcp_is_reno(tp))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_rese=
t_reno_sack(tp);
>> @@ -3117,7 +3106,7 @@ static void tcp_fastretrans_alert(struct sock =
*sk, int pkts_acked,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_add_=
reno_sack(sk);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (icsk->icsk_ca_state =3D=3D TCP_CA_Diso=
rder)
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (icsk->icsk_ca_state <=3D TCP_CA_Disord=
er)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_try_undo_dsack(sk);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!tcp_time_to_recover(sk)) {
>
> How about extending Disorder state until second cumulative ACK that i=
s
> acking >=3D high_seq?

That would seem to add complexity but only provide a partial solution.

This proposed patch has the virtue of providing a general solution
while simplifying the code a little.

What are your concerns with this patch?

Thanks, Ilpo, for taking a look at this patch sequence,
neal
