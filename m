From: jamal <hadi@cyberus.ca>
Subject: Re: Announce: NetKeeper Firewall For Linux
Date: 05 Nov 2003 22:29:06 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1068089345.1020.17.camel@jzny.localdomain>
References: <1067285612.552.9.camel@aphrodite.olympus.net>
	 <20031028014223.129933be.davem@redhat.com>
	 <1067335655.10628.7.camel@rade7.s.cs.auc.dk>
	 <1068001237.1064.31.camel@jzny.localdomain>
	 <1068046114.31636.92.camel@rade7.s.cs.auc.dk>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@redhat.com>, netfilter-devel@lists.netfilter.org,
        netdev@oss.sgi.com, Mikkel Christiansen <mixxel@cs.auc.dk>
Return-path: <netdev-bounce@oss.sgi.com>
To: Emmanuel Fleury <fleury@cs.auc.dk>
In-Reply-To: <1068046114.31636.92.camel@rade7.s.cs.auc.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

On Wed, 2003-11-05 at 10:28, Emmanuel Fleury wrote:=20
> Hi,
>=20
> On Wed, 2003-11-05 at 04:00, jamal wrote:
> >=20
> > You seem to be attempting to replicate that functionality actually;->
> > (as opposed to using it). Therefore you are going to miss a lot of=20
> > good things. What was posted already is just the beggining.
>=20
> I'm not sure it is the case (but I might have missed the point).
>=20

Yes, i think you missed my point ;->=20
You guys are doing a great job at coming up with some good packet
classification algorithm(s). I wanna encourage you to continue doing
that.=20
OTOH, I have spent a lot of time thinking and coming up with a good
architecture for the action part (that follows classification). So it
will be a shame if you miss that because you happened to see one
good thing in the old code.
Putting the two together will result in some good things. You trying to
redo what i am doing will mean you are always a few steps behind[1]. Now
if you can do it better than what i have, then you can convert me=20
too - thats the way opensource works.=20

> Anyway, reading some new code can give us nice ideas.=20
> We would be pleased to see what you've already achieved.
>=20

Lets work together instead of you trying to get nice ideas from
my new code. This way you benefit from any evolution i have; and i have
lots coming down.
You must switch to making your code tc filter capable to do this.

> > Why do you have a limit to 8 actions?
>=20
> This limit is totally artificial.
>=20
> Basically, the story is that we had a union in a struct and we filled u=
p
> the memory space with these actions so that no memory was left behind.

> We decided (on arbitrary basis) that nobody would attach more than 8
> different actions to a precise packet. We also though that having 256
> different actions would be enough.
>=20

Probably true; but no point in making the limits when you dont have to.

> In fact, these two limits (8 and 256) are totally artificial and
> have been introduced in our prototype just because it was "convenient".
> We can extend the list of actions by using a chained list and code the
> actions on a bigger variable than a byte.
>=20

I dont understand why you even have this byte to encode an action.
Look at my code.

> > BTW, since you compile your filters, how fast are you at adding rules=
?
>=20
> So, here, you are hitting the sensitive spot !
>=20
> In fact, we are totally ignorant of what are the requirements on these
> dynamic updates in networking. So any discussion about this is extremel=
y
> valuable for us.
>=20

Anything that requires "connection setup" to dynamically add rules is a
candidate. Think Voip SIP Proxy server for example which will insert
rules; think any authentication schemes that are needed before
installing rules, think tcp-splicing etc.

> For your question, the theory (and the practice) is telling us that the
> time to add a new rule to an existing ruleset depend essentially of the
> complexity of the already existing ruleset.
>=20

I think thats a design issue. For example while u32 classifier may not
process as fast as you (lookups would take longer relatively ) - its
insertion time is independent of the complexity of the rules.
Lakshman (sp?) had a good paper on the tradeoffs between memory space
used, lookup times and insertion times (there was another variable) and
i think he may have proved you cant have all of them work well at the
same time.

