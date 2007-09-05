From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Wed, 5 Sep 2007 22:04:11 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0709051142260.30179@kivilampi-30.cs.helsinki.fi>
References: <46D5F32F.2070502@hp.com> <20070829.153503.18295527.davem@davemloft.net>
 <46D5FBF3.5050700@hp.com> <20070829.161528.38309258.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, ian.mcdonald@jandi.co.nz,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34293 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754304AbXIETEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 15:04:14 -0400
In-Reply-To: <20070829.161528.38309258.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Aug 2007, David Miller wrote:

> From: Rick Jones <rick.jones2@hp.com>
> Date: Wed, 29 Aug 2007 16:06:27 -0700
> 
> > I belive the biggest component comes from link-layer retransmissions. 
> > There can also be some short outtages thanks to signal blocking, 
> > tunnels, people with big hats and whatnot that the link-layer 
> > retransmissions are trying to address.  The three seconds seems to be a 
> > value that gives the certainty that 99 times out of 10 the segment was 
> > indeed lost.
> > 
> > The trace I've been sent shows clean RTTs ranging from ~200 milliseconds 
> > to ~7000 milliseconds.
> 
> Thanks for the info.
> 
> It's pretty easy to generate examples where we might have some sockets
> talking over interfaces on such a network and others which are not.
> Therefore, if we do this, a per-route metric is probably the best bet.
> 
> Ilpo, I'm also very interested to see what you think of all of this :-)

...Haven't been too actively reading mails for a while until now, so I'm a 
bit late in response... I'll try to quickly summarize FRTO here.

It's true that FRTO cannot prevent the first retransmission, yet I suspect 
that it won't cost that much even if you have to pay for each bit, won't 
be that high percentage out of all packets after all :-). However, usually 
when you have a spurious RTO, not only the first segment unnecessarily 
retransmitted but the *whole window*. It goes like this: all cumulative 
ACKs got delayed due to in-order delivery, then TCP will actually send
1.5*original cwnd worth of data in the RTO's slow-start when the delayed 
ACKs arrive (basically the original cwnd worth of it unnecessarily). In 
case one is interested in minimizing unnecessary retransmissions e.g. due 
to cost, those rexmissions must never see daylight. Besides, in the worst 
case the generated burst overloads the bottleneck buffers which is likely 
to significantly delay the further progress of the flow. In case of ll 
rexmissions, ACK compression often occurs at the same time making the 
burst very "sharp edged" (in that case TCP often loses most of the 
segments above high_seq => very bad performance too). When FRTO is 
enabled, those unnecessary retransmissions are fully avoided except for 
the first segment and the cwnd behavior after detected spurious RTO is 
determined by the response (one can tune that by sysctl). Basic version 
(non-SACK enhanced one), FRTO can fail to detect spurious RTO as spurious 
and falls back to conservative behavior. ACK lossage is much less 
significant than reordering, usually the FRTO can detect spurious RTO if 
at least 2 cumulative ACKs from original window are preserved (excluding 
the ACK that advances to high_seq). With SACK-enhanced version, the 
detection is quite robust. Of course one could jump to min_rto bandwagon 
instead, but it often ends up being more or less black magic and can still 
produce unwanted behavior unless one goes to ridicilously high minimum RTOs.

Main obstacle to FRTO use is its deployment as it has to be on the sender 
side where as wireless link is often the receiver's access link but if one 
can tune tcp_min_rto (or equal) on the sender side, one could enable
FRTO at will as well. Anyway, anything older than 2.6.22 is not going to 
give very good results with FRTO. FRTO code's maturity point of view, IMHO 
currently just unconditional clearing of undo_marker (in 
tcp_enter_frto_loss) is on the way of enabling FRTO in future kernels by 
default as it basically disables DSACK undoing, I'll try to solve that 
soon, has been on my todo list for too long already (don't currently have 
much time to devote to that though so 2.6.24-rc1 might come too early for 
me :-(). After that, it might be a good move to enable it in mainline by 
default if you agree... ...Uninteresting enough, even IETF seems to 
interested in advancing FRTO from experimental [1].

Another important thing to consider in cellular besides ll rexmissions is 
bandwidth allocation delay... We actually a week ago ran some measurements 
in a real umts network to determine buffer, one-way delay, etc. behavior 
(though YMMV depending on operators configuration etc.). Basically we saw 
1 s delay spike when allocation delay occurs (it's very hard to predict 
when that happens due to other network users role). One-way propagation 
delay was around 50 ms, so 1500 bytes takes about 80 ms+ to transmit, so 
it's it order of magnitude larger than RTT but queue delay is probably 
large enough to prevent spurious RTOs due to allocation delay. Besides 
that, we saw some long latencies, up to 8-12 s, they could be due to ll 
retransmissions but their source is not yet verified to be the WWAN link 
as we had the phone connected through bluetooth (could interfere). A funny 
sidenote about the experiment, we found out what Linux cannot do (from 
userspace only): it seems to be unable to receive the same packet it has 
sent out to itself as we forced the packet out from eth0 by binding 
sending dev to eth0 and received from ppp0 => the packet gots always 
discard as martian and there seems to be no knob to that, so had to 
hack it :-).


-- 
 i.


[1] http://www1.ietf.org/mail-archive/web/tcpm/current/msg02862.html
