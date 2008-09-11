From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
 dev_deactivate() race
Date: Thu, 11 Sep 2008 03:49:55 -0700 (PDT)
Message-ID: <20080911.034955.111797743.davem@davemloft.net>
References: <20080821.005250.117238212.davem@davemloft.net>
	<20080911.033956.233317469.davem@davemloft.net>
	<20080911104531.GA21913@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47470
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752235AbYIKKuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 06:50:01 -0400
In-Reply-To: <20080911104531.GA21913@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 11 Sep 2008 20:45:31 +1000

> On Thu, Sep 11, 2008 at 03:39:56AM -0700, David Miller wrote:
> >
> > I got to looking into this and we do need the qdisc->dev_queue member,
> > see qdisc_run().  So it's not like we can get rid of it if we replace
> > it with ->netdevdev and add a ->root_qdisc backpointer as well.
> 
> That can't be right.  Let's I've got a single qdisc shared by
> n queues.  It makes no sense for qdisc_run to decide to whether
> it should process the qdisc depending on the status of a single
> one out of the n queues.

Well some kind of check has to be there.

I _did_ remove it during my initial implementation, and that
turned into a reported performance regression.

See:

commit 83f36f3f35f4f83fa346bfff58a5deabc78370e5
Author: David S. Miller <davem@davemloft.net>
Date:   Wed Aug 13 02:13:34 2008 -0700

    pkt_sched: Add queue stopped test back to qdisc_run().
    
    Based upon a bug report by Andrew Gallatin on netdev
    with subject "CPU utilization increased in 2.6.27rc"
    
    In commit 37437bb2e1ae8af470dfcd5b4ff454110894ccaf
    ("pkt_sched: Schedule qdiscs instead of netdev_queue.")
    the test of the queue being stopped was erroneously
    removed from qdisc_run().
    
    When the TX queue of the device fills up, this omission
    causes lots of extraneous useless work to be queued up
    to softirq context, where we'll just return immediately
    because the device is still stuffed up.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>
