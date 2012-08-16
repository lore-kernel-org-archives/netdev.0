From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v1.0] af_packet: don't emit packet on orig fanout
 group
Date: Thu, 16 Aug 2012 14:52:00 -0700 (PDT)
Message-ID: <20120816.145200.694410419765575459.davem@davemloft.net>
References: <1344262918.8024.41.camel@tiger.regit.org>
	<1345131890-15991-1-git-send-email-eric@regit.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric@regit.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755550Ab2HPVwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 17:52:01 -0400
In-Reply-To: <1345131890-15991-1-git-send-email-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Leblond <eric@regit.org>
Date: Thu, 16 Aug 2012 17:44:50 +0200

> If a packet is emitted on one socket in one group of fanout sockets,
> it is transmitted again. It is thus read again on one of the sockets
> of the fanout group. This result in a loop for software which
> generate packets when receiving one.
> This retransmission is not the intended behavior: a fanout group
> must behave like a single socket. The packet should not be
> transmitted on a socket if it originates from a socket belonging
> to the same fanout group.
> 
> This patch fixes the issue by changing the transmission check to
> take fanout group info account.

This looks mostly fine, thanks for fixing this.

I wonder if it wouldn't be better to simply have a callback?  That
would eliminate all of the ifdefs:

	if (ptype->id_match) {
		if (ptype->id_match(ptype, skb->sk))
			return true;
	} else if (ptype->af_packet_priv == skb->sk)
		return true;

It's a shame that we have a user of af_packet_priv outside of
AF_PACKET, in TIPC.  If we could get rid of that we could simplify
things even futher.
