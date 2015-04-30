From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of netfilter
 ingress hooks
Date: Thu, 30 Apr 2015 07:55:22 -0400
Message-ID: <5542182A.800@mojatatu.com>
References: <1430333589-4940-7-git-send-email-pablo@netfilter.org> <55413E99.5000807@iogearbox.net> <20150429233205.GA3416@salvia> <55417545.30103@iogearbox.net> <20150430003019.GE7025@acer.localdomain> <55417A3A.50405@iogearbox.net> <20150430004839.GG7025@acer.localdomain> <20150430011633.GA12674@Alexeis-MBP.westell.com> <20150430013452.GA7956@acer.localdomain> <554191F9.3010301@mojatatu.com> <20150430031138.GA8950@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150430031138.GA8950@acer.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/29/15 23:11, Patrick McHardy wrote:

> Quite frankly, that is ridiculous. I realize we turn in circles
> in this discussion, so we will provide the numbers. Give us a test
> case if you want, something you think is hard.


The usual tests i used to run are throughput and latency of datapath.
Then more importantly update rates of policies - this with and without
traffic.
Start with a zero rules. Add them logarithmically (with and without
traffic running). i.e in order of {0, 1, 10, 100, 1000, ...}
With a single rule you dont notice much difference. Start adding rules
and it becomes very obvious.
The latency for adding rule 1001 when there are say 1000 rules
already added is important from a control perspective if it stays linear.
I am sure this would make a good paper. Where are the firewo/men when
you need them?

>> For sure the attempt to re-use netfilter code from tc has failed.
>
> Agreed.
>

And i do note historically netfilter folks have not been very
willing to help make this better over the years. Actually i would trace
that back way to Harald's time. Pablo has been a lot more helpful in
recent times but now your answer is essentially to subsume tc into
netfilter;-> Great.
I could send a patch to delete it but i worry since people do send
bug reports.

>> I think thats what you keep probably repeating as something that will
>> crash.
>
> *Everything* except the purely passive ones as the policer will crash.
> Everything. Its well known. No point in repeating it.
>

please send fixes or send pointers or even private mail so either
myself or someone else can fix it.
I am sure if you stared long enough at any code you'll find bugs.
As would be the case for netfilter. Depends how much time you are
willing to invest. But to just handwave with "fire fire" is not
helpful. In the engineering world people come up and use solutions
and when they find new use cases either fix bugs that existed or add
new  features. This is how it works in Linux. Bugs _do get fixed_.
I know it is hard for people who take a lot of pride to accept.
To illustrate with an example:
I saw you mentioning the stateless nat action in the other email;
i happen to know that it is _heavily_ used by some large players in
very serious environments. You are probably using tc nat without
knowing it. Are there bugs? possibly yes. Do they apply to those
two big systems? Very unlikely otherwise they'd be fixed by now.
We dont intentionally keep bugs - but we dont aim
for perfection either. Lets refactor and fix bugs as needed.
Ive known you for years and i know you genuinely care about bugs - so
i am in no way trying to diminish what you are saying.
I have just never agreed when you get outraged and try to kill
something because you found bugs.  IOW, the logic of "there are bugs
in there, lets burn down the house" is not how we operate.


> I stopped caring about TC a long time ago, basically when actions were
> merged over my head, despite me being the only person actually taking
> care of TC. You might remember, I spent multiple months cleaning up the
> action mess when it was merged, and that was only the *really* bad bugs.
> Magic numbers in the APIs, lists limited to more magic numbers etc,

Yes, you fixed bugs as did other people over the years. And i have no
doubt you introduced bugs while you were doing that as did other people.
Magic numbers? Seriously? I am sure people are still fixing
magic numbers in netfilter this century and possibly this year.
If you care fix it. Note:
There is a difference between fixing bugs and you trying to reshape
code in your view of the world. The struggle over the years was you
trying to reshape things to your world - as it is in this case.

> I didn't care. Today I do not think its about individual problems anymore,
> the entire thing is broken. Egress has some shared problems with ingress,
> such as horrible userspace code, horrible error reporting, no way to use it
> even for me without looking at both TC and kernel code as the same time, but
> ingress is worse in the sense that the supermajority of it will actually
> crash in very likely cases, and its not about ipt, its everything touching
> a packet in the presence of a tap, like 2/3 of all actions. The qdiscs are
> mostly (except integration of classifiers) fine, everything else is crap.
>

Again, provide fixes or pointers so things can be fixed.

>
> The abstraction is *wrong*. There is no queueing, hence using a qdisc
> is the wrong abstraction. Why are we arguing about that? Its a
> mechanism to invoke classifiers and actions. What is the qdisc actually
> used for?

With all due respect, that is a very flawed arguement in the linux
world. Let me give you an example.
People use netdevs because they provide a nice abstraction and
tooling to go with it. Shall we kill all those netdevs which are
conviniences that take a packet in and out because hell they have
nothing to do with ports. What about xfrm? etc.
The qdisc provided all those niceties.

> It certainly doesn't queue anything, the only thing it's
> doing is imposing the worst locking imaginable on the entire path.
>

And yet despite this "worst locking imaginable" it is still faster than
your lockless approach.

> If that's not enough, look at the actions. I mean, you're not classifying
> for the sake of it, there are not even classes on ingress, its purely
> done for the actions. And they are, as stated, almost completely
> broken. We can do policing. That actually works. Maybe one or two more.
> Except policing, none of those is even remotely related to QoS.
> So let me ask again, in what sense is the abstraction actually right?
>

In the sense i described above.


> Quite frankly, talking about netfilter at all is so wrong that there
> isn't even a possibility to respond. Netfilter is a mechanism - a hook
> to receive a packet. And even that kicks your single threaded ingress
> qdiscs ass every packet of the day. What we're talking about are the
> things built on top. There's no question we also win on hardware that's
> not 1975 there, because people are actually using it.
>

Netfilter is a lot more usable - no doubt about it. It has always
been very good. But there are caveats.
At one point i think we were thankful all the crackheads were using
netfilter instead of tc because tc was harder to understand ;->.
In retrospect i think that was wrong;->

So let me see if i can summarize your arguement:
Hardware is faster than 1975 therefore lets just use netfilter
for usability reasons.
Thats what all those kids using rubyonrails are arguing for.
And there is room for that.
I claim there is still room for C. Heck, we are even trying to move
things into hardware so we can go faster.
But i admit to be envious sometimes when i see code written very rapidly
even though it makes me puke when i see how crappy the performance is.
I still havent learnt to accept that - even though i have come to terms
with accepting bugs.

cheers,
jamal

