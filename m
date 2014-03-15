From: ebiederm@xmission.com (Eric W. Biederman)
Subject: mlx4 netpoll and rx/tx weirdness
Date: Sat, 15 Mar 2014 13:01:09 -0700
Message-ID: <87ob17kz96.fsf_-_@xmission.com>
References: <871ty41dps.fsf_-_@xmission.com> <87lhwcw9j9.fsf_-_@xmission.com>
	<1394897014.15764.26.camel@deadeye.wl.decadent.org.uk>
	<20140315.122912.1621610280186900725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ben@decadent.org.uk, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:49673 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753778AbaCOUBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Mar 2014 16:01:20 -0400
Cc: Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
In-Reply-To: <20140315.122912.1621610280186900725.davem@davemloft.net> (David
	Miller's message of "Sat, 15 Mar 2014 12:29:12 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Sat, 15 Mar 2014 15:23:34 +0000
>
>> On Fri, 2014-03-14 at 18:11 -0700, Eric W. Biederman wrote:
>>> Processing any incoming packets with a with a napi budget of 0
>>> is incorrect driver behavior.
>>> 
>>> This matters as netpoll will shortly call drivers with a budget of 0
>>> to avoid receive packet processing happening in hard irq context.
>> 
>> But this also prevents handling TX completions, at which point you may
>> as well change efx_netpoll() to a no-op.  And then, does it make sense
>> to implement ndo_poll_controller at all?
>> 
>> Note that sfc does have a module parameter to enable separate RX and TX
>> completions so they could be polled separately, but it is disabled by
>> default.
>
> TX completions should run unconditionally, irregardless of the given
> budget.
>
> This is how I have coded all of my drivers, and I how I tell others
> to do so.

Given this comment I have to ask:  How insane is the mellanox mlx4
driver that has separate rx and tx queues, separate rx and tx interrupts
and uses separate napi bottom halves to process each, and honors the
budget passed into it's rx napi handler.

Right now the mlx4 code disables interrupts and calls napi_synchronize
in it's netpoll routine instead of just scheduling the napi bottom
halves as all of the sane drivers do.  napi_synchronize trying to sleep
in hard irq context is pretty terrible, but I can see roughly how that
should be fixed.

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index fa5ee719e04b..2e6fded14e60 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1302,16 +1302,10 @@ out:
 static void mlx4_en_netpoll(struct net_device *dev)
 {
        struct mlx4_en_priv *priv = netdev_priv(dev);
-       struct mlx4_en_cq *cq;
-       unsigned long flags;
        int i;
 
        for (i = 0; i < priv->rx_ring_num; i++) {
-               cq = priv->rx_cq[i];
-               spin_lock_irqsave(&cq->lock, flags);
-               napi_synchronize(&cq->napi);
-               mlx4_en_process_rx_cq(dev, cq, 0);
-               spin_unlock_irqrestore(&cq->lock, flags);
+               napi_schedule(&priv->tx_cq[i]->napi);
        }
 }

What I can't see is what is a clean thing to do with the mlx4 tx bottom
napi bottom half.  As it won't processes the tx cq when I pass in a
budget of 0.

What I can't see is how to prevent a netpoll stalling after enough
packets are transmitted from hard irq context say with sysrq-l on
a machine with enough cpus to fill the tx queue.

If possible I would very much like to get this to work.

Eric
