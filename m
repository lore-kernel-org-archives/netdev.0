From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netlink: add NETLINK_NO_ENOBUFS socket flag
Date: Mon, 23 Mar 2009 12:58:41 +0100
Message-ID: <49C77971.8080302@trash.net>
References: <20090323093353.14253.76823.stgit@Decadence>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36871 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936AbZCWL6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 07:58:48 -0400
In-Reply-To: <20090323093353.14253.76823.stgit@Decadence>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso wrote:
> This patch adds the NETLINK_NO_ENOBUFS socket flag. This flag can
> be used by unicast and broadcast listeners to avoid receiving
> ENOBUFS errors.
> 
> Generally speaking, ENOBUFS errors are useful to notify two things
> to the listener:
> 
> a) You may increase the receiver buffer size via setsockopt().
> b) You have lost messages, you may be out of sync.
> 
> In some cases, ignoring ENOBUFS errors can be useful. For example:
> 
> a) nfnetlink_queue: this subsystem does not have any sort of resync
> method and you can decide to ignore ENOBUFS once you have set a
> given buffer size.
> 
> b) ctnetlink: you can use this together with the socket flag
> NETLINK_BROADCAST_SEND_ERROR to stop getting ENOBUFS errors as
> you do not need to resync (packets whose event are not delivered
> are drop to provide reliable logging and state-synchronization).
> 
> Moreover, the use of NETLINK_NO_ENOBUFS also reduces a "go up, go down"
> effect in terms of performance which is due to the netlink congestion
> control when the listener cannot back off. The effect is the following:
> 
> 1) throughput rate goes up and netlink messages are inserted in the
> receiver buffer.
> 2) Then, netlink buffer fills and overruns (set on nlk->state bit 0).
> 3) While the listener empties the receiver buffer, netlink keeps
> dropping messages. Thus, throughput goes dramatically down.
> 4) Then, once the listener has emptied the buffer (nlk->state
> bit 0 is set off), goto step 1.

I agree that not having netlink drop new messages after congestion
might be useful. Two suggestions though:

- NETLINK_NO_CONGESTION_CONTROL seems a bit more descriptive than
   "NO_ENOBUFS"

- The ENOBUFS error itself is actually not the problem, but the
   congestion handling. It still makes sense to notify userspace
   of congestion. I'd suggest to deliver the error, but avoid setting
   the congestion bit.

