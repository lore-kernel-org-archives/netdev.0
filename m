From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/13]: netdev: Allocate multiple queues for TX.
Date: Tue, 15 Jul 2008 02:45:19 -0700 (PDT)
Message-ID: <20080715.024519.95002238.davem@davemloft.net>
References: <20080710.035610.167480342.davem@davemloft.net>
	<4877CE6B.2050805@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58627
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752531AbYGOJpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 05:45:19 -0400
In-Reply-To: <4877CE6B.2050805@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 11 Jul 2008 23:19:39 +0200

> On i386 for example, sizeof(struct netdev_queue) = 0x2c
> 
> Shouldnt we make sure each queue sits on its own cache line on CONFIG_SMP ?

Yes.

> Also, dev->_tx and dev->num_tx_queues might share a cache line with
> dev->rx_queue, was it intended ?

Nope.

I've added the ____cacheline_aligned_in_smp annotations to my
tree, thanks!

@@ -463,7 +463,7 @@ struct netdev_queue {
 	struct Qdisc		*qdisc_sleeping;
 	struct list_head	qdisc_list;
 	struct netdev_queue	*next_sched;
-};
+} ____cacheline_aligned_in_smp;
 ...
@@ -641,7 +641,9 @@ struct net_device
 	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
 
 	struct netdev_queue	rx_queue;
-	struct netdev_queue	tx_queue ____cacheline_aligned_in_smp;
+
+	struct netdev_queue	*_tx ____cacheline_aligned_in_smp;
+	unsigned int		num_tx_queues;
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
 ...
