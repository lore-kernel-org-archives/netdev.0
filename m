From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bonding inactive slaves vs rx_dropped
Date: Thu, 14 Feb 2013 13:51:01 -0800
Message-ID: <4606.1360878661@death.nxdomain>
References: <20130214.160657.1394358701071068786.davem@davemloft.net>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:47674 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934909Ab3BNVvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 16:51:23 -0500
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 14 Feb 2013 14:51:22 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 3EC463E4003E
	for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 14:51:08 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1ELpESU183368
	for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 14:51:15 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1ELpAqG009118
	for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 14:51:12 -0700
In-reply-to: <20130214.160657.1394358701071068786.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

>People are starting to notice that rx_dropped now increments on every
>packet received on an bond's inactive slave.
>
>I'm actually fine with rx_dropped incrementing in this situation.
>
>The problem I want to address is that rx_dropped is encompassing
>several unrelated situations and thus has become less useful for
>diagnosis.
>
>I think we should add some new RX stats such that we can get at
>least a small amount of granularity for rx_dropped.
>
>This way team, bond, etc. can increment a new netdev_stats->rx_foo in
>this situation, and then someone doing diagnosis can see that
>rx_dropped and rx_foo are incrementing at similar rates.

	This drop isn't really happening in bonding, though.  From
looking at the code, it comes about because, for the inactive slave, the
rx_handler call returns EXACT, and there aren't any exact match ptype
bindings, so __netif_receive_skb throws it away.  This isn't always the
case; sometimes there is an exact match, for things like iSCSI or FCoE
that are really determined to get the packet.

	On a non-bonded interface, the same drop path (except for the
rx_handler) is taken for incoming packets for an unsupported protocol.

	We could probably add an, oh, rx_dropped_inactive, or some
variation on that theme, that is incremented at the end of
__netif_receive_skb if deliver_exact is set, e.g., something like:

diff --git a/net/core/dev.c b/net/core/dev.c
index a87bc74..4cd7c1f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3559,6 +3559,8 @@ ncls:
 	} else {
 drop:
 		atomic_long_inc(&skb->dev->rx_dropped);
+		if (deliver_exact)
+			atomic_long_inc(&skb->dev->rx_dropped_inactive);
 		kfree_skb(skb);
 		/* Jamal, now you will not able to escape explaining
 		 * me how you were going to use this. :-)

	I think this would only hit frames that have been soft-rejected
(rx_handler says EXACT) by bonding or team, but were not subsequently
delivered to an exact match listener.

	There's the separate questions of whether there should be more
counters (e.g., drops in dev_skb_forward or enqueue_to_backlog), and how
to deliver the counter(s) to user space.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
