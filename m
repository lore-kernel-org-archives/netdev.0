From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: [PATCH] sch_sfq: revert dont put new flow at the end of flows
Date: Wed, 14 Mar 2012 12:32:12 +0100
Message-ID: <1331724732.7651.58.camel@probook>
References: <1327570722.8191.46.camel@probook>
	 <1331697865.2456.19.camel@edumazet-laptop>
	 <CAA93jw4kYqCWg424SXkrtQeg9bPfpfgH-x_7tjg=m8uxk_GNaA@mail.gmail.com>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <netoptimizer@brouer.com>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:53906 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755525Ab2CNLcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 07:32:18 -0400
In-Reply-To: <CAA93jw4kYqCWg424SXkrtQeg9bPfpfgH-x_7tjg=m8uxk_GNaA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ons, 14 03 2012 kl. 04:52 +0000, skrev Dave Taht:
> On Wed, Mar 14, 2012 at 4:04 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > This reverts commit d47a0ac7b6 (sch_sfq: dont put new flow at the end of
> > flows)
> >
> > As Jesper found out, patch sounded great but has bad side effects.
> 
> Well under most circumstances it IS great.

Yes, I had really high hopes for this patch.  It unfortunately it can
cause starvation in some situations :-(.


> As the depth of the sfq queue increases it gets increasingly hard to
> trigger the problem. I've been using values in the 200-300 range, and
> in combination with red, haven't seen it happen.

I don't think you should adjust the "depth", but instead "limit" or
"flows".

The problem can be solved by SFQ parameter tuning.  Perhaps, we could
just change the default parameters?

The problem occurs when all flows have ONE packet, then sfq_drop()
cannot find a good flow to drop packets from...

This situation can occur because the default setting is "limit=127"
packets and "flows=127".  If we just make sure that "limit" > "flows",
then one flow with >=2 packets should exist, which is then chosen for
drop.
My practical experiments show that "limit" should be between 10-20
packets larger than "flows" (I'm not completely sure why this is
needed).  

[cut]
> > In stress situation, pushing new flows in front of the queue can prevent
> > old flows doing any progress. Packets can stay in SFQ queue for
> > unlimited amount of time.

In my experiments, one "existing" flow would get all the bandwidth,
while other flows got starved.   And new flows could not be established.


--Jesper Brouer
