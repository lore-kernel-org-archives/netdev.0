From: Mikkel Christiansen <mixxel@cs.auc.dk>
Subject: Re: Announce: NetKeeper Firewall For Linux
Date: Sun, 09 Nov 2003 20:55:07 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FAE9B9B.60007@cs.auc.dk>
References: <1067285612.552.9.camel@aphrodite.olympus.net>	 <20031028014223.129933be.davem@redhat.com>	 <1067335655.10628.7.camel@rade7.s.cs.auc.dk>	 <1068001237.1064.31.camel@jzny.localdomain>	 <1068046114.31636.92.camel@rade7.s.cs.auc.dk>	 <1068089345.1020.17.camel@jzny.localdomain>	 <1068114376.1532.115.camel@rade7.s.cs.auc.dk> <1068211670.1031.49.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Emmanuel Fleury <fleury@cs.auc.dk>, "David S. Miller" <davem@redhat.com>,
        netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1068211670.1031.49.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

>On Thu, 2003-11-06 at 05:26, Emmanuel Fleury wrote:
>
> =20
>
>>Ok, actually we were so focused on the classification scheme that we
>>didn't really try to do something nice for the actions... In a matter o=
f
>>facts, we have only one action (log) and it is not even implemented.=20
>>
>>So, we will definitely look at your code to avoid us to have to think
>>about this part (and avoid to have to recode the actions).=20
>>
>>   =20
>>
>
>I am asking you to switch to the TC code. I dont think i am making my
>point across ;->[1]. Integrate your classifer like any other tc
>classifier and then you dont have to look at my code unless you really
>want to.
>
> =20
>

If we integrate it would mean a new/alternative interface
to tc where you compile the filter/configuratoin before
uploading. We believe this is a good thing since it allows
admins to (syntax) check the filter before inserting it.
I believe the guys from shorewall sees this as a missing
feature of iptables.

Would you consider such an interface for tc good are bad?

>>>Anything that requires "connection setup" to dynamically add rules is =
a
>>>candidate. Think Voip SIP Proxy server for example which will insert
>>>rules; think any authentication schemes that are needed before
>>>installing rules, think tcp-splicing etc.
>>>     =20
>>>
>>Ok, but you are speaking about non permanent rules (aka dynamic rules).=
=20
>>
>>   =20
>>
>
>These types are most dominant these days in my opinion unless you are a
>single user behind a DSL line.
>
> =20
>
>>The idea we have to handle stateful inspection is to have the core
>>filter (totally static) plus some "state" nodes placed inside the IDD
>>which are calling a function to evaluate the "state" of the packet
>>(based on some informations given by the packet header and a database o=
f
>>the open connections).=20
>>   =20
>>
>
>Isnt the state database another classifier and therefore you will be
>faced with the same challenges for it?=20
>I dont think you wuill get a free ride putting the state lookups
>somewhere else.
>
> =20
>
current scheme cant handle dynamic rules - and it will
be a while (if ever) before it can.

