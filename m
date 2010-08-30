From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] TCP_USER_TIMEOUT: a new socket option to specify max
 timeout before a TCP connection is aborted
Date: Sun, 29 Aug 2010 17:23:05 -0700
Message-ID: <AANLkTimW_7a9=yK4po9FshH0i0LT-MZF+fysGRvgT3jG@mail.gmail.com>
References: <1282972408-19164-1-git-send-email-hkchu@google.com>
	<20100828.161320.245404727.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, hannemann@nets.rwth-aachen.de,
	hagen@jauu.net, lars.eggert@nokia.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:43581 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357Ab0H3AXL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Aug 2010 20:23:11 -0400
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id o7U0NAjV026780
	for <netdev@vger.kernel.org>; Sun, 29 Aug 2010 17:23:10 -0700
Received: from yxh35 (yxh35.prod.google.com [10.190.2.227])
	by hpaq2.eem.corp.google.com with ESMTP id o7U0N8Xa009838
	for <netdev@vger.kernel.org>; Sun, 29 Aug 2010 17:23:09 -0700
Received: by yxh35 with SMTP id 35so2027771yxh.12
        for <netdev@vger.kernel.org>; Sun, 29 Aug 2010 17:23:08 -0700 (PDT)
In-Reply-To: <20100828.161320.245404727.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 28, 2010 at 4:13 PM, David Miller <davem@davemloft.net> wro=
te:
>
> From: "H.K. Jerry Chu" <hkchu@google.com>
> Date: Fri, 27 Aug 2010 22:13:28 -0700
>
> > @@ -556,7 +559,14 @@ static void tcp_keepalive_timer (unsigned long=
 data)
> > =A0 =A0 =A0 elapsed =3D keepalive_time_elapsed(tp);
> >
> > =A0 =A0 =A0 if (elapsed >=3D keepalive_time_when(tp)) {
> > - =A0 =A0 =A0 =A0 =A0 =A0 if (icsk->icsk_probes_out >=3D keepalive_=
probes(tp)) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 /* If the TCP_USER_TIMEOUT option is enab=
led, use that
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0* to determine when to timeout instead=
=2E
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> > + =A0 =A0 =A0 =A0 =A0 =A0 if ((icsk->icsk_user_timeout !=3D 0 &&
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 elapsed >=3D icsk->icsk_user_time=
out &&
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 icsk->icsk_probes_out > 0) ||
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (icsk->icsk_user_timeout =3D=3D 0=
 &&
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 icsk->icsk_probes_out >=3D keepal=
ive_probes(tp))) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_send_active_reset(s=
k, GFP_ATOMIC);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_write_err(sk);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>
> I think if we want to add a socket option which overrides, it makes
> more sense to provide overrides in the same units. =A0This
> transformation here is transforming a check against apples into a
> check against oranges.
>
> But if that's how this thing is specified, so be it... I guess. :-/

Correct.=A0 It seems that there has been a bit of inconsistency regardi=
ng the
unit of "timeouts". RFC1122 says "R1 and R2 might be measured in time
units or as a count of retransmissions." Most of the OSes including Lin=
ux
seem to measure timeout in # of retries. But RFC5482 defines its "User
Timeout Option" in time units.

Personally I think as an API, it's easier for an application to grasp
the concept
of a time quantity than # of retransmissions. (E.g., how will an app
determine it
needs 10 retries vs 20 retries?)

Jerry
