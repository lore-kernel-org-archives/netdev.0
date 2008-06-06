From: Patrick McManus <mcmanus@ducksong.com>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
	v2.6.26-rc3+
Date: Fri, 06 Jun 2008 16:08:57 -0400
Message-ID: <1212782937.23706.46.camel@tng>
References: <20080603.150344.145518113.davem@davemloft.net>
	 <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi>
	 <20080605142244.GA19216@elte.hu>
	 <Pine.LNX.4.64.0806052059380.31672@wrl-59.cs.helsinki.fi>
	 <Pine.LNX.4.64.0806052355420.2522@wrl-59.cs.helsinki.fi>
	 <1212708571.19522.10.camel@tng>
	 <Pine.LNX.4.64.0806061248410.16829@wrl-59.cs.helsinki.fi>
	 <1212772293.23706.22.camel@tng> <20080606173339.GA30894@elte.hu>
	 <Pine.LNX.4.64.0806062037240.9424@wrl-59.cs.helsinki.fi>
	 <20080606183926.GB12651@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>, peterz@infradead.org,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>, johnpol@2ka.mipt.ru
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from linode.ducksong.com ([64.22.125.164]:33177 "EHLO
	linode.ducksong.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756096AbYFFUIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 16:08:49 -0400
In-Reply-To: <20080606183926.GB12651@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is all a bit confusing, but here are the conclusions I have drawn.

There definitely is a problem with the locking of the DA commit
ec3c0982a2dd1e671bad8e9d26c28dcba0039d87 . That code was part of 26-rc1
but it never appeared in 25. It exists in pretty much the same form in
rc5 (there was 1 patch to it over that time to fix a different problem).

We're certain this code has a problem with the accept queue both because
of code inspection and the fact that Ingo can back it out (as the
significant part of the 3-patch revert) and the problem goes away in his
testing.

I have run tests that can reproduce the hung socket with distcc over
localhost using 26-rc5. I can also apparently cure it using the locking
fix patch Ilpo sent (c9454f0..d21d2b9) on top of that. (My test of rc5
+lockpatch is at 4.5+ hrs and counting without failures, it fails 6
times an hour with vanilla rc5)

Based on all of that, the right thing to do seems to be to apply the
lockpatch (c9454f0..d21d2b9) to Linus's tree and not revert anything -
just fix the code and I'll send Ilpo and Ingo cookies at Christmas time
for being  great guys. Alternatively, Ingo could run the distcc servers
and clients on -tip with the lockpatch (nothing reverted) for more
testing.

The only lingering problem is Ingo's report yesterday
http://marc.info/?l=linux-netdev&m=121267587715976&w=2
of a distcc hang. In this one it was not over localhost and the distcc
server had the ec3c DA changes totally reverted. (The server is really
the only stack that matters in this case - the client is not impacted by
the DA changes). This has to be a different issue, because the ec3c code
we're talking about here wasn't on the server at all. As Ilpo mentions,
Hakon is beleived to have a different problem and maybe you've tripped
over that too?

If we're sure of that conclusion we should just take Ilpo's DA patch as
that will narrow the field for finding Hakon's issue. Its just with all
of these data points I'm not sure if I'm reaching the right conclusion.




