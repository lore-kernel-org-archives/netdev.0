From: Jason Lunz <lunz@falooley.org>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Wed, 25 Jun 2003 16:01:04 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <slrnbfjhqh.h0q.lunz@stoli.localnet>
References: <20030625072602.529AF2C0B9@lists.samba.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

rusty@rustcorp.com.au said:
> I don't understand the unbalanced dev_put in net_rx_action(), BTW.

It's tricky. There are two paths an skb can take into net_rx_action(),
napi and non-napi. The non-napi path uses dev_hold/dev_put on both
skb->dev and a virtual per-cpu struct net_device, the backlog_dev.

In a non-napi skb receive, the driver uses netif_rx() to hand the skb up
to the net core. netif_rx does a dev_hold on skb->dev, puts the skb on
the current cpu's softnet_data queue, and uses netif_rx_schedule to
schedule that softnet-data's ->backlog_dev to be polled.  In the
process, __netif_rx_schedule does a dev_hold(backlog_dev).

So the queue of ready net_devices processed by net_rx_action may contain
actual struct net_devices (napi) or the virtual ->backlog_dev
net_device. In the former case, net_rx_action's dev_put balances the
dev_hold done when the driver called __netif_rx_schedule(). In the
latter case, net_rx_action's dev_put balances the dev_hold of the
backlog_dev done when netif_rx called __netif_rx_schedule().

I hope that makes some kind of sense. It took a while to figure out, but
I saved my notes. :)

Jason
