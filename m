From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 12 Aug 2008 05:20:48 +0000
Message-ID: <20080812052048.GA4291@ff.dom.local>
References: <20080811205357.GA15293@ami.dom.local> <20080811.181235.141399855.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:49050 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807AbYHLFVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 01:21:01 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1240373fgg.17
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2008 22:21:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080811.181235.141399855.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2008 at 06:12:35PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 11 Aug 2008 22:53:57 +0200
> 
> > pkt_sched: Destroy gen estimators under rtnl_lock().
> > 
> > gen_kill_estimator() requires rtnl_lock() protection, and since it is
> > called in qdisc ->destroy() too, this has to go back from RCU callback
> > to qdisc_destroy().
> > 
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> We can't do this.  And at a minimum, the final ->reset() must
> occur in the RCU callback, otherwise asynchronous threads of
> execution could queue packets into this dying qdisc and
> such packets would leak forever.

Could you explain this more? I've thought this synchronize_rcu() is
just to prevent this (and what these comments talk about?):

void dev_deactivate(struct net_device *dev)
{
        bool running;

        netdev_for_each_tx_queue(dev, dev_deactivate_queue, &noop_qdisc);
        dev_deactivate_queue(dev, &dev->rx_queue, &noop_qdisc);

        dev_watchdog_down(dev);

        /* Wait for outstanding qdisc-less dev_queue_xmit calls. */
        synchronize_rcu();

        do {
                while (some_qdisc_is_running(dev, 0))
                        yield();

                /*
                 * Double-check inside queue lock to ensure that all effects
                 * of the queue run are visible when we return.
                 */
                running = some_qdisc_is_running(dev, 1);

                /*
                 * The running flag should never be set at this point because
                 * we've already set dev->qdisc to noop_qdisc *inside* the same
                 * pair of spin locks.  That is, if any qdisc_run starts after
                 * our initial test it should see the noop_qdisc and then
                 * clear the RUNNING bit before dropping the queue lock.  So
                 * if it is set here then we've found a bug.
                 */
        } while (WARN_ON_ONCE(running));
}

Jarek P.
