From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH][v4] tcp: fix ICMP-RTO war
Date: Fri, 7 May 2010 16:25:46 -0700
Message-ID: <n2gd1c2719f1005071625nd3df3d72t9655a1f64f2fd825@mail.gmail.com>
References: <4B7303C2.5000703@tvk.rwth-aachen.de>
	 <alpine.DEB.2.00.1002151535030.7063@wel-95.cs.helsinki.fi>
	 <20100221.181029.71107197.davem@davemloft.net>
	 <o2z349f35ee1005071622z38fcd66ek398402d7512542ae@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: damian@tvk.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:41922 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951Ab0EGXZv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 19:25:51 -0400
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o47NPm5G018773
	for <netdev@vger.kernel.org>; Fri, 7 May 2010 16:25:49 -0700
Received: from gxk24 (gxk24.prod.google.com [10.202.11.24])
	by kpbe17.cbf.corp.google.com with ESMTP id o47NPWh4004173
	for <netdev@vger.kernel.org>; Fri, 7 May 2010 16:25:47 -0700
Received: by gxk24 with SMTP id 24so997381gxk.18
        for <netdev@vger.kernel.org>; Fri, 07 May 2010 16:25:47 -0700 (PDT)
In-Reply-To: <o2z349f35ee1005071622z38fcd66ek398402d7512542ae@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm working on a patch that tries to measure and use the RTT for the pa=
ssive
open side when the TS option is NOT enabled. My code conflicts with you=
r
recently added "tcp_ack_update_rtt(sk, 0, 0);" Could you tell me why do=
 you
force this call for the no-TS case when obviously "0" is not a measured=
 RTT?
If you try to force icsk_rto to be initialized correctly, it is
already initialized to
TCP_TIMEOUT_INIT by tcp_create_openreq_child(). What am I missing?

Thanks,

Jerry

>From: David Miller <davem@davemloft.net>
>
> Date: Sun, Feb 21, 2010 at 7:10 PM
> Subject: Re: [PATCH][v4] tcp: fix ICMP-RTO war
> To: ilpo.jarvinen@helsinki.fi
> Cc: damian@tvk.rwth-aachen.de, netdev@vger.kernel.org
>
>
> From: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Tue, 16 Feb 2010 14:45:25 +0200 (EET)
>
> > On Wed, 10 Feb 2010, Damian Lukowski wrote:
> >
> >> @@ -5783,12 +5783,10 @@ int tcp_rcv_state_process(struct sock *sk,=
 struct sk_buff *skb,
> >>
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* tcp_=
ack considers this ACK as duplicate
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * and =
does not calculate rtt.
> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Fix it=
 at least with timestamps.
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Force =
it here.
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (tp->r=
x_opt.saw_tstamp &&
> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0t=
p->rx_opt.rcv_tsecr && !tp->srtt)
> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0tcp_ack_saw_tstamp(sk, 0);
> >> -
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tcp_ack_u=
pdate_rtt(sk, 0, 0);
> >> +
> >
> > ...Here a zero seq_rtt is given to RTT estimator (it will be effect=
ive
> > only in the case w/o timestamps, TS case recalculates it from the s=
tored
> > timestamps). Maybe we could use some field (timestamp related one c=
omes to
> > my mind) in request sock to get a real RTT estimate for non-timesta=
mp case
> > too. ...It seems possible to me, though tricky because the request_=
sock is
> > no longer that easily available here so some parameter passing woul=
d be
> > needed.
>
> Agreed.
>
> But even more simply I think we should make even the current
> tcp_ack_update_rtt() call here conditional on at least
> tp->srtt being zero.
>
> Damian do you at least agree with that?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
