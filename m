From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] QoS: new per flow queue
Date: 07 Apr 2005 07:06:01 -0400
Message-ID: <1112871961.1117.121.camel@jzny.localdomain>
References: <20050406123117.0265.LARK@linux.net.cn>
	 <1112789570.1099.37.camel@jzny.localdomain>
	 <20050406210800.0296.LARK@linux.net.cn>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Wang Jian <lark@linux.net.cn>
In-Reply-To: <20050406210800.0296.LARK@linux.net.cn>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Wang,

On Wed, 2005-04-06 at 09:45, Wang Jian wrote:
> Hi jamal,
> 
> 
> On 06 Apr 2005 08:12:50 -0400, jamal <hadi@cyberus.ca> wrote:
> 

> > Essentially rewrite the classid/flowid. In the action just set
> > skb->tc_classid and u32 will make sure the packet goes to the correct
> > major:minor queue. This already works with kernels >= 2.6.10.
> > 
> 
> One question:
> 
> Can I set skb->tc_classid in a qdisc and pass this skb to the specified
> class to handle?
> 

Well, remember the qdisc asks the filter what class a packet belongs to
every time. The best place to change things is at that point. Why not
tell the qdisc whatever class you want it to know instead of passing
metadata like skb->tc_classid for it to further intepret?

> 
> My idea is that the action itself dynamically creates classes. So you
> don't need any other rules. It is looks like #2 but the work is done in
> dynfwmark action. The workflow
> 
> 0. setup, and create flow entry hash;
> 1. when a packet arrives, check if it is a flow or should be a new flow;
> 2. alloc a class id for this flow;

so far so good. But you probably wanna drop the packet after a certain
upper bound for number of flows is reached. 

> 3. dynamically create a htb class using the <flow parameter>
> 4. skb->tc_classid = allocated_ht_class_id
> 
> 1.5 if can't create flow, skb->tc_classid = default_class_id
> 

This may be a little tricky with locks etc. Maybe you could send a
netlink message to the qdisc. Perhaps a workthread which creates these
classes etc. My suggestion was: 

a) qdisc asks filter "what class is this packet?"
b) filter responds "class 1:234"
c) qdisc says "hrm, dont have that class. call create_default_class"
d) qdisc::create_default_class() 
      create class and set default parameters. Default parameters are
      passed from user space (eg 10kbps rate etc). 
e) enqueue packet on new queue.

Also now you have to create the dynamic class rewriter action and change
a qdisc ;-> What i was saying earlier is that the create_default_class 
maybe a good addition to qdiscs. 
The question is do you keep those queues forver or kill them after a
period of no activity?
The idea of creating them permanently upto a certain max numbers is
probably ok. It will be no different than creating them via a script.

> > One thing i noticed is that you dont have multiple queues actually in
> > your code - did i misread that? i.e multiple classes go to the same
> > queue.
> > 
> 
> Didn't you notice that it is a classless qdisc? The queue is per qdisc,
> not per class :) 

Sorry missed that ;->

> It is the parent class's duty to define what kind of
> flow this qdisc handle. It is very generic, you can even mix UDP/TCP
> flows together but I don't think it is good idea.
> 

Doesnt that defeat the purpose of it being "per flow queue" ;->

> Think the scenario
> 
> 1. You have VoIP flows (UDP)
> 2. You have pptp vpn flows (eh, per flow can't handle it at this time, I
> think)
> 
> You create HTBs for them, and use filter to classify them. And then, use
> per flow qdisc as the only child of these HTBs. per flow qdisc will
> guarantee the per flow QoS.
> 

I got this. Of course you understand creating all these filters and
queues is taking system resources. It may be sufficient to create
heuristics like a simple priority qdisc where you put voip as first
class citizen, vpn as second and rest as best effort.

> > The only unfriendliness to user space is in #1 where you end up having a
> > script creating as many classes as you need. It is _not_ bloat because
> > you dont add any code at all. It is anti-bloat actually ;->
> > 
> 
> In this way, it is very hard to write good user interface in userspace.
> My current implementation takes good user-friendly (or user space
> scripter/programmer friendly) into serious consideration.
> 

It is not hard - its annoying in user space ;->
You could write a for loop to produce them. such as:

for i stating from 1 to 1000
 tc class add .... rate 10Kbps classid 1:$i
endfor

Trying to list those classes will list at least a 1000 lines of course.
But this listing issue will happen even when you dynamically create
these classes.
So annoyance is more descriptive.

> The 'bloated' comment is on the 
> 
> "If it carries an unique id or something like in its own namespace, then
> it can be clean and friendly for userspace"
> 

I am not disagreeing with you. If you want to go that path instead what
i am saying is its more coding.

> I think too much and my thought is jumpy ;) You even didn't notice that
> I gave another suggestion on implementation in this sentence.
> 

What? You did? 
just kidding;-> 
 
> > I am suprised no one has compared all the rate control schemes.
> > 
> > btw, would policing also suffice for you? The only difference is it will
> > drop packets if you exceed your rate. You can also do hierachical
> > sharing.
> 
> policy suffices, but doesn't serve the purpose of per flow queue.
> 

Policing will achieve the goal of rate control without worrying about
any queueing. I like the idea of someone trying to create dynamic queues
though ;-> 

cheers,
jamal
