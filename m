From: David Miller <davem@davemloft.net>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Fri, 02 Dec 2011 16:30:24 -0500 (EST)
Message-ID: <20111202.163024.1294014889349291295.davem@davemloft.net>
References: <1322857369.2762.63.camel@edumazet-laptop>
	<20111202.152426.447759025066188323.davem@davemloft.net>
	<1322858756.2762.68.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: subramanian.vijay@gmail.com, therbert@google.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49138 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755102Ab1LBVab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 16:30:31 -0500
In-Reply-To: <1322858756.2762.68.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 02 Dec 2011 21:45:56 +0100

> Retransmits could transmits 3 bytes already ACKed, is it a big deal ?

Unfortunately this kind of adjustment doesn't work.

When we trim the head in response to ACK'd data, the stack assumes that
the first byte sitting at the front of the retransmit queue is ->snd_una.

So if you just back align the pull, and don't make amends for the setting
of ->snd_una, we'll retransmit the wrong bytes.  The send queue will be
out of sync with the sequence number state of the socket.

This has implications for SACK tagging state bit in the transmit queue
as well.

In fact, this is a real dangerous road to go down, I think :-)
