From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: fix MSG_PEEK race check
Date: Mon, 18 May 2009 15:04:33 -0700 (PDT)
Message-ID: <20090518.150433.92463181.davem@davemloft.net>
References: <Pine.LNX.4.64.0905110926520.10047@wrl-59.cs.helsinki.fi>
	<20090517.154137.104422195.davem@davemloft.net>
	<Pine.LNX.4.64.0905180958150.3381@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: elendil@planet.nl, matthias.andree@gmx.de, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46804
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752393AbZERWEg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2009 18:04:36 -0400
In-Reply-To: <Pine.LNX.4.64.0905180958150.3381@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 18 May 2009 10:24:23 +0300 (EEST)

> Sorry, I'm not sure you thought this fully through here. What my patc=
h=20
> with urg_hole does is that it keeps peek_seq non-advancing using the=20
> offsets. Now without the urg offsetting, the peek_seq side of the rac=
e=20
> check advances, which means that we didn't catch the race when it hap=
pened=20
> for real as copied_seq advanced too?!?

I see now what the situation is, thanks for explaining.

You're account for the "*seq" advance for URG that happens in
tcp_recvmsg() rather than the one that happens in tcp_check_urg().

> From another perspective when the race didn't happen but potential fo=
r it=20
> existed, the current check should catch that since peek_seq advanced =
and=20
> copied_seq stayed where it was. But that certainly doesn't match to y=
our=20
> description above.

Right.

> I wonder why all this fuzz about this particular race as we will do o=
ur=20
> best anyway to skip the hole on MSG_PEEK side (if I read the code rig=
ht)?=20
> Either we never see the hole in MSG_PEEK side, or we're happily past =
it=20
> already, does it make any difference anymore in the latter case? <ins=
ert=20
> some "not that I fully understand all of that multipage function"=20
> disclaimer here though, I may think too simple scenarios here>. Not t=
hat=20
> I'm too interested in "improving" urg or so anywa, I'm just curious..=
=2E :-)

A long long time ago we had an assertion here checking whether
->copied_seq moved without our knowledge.  Alexey and I found this
could trigger and investigation of that is what helped us
find the tcp_check_urg()+MSG_PEEK case.  That's when we added this
test and log message.

When the MSG_PEEK test existing in the !copied if() branch of
tcp_recvmsg(), so many of these code paths we are dealing with in this
fix could simply not be reached when MSG_PEEK.  That ++*seq could
never happen, because if "copied" was non-zero and MSG_PEEK was true
we would leave the loop and return from tcp_recvmsg() immediately.

Now, we have to accomodate those adjustments.

Since I now understand your urg_hole code I'm going to apply your v2
patch which takes care of the URG stuff.  I also buy the argument that
perhaps we should get rid of the log message, but look at how it
helped us find this kernel regression :-)
