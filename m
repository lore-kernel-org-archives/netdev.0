From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: dummy as IMQ replacement
Date: Tue, 01 Feb 2005 14:53:29 +0000
Message-ID: <41FF97E9.7040501@dsl.pipex.com>
References: <1107123123.8021.80.camel@jzny.localdomain>	 <41FEB3AE.3090400@dsl.pipex.com> <1107258578.1095.570.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: hadi@cyberus.ca
In-Reply-To: <1107258578.1095.570.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2005-01-31 at 17:39, Andy Furniss wrote:
> 
>>Jamal Hadi Salim wrote:
> 
> 
>>>2) Allows for queueing incoming traffic for shaping instead of
>>>dropping. I am not aware of any study that shows policing is 
>>>worse than shaping in achieving the end goal of rate control.
>>
>>I would say the end goal is shaping not just rate control. Shaping 
>>meaning different things to different people and ingress shaping being 
>>different from egress.
> 
> 
> I know for a while the Bart howto was mislabeling the meaning of
> policing - not sure about shaping. 
> Shaping has a precise definition that involves a queue and a
> non-working-conserving scheduler in order to rate control. This doesnt
> matter where it happens (egress or ingress). Policing on the other hand
> is work conserving etc.

Ok, but shaping to LARTC posters means being able to classify traffic 
and set up sharing/priorotising of classes. This is the reason most need 
to be able to queue - they want to use htb/hfsc for complicated setups 
and until now were not aware that it was even possible to replicate this 
in policers and if it becomes feasable it will probably appear daunting 
to do compared with HTB and all the existing docs/scripts.

For me, I think queuing and dropping is better than just dropping, you 
can affect tcp by delaying eg. 1 ack per packet rather than delayed acks 
and clocking out the packets helps smooth burstiness, which hurts 
latency if you are doing traffic control from the wrong end of the 
bottleneck.

> 
>>For me it's from the wrong end of a relativly narrow (512kbit) 
>>bottleneck link that has a 600ms fifo at the other end. My aim to 
>>sacrifice as little bandwidth as possible while not adding latency 
>>bursts for gaming and per user bandwidth allocation (with sharing of 
>>unused) and sfq within that for bulk tcp traffic.
>>
>>If I was shaping LAN traffic, then policers/drops would be OK for me - 
>>but for a slow link I think queueing and dropping are better/give more 
>>control eg. I get to use sfq which should not drop the one packet a 56k 
>>user has managed to send me in the face of lots of incoming from low 
>>latency high bandwidth servers.
>>
>>Even if it's possible I bet few can easily get policers to setup the 
>>complex sharing/prioritisations that you can with HTB or HFSC.
> 
> 
> sfq has a built in classifier that can efficiently separate those
> flows so you can achieve semi-fairness; so its not the shaping perse
> that helps, rather you ended up using a clever scheme that can isolate
> flows and benefited from shaping as a result; the hashing function
> should prove weak when a lot of flows start showing up.
> You could write some interesting classifier (as an example steal the one
> that sfq has) and achieve the same end results with policing. This would
> be easier now with ematches .. 

The idea of loosing the s from sfq and doing multilevel hash/mapping is 
attractive - of course I would want to queue each flow and have the 
queue be variable length for each flow depending on occupancy of other 
flows. I suppose a per flow intelligent dropping scheme would be even 
better. It would be nice to be able to set/control queuelength for link 
bandwidth, nothing classful in linux tc does this.


> 
> 
>>>But i wont go back to putting netfilter hooks in the device to satisfy
>>>this.  I also dont think its worth it hacking dummy some more to be 
>>>aware of say L3 info and play ip rule tricks to achieve this.
>>>--> Instead the plan is to have a contrack related action. This action
>>>will selectively either query/create contrack state on incoming packets.
>>
>>I don't understand exactly what you mean here - for my setup to work I 
>>need to see denatted addresses and mark (connbytes - it helps me be 
>>extra nasty to multiple simoultaneous connections in slowstart and 
>>prioritise browsing over bulk) in prerouting mangle. Of course if I can 
>>use netfilter to classify and save into contrack then I could do 
>>evrything in netfilter and then use something like connmark to save it 
>>per connection.
>>
> 
> 
> You may be refering to requirement #3 then? 
> In other words what you are doing is best served by knowing the state?

As long as I could use netfilter to mark/classify connections then I 
think I can sort my setup, don't know about others.


> Are pre/post routing sufficient as netfilter hooks for your case?

Yes but depends on where in pre/postrouting. For me after/before nat, as 
I say above though I could workaround if I classify connections with 
netfilter. For others as long as they can filter on a mark/classify set 
in forward, then I think it will be OK for them.

> 
> 
>>>Packets could then be redirected to dummy based on what happens -> eg 
>>>on incoming packets; if we find they are of known state we could send to
>>>a different queue than one which didnt have existing state. This
>>>all however is dependent on whatever rules the admin enters.
>>
>>
>>How does the admin enter the rules - netfilter or other?
>>
>  
> Just like i showed in that post (It was long - so dont wanna cutnpaste
> here).
> 

I am not sure what exactly can can't be done in your example:



 ># redirect all IP packets arriving in eth0 to dummy0
 ># use mark 1 --> puts them onto class 1:1
 >$TC filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
 >match u32 0 0 flowid 1:1 \

What I can do here depends where it hooks packets.

 >action ipt -j MARK --set-mark 1 \

I don't know what table I am using - may be OK as long as I can test for 
a mark I made earlier in the egress dummy case or test connmark/state I 
set for that connection in the ingress case.

 >action mirred egress redirect dev dummy0

Andy.


> cheers,
> jamal
> 
> 
