From: Emmanuel Fleury <fleury@cs.auc.dk>
Subject: Re: Announce: NetKeeper Firewall For Linux
Date: Wed, 05 Nov 2003 16:28:34 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1068046114.31636.92.camel@rade7.s.cs.auc.dk>
References: <1067285612.552.9.camel@aphrodite.olympus.net>
	 <20031028014223.129933be.davem@redhat.com>
	 <1067335655.10628.7.camel@rade7.s.cs.auc.dk>
	 <1068001237.1064.31.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@redhat.com>, netfilter-devel@lists.netfilter.org,
        netdev@oss.sgi.com, Mikkel Christiansen <mixxel@cs.auc.dk>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1068001237.1064.31.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

On Wed, 2003-11-05 at 04:00, jamal wrote:
>=20
> You seem to be attempting to replicate that functionality actually;->
> (as opposed to using it). Therefore you are going to miss a lot of=20
> good things. What was posted already is just the beggining.

I'm not sure it is the case (but I might have missed the point).

My first answer to David S. Miller was probably misleading. What we are
trying to do is to investigate an alternate algorithm to do packet
classification. Our overall goal is not to produce a shiny tool that
goes into Linux, but a new scheme which is more scalable than the one
that everybody is using right now (i.e. the "world famous"
classification based on rulesets).

If our scheme can be useful and is, at some point, included in one
existing tool, I would be the first one to take the netkeeper code and
put it to the trash (as it serve only to demonstrate and tune our
scheme).

So do not consider us as "yet another concurrent project to fight with",
because we are not really aiming at the same thing. :)

> If you want to incorporate i can send you the latest patches (posted
> patches have intentional bugs to see who is actually testing). You
> seem to be already hooking into netfilter btw so not sure how easy it
> would be for you;

Anyway, reading some new code can give us nice ideas.=20
We would be pleased to see what you've already achieved.

> Why do you have a limit to 8 actions?

This limit is totally artificial.

Basically, the story is that we had a union in a struct and we filled up
the memory space with these actions so that no memory was left behind.

We decided (on arbitrary basis) that nobody would attach more than 8
different actions to a precise packet. We also though that having 256
different actions would be enough.

In fact, these two limits (8 and 256) are totally artificial and
have been introduced in our prototype just because it was "convenient".
We can extend the list of actions by using a chained list and code the
actions on a bigger variable than a byte.

> BTW, since you compile your filters, how fast are you at adding rules?

So, here, you are hitting the sensitive spot !

In fact, we are totally ignorant of what are the requirements on these
dynamic updates in networking. So any discussion about this is extremely
valuable for us.

For your question, the theory (and the practice) is telling us that the
time to add a new rule to an existing ruleset depend essentially of the
complexity of the already existing ruleset.

Don't miss my point, the number of rules which compose the ruleset is
not the only parameter. Because, as your are going through an
optimization a ruleset with a lot of trivial rules is simplified and
will be trivial at the end.

Therefore, it essentially depend on the ruleset to which you are adding
your new rule.=20

But, we still have to work on this part. The way we have coded the
compiler is very simple and we have already some ideas on how to
optimize it.

Actually, a good thing for us would be to know what are your expectation
in matter of adding a new rule. What is "acceptable" and what is "not".

And, now, some tables with numbers:

+--------+---------+-------+-------+----------+
| #rules | time(s) | nodes | edges | size(KB) |
+--------+---------+-------+-------+----------+
|     10 |   0.01  |    28 |   102 |    1.584 |
|     25 |   0.03  |    77 |   279 |    4.296 |
|     50 |   0.11  |   128 |   481 |    7.332 |
|    100 |   0.44  |   232 |   891 |   13.500 |
|    250 |   3.44  |   542 |  2109 |   31.836 |
|    500 |  19.14  |   998 |  3952 |   59.424 |
|  1,000 |  37.72  |  1884 |  7544 |  113.160 |
|  2,500 |  102.1  |  4289 | 17493 |  261.408 |
|  5,000 |  237.0  |  7678 | 31880 |  474.720 |
| 10,000 |  571.4  | 13420 | 57417 |  850.068 |
| 25,000 | 1832.0  | 24657 |116673 | 1695.984 |
| 50,000 | 5221.0  | 37416 |198754 | 2834.064 |
+--------+---------+-------+-------+----------+

The rulesets considered here are totally artificially generated and are
matching our worst case in term of computing time.

Of course your question was about taking one of this big filters and
then add one tiny winny rule to it. So, I guess the time to do so would
be at most 1s (in the very worst case, I would say).

> What about dynamic in kernel rules (such as those that may be created
> by contracking) - do you have to cross to user space to compile them?

We have some ideas on how to handle it. But for now, the scheme is
totally static. I would say that we are keeping this area of research
(stateful inspection) for later. :)

> - Is there any reason you move the commit decision to the kernel?
> Could this not have been done in user space?

Yes, definitely.

When coding in the kernel, we are coding with the idea that:=20
   =AB The kernel should defend itself against user-space. =BB

So, when the user say: "Commit".=20

The kernel will first check the decision diagram for safety (no NULL
pointers, out of range variables, no loops, etc) and depending of the
tests, will take the decision to commit or not.

Actually, I think I read some stuff about it on the Netfilter-devel
mailing-list. As far as I remember, there was a similar problem in
netfilter as the safety of the whole thing is never really tested in
depth. Therefore you can end-up with some loops or inconsistancy=20
(WARNING: I'm not sure about it!).

> I have doubts how fast you can install rules - which is a fundamental
> measure of good filters.

The fact is that theory is saying that optimizing is a complex problem
(but it still has a polynomial time complexity ). But, we can for sure
improve A LOT our current tools. The problem for us is that we do not
know against what we are fighting ! We really need some hints on how
fast should be this operation (just to see if it is possible or not in
our scheme).

PS: I would like also to say here that we got a really great feed back
from the nf-hipac team. So, thank a lot to Michael Bellion and Thomas
Heinz.

Regards
--=20
Emmanuel

Netkeeper (An IDD firewall) http://www.cs.auc.dk/~fleury/netkeeper/
