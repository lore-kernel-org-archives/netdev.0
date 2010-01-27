From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] tcp: fix ICMP-RTO war
Date: Wed, 27 Jan 2010 17:14:58 +0300
Message-ID: <20100127141457.GB1418@ms2.inr.ac.ru>
References: <alpine.DEB.2.00.1001240007530.16552@melkinpaasi.cs.helsinki.fi> <201001240045.52846.denys@visp.net.lb> <4B5DB3BF.1080409@tvk.rwth-aachen.de> <20100125.234557.00486980.davem@davemloft.net> <alpine.DEB.2.00.1001260957540.17103@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, damian@tvk.rwth-aachen.de,
	denys@visp.net.lb, Netdev <netdev@vger.kernel.org>
To: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:57463 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754554Ab0A0PPN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2010 10:15:13 -0500
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1001260957540.17103@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

> I went through some history, it seems that this comment about the lower 
> bound originates from Alexey [1]:

Yes, I even remember why it was done.

Actual comment starts with "If rtt variance happened to be less 50msec...".

It was observed that sometimes due to high burstiness of ACKs
(found originally when linux commuinitected to solaris tcp stack,
which issued huge burst of acks each 50msec. I think he data can be found
in netdev archives), rtt deviation tends to collapse to 0 during such burst,
rto was calculated as plain rtt and obviously we falled to retransmit.

So, the algorithm was repaired. First, to avoid glitches in the future
mdev was clamped to 50ms (rttvar, contribution to rto, is 200msec).
That's what the comment is about.

Second, Linux used to sample rtt each ack, not each rtt (which is technically
main source of the problem). Instead of decreasing sampling rate
I used different sampling rates for growing and dropping rtt:
it grows with rate of arriving acks and drops each rtt i.e. rto grows
quickly, but drops slowly.

Alexey
