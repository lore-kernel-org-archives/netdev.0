From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Wed, 18 Nov 2015 22:04:20 +0900
Message-ID: <CAKD1Yr1URnEWDpF9JUo_K3w+31YjfrO6tzL6QBcrKmSYu1_fhA@mail.gmail.com>
References: <1447811024-8553-1-git-send-email-lorenzo@google.com>
 <20151117192738.365145d7@samsung9> <1447819493.22599.137.camel@edumazet-glaptop2.roam.corp.google.com>
 <1447841988.834928.443071345.1AAFF2A9@webmail.messagingengine.com>
 <CAKD1Yr0Gpr6Ex2i1TXEWyETn48P4g5vBvFZ9=_g+Lz_7-PqBDQ@mail.gmail.com> <1447845552.846962.443112033.03C5152B@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:35460 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754954AbbKRNEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 08:04:41 -0500
Received: by ykba77 with SMTP id a77so61180977ykb.2
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 05:04:40 -0800 (PST)
In-Reply-To: <1447845552.846962.443112033.03C5152B@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 18, 2015 at 8:19 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> I was wondering why you didn't use tcp_close function, because still we
> could have the address and we would like to do a proper shutdown of the
> connection. While this patchset wants to tear down sockets for addresses
> no longer alive, it still can be used with full sockets.

>From the perspective of the TCP state machine, there's not much
difference. In most TCP states, tcp_close takes the socket straight to
TCP_CLOSE (not into TCP_TIME_WAIT).

There is a difference in that tcp_close() sends a RST by calling
tcp_send_active_reset. We could make tcp_diag_destroy do that too. Not
sure it's worth it because in most of the the cases where you'd want
to use SOCK_DESTROY (e.g., you've lost a network connection, a VPN
connected, etc.), tcp_send_active_reset is either not going to send a
RST at all or it's going send on the wrong network. Even if we're
still connected to the same network (e.g., in the case where you're
running "ss --kill" to close a socket instead of the bad old days
where you had to load your process in gdb and call close() from there
:-)), not sending a RST is not the end of the world, because as soon
as the peer sends us a packet we'll send a RST anyway.

In any case calling tcp_close itself won't work - that's intended for
userspace closes. It calls sock_orphan, which nulls out the
backpointer to the userspace socket structure, and assumes that there
are no userspace references to the protocol socket. If we make
SOCK_DESTROY call tcp_close without releasing the userspace
components, things blow up as soon as the app calls close().
