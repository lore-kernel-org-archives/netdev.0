From: Jeffrey Knockel <jeffk@cs.unm.edu>
Subject: Re: [PATCH net] ip: make IP identifiers less predictable
Date: Fri, 25 Jul 2014 09:55:58 -0600
Message-ID: <53D27E0E.40102@cs.unm.edu>
References: <1406189276.3363.63.camel@edumazet-glaptop2.roam.corp.google.com> <CA+55aFyCDNq3E+bZ3aPfS33w8mA_86J+cNWR5V6fdogNihSh2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Jedidiah R. Crandall" <crandall@cs.unm.edu>,
	Willy Tarreau <w@1wt.eu>,
	"security@kernel.org" <security@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from snape.cs.unm.edu ([64.106.20.59]:47451 "EHLO snape.cs.unm.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752808AbaGYQE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2014 12:04:29 -0400
In-Reply-To: <CA+55aFyCDNq3E+bZ3aPfS33w8mA_86J+cNWR5V6fdogNihSh2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/24/2014 12:21 PM, Linus Torvalds wrote:
> On Thu, Jul 24, 2014 at 1:07 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>
>> This patch adds a random amount of perturbation so that IP identifiers
>> for a given destination [1] are no longer monotonically increasing after
>> an idle period.
> 
> This certainly looks good to me. It would be good to have actual
> testing by Jeffrey &al, but this seems simple and complete.

I've just tested it, and this easily defeats our implementation of the
side-channel attack, as our implementation assumes we're trying to infer
the value of a per-destination counter that isn't moving on its own.

I've let my thoughts on this problem percolate some more overnight.

Commit 73f156a6e8c1 ("inetpeer: get rid of ip_id_count") really does
change the problem of inferring the existence of traffic between
machines, both for better and for worse.  It helps the problem in one
way in that the IP id counter corresponding to any destination is now
noisier, particularly for high traffic servers, although for servers
with a small population of users this isn't so helpful.  It actually
hurts the problem though in that we don't even need to use our
side-channel if we control enough addresses (or at least an address that
hashes to the same counter as an address whose traffic to the server we
want to measure).  So for an attacker controlling a large number of
addresses trying to measure which of a server's small population of
users are accessing it, the problem actually seems worse since this commit.

So now about how this proposed patch changes things.  It breaks our use
of a side-channel to infer the value of counters, since our
binary-search-like approach which we rely on to efficiently find the
value of the counter just doesn't handle a randomly moving counter.
Moreover, it would seem very difficult to make it robust to that.  I
suspect that the best someone could ever do is infer a rough idea of the
counter at any one time.  And then trying to use our side-channel to
meaningfully infer anything but the largest of differences to the
counter over time would be even more difficult.  So I believe that this
patch adequately addresses the side-channel attack in our paper.

On the other hand, in the post-73f156a6e8c1 world, we also have this new
problem of where an attacker doesn't even need to use our side-channel
if he controls a large number of addresses and can measure the values of
the counters directly.  The proposed patch actually helps with this case
too.  However, the existence of traffic between the server and some
other address could probably still be inferred by a sufficiently
determined attacker.  Certainly it could be if the server is sending the
address a very large number packets, as the signal would just overcome
the noise.  But even if the number of packets being sent is very small,
surprisingly, this may still be inferable under this patch, as, e.g.,

randint(25) + randint(25) + randint(25) + randint(25)

has a much different probability distribution than randint(100), and a
determined attacker may be able to determine if he is sampling from
randint(100) or not with enough samples.

So my thoughts in a nutshell:  I believe that this proposed patch solves
the original problem of attackers being able to infer the value of
counters via a side-channel.  However, in the post-73f156a6e8c1 world,
there's also a new problem which we might care about too where we have
an attacker who controls a large number of addresses.  This patch also
happens to help with this problem too, but maybe not enough, depending
on how sophisticated of an attacker we want to protect against.

Jeff
