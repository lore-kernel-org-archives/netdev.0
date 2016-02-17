From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH] Revert "net: sched: drop all special handling of
 tx_queue_len == 0"
Date: Wed, 17 Feb 2016 13:47:07 +0100
Message-ID: <20160217124707.GB19575@orbyte.nwl.cc>
References: <1455670592-5649-1-git-send-email-mathieu.desnoyers@efficios.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:45204 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934224AbcBQMxe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 07:53:34 -0500
Content-Disposition: inline
In-Reply-To: <1455670592-5649-1-git-send-email-mathieu.desnoyers@efficios.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Feb 16, 2016 at 07:56:23PM -0500, Mathieu Desnoyers wrote:
> This reverts commit 348e3435cbefa815bd56a5205c1412b5afe7b92e.
> It breaks HTB classful qdiscs on the loopback interface.
> 
> It has been broken since kernel v4.2. The offending commit has
> been identified by bissection of the issue with the following
> test-case. It appears that the loopback interface does indeed
> still have tx_queue_len == 0.
> 
> Reverting the commit on a v4.4.1 kernel fixes the issue.

Indeed, this is ugly. Affected are all drivers not calling ether_setup()
in their setup callback, and therefore not initializing tx_queue_len.

As the commit to be reverted shows, there is no common fallback value
for tx_queue_len - most qdisc implementations used 1, but HTB fell back
to 2 and PLUG to 100. But as the removed comment in sch_plug.c stated:

| /* We will set a default limit of 100 pkts (~150kB)
|  * in case tx_queue_len is not available. The
|  * default value is completely arbitrary.
|  */

It seems not to be overly important to fallback to the exact value each
qdisc had before. Therefore I guess the following change should
appropriately fix the issue at hand:

--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7440,8 +7440,10 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
        dev->priv_flags = IFF_XMIT_DST_RELEASE | IFF_XMIT_DST_RELEASE_PERM;
        setup(dev);
 
-       if (!dev->tx_queue_len)
+       if (!dev->tx_queue_len) {
                dev->priv_flags |= IFF_NO_QUEUE;
+               dev->tx_queue_len = 1;
+       }
 
        dev->num_tx_queues = txqs;
        dev->real_num_tx_queues = txqs;

Unless there is concern, I will formally submit this later.

Thanks, Phil
