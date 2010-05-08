From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH][v4] tcp: fix ICMP-RTO war
Date: Sun, 9 May 2010 01:00:32 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1005090037460.9479@melkinpaasi.cs.helsinki.fi>
References: <4B7303C2.5000703@tvk.rwth-aachen.de>  <alpine.DEB.2.00.1002151535030.7063@wel-95.cs.helsinki.fi>  <20100221.181029.71107197.davem@davemloft.net>  <o2z349f35ee1005071622z38fcd66ek398402d7512542ae@mail.gmail.com>
 <n2gd1c2719f1005071625nd3df3d72t9655a1f64f2fd825@mail.gmail.com>  <4BE5213C.1030300@tvk.rwth-aachen.de> <k2xd1c2719f1005081027v376a4ebfp300c6272f9ea91df@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696250871-1748872215-1273356032=:9479"
Cc: Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46741 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754390Ab0EHWAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 May 2010 18:00:34 -0400
In-Reply-To: <k2xd1c2719f1005081027v376a4ebfp300c6272f9ea91df@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696250871-1748872215-1273356032=:9479
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 8 May 2010, Jerry Chu wrote:

> On Sat, May 8, 2010 at 1:30 AM, Damian Lukowski
> <damian@tvk.rwth-aachen.de> wrote:
> >
> > > I'm working on a patch that tries to measure and use the RTT for the passive
> > > open side when the TS option is NOT enabled. My code conflicts with your
> > > recently added "tcp_ack_update_rtt(sk, 0, 0);" Could you tell me why do you
> > > force this call for the no-TS case when obviously "0" is not a measured RTT?
> > > If you try to force icsk_rto to be initialized correctly, it is
> > > already initialized to
> > > TCP_TIMEOUT_INIT by tcp_create_openreq_child(). What am I missing?
> >
> > Hi,
> > the backoff reversion code uses __tcp_set_rto() to recalculate icsk_rto,
> > which itself relies on tp->srtt and rttvar.
> 
> Guess you are talking about
> 
> inet_csk(sk)->icsk_rto = __tcp_set_rto(tp) <<
>                                          icsk->icsk_backoff;
> 
> inside tcp_v4_err(), right? (I'm looking at 2.6.33 kernel.)
> 
> Yes it seems to be a bug when __tcp_set_rto() is called before
> tcp_rtt_estimator()
> gets a chance to initialize all the variables properly.
>
> But I don't like your fix of adding tcp_ack_update_rtt(sk, 0, 0); to
> tcp_rcv_state_process()
> because that means you've got a measured RTT of 0 (really meaning < 1 tick) for
> the no-TS case, which will cause tcp_rtt_estimator() to compute all
> the variables as if
> there has been a valid RTT measurement of 1.
> 
> A better fix IMHO is to make sure all the variables are properly
> initialized when exiting
> tcp_init_metrics(), e.g, if srtt remains 0, make sure
> tp->mdev = tp->mdev_max = tp->rttvar = TCP_TIMEOUT_INIT;
> (mdev already been initialized to TCP_TIMEOUT_INIT. I think you got
> hit by rttvar == 0)
> 
> > srtt is explicitly set to 0 in tcp_create_openreq_child(), so I didn't change it.
> > Initializing it with TCP_TIMEOUT_INIT should also fix that specific bug,
> > but I don't know if there are other impacts.
> 
> So what do I care? Because I'm mucking with the code in this area and your fix
> causes some conflict with my logic.
> 
> What do you think?

I didn't/don't like the fix either, but it's better than ICMP-RTO war that 
it fixed.

I think that most sensible solution to this issue would not be to 
initialize with the TCP_TIMEOUT_INIT bogosity either but do the real 
measurement for rtt which should be possible already. I suggested this 
already when the fix was made but nobody has yet found the time and
energy to code the rtt measurement for the early rtt when not using TS. 
Since you're going to make that lack of feature to go away, please change 
this illogical call too then while you go :-).

-- 
 i.
---696250871-1748872215-1273356032=:9479--