> Don't miss my point, the number of rules which compose the ruleset is
> not the only parameter. Because, as your are going through an
> optimization a ruleset with a lot of trivial rules is simplified and
> will be trivial at the end.
>=20
> Therefore, it essentially depend on the ruleset to which you are adding
> your new rule.=20
>=20
> But, we still have to work on this part. The way we have coded the
> compiler is very simple and we have already some ideas on how to
> optimize it.
>=20
> Actually, a good thing for us would be to know what are your expectatio=
n
> in matter of adding a new rule. What is "acceptable" and what is "not".
>=20
> And, now, some tables with numbers:
>=20
> +--+--+--+--+--+
> | #rules | time(s) | nodes | edges | size(KB) |
> +--+--+--+--+--+
> |     10 |   0.01  |    28 |   102 |    1.584 |
> |     25 |   0.03  |    77 |   279 |    4.296 |
> |     50 |   0.11  |   128 |   481 |    7.332 |
> |    100 |   0.44  |   232 |   891 |   13.500 |
> |    250 |   3.44  |   542 |  2109 |   31.836 |
> |    500 |  19.14  |   998 |  3952 |   59.424 |
> |  1,000 |  37.72  |  1884 |  7544 |  113.160 |
> |  2,500 |  102.1  |  4289 | 17493 |  261.408 |
> |  5,000 |  237.0  |  7678 | 31880 |  474.720 |
> | 10,000 |  571.4  | 13420 | 57417 |  850.068 |
> | 25,000 | 1832.0  | 24657 |116673 | 1695.984 |
> | 50,000 | 5221.0  | 37416 |198754 | 2834.064 |
> +--+--+--+--+--+
>=20

So if you add rule #50000 while there are already 49999 existing
it will take over an hour to install in the worst case, did i understand
this correctly?

> The rulesets considered here are totally artificially generated and are
> matching our worst case in term of computing time.
>=20
> Of course your question was about taking one of this big filters and
> then add one tiny winny rule to it. So, I guess the time to do so would
> be at most 1s (in the very worst case, I would say).
>=20

Ok, so i didnt understand your table above then. 1s is very bad;
actually i shouldnt say that since i dont have numbers infront of me of
what is considered good. I will look this up

> > What about dynamic in kernel rules (such as those that may be created
> > by contracking) - do you have to cross to user space to compile them?
>=20
> We have some ideas on how to handle it. But for now, the scheme is
> totally static. I would say that we are keeping this area of research
> (stateful inspection) for later. :)
>=20

Which is fine. I would say for something like firewalling you have a
desirable feature of very optimized lookups.

> > - Is there any reason you move the commit decision to the kernel?
> > Could this not have been done in user space?
>=20
> Yes, definitely.
>=20
> When coding in the kernel, we are coding with the idea that:=20
>    =AB The kernel should defend itself against user-space. =BB
>=20
> So, when the user say: "Commit".=20
>=20
> The kernel will first check the decision diagram for safety (no NULL
> pointers, out of range variables, no loops, etc) and depending of the
> tests, will take the decision to commit or not.
>=20
> Actually, I think I read some stuff about it on the Netfilter-devel
> mailing-list. As far as I remember, there was a similar problem in
> netfilter as the safety of the whole thing is never really tested in
> depth. Therefore you can end-up with some loops or inconsistancy=20
> (WARNING: I'm not sure about it!).
>=20

That sounds more like still a user space problem ;->
I saw in your paper briefly that you have infact a checker for something
like this. That checker should run outside the kernel in my opinion.
The value in putting the commit in the kernel maybe for say making sure
you get the memory allocation you want etc before installing. But even
this is not a strong arguement.=20

> > I have doubts how fast you can install rules - which is a fundamental
> > measure of good filters.
>=20
> The fact is that theory is saying that optimizing is a complex problem
> (but it still has a polynomial time complexity ). But, we can for sure
> improve A LOT our current tools. The problem for us is that we do not
> know against what we are fighting ! We really need some hints on how
> fast should be this operation (just to see if it is possible or not in
> our scheme).
>=20

So i would suggest that you look at the Lakshman paper for starters.
In my view the most important issues in priority order are:
lookup speed regardless of table size, insert/delete rate regardless of
table size, Capacity (should be able to go to the hundreds of thousands
of flows), memory use for storage purposes - although i dont really care
very much about these since memory is cheap these days.

> PS: I would like also to say here that we got a really great feed back
> from the nf-hipac team. So, thank a lot to Michael Bellion and Thomas
> Heinz.
>=20

I am sorry i confused you with them;-> I suppose you are both from .dk.

cheers,
jamal

[1]I briefly looked at your paper and it seems the only action you had
initially was DENY or ACCEPT.
Looking at your code you now have an action dispatcher that seems
to be exactly like the old one i have (you havent implemented code
around it but you have the hooks in place). This is why i made the
comment.=20
