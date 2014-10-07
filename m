From: David Miller <davem@davemloft.net>
Subject: sunvnet and ->xmit_more
Date: Tue, 07 Oct 2014 15:18:49 -0400 (EDT)
Message-ID: <20141007.151849.84417269004453869.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.stevens@oracle.com, Raghuram.Kothakota@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932144AbaJGTSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 15:18:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David and others working on sunvnet, I just wanted to point out that
in the net-next tree there is a new facility that can improve
performance quite a bit in sunvnet.

Basically in the ->ndo_start_xmit() handler, if you see skb->xmit_more
set then the stack is telling you that it guarentees that another
packet will be given to you immediately when ->ndo_start_xmit()
returns.

This means that, unless you have filled up your TX queue, you can
defer the TX indication to the device.

For example, in the virtio_net driver the test is:

	if (__netif_subqueue_stopped(dev, qnum) || !skb->xmit_more)
		virtqueue_kick(sq->vq);

The pktgen module also has a new "burst" parameter you can use to test
out this facility directly, and the qdisc layer has heuristics for
dequeueing multiple packets at a time for normal traffic.

Just FYI...
