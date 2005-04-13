From: Wang Jian <lark@linux.net.cn>
Subject: [RFC] QoS: frg queue (was [RFC] QoS: new per flow queue)
Date: Wed, 13 Apr 2005 13:45:25 +0800
Message-ID: <20050413131916.030F.LARK@linux.net.cn>
References: <20050407203631.02CF.LARK@linux.net.cn> <1112964208.1088.226.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1112964208.1088.226.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi jamal,

Sorry for the late reply. I am occupied by other things and just have
time back to this topic.

On 08 Apr 2005 08:43:28 -0400, jamal <hadi@cyberus.ca> wrote:


> On Thu, 2005-04-07 at 09:14, Wang Jian wrote:
> 
> > 1. a flow (in my perflow queue implementation) is a tuple of five
> > elements, but, for some reason, if the users misused this queue and send
> > non-flow packet, e.g. ICMP packet here;
> > 
> > 2. a queue is configured to handle 100 flows, but the 101st flow comes;
> > 
> > For this two situations, currently, the implementation just drops
> > packets. However, a clean way is to reclassify the packet into another
> > class (default) and provides no per flow guarantee.
> > 
> 
> The reclassification or #1 will best be left to the user. This is not
> hard to do.

I scan through other code and find no easy way to redirect non-handled
traffic to another class. Can you give me some hint on that?


> 
> Ok, stop calling it per-flow-queue then ;-> You should call it
> per-flow-rate-guarantee.

I have renamed it to frg (flow rate guarantee) per your suggestion.
After the above reclassification is done, I will post new patch here.

I will extend the concept of flow to include GRE, so pptp VPN can be
supported. There are other 'flows' to consider.


> > As I already said, this approach has drawbacks
> > 
> > 1. when flow count overlimit, no guarantee
> > 2. when flow count is underlimit, the guaranteed sum bandwidth can be
> > exploited to waste bandwidth.
> > 
> > So, thinking of per flow queue, it is "queue which can provide bandwidth
> > assurance and constraint per flow", and with only one queue!
> > 
> 
> Sharing is not a big challenge -  and should be policy driven.
> HTB and CBQ both support it. I am not sure about HFSC.
> 

Still, I am not clear if you understand me. How it works for this
purpose:

guarantee and only guarantee rate * n when there are n flows?

When there only 1 flow, guarantee only rate * 1
When there only 2 flows, guarantee only rate * 2
...
and so on

If always guarantee rate * limit, then the excessive guaranteed rate can
be abused.

But if always guarantee only rate * 1, then it is not enough.

>  
> > You only need to create one HTB, one filter and one per flow queue for
> > VoIP; and one HTB, one filter and one per flow queue for VPN.
> > 
> > I think the "per flow" name does confuse you ;) My fault.
> 
> The "queue" part is confusing - the "perflow" is fine. Lets stick with
> per-flow-rate-guarantee as the description.
> 
> So it seems you want by all means to avoid entering something that
> will take forever to list. Did i understand this correctly?

Yes. It is special purpose but general enough. I think it's worthy of
adding a new qdisc for it to avoid the dirty long listing part.

> 
> We can probably avoid insisting on dynamically creating classes maybe.
> You can rate control before you enqueue and we can use fwmark perhaps.
> Earlier i also asked whether policing will suffice. Heres an example
> (maybe dated syntax, but concept still valid) that shows sharing using
> policers:
> http://www.cyberus.ca/~hadi/patches/action/README

I will look at it later.

> look at the example where it says "--cut here --"
> 
> The only difference in this case is instead of creating 1000 classes
> you create 1000 policers as a result of the hash. 
> Something along:
> 
>     u32 classify for port 80 prio high \
>        action dymfwmark create range min 1 max 1000 \
>        action police to some rate if result is drop we stop here \
>        else continue \
>     fwmark classify prio low\
>        select one of two queues (high prio or low prio Q)
>  
> Very small script but still doesnt avoid the "seeing 1000 things". In
> this case if you list actions you see 1000.
> The lockings in this case are more bearable than having the dynamic
> marker creating queues.
> Typically the actions in a topology graph are stiched together at policy
> init time for efficiency reasons - so we dont have to do lookups at
> runtime. In this case it will need to have static lookup instead because
> depending on what the hash selects you want to select a different
> policer instance. I think i know an easy way of doing this (example
> storing per hash policer pointer in the dynmark table and doing the
> invoke from within dynmark).
> 

If we can do it with one thing, we should avoid creating 1000 things.
The policy way works but is dirty.

> > The problem occurs when you delete and add, and so on. It not good idea
> > to reuse a used classid when there is stream classified as old.
> > 
> > For example, you give class 1:1000 htb rate 200kbps ceil 200kbps for
> > http, and you delete the class 1:1000 and redefine 1:1000 htb rate
> > 30kbps ceil 30kbps for ftp.
> > 
> > At this time, the remained http streams carries a CONNMARK and restore
> > to MARK and then classified as 1:0000. Then 1:1000 is not what you want.
> > 
> 
> I would think the number 1000 should be related to hash of flow header,
> no? In which case there should be no collision unless the hash of ftp
> and http are 1000.
> 

To save netfilter rule matching work, if the CONNMARK is set, then it
will be used to set nfmark.

If a CONNMARK is already set on this http stream, it will be kept. Then
if you redefine 1:1000 as another meaning, then this http carrying
1:1000 will be mis-classified.


> > 
> > >  
> > > > > I am suprised no one has compared all the rate control schemes.
> > > > > 
> > > > > btw, would policing also suffice for you? The only difference is it will
> > > > > drop packets if you exceed your rate. You can also do hierachical
> > > > > sharing.
> > > > 
> > > > policy suffices, but doesn't serve the purpose of per flow queue.
> > > > 
> > > 
> > > Policing will achieve the goal of rate control without worrying about
> > > any queueing. I like the idea of someone trying to create dynamic queues
> > > though ;-> 
> > >
> > 
> > You need per flow queue to control something, like VoIP streams, or VPN
> > streams. If you just use policy, mixed traffic is send to per flow queue.
> > That is definitely not the purpose of per flow queue.
> > 
> > The dynamic queue creating is another way to implement the per flow
> > control (yes, one class and queue per flow). I think it is more complex
> > and wastes resources.
> > 
> 
> Look at the above suggestion - what you will waste in that case is
> polices. You should actually not use HTB but rather strict prio qdisc
> with policers.

As I said above, it works, but is dirty anyway ;)

> cheers,
> jamal



-- 
  lark
