From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH v2] tcp: fix MSG_PEEK race check
Date: Tue, 19 May 2009 07:33:02 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0905190654400.4379@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0905110926520.10047@wrl-59.cs.helsinki.fi>
 <20090517.154137.104422195.davem@davemloft.net>
 <Pine.LNX.4.64.0905180958150.3381@wrl-59.cs.helsinki.fi>
 <20090518.150433.92463181.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1026193699-1242707582=:4379"
Cc: elendil@planet.nl, matthias.andree@gmx.de,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51812 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbZESEdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 00:33:04 -0400
In-Reply-To: <20090518.150433.92463181.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1026193699-1242707582=:4379
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 18 May 2009, David Miller wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 18 May 2009 10:24:23 +0300 (EEST)
> 
> > Sorry, I'm not sure you thought this fully through here. What my patch 
> > with urg_hole does is that it keeps peek_seq non-advancing using the 
> > offsets. Now without the urg offsetting, the peek_seq side of the race 
> > check advances, which means that we didn't catch the race when it happened 
> > for real as copied_seq advanced too?!?
> 
> I see now what the situation is, thanks for explaining.
> 
> You're account for the "*seq" advance for URG that happens in
> tcp_recvmsg() rather than the one that happens in tcp_check_urg().

Right.

[I've moved the next fragment here from below...]

> When the MSG_PEEK test existing in the !copied if() branch of
> tcp_recvmsg(), so many of these code paths we are dealing with in this
> fix could simply not be reached when MSG_PEEK.  That ++*seq could
> never happen, because if "copied" was non-zero and MSG_PEEK was true
> we would leave the loop and return from tcp_recvmsg() immediately.
>
> Now, we have to accomodate those adjustments.

...I thought I wrote something along those lines in the log message 
(though I failed to make it so dead obvious as you do it here :-)).
 
> > From another perspective when the race didn't happen but potential for it 
> > existed, the current check should catch that since peek_seq advanced and 
> > copied_seq stayed where it was. But that certainly doesn't match to your 
> > description above.
> 
> Right.

[...more moving of fragments here...]

> Since I now understand your urg_hole code I'm going to apply your v2
> patch which takes care of the URG stuff.

I wonder if you realized, that after my change the check _no longer_ 
catches this case where the potential exists but race didn't happen for 
real? (bleh, I realized while writing the previous mail that this might be 
misinterpreted but I was lazy enough to not fix that :-()

If we want to "forbid" urgs during msg_peek (ie., unconditionally warn), 
we could just change the check to do || urg_hole and that would catch both 
cases, or even better, just clone it into if (MSG_PEEK) under urg hole 
branch. The latter would even allow us to distinguish between the cases => 
more intelligent message can then be given in the urg case but that of 
course needs first the decision that it's something we must check for
at all.

> > I wonder why all this fuzz about this particular race as we will do our 
> > best anyway to skip the hole on MSG_PEEK side (if I read the code right)? 
> > Either we never see the hole in MSG_PEEK side, or we're happily past it 
> > already, does it make any difference anymore in the latter case? <insert 
> > some "not that I fully understand all of that multipage function" 
> > disclaimer here though, I may think too simple scenarios here>. Not that 
> > I'm too interested in "improving" urg or so anywa, I'm just curious... :-)
> 
> A long long time ago we had an assertion here checking whether
> ->copied_seq moved without our knowledge.  Alexey and I found this
> could trigger and investigation of that is what helped us
> find the tcp_check_urg()+MSG_PEEK case.  That's when we added this
> test and log message.

Sure, the copied_seq is moving, but what I'm after is that does it really 
make any difference from tcp_recvmsg point of view? It certainly triggers 
the message but that won't work as a proof of the evilness for me.

...The above paragraph is assuming recvmsg is able to deal with that and 
doesn't choke because of the changing copied_seq. I'd have to audit it 
once again to verify that it's really ok but I don't see any particular 
reason why it couldn't be possible to make recvmsg to not care on the 
tcp_check_urg side copied_seq changes but I'd like to hear a clear 
confirmation on that from you too.

> I also buy the argument that perhaps we should get rid of the log message, 

I'm not against the log message here. It's still useful for detecting real 
userspace races but the urg vs. MSG_PEEK case is what I'm not so sure is 
as evil in itself as claimed. I'm not sure if you meant the latter?

> but look at how it helped us find this kernel regression :-)

Heh, the regression was quite devastating yeah... ...limited to that check
itself :-). However, I had to audit rest of the loop too to check for 
other similar problems, so it certainly had more potential that just 
spurious printout (luckily I didn't find any other problem like this). 

-- 
 i.
---696208474-1026193699-1242707582=:4379--
