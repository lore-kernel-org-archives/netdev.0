From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] QoS: new per flow queue
Date: 08 Apr 2005 08:43:28 -0400
Message-ID: <1112964208.1088.226.camel@jzny.localdomain>
References: <20050406210800.0296.LARK@linux.net.cn>
	 <1112871961.1117.121.camel@jzny.localdomain>
	 <20050407203631.02CF.LARK@linux.net.cn>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Wang Jian <lark@linux.net.cn>
In-Reply-To: <20050407203631.02CF.LARK@linux.net.cn>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Wang,

sorry for not getting back sooner - I actually wanted to read what you
are saying before responding ;->

On Thu, 2005-04-07 at 09:14, Wang Jian wrote:

> 1. a flow (in my perflow queue implementation) is a tuple of five
> elements, but, for some reason, if the users misused this queue and send
> non-flow packet, e.g. ICMP packet here;
> 
> 2. a queue is configured to handle 100 flows, but the 101st flow comes;
> 
> For this two situations, currently, the implementation just drops
> packets. However, a clean way is to reclassify the packet into another
> class (default) and provides no per flow guarantee.
> 

The reclassification or #1 will best be left to the user. This is not
hard to do.

> > Doesnt that defeat the purpose of it being "per flow queue" ;->
> 
> Per flow queue, is not one queue per flow ;) It is queue which can
> provide bandwidth assurance and constraint per flow.
> 
> The implementation can be either one queue per flow, or all flows fit
> into one queue.
> 

Ok, stop calling it per-flow-queue then ;-> You should call it
per-flow-rate-guarantee.

> As I already said, this approach has drawbacks
> 
> 1. when flow count overlimit, no guarantee
> 2. when flow count is underlimit, the guaranteed sum bandwidth can be
> exploited to waste bandwidth.
> 
> So, thinking of per flow queue, it is "queue which can provide bandwidth
> assurance and constraint per flow", and with only one queue!
> 

Sharing is not a big challenge -  and should be policy driven.
HTB and CBQ both support it. I am not sure about HFSC.

 
> You only need to create one HTB, one filter and one per flow queue for
> VoIP; and one HTB, one filter and one per flow queue for VPN.
> 
> I think the "per flow" name does confuse you ;) My fault.

The "queue" part is confusing - the "perflow" is fine. Lets stick with
per-flow-rate-guarantee as the description.

So it seems you want by all means to avoid entering something that
will take forever to list. Did i understand this correctly?

We can probably avoid insisting on dynamically creating classes maybe.
You can rate control before you enqueue and we can use fwmark perhaps.
Earlier i also asked whether policing will suffice. Heres an example
(maybe dated syntax, but concept still valid) that shows sharing using
policers:
http://www.cyberus.ca/~hadi/patches/action/README
look at the example where it says "--cut here --"

The only difference in this case is instead of creating 1000 classes
you create 1000 policers as a result of the hash. 
Something along:

    u32 classify for port 80 prio high \
       action dymfwmark create range min 1 max 1000 \
       action police to some rate if result is drop we stop here \
       else continue \
    fwmark classify prio low\
       select one of two queues (high prio or low prio Q)
 
Very small script but still doesnt avoid the "seeing 1000 things". In
this case if you list actions you see 1000.
The lockings in this case are more bearable than having the dynamic
marker creating queues.
Typically the actions in a topology graph are stiched together at policy
init time for efficiency reasons - so we dont have to do lookups at
runtime. In this case it will need to have static lookup instead because
depending on what the hash selects you want to select a different
policer instance. I think i know an easy way of doing this (example
storing per hash policer pointer in the dynmark table and doing the
invoke from within dynmark).

> The problem occurs when you delete and add, and so on. It not good idea
> to reuse a used classid when there is stream classified as old.
> 
> For example, you give class 1:1000 htb rate 200kbps ceil 200kbps for
> http, and you delete the class 1:1000 and redefine 1:1000 htb rate
> 30kbps ceil 30kbps for ftp.
> 
> At this time, the remained http streams carries a CONNMARK and restore
> to MARK and then classified as 1:0000. Then 1:1000 is not what you want.
> 

I would think the number 1000 should be related to hash of flow header,
no? In which case there should be no collision unless the hash of ftp
and http are 1000.

> 
> >  
> > > > I am suprised no one has compared all the rate control schemes.
> > > > 
> > > > btw, would policing also suffice for you? The only difference is it will
> > > > drop packets if you exceed your rate. You can also do hierachical
> > > > sharing.
> > > 
> > > policy suffices, but doesn't serve the purpose of per flow queue.
> > > 
> > 
> > Policing will achieve the goal of rate control without worrying about
> > any queueing. I like the idea of someone trying to create dynamic queues
> > though ;-> 
> >
> 
> You need per flow queue to control something, like VoIP streams, or VPN
> streams. If you just use policy, mixed traffic is send to per flow queue.
> That is definitely not the purpose of per flow queue.
> 
> The dynamic queue creating is another way to implement the per flow
> control (yes, one class and queue per flow). I think it is more complex
> and wastes resources.
> 

Look at the above suggestion - what you will waste in that case is
polices. You should actually not use HTB but rather strict prio qdisc
with policers.

cheers,
jamal
