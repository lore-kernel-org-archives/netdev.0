From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Wed, 18 Nov 2015 14:31:55 +0100
Message-ID: <1447853515.875338.443199993.7D592088@webmail.messagingengine.com>
References: <1447811024-8553-1-git-send-email-lorenzo@google.com>
 <20151117192738.365145d7@samsung9>
 <1447819493.22599.137.camel@edumazet-glaptop2.roam.corp.google.com>
 <1447841988.834928.443071345.1AAFF2A9@webmail.messagingengine.com>
 <CAKD1Yr0Gpr6Ex2i1TXEWyETn48P4g5vBvFZ9=_g+Lz_7-PqBDQ@mail.gmail.com>
 <1447845552.846962.443112033.03C5152B@webmail.messagingengine.com>
 <CAKD1Yr1URnEWDpF9JUo_K3w+31YjfrO6tzL6QBcrKmSYu1_fhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Erik Kline <ek@google.com>,
	=?UTF-8?Q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:51802 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755898AbbKRNb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 08:31:56 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 1853920B2E
	for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 08:31:56 -0500 (EST)
In-Reply-To: <CAKD1Yr1URnEWDpF9JUo_K3w+31YjfrO6tzL6QBcrKmSYu1_fhA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, Nov 18, 2015, at 14:04, Lorenzo Colitti wrote:
> On Wed, Nov 18, 2015 at 8:19 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > I was wondering why you didn't use tcp_close function, because still we
> > could have the address and we would like to do a proper shutdown of the
> > connection. While this patchset wants to tear down sockets for addresses
> > no longer alive, it still can be used with full sockets.
> 
> From the perspective of the TCP state machine, there's not much
> difference. In most TCP states, tcp_close takes the socket straight to
> TCP_CLOSE (not into TCP_TIME_WAIT).

Active close will end up in time wait in the end anyway (with some
exceptions).

> There is a difference in that tcp_close() sends a RST by calling
> tcp_send_active_reset. We could make tcp_diag_destroy do that too. Not
> sure it's worth it because in most of the the cases where you'd want
> to use SOCK_DESTROY (e.g., you've lost a network connection, a VPN
> connected, etc.), tcp_send_active_reset is either not going to send a
> RST at all or it's going send on the wrong network. Even if we're
> still connected to the same network (e.g., in the case where you're
> running "ss --kill" to close a socket instead of the bad old days
> where you had to load your process in gdb and call close() from there
> :-)), not sending a RST is not the end of the world, because as soon
> as the peer sends us a packet we'll send a RST anyway.

Ack. I don't think it makes sense to provide a FIN/RST less way of
closing a socket, just invoke a shutdown() from an interface might be
okayish IMHO.

> In any case calling tcp_close itself won't work - that's intended for
> userspace closes. It calls sock_orphan, which nulls out the
> backpointer to the userspace socket structure, and assumes that there
> are no userspace references to the protocol socket. If we make
> SOCK_DESTROY call tcp_close without releasing the userspace
> components, things blow up as soon as the app calls close().

I was not saying using tcp_close literally, sorry for not making that
clear, but just model the state transitions after tcp_close. At least it
seems like a normal close to me.

Thanks,
Hannes
