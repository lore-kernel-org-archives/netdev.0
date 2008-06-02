From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Mon, 2 Jun 2008 11:23:53 +0200
Message-ID: <20080602092353.GB22060@elte.hu>
References: <20080529112257.GA18130@elte.hu> <20080530181839.GA31915@elte.hu> <20080531060947.GA26441@elte.hu> <Pine.LNX.4.64.0805311431100.2329@wrl-59.cs.helsinki.fi> <Pine.LNX.4.64.0805311505410.2329@wrl-59.cs.helsinki.fi> <20080531125428.GA22111@elte.hu> <Pine.LNX.4.64.0805311555570.2329@wrl-59.cs.helsinki.fi> <20080531163501.GB22607@elte.hu> <1212273974.28319.107.camel@tng> <48423C0A.1090104@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McManus <mcmanus@ducksong.com>,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:39609 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750735AbYFBJYZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2008 05:24:25 -0400
Content-Disposition: inline
In-Reply-To: <48423C0A.1090104@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Eric Dumazet <dada1@cosmosbay.com> wrote:

>>>  22003 write(3, "distccd[22003] (dcc_listen_by_ad"..., 62) = 62
>>>  22003 listen(4, 10)                     = 0
>>>  22003 setsockopt(4, SOL_TCP, TCP_DEFER_ACCEPT, [1], 4) = 0
>>>
>>> i'll queue up your reverts for testing in -tip.

I turned off localhost distcc two days ago and there has not been a 
single hung socket since then, so we now know it for sure that without 
localhost distcc connections, -tip's QA will not produce any hung 
sockets in about 1000 random-kernel-build+boot iterations.

i've added those reverts this morning and added back the localhost 
distcc rules - we'll see whether the hung sockets are back.

> I believe Ingo problems come on long lived sockets (were many bytes 
> were exchanged between the peers), so I dont think DEFER_ACCEPT is the 
> cullprit.
>
> I suggest to enable CONFIG_TIMER_STATS and to check timers, because 
> /proc/net/tcp can display apparently large timer values when the timer 
> is elapsed (jiffies > icsk->icsk_timeout) and 
> jiffies_to_clock_t(timer_expires - jiffies) is then overflowing doing 
> a multiply and a divide.

i'm wondering whether your suspicion on broken TCP timers is consistent 
with the symptoms i've seen: the hung sockets clearly produced periodic 
packet activity every 180 seconds, up to 8 hours, without ever changing 
their receive of send queue. So at least a part of the TCP timer 
mechanism for that specific stuck socket was working fine.

is there no sysctl or other debug mechanism to somehow get its full TCP 
state and the reasons for why it is stuck? I'm wondering how you debug 
broken TCP state machines without enabling testers to be able to dump 
all state and passing it to developers.

I have a clearly reproducable testcase and i'd like to help out, but the 
whole effort is stalled on 'not enough information' it appears. Doing 
random reverts might help in truly helpless situations where a bug has 
no debuggable state - but this situation seems really routine to me: 
it's very difficult to trigger the bug but once it triggers the bug 
scenario is stable and analyzable. I'd be glad to test any 
instrumentation patch that makes similar scenarios more analyzable.

	Ingo
