From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/9] Make dev_hard_start_xmit() work fundamentall on lists
Date: Mon, 01 Sep 2014 15:24:30 -0700 (PDT)
Message-ID: <20140901.152430.1711925724234542172.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031AbaIAWYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 18:24:33 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id E6A9E58FC92
	for <netdev@vger.kernel.org>; Mon,  1 Sep 2014 15:24:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


After this patch set, dev_hard_start_xmit() will work fundemantally
on any and all SKB lists.

This opens the path for a clean implementation of pulling multiple
packets out during qdisc_restart(), and then passing that blob
in one shot to dev_hard_start_xmit().

There were two main architectural blockers to this:

1) The GSO handling, we kept the original GSO head SKB around
   simply because dev_hard_start_xmit() had no way to communicate
   to the caller how far into the segmented list it was able to
   go.  Now it can, so the head GSO can be liberated immediately.

   All of the special GSO head SKB destructor et al. handling goes
   away too.

2) Validate of VLAN, CSUM, and segmentation characteristics was being
   performed inside of dev_hard_start_xmit().  If want to truly batch,
   we have to let the higher levels to this.  In particular, this is
   now dequeue_skb()'s job.

And with those two issues out of the way, it should now be trivial to
build experiments on top of this patch set, all of the framework
should be there now.  You could do something as simple as:

	skb = q->dequeue(q);
	if (skb)
		skb = validate_xmit_skb(skb, qdisc_dev(q));
	if (skb) {
		struct sk_buff *new, *head = skb;
		int limit = 5;

		do {
			new = q->dequeue(q);
			if (new)
				new = validate_xmit_skb(new, qdisc_dev(q));
			if (new) {
				skb->next = new;
				skb = new;
			}
		} while (new && --limit);
		skb = head;
	}

inside of the else branch of dequeue_skb().

Signed-off-by: David S. Miller <davem@davemloft.net>
