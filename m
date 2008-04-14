From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: RE: A Linux TCP SACK Question
Date: Mon, 14 Apr 2008 19:48:26 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804141927060.28474@wrl-59.cs.helsinki.fi>
References: <fc471cb97cfd.47f5520e@fnal.gov>
 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
 <000001c8967c$496efa20$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804042253000.415@wrl-59.cs.helsinki.fi>
 <000b01c89699$00e99590$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0804050037380.8186@wrl-59.cs.helsinki.fi>
 <000f01c896a1$3022fec0$c95ee183@D2GT6T71> <649aecc70804051417l4cf9b30asec8ca8d55e79e051@mail.gmail.com>
 <fb8e9e4f102e.47f8ebfd@fnal.gov> <649aecc70804061543v3ca3d0dau2ce303ecd2310bdc@mail.gmail.com>
 <000701c898bf$99fc3f80$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
 <000001c89e4a$019f1330$6b5ee183@D2GT6T71>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Sangtae Ha' <sangtae.ha@gmail.com>,
	'John Heffner' <johnwheffner@gmail.com>,
	'Netdev' <netdev@vger.kernel.org>
To: Wenji Wu <wenji@fnal.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58180 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754242AbYDNQsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 12:48:30 -0400
In-Reply-To: <000001c89e4a$019f1330$6b5ee183@D2GT6T71>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Apr 2008, Wenji Wu wrote:

> The latest results have been posted to:
> 
> https://plone3.fnal.gov/P0/WAN/Members/wenji/tcp_dump_files_sack/
> 
> The kernel under test is: Linux-2.6.25-rc9. I have checked with its
> changelog, which shows that your latest fix is included.

Hmm, now there are even less retransmissions (barely some with
the SACK in the end).

I suppose the reordering detection is good enough to kill them. ...You 
could perhaps figure that out from MIBs if you would want to.

> In the tests, I vary the tcp_frto (0, 1, and 2) with SACK On/Off.

...I should have said it more clearly last time already that these are 
not significant with your workload.

> The experiment works as:
> 
>       Sender --- Router --- Receiver
> 
> Iperf is sending from the sender to the receiver. In between there is an
> emulated router which runs netem. The emulated router has two interfaces,
> both with netem configured.  One interface emulates the forward path and the
> other for the reverse path. Both netem interfaces are configured with 1.5ms
> delay and 0.15ms variance. No packet drops in tests and packet capturing.

...How about this theory:

Forward path reordering causes duplicate ACKs due to old segments. These 
are threated differently for NewReno and SACK:

NewReno => Sends new data out (limited xmit; it's not limited to two 
           segments in linux as per RFC, however, RFC doesn't consider
	   autotuning of DupThresh either)
SACK =>    No new SACK block discovered. Packets in flight remains the 
           same, and thus no new segment is sent.

...What do other think?

I guess it should be visible with fwd path reordering alone, though the 
added distance with reverse path reordering might act as amplifier 
because NewReno benefits from shorter RTTed packets when fwd path 
old segment arrived while SACK losses its ability to increase 
outstanding data...

...A quick look into it with tcptrace's outstanding date plot, it seems 
that NewReno levels ~100000 and SACK ~68000.

...I think SACK just knows too much? :-/


> All of these systems are multi-core platforms, with 2G+ CPU. I run
> TOP to verify, CPUs are idle most of time.

Thanks for adding this for other. I agree with you that this is not
an cpu horsepower issue.


-- 
 i.

