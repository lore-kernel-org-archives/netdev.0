From: Emmanuel Fleury <fleury@cs.auc.dk>
Subject: Re: Announce: NetKeeper Firewall For Linux
Date: Thu, 06 Nov 2003 11:26:16 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1068114376.1532.115.camel@rade7.s.cs.auc.dk>
References: <1067285612.552.9.camel@aphrodite.olympus.net>
	 <20031028014223.129933be.davem@redhat.com>
	 <1067335655.10628.7.camel@rade7.s.cs.auc.dk>
	 <1068001237.1064.31.camel@jzny.localdomain>
	 <1068046114.31636.92.camel@rade7.s.cs.auc.dk>
	 <1068089345.1020.17.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@redhat.com>, netfilter-devel@lists.netfilter.org,
        netdev@oss.sgi.com, Mikkel Christiansen <mixxel@cs.auc.dk>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1068089345.1020.17.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

On Thu, 2003-11-06 at 04:29, jamal wrote:
>=20
> Yes, i think you missed my point ;->=20

Oops ! :)

> You guys are doing a great job at coming up with some good packet
> classification algorithm(s). I wanna encourage you to continue doing
> that.=20
> OTOH, I have spent a lot of time thinking and coming up with a good
> architecture for the action part (that follows classification). So it
> will be a shame if you miss that because you happened to see one
> good thing in the old code.
>
Putting the two together will result in some good things. You trying to
> redo what i am doing will mean you are always a few steps behind[1]. No=
w
> if you can do it better than what i have, then you can convert me=20
> too - thats the way opensource works.=20

Ok, actually we were so focused on the classification scheme that we
didn't really try to do something nice for the actions... In a matter of
facts, we have only one action (log) and it is not even implemented.=20

So, we will definitely look at your code to avoid us to have to think
about this part (and avoid to have to recode the actions).=20

> Anything that requires "connection setup" to dynamically add rules is a
> candidate. Think Voip SIP Proxy server for example which will insert
> rules; think any authentication schemes that are needed before
> installing rules, think tcp-splicing etc.

Ok, but you are speaking about non permanent rules (aka dynamic rules).=20

The idea we have to handle stateful inspection is to have the core
filter (totally static) plus some "state" nodes placed inside the IDD
which are calling a function to evaluate the "state" of the packet
(based on some informations given by the packet header and a database of
the open connections). When reaching the terminals, one of the action
can be to change the state of the connection.

I guess that what you describe can be handled by such mechanism=20
(better than changing the ruleset each time). As it is handled outside
of the IDD, this take only the time of the look-up in the database and
the time to modify the database (when necessary).

But, I over simplified things here, this scheme is far from being ready
at this point. We should investigate it more in depth (we need more
time!!!).=20

> I think thats a design issue. For example while u32 classifier may not
> process as fast as you (lookups would take longer relatively ) - its
> insertion time is independent of the complexity of the rules.
> Lakshman (sp?) had a good paper on the tradeoffs between memory space
> used, lookup times and insertion times (there was another variable) and
> i think he may have proved you cant have all of them work well at the
> same time.

Ok. Could you give more details about the references of this paper from
Lakshman ?

> So if you add rule #50000 while there are already 49999 existing
> it will take over an hour to install in the worst case, did i understan=
d
> this correctly?

Yes (I messed up things in the following paragraph), you are totally
right here. I totally forgot that you have to deal with rule-overlapping
which is actually making things incredibly sequential).

> > Of course your question was about taking one of this big filters and
> > then add one tiny winy rule to it. So, I guess the time to do so woul=
d
> > be at most 1s (in the very worst case, I would say).

I am wrong here, terribly wrong. The thing is that is you add a rule at
the end of your filter, you will not have to rebuild it, but inserting a
rule randomly in the list is... bad. For now, we don't have any good
algorithm to insert a rule, so we just rebuild the whole thing.

> > When coding in the kernel, we are coding with the idea that:=20
> >    =AB The kernel should defend itself against user-space. =BB
> >=20
> > So, when the user say: "Commit".=20
> >=20
> > The kernel will first check the decision diagram for safety (no NULL
> > pointers, out of range variables, no loops, etc) and depending of the
> > tests, will take the decision to commit or not.
>=20
> That sounds more like still a user space problem ;->

No.

Users shouldn't be able to break the kernel just by misconfiguring it.

> I saw in your paper briefly that you have infact a checker for somethin=
g
> like this.=20

If you are speaking about the "network access verifier", it is something
totally different. But, I might have misunderstood you.

> In my view the most important issues in priority order are:
> lookup speed regardless of table size, insert/delete rate regardless of
> table size, Capacity (should be able to go to the hundreds of thousands
> of flows), memory use for storage purposes - although i dont really car=
e
> very much about these since memory is cheap these days.

Ok, I think we have to work on the insert/delete part. I know for a fact
that insert/delete inside the IDD is not an option (as the complexity of
this operation is too high), so we will look at some other way to handle
it.

> > PS: I would like also to say here that we got a really great feed bac=
k
> > from the nf-hipac team. So, thank a lot to Michael Bellion and Thomas
> > Heinz.
> >=20
>=20
> I am sorry i confused you with them;-> I suppose you are both from .dk.

No, Michael and Thomas are from Germany. Mikkel Christiansen is from
Denmark and I'm from France (working in Denmark currently).

> [1]I briefly looked at your paper and it seems the only action you had
> initially was DENY or ACCEPT.

We can extend this without any problem.

> Looking at your code you now have an action dispatcher that seems
> to be exactly like the old one i have (you havent implemented code
> around it but you have the hooks in place). This is why i made the
> comment.=20

Actually, as I said, we were just no so concerned about the handling of
the actions, so we just did it in the most natural way (for us). It is a
good sign that we are meeting your very first implementation.=20

Regards
--=20
Emmanuel Fleury

Computer Science Department, |  Office: B1-201
Aalborg University,          |  Phone:  +45 96 35 72 23
Fredriks Bajersvej 7E,       |  Fax:    +45 98 15 98 89
9220 Aalborg East, Denmark   |  Email:  fleury@cs.auc.dk
