From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] netem: Segment GSO packets on enqueue.
Date: Tue, 26 Apr 2016 15:00:27 -0400
Message-ID: <20160426190026.GB12788@hmsreliant.think-freely.org>
References: <1461692618-21333-1-git-send-email-nhorman@tuxdriver.com>
 <1461696598.5535.35.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	netem@lists.linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34085 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843AbcDZTAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 15:00:46 -0400
Content-Disposition: inline
In-Reply-To: <1461696598.5535.35.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2016 at 11:49:58AM -0700, Eric Dumazet wrote:
> On Tue, 2016-04-26 at 13:43 -0400, Neil Horman wrote:
> > This was recently reported to me, and reproduced on the latest net kernel, when
> > attempting to run netperf from a host that had a netem qdisc attached to the
> > egress interface:
> 
> ..
> 
> > The problem occurs because netem is not prepared to handle GSO packets (as it
> > uses skb_checksum_help in its enqueue path, which cannot manipulate these
> > frames).
> > 
> > The solution I think is to simply segment the skb in a simmilar fashion to the
> > way we do in __dev_queue_xmit (via validate_xmit_skb), except here we always
> > segment, instead of only when the interface needs us to do it.  This allows
> > netem to properly drop/mangle/pass/etc the correct percentages of frames as per
> > its qdisc configuration, and avoid failing its checksum operations
> > 
> > tested successfully by myself on the latest net kernel, to whcih this applies
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > CC: Jamal Hadi Salim <jhs@mojatatu.com>
> > CC: "David S. Miller" <davem@davemloft.net>
> > CC: netem@lists.linux-foundation.org
> > ---
> >  net/sched/sch_netem.c | 34 +++++++++++++++++++++++++++++++++-
> >  1 file changed, 33 insertions(+), 1 deletion(-)
> 
> 
> This is not correct.
> 
> I want my TSO packets being still TSO after netem traversal.
> 
> Some of us use netem at 40Gbit speed ;)
> 
I can understand that, but that raises two questions in my mind:

1)  Doesn't that make all the statistical manipulation for netem wrong?  That is
to say, if netem drops 5% of packets, and it happens to drop a GSO packet, its
actually dropping several, instead of the single one required.

2) How are you getting netem to work with GSO at all?  The warning is triggered
for me on every GSO packet, which I think would impact throughput :)

Neil
