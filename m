From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH][RFC]: ingress socket filter by mark
Date: Sun, 18 Oct 2009 16:09:48 -0700
Message-ID: <55a4f86e0910181609o6b21d667g8e65638667a1d687@mail.gmail.com>
References: <1255869758.4815.40.camel@dogo.mojatatu.com>
	 <4ADB5043.7070707@gmail.com>
	 <1255897680.4815.63.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Atis Elsts <atis@mikrotik.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:57251 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755466AbZJRXJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 19:09:44 -0400
Received: by fxm18 with SMTP id 18so4416407fxm.37
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2009 16:09:48 -0700 (PDT)
In-Reply-To: <1255897680.4815.63.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I haven't looked at the patches, but I do not believe requiring
marking to be symmetric to be a good idea.

Example:
- a relatively complex router/load balancer setup
- normal (no mark) packets get routed/load balanced to destinations
which are healthy
- a separate job which health checks the destinations (and updates the
no mark routing table on destination health state transitions) - it
uses socket marking to select a separate routing table which throws
all load at a specific destination host.

ie. the socket marking is used to explicitly direct load at a specific
destination host.
Obviously only the transmit path is affected.  There is no marking
happening on the receive path.

Another example would be tunneling. I'd envision something like:
ip tunnel add vtun0 mode gre remote ... local ... tos inherit ttl 64 mark 0x1234

ip rule add fwmark 0x1234 lookup 250
ip route add 192.168.1.0/24 dev eth0 table 250
ip route add default via 192.168.1.1 dev eth0 table 250
ip route add default dev vtun0 table main

(obviously this is just an example and not fully fleshed out,
furthermore ip tunnel doesn't currently support mark, nor do the
tunnel modules themselves)

If you do want to allow explicit incoming mark filtering use another
socket option (SO_MARK_RCV) and a different/new socket field.

>> I vote for extending BPF, and not adding the price of a compare
>> for each packet. Only users wanting mark filtering should pay the price.

I agree that being able to filter on mark in bpf makes a lot of sense.
I wonder if we're not hitting the filters potentially before the mark
is set though (on receive at least)...
I'm nowhere near sure but I think packets get diverted/cloned to
tcpdump before they hit the ip stack (and thus potentially get marked
by ip(6)table mangle rules)
