From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC][PATCH 1/2] TCP: fix lost retransmit detection
Date: Tue, 9 Oct 2007 15:19:50 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710091304120.31129@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0710041419560.31129@kivilampi-30.cs.helsinki.fi>
 <20071007.145100.00679926.takano@axe-inc.co.jp>
 <Pine.LNX.4.64.0710081258440.31129@kivilampi-30.cs.helsinki.fi>
 <20071009.152834.38612348.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1619944004-1191924263=:31129"
Cc: Netdev <netdev@vger.kernel.org>, y-kodama@aist.go.jp
To: TAKANO Ryousei <takano@axe-inc.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34987 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbXJIMTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 08:19:53 -0400
In-Reply-To: <20071009.152834.38612348.takano@axe-inc.co.jp>
Content-ID: <Pine.LNX.4.64.0710091517580.31129@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1619944004-1191924263=:31129
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0710091306231.31129@kivilampi-30.cs.helsinki.fi>

On Tue, 9 Oct 2007, TAKANO Ryousei wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Subject: Re: [RFC][PATCH 1/2] TCP: fix lost retransmit detection
> Date: Mon, 8 Oct 2007 14:11:55 +0300 (EEST)
> 
> > On Sun, 7 Oct 2007, TAKANO Ryousei wrote:
> > 
> > > From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> > > 
> > > > Just couple of thoughts, not that this change itself is incorrect...

...Added this line back, it's important. :-)

> > > > In case sacktag uses fastpath, this code won't be executed for the skb's 
> > > > that we would like to check (those with SACKED_RETRANS set, that are 
> > > > below the fastpath_skb_hint). We will eventually deal with the whole queue 
> > > > when fastpath_skb_hint gets set to NULL, with the next cumulative ACK that 
> > > > fully ACKs an skb at the latest. Maybe there's a need for a larger surgery 
> > > > than this to fix it. I think we need additional field to tcp_sock to avoid 
> > > > doing a full-walk per ACK:
> > >
> > > I think the problem occurs in slowpath. For example, in case when the receiver
> > > detects and sends back a new SACK block, the sender may fail to detect loss
> > > of a retransmitted packet.
> > 
> > ...No, the slow path is very likely to _correct_ the problem! The problem 
> > occurs because fastpath _skips_ processing of skbs below fastpath_skb_hint 
> > whereas slowpath starts from tcp_write_queue_head. The retransmitted skbs 
> > we're interested in reside exactly on that skipped range.
> > 
> Sorry, my explanaton is insufficient.
> This problem occurs even if we are in the slowpath.
>
> [...long explination snip...]
>
> Is it corrent?

Yes, we're dealing with two related, but different problems here. I 
understood well what you're trying to fix, and even acknowledged your 
change (see what I added back from my original reply above). The far
worse problem which I describe, however, occurs with fastpath only (well, 
very unlikely to occur with slow-path but it could in theory), has been 
like this since the hints were added. And it's preventing the execution
of this portion you fixed (until slowpath is taken).

...What makes the other problem even nastier is the fact that it
becomes more and more significant when fastpath (or it's equivalent)
skips more and more skb processing. It's good that we noticed it
now...

I tried to do a fix to that other problem, it seems that the solution
will be intertwined with the problem you're describing so that I in
fact ended removing the code block where your key modification is and
placing  somewhat similar sequence gathering elsewhere... Posting it 
shortly.

-- 
 i.
---696243703-1619944004-1191924263=:31129--
