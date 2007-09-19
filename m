From: David Miller <davem@davemloft.net>
Subject: new NAPI quota synchronization issue
Date: Wed, 19 Sep 2007 09:58:25 -0700 (PDT)
Message-ID: <20070919.095825.39465358.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35840
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755618AbXISQ6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 12:58:41 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ok, as has been hinted at with some postings from Krishna and others,
we still have some mutual exclusion issues in the new NAPI code.

In short, the napi->quota updates happen outside of the sections where
the code stream "owns" the napi_struct instance, so it can be modified
in parallel on multiple cpus, the n->quota can go negative, and the
quota bug checks trigger.

It just seems that gradually I'm reverting every single cleanup done
by Stephen in his original patch, first the list handling and now the
quota bits too :-)

Probably a good way to deal with this is to simply make the quota
handling stateless.

The only reason we handle partial quota usage is to handle the
global netdev_budget.  But we can simply "round up" and let
netdev_budget get oversubscribed by one napi->quota's worth
if necessary.

At that point, n->quota only holds two states when used, full
and empty.  And at that point there is no reason to maintain
it's value at all.  Only the weight is necessary.

I'll try to post a patch which implements this later today.
