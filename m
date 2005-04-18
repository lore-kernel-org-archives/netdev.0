From: Wang Jian <lark@linux.net.cn>
Subject: Re: [RFC] QoS: frg queue (was [RFC] QoS: new per flow queue)
Date: Tue, 19 Apr 2005 00:01:48 +0800
Message-ID: <20050418214446.0389.LARK@linux.net.cn>
References: <20050413131916.030F.LARK@linux.net.cn> <1113830063.26757.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1113830063.26757.15.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi jamal,

> > On 08 Apr 2005 08:43:28 -0400, jamal <hadi@cyberus.ca> wrote:
> > 
> > 
> 
> > > The reclassification or #1 will best be left to the user. This is not
> > > hard to do.
> > 
> > I scan through other code and find no easy way to redirect non-handled
> > traffic to another class. Can you give me some hint on that?
> > 
> 
> There are two constructs at the classifier level: the first one is
> "reclassify" which basically asks the classification activity to
> restart. Another one is the " continue"  construct which basically asks
> for the classification to continue where the last one ended.
> Does this explanation help?
> 

I will look into this afterwards. But I don't think this helps because
FRG is not at classifier level.

> > I will extend the concept of flow to include GRE, so pptp VPN can be
> > supported. There are other 'flows' to consider.
> > 
> 
> I think you should start by decoupling the classification away from your
> qdisc.


Actually, I am not very sure if FRG does do classification at the moment.
Because FRG is a quick hack from looking at SFQ and FIFO, I am still not
sure whether classification is what I think it is. There is so little
documentation on how to write tc code :(

FRG does things the same way as SFQ,  the only difference is the flow
tracking algorithm.  So IMHO, my current code doesn't do classification
at all. Am I wrong?

> 
> Lets say you have 8 flows; each to be guaranteed 100Kbps. Lets say your
> wire rate is only 1Mbps. 
> 
> Then you create policies so that each gets 100Kbps. If they all use
> their quota you still have 200Kbps to play with. You could then say that
> out of that 200Kps, 100kbps is to be shared amongst the 8 flows if they
> exceed their allocated 100Kbps(sharing) and the other 100kbps is for
> best effort traffic. 
> In this case, each flow is _guaranteed_ 100Kbps and upto 100Kbps from
> shared quota if no-one else is using that shared quota. 
> If multi flows are using the shared 100Kbps then, its given out on first
> come basis. "Guaranteed" in this case means it is _reserved_ i.e if flow
> #3 is not using its allocation, flow #2 cant use it.
> 
> Ok, so now tell me where you and i are differing on semantics?
> Is the above what you are also saying? 

In the above,  you still didn't mention "fewer flows than expected" case.
This is what FRG wants to address.  Also, "guaranteed" has difference
semantics.

For FRG, there are two rates: guaranteed and ceiled.

1. guaranteed rate is in the sense of "if you need so much, I will
provide so much; but if you need not so much, others can use the spared"

2. ceiled rate is in the sense of "you can't exceed this much whenever
and whatever"

The guaranteed and ceiled rate take effects on a per flow basis, not on a
group basis.

So, if currently there is only one flow, FRG will only have 1*100kbps
guaranteed, and have a ceil of 1*ceil kbps. Other traffic not managed by
FRG can takes from 1Mbps - 1*ceil to 1Mbps - 1*100kbps bandwidth. This
makes bandwidth to be used in more efficient way than _reserved_. This
is "fewer flows than expected" case.

But for the grouped quota, 1 flow can take upto 8*100kbps bandwidth,
and more from the left 200kbps on the first comes first served basis.
HTB/CBQ provides grouped quota.

Why the difference? Because in the sense of per flow guarantee, it is
supposed that if guaranteed rate is met, the flow will work well in most
cases, and the available extra bandwidth ( ceil - guarantted_rate)
merely is protection against possible jitter. A flow is hard limited below
ceil, which prevents a flow hog the bandwidth. 

Of course, one htb class with rate + ceil per flow can do the same thing.
And I think one policy perl flow can do the same thing too. The dynamic
class or policy we discussed before can also work it out. But see below.

> 
> > > So it seems you want by all means to avoid entering something that
> > > will take forever to list. Did i understand this correctly?
> > 
> > Yes. It is special purpose but general enough. I think it's worthy of
> > adding a new qdisc for it to avoid the dirty long listing part.
> > 
> 
> I am not sure about the "general enough" part. You need to know what is
> happening at any instance in time if this is to be useful. So that
> information for listing should be available - you may wish not to
> display it unless someone asks for verbose output.
> 
> > > 
> > > We can probably avoid insisting on dynamically creating classes maybe.
> > > You can rate control before you enqueue and we can use fwmark perhaps.
> > > Earlier i also asked whether policing will suffice. Heres an example
> > > (maybe dated syntax, but concept still valid) that shows sharing using
> > > policers:
> > > http://www.cyberus.ca/~hadi/patches/action/README
> > 
> > I will look at it later.
> > 
> 
> Please do so we can have a synchronized discussion.
> 

I have read it now.  Considering the purpose why FRG is created, I
didn't see it is useful, because it is still on  "grouped"  basis but not
"flow"  basis.

> 
> > If we can do it with one thing, we should avoid creating 1000 things.
> > The policy way works but is dirty.
> 
> yes, but that hiding can be hidden at user space for example. 
> There are several levels of verbosity if you insist:
> - See nothing
> - just see info which says "at the moment we have 234 classes
> dynamically created" 
> - get a full listing for each of 234 classes and their attributes.
> - get a full listing for each 234 class and their attributes as well as
> stats. 

Basically, the divergency between our opinions is not whether and how we
can do it in that way, but why we should do it in that way.

Current FRG implementation doesn't need its own filter. A FRG queue
processes packets from its parent (leaf) class, which defines flow
criteria. Internally, a FRG queue distinguishes and tracks flows, and do
rate guarantee and ceil by manipulating packets over a single queue.

The implementation is simple and clean, and does work as expected. It
also simplify user space management.

So the question is: why we should use a complex implementation which
is also complicated in userspace (considering dynamic classid allocation),
but not use a simple implementation which is also simple for userspace?

> 
> your policy management/scripts are then responsible to make sure
> everything is synchronized between iptables and tc. 

This is necessary, but this can range from simple to complex.
Unfortunately, dynamic class/policy goes to the complex end.

> Once we have the  tracker action, this would only need to be doen via tc.
> 

Is there any document about the tracker action?

-- 
  lark
