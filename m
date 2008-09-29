From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: AIM9 regression
Date: Mon, 29 Sep 2008 17:24:29 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0809291252490.1034@wrl-59.cs.helsinki.fi>
References: <20080924051237.GA6173@gondor.apana.org.au>
 <20080923.221831.126801015.davem@davemloft.net> <20080924081603.08a5f808@extreme>
 <20080924.123657.217162945.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, herbert@gondor.apana.org.au,
	cl@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55154 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750712AbYI2OYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 10:24:31 -0400
In-Reply-To: <20080924.123657.217162945.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Sep 2008, David Miller wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 24 Sep 2008 08:16:03 -0700
> 
> > On Tue, 23 Sep 2008 22:18:31 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> > > From: Herbert Xu <herbert@gondor.apana.org.au>
> > > Date: Wed, 24 Sep 2008 13:12:37 +0800
> > > 
> > > > On Tue, Sep 23, 2008 at 01:14:27PM -0500, Christoph Lameter wrote:
> > > > > I just dont seem to be able to get 2.6.27 to behave in a speedy way network
> > > > > wise. Configured out various components (netfilter, etc etc) but I still keep
> > > > > getting these aim9 result against 2.6.22:
> > > > 
> > > > Could you please compare this against something less ancient,
> > > > like 2.6.26 perhaps?
> > > 
> > > Herbert, this is part of the tbench regression issues.  Christoph
> > > took tbench from 2.6.22 until 2.6.27 and at basically every release
> > > tbench performance suffered noticably.
> > > 
> > > Now, he's taking the AIM9 benchmark networking numbers and showing
> > > that the same exact effect is seen there too.
> > > 
> > > It really behooves us to start doing something proactive about this
> > > blindingly obvious set of networking performance regressions through
> > > the past 6 or so releases instead of barking at the reporters saying
> > > things like "try this, try that, what's your config" etc.
> > > 
> > > :-)
> > 
> > These loopback benchmarks are often more sensitive to scheduler than 
> > networking changes.
> 
> When it gets to %20, I strong start to doubt that, and this is exactly
> what's happening here.
>
> What is it going to take to actually get someone to start profiling and
> analyzing this?  :-)

...I was thinking earlier to answer "time?", but now once been there, it 
seems that more time is more appropriate... So far I haven't been able to 
find a way to create a reproducable serie of result numbers with aim9 
tcp_test... it seems that the results vary within that (at least) 20% 
margin. Can Christoph actually get stable numbers out of it with 27-rcs
(I haven't extensively tested .22 yet with long test durations but it 
seems that same problem occurs with it as well if short tests were used)?

...And what I've learned, I couldn't even finish a testrun with conntrack 
and default settings as ipv4 conntrack run out of entries :-).

Ow, almost forgot, I got some stable regression with lockdep though,
I hope we've gotten some more power to its detection in return for the
lost performance.

I got these top variations (in absolute numbers) between three consecutive 
runs of 1000 seconds aim9 tcp_test (3xoprof(abs,%), func, max-min, 
(max-min)/min), aim9+its data on tmpfs (with nodebug-nonf config):

266288	1.0221	420190	1.6457	614494	2.4039	vfs_read	348206	1.30763
233649	0.8968	317763	1.2446	508838	1.9906	vfs_write	275189	1.17779
228732	0.8779	496359	1.9440	324747	1.2704	dnotify_parent	267627	1.17005
671548	2.5776	592604	2.3210	445792	1.7440	inet_csk_get_port	225756	0.506416
392960	1.5083	362665	1.4204	491234	1.9217	netif_rx	128569	0.354512
121337	0.4657	208314	0.8159	249783	0.9772	do_sync_write	128446	1.05859
164951	0.6331	168276	0.6591	285451	1.1167	loopback_xmit	120500	0.73052
359659	1.3805	242133	0.9483	256785	1.0046	__tcp_select_window	117526	0.485378
876319	3.3636	762690	2.9872	772554	3.0223	tcp_sendmsg	113629	0.148985
266895	1.0244	199204	0.7802	176985	0.6924	tcp_established_options	89910	0.508009
689652	2.6471	647962	2.5378	608943	2.3822	dev_queue_xmit	80709	0.132539
206754	0.7936	265523	1.0400	284087	1.1114	__kmalloc_track_caller	77333	0.374034
544026	2.0882	496654	1.9452	571982	2.2376	tcp_recvmsg	75328	0.151671
600414	2.3046	525704	2.0590	567588	2.2204	ip_queue_xmit	74710	0.142114
131820	0.5060	59259	0.2321	121586	0.4757	getnstimeofday	72561	1.22447
67061	0.2574	132155	0.5176	137914	0.5395	rw_verify_area	70853	1.05655
129676	0.4977	60652	0.2376	98307	0.3846	sock_rfree	69024	1.13803
535701	2.0562	586248	2.2961	517563	2.0247	ip_finish_output	68685	0.132708
692187	2.6568	634962	2.4869	623888	2.4407	tcp_rcv_established	68299	0.109473
949233	3.6435	900741	3.5279	882256	3.4514	tcp_transmit_skb	66977	0.0759156

...like said, the variation in the aim9 results were ~20% at most.


-- 
 i.
