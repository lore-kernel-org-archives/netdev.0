From: Wang Jian <lark@linux.net.cn>
Subject: Re: [RFC] QoS: new per flow queue
Date: Thu, 07 Apr 2005 21:14:38 +0800
Message-ID: <20050407203631.02CF.LARK@linux.net.cn>
References: <20050406210800.0296.LARK@linux.net.cn> <1112871961.1117.121.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1112871961.1117.121.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi jamal,


On 07 Apr 2005 07:06:01 -0400, jamal <hadi@cyberus.ca> wrote:

> > 
> > One question:
> > 
> > Can I set skb->tc_classid in a qdisc and pass this skb to the specified
> > class to handle?
> > 
> 
> Well, remember the qdisc asks the filter what class a packet belongs to
> every time. The best place to change things is at that point. Why not
> tell the qdisc whatever class you want it to know instead of passing
> metadata like skb->tc_classid for it to further intepret?
> 

1. a flow (in my perflow queue implementation) is a tuple of five
elements, but, for some reason, if the users misused this queue and send
non-flow packet, e.g. ICMP packet here;

2. a queue is configured to handle 100 flows, but the 101st flow comes;

For this two situations, currently, the implementation just drops
packets. However, a clean way is to reclassify the packet into another
class (default) and provides no per flow guarantee.



> > 
> > Didn't you notice that it is a classless qdisc? The queue is per qdisc,
> > not per class :) 
> 
> Sorry missed that ;->
> 
> > It is the parent class's duty to define what kind of
> > flow this qdisc handle. It is very generic, you can even mix UDP/TCP
> > flows together but I don't think it is good idea.
> > 
> 
> Doesnt that defeat the purpose of it being "per flow queue" ;->

Per flow queue, is not one queue per flow ;) It is queue which can
provide bandwidth assurance and constraint per flow.

The implementation can be either one queue per flow, or all flows fit
into one queue.

> 
> > Think the scenario
> > 
> > 1. You have VoIP flows (UDP)
> > 2. You have pptp vpn flows (eh, per flow can't handle it at this time, I
> > think)
> > 
> > You create HTBs for them, and use filter to classify them. And then, use
> > per flow qdisc as the only child of these HTBs. per flow qdisc will
> > guarantee the per flow QoS.
> > 
> 
> I got this. Of course you understand creating all these filters and
> queues is taking system resources. It may be sufficient to create
> heuristics like a simple priority qdisc where you put voip as first
> class citizen, vpn as second and rest as best effort.

As I already said, this approach has drawbacks

1. when flow count overlimit, no guarantee
2. when flow count is underlimit, the guaranteed sum bandwidth can be
exploited to waste bandwidth.

So, thinking of per flow queue, it is "queue which can provide bandwidth
assurance and constraint per flow", and with only one queue!

You only need to create one HTB, one filter and one per flow queue for
VoIP; and one HTB, one filter and one per flow queue for VPN.

I think the "per flow" name does confuse you ;) My fault.


> 
> > > The only unfriendliness to user space is in #1 where you end up having a
> > > script creating as many classes as you need. It is _not_ bloat because
> > > you dont add any code at all. It is anti-bloat actually ;->
> > > 
> > 
> > In this way, it is very hard to write good user interface in userspace.
> > My current implementation takes good user-friendly (or user space
> > scripter/programmer friendly) into serious consideration.
> > 
> 
> It is not hard - its annoying in user space ;->
> You could write a for loop to produce them. such as:
> 
> for i stating from 1 to 1000
>  tc class add .... rate 10Kbps classid 1:$i
> endfor
> 
> Trying to list those classes will list at least a 1000 lines of course.
> But this listing issue will happen even when you dynamically create
> these classes.
> So annoyance is more descriptive.
>

The problem occurs when you delete and add, and so on. It not good idea
to reuse a used classid when there is stream classified as old.

For example, you give class 1:1000 htb rate 200kbps ceil 200kbps for
http, and you delete the class 1:1000 and redefine 1:1000 htb rate
30kbps ceil 30kbps for ftp.

At this time, the remained http streams carries a CONNMARK and restore
to MARK and then classified as 1:0000. Then 1:1000 is not what you want.


>  
> > > I am suprised no one has compared all the rate control schemes.
> > > 
> > > btw, would policing also suffice for you? The only difference is it will
> > > drop packets if you exceed your rate. You can also do hierachical
> > > sharing.
> > 
> > policy suffices, but doesn't serve the purpose of per flow queue.
> > 
> 
> Policing will achieve the goal of rate control without worrying about
> any queueing. I like the idea of someone trying to create dynamic queues
> though ;-> 
>

You need per flow queue to control something, like VoIP streams, or VPN
streams. If you just use policy, mixed traffic is send to per flow queue.
That is definitely not the purpose of per flow queue.

The dynamic queue creating is another way to implement the per flow
control (yes, one class and queue per flow). I think it is more complex
and wastes resources.


-- 
  lark
