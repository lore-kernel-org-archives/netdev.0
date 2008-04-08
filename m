From: Wenji Wu <wenji@fnal.gov>
Subject: Re: RE: A Linux TCP SACK Question
Date: Tue, 08 Apr 2008 09:30:14 -0500
Message-ID: <fba201de4228.47fb3b26@fnal.gov>
References: <fc471cb97cfd.47f5520e@fnal.gov>
 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
 <000001c8967c$496efa20$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804042253000.415@wrl-59.cs.helsinki.fi>
 <000b01c89699$00e99590$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0804050037380.8186@wrl-59.cs.helsinki.fi>
 <000f01c896a1$3022fec0$c95ee183@D2GT6T71>
 <649aecc70804051417l4cf9b30asec8ca8d55e79e051@mail.gmail.com>
 <fb8e9e4f102e.47f8ebfd@fnal.gov>
 <649aecc70804061543v3ca3d0dau2ce303ecd2310bdc@mail.gmail.com>
 <000701c898bf$99fc3f80$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
 <fbbce0572843.47fb038c@fnal.gov>
 <Pine.LNX.4.64.0804081623500.21784@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: 'Sangtae Ha' <sangtae.ha@gmail.com>,
	'John Heffner' <johnwheffner@gmail.com>,
	'Netdev' <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.fnal.gov ([131.225.111.12]:33773 "EHLO mailgw2.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752453AbYDHOgK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 10:36:10 -0400
Received: from mailav2.fnal.gov (mailav2.fnal.gov [131.225.111.20])
 by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0JZ00055AFW4X9@mailgw2.fnal.gov> for netdev@vger.kernel.org;
 Tue, 08 Apr 2008 09:30:14 -0500 (CDT)
Received: from mailgw1.fnal.gov ([131.225.111.11])
 by mailav2.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008040809301402912 for
 <netdev@vger.kernel.org>; Tue, 08 Apr 2008 09:30:14 -0500
Received: from conversion-daemon.mailgw1.fnal.gov by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0JZ000C01FSVG9@mailgw1.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Tue, 08 Apr 2008 09:30:14 -0500 (CDT)
In-reply-to: <Pine.LNX.4.64.0804081623500.21784@wrl-59.cs.helsinki.fi>
Content-language: en
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Yes, the adaptive tp->reordering will play a role here. 
> 
> ...What is not clear to me why NewReno does not go to recovery at 
> least 
> once near the beginning, or at least it won't result in a retransmission.


The problem cause me two weeks' time to debug!

With 3 DupACKs, tcp_ack() calls tcp_fastretrans_alert(), and which in turn calls tcp_xmit_retransmit_queue().

Within tcp_xmit_retransmit_queue(), there is a line of code that would cause the problem above:

......................................................................................................
 /* Forward retransmissions are possible only during Recovery. */
1999        if (icsk->icsk_ca_state != TCP_CA_Recovery)
2000                return;

2001
2002        /* No forward retransmissions in Reno are possible. */
2003        if (tcp_is_reno(tp))
2004                return;

.....................................................................................................

if you look at "tcp_is_reno", you would see that with SACK off, Reno does not do retransmit, it will return!!!

Really do not understand why these two lines of code exist there!!!

Also, this code still in 2.6.25.


 
> In which kernel version this dump comes from? 2.6.24 newreno is 
> crippled 
> with TSO as was recently discovered, ie., it won't mark lost super 
> skbs 
> at head and thus won't retransmit them. Also 2.6.25-rcs are still 
> broken 
> (though they'll transmit too much, I'll not go detail in here), DaveM 
> now 
> has the fix for 2.6.25-rcs in net-2.6.

The dumped file is from 2.6.24. 2.6.25's is similiar.

 
> > You can reverse the order of the tests, with SACK option on/off. The 
> 
> > results are still the same.
> 
> Ok. I just wanted to make sure so that we don't end up trace some test 
> 
> setup issue :-).
> 
> > Also, according to the source code, tp->reordering will be 
> initialized 
> > to "/proc/sys/net/ipv4/tcp_reordering" (default 3), when the new 
> > connection is established.
> 
> In addition, in tcp_init_metrics():
> 
> 	if (dst_metric(dst, RTAX_REORDERING) &&
>             tp->reordering != dst_metric(dst, RTAX_REORDERING)) {
>                 tcp_disable_fack(tp);
>                 tp->reordering = dst_metric(dst, RTAX_REORDERING);
>         }

Good to know this, thanks



wenji
