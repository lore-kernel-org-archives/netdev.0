From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] QoS: new per flow queue
Date: 06 Apr 2005 08:12:50 -0400
Message-ID: <1112789570.1099.37.camel@jzny.localdomain>
References: <20050405224956.0258.LARK@linux.net.cn>
	 <1112723858.1076.46.camel@jzny.localdomain>
	 <20050406123117.0265.LARK@linux.net.cn>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Wang Jian <lark@linux.net.cn>
In-Reply-To: <20050406123117.0265.LARK@linux.net.cn>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Wang,

On Wed, 2005-04-06 at 01:12, Wang Jian wrote:
> Hi jamal,
> 
> I know your concern. Actually, I first try to implement it like you
> point out, but then I dismiss that scheme, because it is hard to
> maintain for the userspace.
> 
> But if the dynfwmark can dynamically alloc htb class in the given class
> id range. For example
> 
> tc filter ip u32 tc filter ip u32 match ip sport 80 0xffff flowid 1:12 \
>      action dynfwmark major 1 range 1:1000 <flow parameter> continue
> 

Yes, this looks better except for the <flow parameter> part - why do you
need that? The syntax may have to explicitly say min 1 max 1000 for
usability, but thats not a big deal.
Essentially rewrite the classid/flowid. In the action just set
skb->tc_classid and u32 will make sure the packet goes to the correct
major:minor queue. This already works with kernels >= 2.6.10.

> When it detects a new flow, it creates the necessary htb class? So the
> userspace work is simple. But when we have segmented class id space, we
> may not get such an enough empty range.
> 

Yes, I thought about this too when i was responding to you earlier. 
Theres two ways to do it in my opinion:
1) create apriori at setup time 1024 or whatever number of HTB classes.
So when u32 selects the major:minor its already there.
OR
2) do what you are suggesting to dynamically create classes; i.e
"classifier returned a non-existing class, create default class
using that major/minor number". 
Default class could be defined from user space to be one that is
initialized to 10 Kbps rate burst 1kbps etc. You may have to teach the
qdisc the maximum number of classes it should create.

#1 above will work immediately and you dont have to hack any of the
qdiscs. The disadvantage is your user space app will have to
create every class individualy - so if you have 1024 queues then 1024
queues are needed. 
#2 is nice because it avoids the above problem - disadvantage is you
need to manage creation and deletion of these queues and write code.

I do think the idea of dynamically creating the flow queues is
interesting and useful as well. It would be nice if it can be done for
all classful qdiscs.

One thing i noticed is that you dont have multiple queues actually in
your code - did i misread that? i.e multiple classes go to the same
queue.


> I think per flow control in nature means that classifier must be
> intimately coupled with scheduler. There is no way around it. If you
> seperate them, you must provide a way to link them together again. The
> dynfwmark way you suggested actually does so, but not clean (because you
> choose to use existing nfmark infrastructure). If it carries an unique
> id or something like in its own namespace, then it can be clean and
> friendly for userspace, but I bet it is unnecessarily bloated.
> 

The only unfriendliness to user space is in #1 where you end up having a
script creating as many classes as you need. It is _not_ bloat because
you dont add any code at all. It is anti-bloat actually ;->

Look at above - and based on your suggestion; lets reset the
flowid/classid.

>  In my test, HTB performs very well. I intensionally requires a HTB
> class to enclose a perflow queue to provide guaranteed sum bandwidth. The
> queue is proven to be fair enough and can guarantee rate internally for
> its flows (if the per flow rate is at or above 10kbps).
> 

Well, HTB is just a replica of the token bucket scheduler with
additional knobs - so i suspect the numbers will look the same with TB
as well. Someone needs to be test all of them and see how accurate they
are. The clock sources at compile time and your hardware will also
affect you.

> I haven't tested rate lower than 10kbps, because my test client is not
> that accurate to show the number. It's simply a "lftpget <url>".
> 
> There are short threads before in which someone asked for a per flow
> control solution, and was suggested to use HTB + SFQ. My test reveals
> that SFQ is far away from fairness and can't meet the requirement of
> bandwidth assurance.
> 

I dont think SFQ will give you per flow; actually I should say - depends
on your definition of flow - seems yours is the 5 tuple { src/dst IP,
src/dst port, proto=UDP/TCP/SCTP}. SFQ will work for a subset of these
tuples and is therefore not fair at the granularity that you want.

> For HFSC, I haven't any experience with it because the documentation is
> lacked.
> 

I am suprised no one has compared all the rate control schemes.

btw, would policing also suffice for you? The only difference is it will
drop packets if you exceed your rate. You can also do hierachical
sharing.

cheers,
jamal
