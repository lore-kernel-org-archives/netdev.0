From: David Miller <davem@davemloft.net>
Subject: netlink recvmsg() and MSG_TRUNC
Date: Tue, 06 Mar 2007 15:19:53 -0800 (PST)
Message-ID: <20070306.151953.112290310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38411
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030688AbXCFXTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 18:19:55 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 31918AE41E1
	for <netdev@vger.kernel.org>; Tue,  6 Mar 2007 15:19:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


So if you don't give a large enough buffer to
recvmsg() for the netlink response a few things
happen:

1) MSG_TRUNC is set
2) The length returned and the amount of data copied is the
   size given in the recvmsg() call
3) If enough other packets remain in the receive buffer,
   nlk->cb is left at non-NULL for a partial dump.  This
   means that you can't just immediately resubmit the
   original request else you'll get NLMSG_ERROR with error
   set to -EBUSY.  This is what netlink_dump_start() does
   when it sees nlk->cb non-NULL.

Now, the user is basically stuck and there is no real
way to recover from this besides doing something like
openning up a new netlink socket and then doing the recvmsg()
with a larger buffer, wash rinse repeat.

I looked at how some of our standard userspace code handles
this and it's not pretty:

1) iproute2 basically just uses a 16K buffer, signals an error
   when it sees MSG_TRUNC, and that's it, whoopee

2) Thomas's libnl believes that recvmsg() will return the
   true length necessary to receive the whole message, he
   signals on this to double the buffer size and try the
   recvmsg() again.  As mentioned recvmsg() never returns
   a length larger than the given buffer size, so this code
   never triggers, and if it did it would lose entries because
   netlink_recvmsg() drops the SKB even when it signals
   MSG_TRUNC.

The behavior of dropping the SKB matches what UDP does in
the case of MSG_TRUNC.

I guess one thing the user could do when it sees MSG_TRUNC
is keep calling recvmsg() until the receive queue is emptied
of packets, in order to get that pesky nlk->cb cleared to
NULL, then resubmit.

But that's rediculous and complicated.

Any ideas?