>>When reaching the terminals, one of the action
>>can be to change the state of the connection.
>>   =20
>>
>
>tc allows you to have multiple cascaded classifiers; so=20
>you could "reclassify" and jump to a state classifier.
>I think the other guys from .dk also had their own scheme of achieving
>the same goal. Being able to do this in my opinion is architecturally
>cleaner.
>
> =20
>
>>I guess that what you describe can be handled by such mechanism=20
>>(better than changing the ruleset each time). As it is handled outside
>>of the IDD, this take only the time of the look-up in the database and
>>the time to modify the database (when necessary).
>>
>>   =20
>>
>
>This is true if you consider the state database to be a different
>problem other than a classification one.=20
>
> =20
>
>>But, I over simplified things here, this scheme is far from being ready
>>at this point. We should investigate it more in depth (we need more
>>time!!!).=20
>>
>>   =20
>>
>
>no problem.
>
> =20
>
>>>I think thats a design issue. For example while u32 classifier may not
>>>process as fast as you (lookups would take longer relatively ) - its
>>>insertion time is independent of the complexity of the rules.
>>>Lakshman (sp?) had a good paper on the tradeoffs between memory space
>>>used, lookup times and insertion times (there was another variable) an=
d
>>>i think he may have proved you cant have all of them work well at the
>>>same time.
>>>     =20
>>>
>>Ok. Could you give more details about the references of this paper from
>>Lakshman ?
>>
>>   =20
>>
>
>You are in academia, you better make sure you are aware of these=20
>things ;->=20
>
> =20
>
>The Lakshman paper describes an algorithm but i remember it was the
>first to introduce classification constraints:
>
>T.V.Lakshman and D.Stiliadis. High Speed Policy-based Packet Forwarding
>Using Efficient Multi-dimensional Range Matching. Proceedings of ACM
>Sigcomm98
>
>Another good paper to look at is:
>
>A.Feldmann and S.Muthukrishnan. Tradeoffs for packet classification.
>Proceedings of IEEE Infocom2000
>
> =20
>
>>I am wrong here, terribly wrong. The thing is that is you add a rule at
>>the end of your filter, you will not have to rebuild it, but inserting =
a
>>rule randomly in the list is... bad. For now, we don't have any good
>>algorithm to insert a rule, so we just rebuild the whole thing.
>>
>>   =20
>>
>
>Then you have some work to do
>
> =20
>
>>>>When coding in the kernel, we are coding with the idea that:=20
>>>>   =AB The kernel should defend itself against user-space. =BB
>>>>
>>>>So, when the user say: "Commit".=20
>>>>
>>>>The kernel will first check the decision diagram for safety (no NULL
>>>>pointers, out of range variables, no loops, etc) and depending of the
>>>>tests, will take the decision to commit or not.
>>>>       =20
>>>>
>>>That sounds more like still a user space problem ;->
>>>     =20
>>>
>>No.
>>
>>Users shouldn't be able to break the kernel just by misconfiguring it.
>>
>>   =20
>>
>
>Couldnt you, knowing the rules already existing check for breakage in
>user space?
>
> =20
>
no - if someone decided to write their own "client/compiler" in
userspace they could potentially produce a broken IDD - that
could crash the kernel!

>>>I saw in your paper briefly that you have infact a checker for somethi=
ng
>>>like this.=20
>>>     =20
>>>
>>If you are speaking about the "network access verifier", it is somethin=
g
>>totally different. But, I might have misunderstood you.
>>
>>   =20
>>
>
>I meant that network access verifier. I believe you should be able to
>verify things not only just in user space bu even in a remote location
>(example a network management station). Now this stuff is interesting.
>
> =20
>
>>>In my view the most important issues in priority order are:
>>>lookup speed regardless of table size, insert/delete rate regardless o=
f
>>>table size, Capacity (should be able to go to the hundreds of thousand=
s
>>>of flows), memory use for storage purposes - although i dont really ca=
re
>>>very much about these since memory is cheap these days.
>>>     =20
>>>
>>Ok, I think we have to work on the insert/delete part. I know for a fac=
t
>>that insert/delete inside the IDD is not an option (as the complexity o=
f
>>this operation is too high), so we will look at some other way to handl=
e
>>it.
>>
>>   =20
>>
>
>cool. Looking forward to see some of your thoughts on this when you have
>experienced it.
>
>cheers,
>jamal
>
>[1] Look at your action code dispatch name and my old one and note the
>name being _exactly_ the same. I dont think it is a big coincidence and
>i dont think you had any bad intent. I am just saying you can continue
>doing that or you can integrate. Why dont we drop this part of the
>discussion if you dont wanna move forward to the tc code? I thought you
>agreed with Dave to integrate ;->
>
> =20
>
Well, then you need to think again - it is in fact a coincidence!

Cheers
    Mikkel
