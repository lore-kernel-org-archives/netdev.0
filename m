From: Johannes Berg <johannes@sipsolutions.net>
Subject: creating netdev queues on the fly?
Date: Thu, 10 Nov 2011 14:58:21 +0100
Message-ID: <1320933501.3967.68.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:48134 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498Ab1KJN63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 08:58:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've been thinking about how we manage TX queues in wifi and right now
we just split things up by access category for QoS purposes.

However we have the issue that we might be pushing data to stations with
completely different speeds. Onn wired, where our outgoing speed is
essentially constant and some router/switch has to drop packets for the
slow link:

machine A === 1000mbps link ==== [switch] === 1000mbps === machine B
                                     |
                                     +--- 100mbps link --- machine C

But on wireless we really transmit to slow stations only with a slow
speed, so our outgoing speed differs. I think the scenario is quite
different, also because the speed can vary obviously.

So to get to my question: What if we could create netdev queues on the
fly?

The reason to do that is that we really don't want to reserve some 8000
queues just because somebody could possibly try to create 2000
connections (2007 is the theoretical max due to protocol restrictions)
to the AP interface. We also don't really want to create a netdev for
each peer (though you could implement it that way today).

I looked at this and it doesn't seem terrible. Creating & destroying the
queues might be tricky though. I think ndo_select_queue might return the
queue pointer instead of an index, and then that queue could be used.
The normal queues would still be in an array, with maybe a linked list
of extra queues that were dynamically created. Obviously the driver
would have to be able to manage that.

Ultimately, all the frames will of course end up on the same four
hardware queues again. But this would some better management, and piled
up traffic to one station that suddenly dies wouldn't impact performance
for all others as badly as it does today since we wouldn't let all those
frames pile up on the hardware queues, they'd only get there with some
mechanism that might take airtime into account.

I think this might also make implementing reservation (tspec) easier.
Not sure if anyone wants/needs that though.


Am I completely crazy?


johannes
