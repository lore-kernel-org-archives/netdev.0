From: David Miller <davem@davemloft.net>
Subject: Re: SACK scoreboard
Date: Tue, 08 Jan 2008 14:44:56 -0800 (PST)
Message-ID: <20080108.144456.173014334.davem@davemloft.net>
References: <Pine.LNX.4.64.0712111547300.18529@kivilampi-30.cs.helsinki.fi>
	<20080107.233617.203640686.davem@davemloft.net>
	<4783AA29.3080406@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, lachlan.andrew@gmail.com,
	netdev@vger.kernel.org, quetchen@caltech.edu
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33564
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751867AbYAHWo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 17:44:58 -0500
In-Reply-To: <4783AA29.3080406@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Heffner <jheffner@psc.edu>
Date: Tue, 08 Jan 2008 11:51:53 -0500

> I haven't thought about this too hard, but can we approximate this by 
> moving scaked data into a sacked queue, then if something bad happens 
> merge this back into the retransmit queue?

That defeats the impetus for the change.

We want to free up the data, say, 2 packets at a time as
ACKs come in.  The key goal is smooth liberation of
retransmit queue packets over time.

The big problem is that recovery from even a single packet loss in a
window makes us run kfree_skb() for a all the packets in a full
window's worth of data when recovery completes.

If we just move such packets to a seperate list, we still have to
iterate over all of them when the cumulative ACK arrives.

This problem, that retransmit queue liberation is not smooth, is the
biggest flaw in how SACK is specified.  I mean, consider Ilpo's
mentioned case of 500,000 packet windows.  The issue cannot be
ignored.  SACK is clearly broken.

You speak of a path in Linux where we can reneg on SACKs, but I doubt
it really ever runs because of how aggressive the queue collapser is.
Alexey even has a comment there:

	 * This must not ever occur. */

To be honest this code sits here because it was written before the
queue collapser was coded up.

Really, find me a box where the LINUX_MIB_OFOPRUNED or
LINUX_MIB_RECVPRUNED counters are anything other than zero.

So this is a non-issue and I did consider it before proposing that we
redefine SACK.
