From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/14]: Make packet scheduler multiqueue aware.
Date: Mon, 14 Jul 2008 15:59:08 -0700 (PDT)
Message-ID: <20080714.155908.174564017.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49255
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758242AbYGNW7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 18:59:08 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id C3531C8C187
	for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 15:59:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ok, here are the fruits of my weekend in a nutshell, it's
pushed into the net-tx-2.6 tree:

1) Every configuration operation previded by qdiscs and
   classifiers is split into two or three operations:

   Either:

		->validate_foo()
		->commit_foo()
		->cancel_foo()

   Or just:

		->validate_foo()
		->commit_foo()

   The deciding factor is whether validate_foo() allocates
   some resources which need to be liberated if we decide to
   no perform the commit operation.

2) The generic top-level operation code allocates an array
   of info blobs that record the progress of things.

3) First, we iterate over all queues and validate the operation.

4) If all validations pass, we iterate and commit the operation.

5) Else, we iterate and cancel the operation if necessary.

As you can see, this required surgery to a lot of the
packet scheduler layer.  I'm sure I got something wrong,
but conceptually I think everything is sound.

At this point I've tested basic qdisc changes.  For example
on my workstation I'm using a PRIO with 3 bands pointing to
various SFQ and TBF qdiscs.

So I haven't given the filter/classifier stuff much of a good
testing yet.

My next plans are:

1) Integrate the feedback received over the weekend which I
   didn't have time to process yet.

2) Respin the tree against a fresh net-next-2.6

3) Implement "QUEUE_NUM" netlink attribute so that the user can
   request that packet scheduler operations apply to a specific
   queue only.

I think, frankly, this is ready to merge upstream even in it's current
state.  We'll have 3 months to test things more thoroughly and sort
out any thinkos I added to the code.
