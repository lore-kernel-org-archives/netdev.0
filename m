From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: RE: A Linux TCP SACK Question
Date: Tue, 8 Apr 2008 17:59:06 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804081742270.21784@wrl-59.cs.helsinki.fi>
References: <fc471cb97cfd.47f5520e@fnal.gov>
 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
 <000001c8967c$496efa20$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804042253000.415@wrl-59.cs.helsinki.fi>
 <000b01c89699$00e99590$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0804050037380.8186@wrl-59.cs.helsinki.fi>
 <000f01c896a1$3022fec0$c95ee183@D2GT6T71> <649aecc70804051417l4cf9b30asec8ca8d55e79e051@mail.gmail.com>
 <fb8e9e4f102e.47f8ebfd@fnal.gov> <649aecc70804061543v3ca3d0dau2ce303ecd2310bdc@mail.gmail.com>
 <000701c898bf$99fc3f80$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
 <fbbce0572843.47fb038c@fnal.gov> <Pine.LNX.4.64.0804081623500.21784@wrl-59.cs.helsinki.fi>
 <fba201de4228.47fb3b26@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Sangtae Ha' <sangtae.ha@gmail.com>,
	'John Heffner' <johnwheffner@gmail.com>,
	'Netdev' <netdev@vger.kernel.org>
To: Wenji Wu <wenji@fnal.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57722 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752510AbYDHO7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 10:59:09 -0400
In-Reply-To: <fba201de4228.47fb3b26@fnal.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Apr 2008, Wenji Wu wrote:

> With 3 DupACKs, tcp_ack() calls tcp_fastretrans_alert(), and which in 
> turn calls tcp_xmit_retransmit_queue().

Yeah. It should.

> Within tcp_xmit_retransmit_queue(), there is a line of code that would 
> cause the problem above:
> 
> ......................................................................................................
>  /* Forward retransmissions are possible only during Recovery. */
> 1999        if (icsk->icsk_ca_state != TCP_CA_Recovery)
> 2000                return;
> 
> 2001
> 2002        /* No forward retransmissions in Reno are possible. */
> 2003        if (tcp_is_reno(tp))
> 2004                return;
> 
> .....................................................................................................
> 
> if you look at "tcp_is_reno", you would see that with SACK off, Reno 
> does not do retransmit, it will return!!!

Your analysis is missing something important here, there are two loops 
there :-). One for retransmitting assumed lost segments that's above those 
lines you quoted! The other below is for non-lost marked similar to what 
is specified by RFC3517's Rule 3 for NextSeg, which definately won't apply 
for newreno nor should be executed.

> Really do not understand why these two lines of code exist there!!!
>
> Also, this code still in 2.6.25.

Sure, but there's nothing wrong with them! 2.6.24 just is currently broken 
if you have TSO+NewReno because it won't do the correct lost marking which 
is a necessary preparation step for the loop above that, too bad as I just 
figured that out one/two days ago so there's no fix yet available :-).

> > In which kernel version this dump comes from? 2.6.24 newreno is 
> > crippled 
> > with TSO as was recently discovered, ie., it won't mark lost super 
> > skbs 
> > at head and thus won't retransmit them. Also 2.6.25-rcs are still 
> > broken 
> > (though they'll transmit too much, I'll not go detail in here), DaveM 
> > now 
> > has the fix for 2.6.25-rcs in net-2.6.
> 
> The dumped file is from 2.6.24. 2.6.25's is similiar.

It's a bit hard for me to believe, considering what the last weeks debug 
has revealed about internals of it. Have you checked it from the dumps or 
from the overall results, a similarity in the latter could be due to 
other factors related to the differences in reordering detection between 
NewReno/SACK.

> > In addition, in tcp_init_metrics():
> > 
> > 	if (dst_metric(dst, RTAX_REORDERING) &&
> >             tp->reordering != dst_metric(dst, RTAX_REORDERING)) {
> >                 tcp_disable_fack(tp);
> >                 tp->reordering = dst_metric(dst, RTAX_REORDERING);
> >         }
> 
> Good to know this, thanks

...There might be some bug which causes it to get skipped under some 
circumstances though (which I haven't yet remembered to fix). I don't 
remember too well anymore, probably some goto which caused skipping most 
of what's in there.

-- 
 i.
