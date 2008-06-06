From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
 v2.6.26-rc3+
Date: Sat, 7 Jun 2008 00:12:55 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806062314420.9424@wrl-59.cs.helsinki.fi>
References: <20080603.150344.145518113.davem@davemloft.net>
 <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi>  <20080605142244.GA19216@elte.hu>
  <Pine.LNX.4.64.0806052059380.31672@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0806052355420.2522@wrl-59.cs.helsinki.fi>  <1212708571.19522.10.camel@tng>
  <Pine.LNX.4.64.0806061248410.16829@wrl-59.cs.helsinki.fi>
 <1212772293.23706.22.camel@tng> <20080606173339.GA30894@elte.hu>
 <Pine.LNX.4.64.0806062037240.9424@wrl-59.cs.helsinki.fi>  <20080606183926.GB12651@elte.hu>
 <1212782937.23706.46.camel@tng>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1018668328-1212784580=:9424"
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	peterz@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>, johnpol@2ka.mipt.ru
To: Patrick McManus <mcmanus@ducksong.com>,
	Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44359 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755666AbYFFVM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 17:12:57 -0400
In-Reply-To: <1212782937.23706.46.camel@tng>
Content-ID: <Pine.LNX.4.64.0806070006270.9424@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1018668328-1212784580=:9424
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0806062336291.9424@wrl-59.cs.helsinki.fi>

...added Arjan.

On Fri, 6 Jun 2008, Patrick McManus wrote:

> This is all a bit confusing, but here are the conclusions I have drawn.

Your observations here match what I've understood :-).

> There definitely is a problem with the locking of the DA commit
> ec3c0982a2dd1e671bad8e9d26c28dcba0039d87 . That code was part of 26-rc1
> but it never appeared in 25. It exists in pretty much the same form in
> rc5 (there was 1 patch to it over that time to fix a different problem).
>
> We're certain this code has a problem with the accept queue both because
> of code inspection and the fact that Ingo can back it out (as the
> significant part of the 3-patch revert) and the problem goes away in his
> testing.

Problems were at least these:
- Accept queue addition was racy and could leave dangling items
- Dangling items caused inconsistent sk_ack_backlog
- Checking for still in LISTEN state was racy, could be changed after
  the check was made (shouldn't happen with distcc though)

I didn't read ->sk_data_ready that carefully, it could have some 
additional problems that are not listed (but they all should be fixed
by the added locking anyway).

AFAICT, rest of that ec3c change is safe wrt. locking, just holding sk is 
enough for the rest and those bits mostly shouldn't anyway be executed 
with a distcc setup.

> I have run tests that can reproduce the hung socket with distcc over
> localhost using 26-rc5. I can also apparently cure it using the locking
> fix patch Ilpo sent (c9454f0..d21d2b9) on top of that. (My test of rc5
> +lockpatch is at 4.5+ hrs and counting without failures, it fails 6
> times an hour with vanilla rc5)
>
> Based on all of that, the right thing to do seems to be to apply the
> lockpatch (c9454f0..d21d2b9) to Linus's tree and not revert anything -
> just fix the code and I'll send Ilpo and Ingo cookies at Christmas time
> for being  great guys. Alternatively, Ingo could run the distcc servers
> and clients on -tip with the lockpatch (nothing reverted) for more
> testing.

Anyway, we still would have an option to revert both the DA change + the 
locking fix later if the problem is still clearly more likely than with 
stable-2.6.25.

> The only lingering problem is Ingo's report yesterday
> http://marc.info/?l=linux-netdev&m=121267587715976&w=2
> of a distcc hang. In this one it was not over localhost and the distcc
> server had the ec3c DA changes totally reverted. (The server is really
> the only stack that matters in this case - the client is not impacted by
> the DA changes).

It definately didn't fit to picture that well if we would be talking just 
a single bug here.

...I wish Ingo would have provided the receiver state already then. :-)

> This has to be a different issue, because the ec3c code
> we're talking about here wasn't on the server at all. As Ilpo mentions,
> Hakon is beleived to have a different problem and maybe you've tripped
> over that too?

...The Håkon's case is definately different thing, also the symptoms 
are quite different because there's no deadlock at all but the TCP flow 
eventually dies, I don't yet know with what timescale that dying happens.
Only common denominator actually was this receiver process missing, though 
it provably still was there.

Besides, I don't know how long Ingo waited in this case until concluding 
that the TCP was stuck again?

> If we're sure of that conclusion we should just take Ilpo's DA patch as
> that will narrow the field for finding Hakon's issue. Its just with all
> of these data points I'm not sure if I'm reaching the right conclusion.

Lets widen the scope to two to three bugs then, one down already...

In case you missed btw, also Arjan reported some problem quite early, but 
in his case claws mua+imap was the workload, so I doubt that DEFER_ACCEPT 
would be involved but who knows without strace, here:
  http://marc.info/?l=linux-kernel&m=121182171000434&w=2

Arjan, can you please check if your workload uses setsockopt 
TCP_DEFER_ACCEPT for the LISTENing socket? ...If not, then your case
is different from Ingo's.


-- 
 i.
---696208474-1018668328-1212784580=:9424--
