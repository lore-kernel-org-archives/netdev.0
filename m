From: Patrick McHardy <kaber@trash.net>
Subject: Re: poll problem with PF_PACKET when using PACKET_RX_RING
Date: Sun, 15 Oct 2006 16:00:43 +0200
Message-ID: <45323F0B.2010604@trash.net>
References: <20061014214328.25873.qmail@web50614.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:29684 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S964838AbWJOOAr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Oct 2006 10:00:47 -0400
To: Joan Raventos <jraventos@yahoo.com>
In-Reply-To: <20061014214328.25873.qmail@web50614.mail.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joan Raventos wrote:
> Hello,
> 
> In order to use PF_PACKET/SOCK_RAW with PACKET_RX_RING
> one would possibly do (as described in
> Documentation/networking/packet_mmap.txt):
> 1. setup PF_PACKET socket via socket call.
> 2. use setsockopt to change the PF_PACKET socket into
> PACKET_RX_RING mode and alloc the ring.
> 3. mmap the ring.
> 4. use poll with the socket descriptor and then
> directly access the pkts from the mmaped ring.
> 
> However I've observed that if the socket is opened on
> a link with substantial traffic, chances are that some
> pkts might hit the socket between (1) and (2). At that
> point those pkts will make the socket descriptor be
> active (packet_poll is built as an OR from
> datagram_poll -essentially whether sk_receive_queue is
> empty- and the ring status). However after (2) pkts
> are no longer processed by packet_rcv but via
> tpacket_rcv, and thus no longer queued in the
> sk_receive_queue but into the ring. Moreover since the
> user-space app is likely to access them directly (4),
> no one is going to empty the socket queue and the
> descriptor will remain always active, converting the
> poll loop into a busy wait (100% cpu occupied by the
> user-space process, etc.).
> 
> Is this a bug in PF_PACKET? Should the socket queue be
> emptied by packet_set_ring (called via setsockopt when
> PACKET_RX_RING is used) so the above cannot happen?
> Should the user-space app drain the socket queue with
> recvfrom prior to (4) -quite unlikely in practice-?


I guess the best way is not to bind the socket before having
completed setup. We could still flush the queue to make life
easier for userspace, not sure about that ..

