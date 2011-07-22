From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods
Date: Thu, 21 Jul 2011 21:37:19 -0400
Message-ID: <20110722013718.GA1993@neilslaptop.think-freely.org>
References: <4E28A4C8.8040707@candelatech.com>
 <20110721.151903.297506479006061401.davem@davemloft.net>
 <20110721235049.GA29489@hmsreliant.think-freely.org>
 <20110721.170855.1343650615466483577.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greearb@candelatech.com, eric.dumazet@gmail.com, jpirko@redhat.com,
	netdev@vger.kernel.org, adobriyan@gmail.com,
	robert.olsson@its.uu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60256 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599Ab1GVBhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 21:37:35 -0400
Content-Disposition: inline
In-Reply-To: <20110721.170855.1343650615466483577.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 21, 2011 at 05:08:55PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Thu, 21 Jul 2011 19:50:49 -0400
> 
> > I'm happy to go down this route Dave, and agree, its a more solid solution, but
> > I think the problem with it (which Ben may have been alluding to previously) is
> > that pktgen doesn't use dev_queue_xmit or dev_hard_start_xmit to send frames.
> 
> Neil, that's THE WHOLE POINT, and HOW MY IDEA WORKS.
> 
Dave, RELAX! I GET HOW YOUR IDEA SHOULD WORK!  CAPS ARENT NEEDED! :) 

> Pktgen bypasses those functions, so it won't trigger the check and
> therefore won't trigger making a copy of the SKB, since copying isn't
> needed.
> 
But thats part of the problem, we can't just have pktgen bypass those calls
entirely, assuming that the underlying driver will do so.  See the ppp driver as
an example, it does an skb_pull to add a header to the skb, so multiple
iterations of the multi-skb case will result in stacked header inadvertently.
Another example is the virtio_net driver, which uses the skb->cb area to store
information that would get corrupted in the process.  Neither of those would
pass through the dev_hard_start_xmit path and would be left uncovered by this
solution.

We could fix that by:

a) having pktgen call dev_hard_start_xmit for all frames, giving rise to the
performance issue I was bringing up in my last note.

b) augmenting each driver to check for the flag in the skb as you describe,
which in my mind is no better than having a flag in the netdevice informing
pktgen of weather or not it can use a shared skb approach.

> Only layering devices will end up eventually calling into those two
> functions and trigger the "need to copy because this SKB is pktgen
> shared" check.
> 
See above, that doesn't solve the entire problem.

Regards
Neil

