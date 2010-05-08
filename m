From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH][v4] tcp: fix ICMP-RTO war
Date: Sat, 8 May 2010 10:27:43 -0700
Message-ID: <k2xd1c2719f1005081027v376a4ebfp300c6272f9ea91df@mail.gmail.com>
References: <4B7303C2.5000703@tvk.rwth-aachen.de>
	 <alpine.DEB.2.00.1002151535030.7063@wel-95.cs.helsinki.fi>
	 <20100221.181029.71107197.davem@davemloft.net>
	 <o2z349f35ee1005071622z38fcd66ek398402d7512542ae@mail.gmail.com>
	 <n2gd1c2719f1005071625nd3df3d72t9655a1f64f2fd825@mail.gmail.com>
	 <4BE5213C.1030300@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:10726 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751610Ab0EHR1r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 May 2010 13:27:47 -0400
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o48HRjsN025203
	for <netdev@vger.kernel.org>; Sat, 8 May 2010 10:27:45 -0700
Received: from gwj19 (gwj19.prod.google.com [10.200.10.19])
	by kpbe19.cbf.corp.google.com with ESMTP id o48HRiLf019449
	for <netdev@vger.kernel.org>; Sat, 8 May 2010 10:27:44 -0700
Received: by gwj19 with SMTP id 19so1241380gwj.5
        for <netdev@vger.kernel.org>; Sat, 08 May 2010 10:27:43 -0700 (PDT)
In-Reply-To: <4BE5213C.1030300@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 8, 2010 at 1:30 AM, Damian Lukowski
<damian@tvk.rwth-aachen.de> wrote:
>
> > I'm working on a patch that tries to measure and use the RTT for th=
e passive
> > open side when the TS option is NOT enabled. My code conflicts with=
 your
> > recently added "tcp_ack_update_rtt(sk, 0, 0);" Could you tell me wh=
y do you
> > force this call for the no-TS case when obviously "0" is not a meas=
ured RTT?
> > If you try to force icsk_rto to be initialized correctly, it is
> > already initialized to
> > TCP_TIMEOUT_INIT by tcp_create_openreq_child(). What am I missing?
>
> Hi,
> the backoff reversion code uses __tcp_set_rto() to recalculate icsk_r=
to,
> which itself relies on tp->srtt and rttvar.

Guess you are talking about

inet_csk(sk)->icsk_rto =3D __tcp_set_rto(tp) <<
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 icsk->icsk_backoff;

inside tcp_v4_err(), right? (I'm looking at 2.6.33 kernel.)

Yes it seems to be a bug when __tcp_set_rto() is called before
tcp_rtt_estimator()
gets a chance to initialize all the variables properly.

But I don't like your fix of adding tcp_ack_update_rtt(sk, 0, 0); to
tcp_rcv_state_process()
because that means you've got a measured RTT of 0 (really meaning < 1 t=
ick) for
the no-TS case, which will cause tcp_rtt_estimator() to compute all
the variables as if
there has been a valid RTT measurement of 1.

A better fix IMHO is to make sure all the variables are properly
initialized when exiting
tcp_init_metrics(), e.g, if srtt remains 0, make sure
tp->mdev =3D tp->mdev_max =3D tp->rttvar =3D TCP_TIMEOUT_INIT;
(mdev already been initialized to TCP_TIMEOUT_INIT. I think you got
hit by rttvar =3D=3D 0)

> srtt is explicitly set to 0 in tcp_create_openreq_child(), so I didn'=
t change it.
> Initializing it with TCP_TIMEOUT_INIT should also fix that specific b=
ug,
> but I don't know if there are other impacts.

So what do I care? Because I'm mucking with the code in this area and y=
our fix
causes some conflict with my logic.

What do you think?

Best,

Jerry

>
> Regards
> =A0Damian
>
> > Thanks,
> >
> > Jerry
> >
> >> From: David Miller <davem@davemloft.net>
> >>
> >> Date: Sun, Feb 21, 2010 at 7:10 PM
> >> Subject: Re: [PATCH][v4] tcp: fix ICMP-RTO war
> >> To: ilpo.jarvinen@helsinki.fi
> >> Cc: damian@tvk.rwth-aachen.de, netdev@vger.kernel.org
> >>
> >>
> >> From: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> >> Date: Tue, 16 Feb 2010 14:45:25 +0200 (EET)
> >>
> >>> On Wed, 10 Feb 2010, Damian Lukowski wrote:
> >>>
> >>>> @@ -5783,12 +5783,10 @@ int tcp_rcv_state_process(struct sock *s=
k, struct sk_buff *skb,
> >>>>
> >>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* tc=
p_ack considers this ACK as duplicate
> >>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * an=
d does not calculate rtt.
> >>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Fix =
it at least with timestamps.
> >>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Forc=
e it here.
> >>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> >>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (tp-=
>rx_opt.saw_tstamp &&
> >>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
tp->rx_opt.rcv_tsecr && !tp->srtt)
> >>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0tcp_ack_saw_tstamp(sk, 0);
> >>>> -
> >>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tcp_ack=
_update_rtt(sk, 0, 0);
> >>>> +
> >>>
> >>> ...Here a zero seq_rtt is given to RTT estimator (it will be effe=
ctive
> >>> only in the case w/o timestamps, TS case recalculates it from the=
 stored
> >>> timestamps). Maybe we could use some field (timestamp related one=
 comes to
> >>> my mind) in request sock to get a real RTT estimate for non-times=
tamp case
> >>> too. ...It seems possible to me, though tricky because the reques=
t_sock is
> >>> no longer that easily available here so some parameter passing wo=
uld be
> >>> needed.
> >>
> >> Agreed.
> >>
> >> But even more simply I think we should make even the current
> >> tcp_ack_update_rtt() call here conditional on at least
> >> tp->srtt being zero.
> >>
> >> Damian do you at least agree with that?
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe netdev" =
in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at =A0http://vger.kernel.org/majordomo-info.ht=
ml
>
