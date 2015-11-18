From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Tue, 17 Nov 2015 19:57:00 -0800
Message-ID: <CAHo-OoyuH=XFFNs+J_s0ws_RsAXkzF5AuafFPaevg8UV35iT+w@mail.gmail.com>
References: <1447811024-8553-1-git-send-email-lorenzo@google.com>
	<20151117192738.365145d7@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lorenzo Colitti <lorenzo@google.com>,
	Linux NetDev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, ek@google.com,
	dtor@google.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:35514 "EHLO
	mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753560AbbKRD5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 22:57:02 -0500
Received: by lfdo63 with SMTP id o63so18389764lfd.2
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 19:57:00 -0800 (PST)
In-Reply-To: <20151117192738.365145d7@samsung9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't know what the right fix is...

However, speaking as an end user with laptops on wifi and/or home
gateways on dialup connections where the IP address occasionally (or
constantly) changes, I find it very frustrating that by default as IP
addresses get removed from interfaces all the related state (whether
conntrack or open connections) doesn't get cleaned up.

[side note: I realize there is tooling to do this manually from
userspace for conntrack and that there are even some gateways that
correctly make use of it.]

Sure this might not be desirable on servers (where configuration is
usually static and complex) but on most end user devices (CPE, cell
phone, laptop) - that are prone to roaming in todays world - this (or
something like this) would be super useful.

I would almost argue it should be the default (or controlled by
sysctl) - hung connections are super frustrating, and they often
prevent normal retry logic (ie. establishing a new connection) from
functioning correctly, because the kernel is just waiting for some
enormous tcp (retransmit) timeouts that only make sense if we still
own the IP, and userspace thinks everything is still ok...  If we
don't even own the IP any more often retransmits just get blackholed
so you don't even get notifications from the network of packet
delivery problems.

Something like this either needs to be implemented in kernel, or APIs
need to be provided so that network manager (or your favourite
userspace network management utility) can act on behalf of the user to
clean stuff up.

In general I'm not in favour of embedding logic like this in the
kernel since you usually get more configurability if you leave it in
userspace.

Sure you can hack something together via firewall hacks and routing
hacks or injecting tcp resets via raw sockets, but that requires a lot
of work, and still doesn't cover everything (firewall and routing
hacks won't fix idle sockets, in particular those waiting for a
message from the other side of the connection, ie. push notifications
for a cell phone).

- Maciej
