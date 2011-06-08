From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] RFC2988bis + taking RTT sample from 3WHS for the passive
 open side
Date: Wed, 8 Jun 2011 15:26:40 -0700
Message-ID: <BANLkTimo_fbezdX2evKt0pAg0N+DSJQeSR6NoHLus=Z40WLkHg@mail.gmail.com>
References: <1307509203-30973-1-git-send-email-hkchu@google.com>
	<1307550654.3057.70.camel@edumazet-laptop>
	<BANLkTikpmXMpuTmgejsgisV9O2fP1i7VLnUO3bcYLSU0+iXJVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Hagen Paul Pfeifer <hagen@jauu.net>, tsunanet@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:8753 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277Ab1FHW0o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 18:26:44 -0400
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p58MQg6P024931
	for <netdev@vger.kernel.org>; Wed, 8 Jun 2011 15:26:42 -0700
Received: from yic15 (yic15.prod.google.com [10.243.65.143])
	by kpbe16.cbf.corp.google.com with ESMTP id p58MQC6T030099
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 8 Jun 2011 15:26:40 -0700
Received: by yic15 with SMTP id 15so455375yic.12
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2011 15:26:40 -0700 (PDT)
In-Reply-To: <BANLkTikpmXMpuTmgejsgisV9O2fP1i7VLnUO3bcYLSU0+iXJVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric,

It just occurred to me now that initRTO is being reduced, both TCP_SYN_=
RETRIES
and TCP_SYNACK_RETRIES should be bumped up a bit, to e.g., 7 (?) to mee=
t the
3 minutes R2 requirement per RFC1122.

If you agree, I will submit another patch.

Thanks,

Jerry

On Wed, Jun 8, 2011 at 10:04 AM, Jerry Chu <hkchu@google.com> wrote:
> +netdev (add missing cc)
>
> On Wed, Jun 8, 2011 at 9:30 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>>
>> Le mardi 07 juin 2011 =E0 22:00 -0700, H.K. Jerry Chu a =E9crit :
>> > From: Jerry Chu <hkchu@google.com>
>> >
>> > This patch lowers the default initRTO from 3secs to 1sec per
>> > RFC2988bis. It falls back to 3secs if the SYN or SYN-ACK packet
>> > has been retransmitted, AND the TCP timestamp option is not on.
>> >
>> > It also adds support to take RTT sample during 3WHS on the passive
>> > open side, just like its active open counterpart, and uses it, if
>> > valid, to seed the initRTO for the data transmission phase.
>> >
>> > The patch also resets ssthresh to its initial default at the
>> > beginning of the data transmission phase, and reduces cwnd to 1 if
>> > there has been MORE THAN ONE retransmission during 3WHS per RFC568=
1.
>> >
>> > Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
>> > ---
>>
>> ...
>>
>> > @@ -1854,7 +1859,7 @@ static int tcp_v4_init_sock(struct sock *sk)
>> > =A0 =A0 =A0 =A0* algorithms that we must have the following bandai=
d to talk
>> > =A0 =A0 =A0 =A0* efficiently to them. =A0-DaveM
>> > =A0 =A0 =A0 =A0*/
>> > - =A0 =A0 tp->snd_cwnd =3D 2;
>> > + =A0 =A0 tp->snd_cwnd =3D TCP_INIT_CWND;
>>
>> Hmm, are you sure this belongs to this patch ?
>>
>> >
>> > =A0 =A0 =A0 /* See draft-stevens-tcpca-spec-01 for discussion of t=
he
>> > =A0 =A0 =A0 =A0* initialization of these values.
>> > diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
>> > index 80b1f80..d2fe4e0 100644
>> > --- a/net/ipv4/tcp_minisocks.c
>> > +++ b/net/ipv4/tcp_minisocks.c
>> > @@ -486,7 +486,7 @@ struct sock *tcp_create_openreq_child(struct s=
ock *sk, struct request_sock *req,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* algorithms that we must have the =
following bandaid to talk
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* efficiently to them. =A0-DaveM
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> > - =A0 =A0 =A0 =A0 =A0 =A0 newtp->snd_cwnd =3D 2;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 newtp->snd_cwnd =3D TCP_INIT_CWND;
>>
>> same here ?
>
> It's part of the cwnd initialization stuff, which I included some fix
> per RFC5681 (in
> tcp_init_metrics()). The field is currently not being used anyway
> until data-in-SYN is
> supported. I fixed it here just because TCP_INIT_CWND is the right va=
lue.
>
>>
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 newtp->snd_cwnd_cnt =3D 0;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 newtp->bytes_acked =3D 0;
>> >
>> > @@ -720,6 +720,10 @@ struct sock *tcp_check_req(struct sock *sk, s=
truct sk_buff *skb,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 NET_INC_STATS_BH(sock_net(sk), LINUX_M=
IB_TCPDEFERACCEPTDROP);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> > =A0 =A0 =A0 }
>> > + =A0 =A0 if (tmp_opt.saw_tstamp && tmp_opt.rcv_tsecr)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 tcp_rsk(req)->snt_synack =3D tmp_opt.rcv=
_tsecr;
>> > + =A0 =A0 else if (req->retrans) /* don't take RTT sample if retra=
ns && ~TS */
>> > + =A0 =A0 =A0 =A0 =A0 =A0 tcp_rsk(req)->snt_synack =3D 0;
>>
>> Could you clarify why this is done in this order ?
>
> What else is more appropriate? It needs to decide if we've got a vali=
d
> RTT sample.
> If TS is on and rcv_tsec !=3D 0 then we've got a valid RTT sample. Ot=
herwise it
> does not take sample if there has been retrans per Karn's algorithm.
>
> Thanks,
>
> Jerry
>
>>
>> Thanks !
>>
>>
>
