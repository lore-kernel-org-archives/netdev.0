From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/2] CARP implementation. HA master's failover.
Date: Sun, 18 Jul 2004 00:04:11 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040718000411.0a5ae938@zanzibar.2ka.mipt.ru>
References: <1089898303.6114.859.camel@uganda>
	<1089898595.6114.866.camel@uganda>
	<1089902654.1029.23.camel@jzny.localdomain>
	<1089905244.6114.887.camel@uganda>
	<1089906936.6114.904.camel@uganda>
	<1089908900.1027.77.camel@jzny.localdomain>
	<1089910757.6114.965.camel@uganda>
	<1089912658.1029.101.camel@jzny.localdomain>
	<20040715232035.37e016ef@zanzibar.2ka.mipt.ru>
	<1089981282.1060.1293.camel@jzny.localdomain>
	<1089990384.6114.2842.camel@uganda>
	<1090065129.1066.1196.camel@jzny.localdomain>
	<20040717165942.1e7f847f@zanzibar.2ka.mipt.ru>
	<1090079263.1063.1303.camel@jzny.localdomain>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1090079263.1063.1303.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 17 Jul 2004 11:47:43 -0400
jamal <hadi@cyberus.ca> wrote:

> On Sat, 2004-07-17 at 08:59, Evgeniy Polyakov wrote:
> > On 17 Jul 2004 07:52:09 -0400
> > jamal <hadi@cyberus.ca> wrote:
> 
> > > BTW, theres a very nice paper being presented at OLS by someone
> > > from.au who is trying infact to move drivers to user space ;-> 
> > 
> > I saw it...
> > May I not comment it? I do not want to look like rude freak... :)
> 
> rude freaks are not frowned upon here;-> They are loved (ok, maybe
> some uptight people may have a problem with it;->). 
> But maybe we should keep that thread separate from this.

:) Sure.

> > > Big difference though with CARP. CARP shouldnt need to process
> > > 100Kpps; but even if it did, CARP packet contain control
> > > information that is valuable in policy settings. Control protocols
> > > tend to be"rich" and evolve over much shorter periods of time.  
> > > A better comparison what you are saying is to move OSPF to the
> > > kernel.
> > 
> > Only for now, since we can imagine only some examples now.
> > When number of agents controlled/connected to CARP will became
> > significant broadcasting and userspace arbiter's overhead may not
> > satisfy HA needs.
> 
> So let me put your fears to rest and share my experiences:
> I have some experience in using VRRP in a variety of very large,
> critical and at times very weird senseless setups. This is with some
> of the most anal telco types you can come across. They protect the
> network uptime just as if it was a part of their body. I hate to use
> dirty cliches like "carrier grade" - but it would probably be the
> closest qualifier; Telcos dont let you mess around their setups and
> create any holes which will bring down anything for a few seconds.
> Note, this is with VRRP running in user space. In _every_ case i have
> been in, i have always been challenged as to why its not in the kernel
> or running as realtime process. and in all cases, running in user
> space didnt prove to be the problem. The biggest challenge was fixing
> broadcast storms because someone created a bcast loop in which case
> the machine is under DoS attack. The otehr valuable thing to do is to
> make sure that VRRP packets (as any other control packets) get higher
> priority in the network. 
> 
> BTW, If you are thinking of instantiating carpd for every agent, then
> you got to rethink that plan. Hint: You need to handle all carp
> protocol within one daemon. Maybe thats what you are saying but only
> to do it in the kernel.
> 
> Broadcasts: I wasnt sure what you meant.

Netlink broadcast...

I absolutely agree with you, that userspace heartbeat application may
satisfy most of current needs.
But if you need kernel access you need to create not only kernel part,
but also some userspace controlling application. So we will have carpd,
which controls userspace application which in turn control kernel parts.
Maybe it is solution, but sometimes better just to use existing kernel
part with privided in-kernel carp.
Your position is that any control arbiter must live in userspace, but I
offer in-kernel solution for those who needs only in-kernel access.

> > Control, but it must have possibility to control any dataflow
> > element. If using all_flows_one_arbiter, then we must have near
> > standing controller like in-kernel CARP.
> > If using one_flow_one_arbiter(like tc) then we may use far
> > outstanding control mechanism and near standing arbiter. 
> > Like qdisk + tc + ucarp.
> > 
> > The question is: "Do we need to create near standing ariters and far
> > standing controller for scenatio A, while we may have near standing
> > controller?".
> > I do believe that for some situations we just need in-kernel
> > controller without any overhead and simple in-kernel interface.
> 
> I think the example of ARP contradicts your view and may apply well
> here. For small setups, you can use in-kernel ARP.
> To scale it you move things to arpd in user space. Unfortunately, ARP
> has always been in the kernel for Linux; so that maybe the reason
> Alexey never ripped it out totaly.

Yep, it is good example.
But this medal has another side: linux handles all network traffik only
in one processor in a time. Consider userspace process that binds to
receiving interface or some address or even skb, and such processes may
be processed in parallel, amy have prioritisation and so forth...
Ridiculous example, i know, and absolutely exaggerated but moving from
kernel to userspace not always good idea.
Even if it is not dataflow and just rare control.

> > BTW, I just reread OpenBSD's load balancing code...
> > IT is different from that one which may be created with tc and it's
> > extensions.
> > 
> > They look into each packet and if it's "signature" is controlled by
> > node and this node is master than process this packet.
> > They have one arbiter for any dataflow, while Linux has many
> > arbiters each of which may be controlled from userspace, that is the
> > difference.
> 
> I think thats the wrong way to go about it.
> What you need is enter a simple rule like:
> 
> filter: If you see ARP asking for our IPs
> action: Accept
> filter(installed by carpd): if you see ARP for IP X
> action: accept
> .... repeat a few similar ARP rules by carpd for different IPs ..
> default action: drop all ARPs.
> 
> This is installed in the datapath before ARP code gets hit.
> The additional accepts are entered by carpd when it receives CARP
> packets which describe how to load balance.

Sure.
It is do correct way of doing this.
But we just lucky guys and can control this dataflow in such way.
Not everithing may be fitted for such scenario.

> > So their schema may not be implemented in userspace CARP, while in
> > Linux it may be implemented using tc extensions with userspace CARP.
> 
> You could do the above in the kernel. It means everytime i want to
> make changes i now have to change the kernel.
> 
> > I will rewrite my resume:
> > With your approach any data flow MUST go through userspace arbiters
> > with all overhead and complexity. With my approach any data flow
> > _MAY_ go through userspace arbiters, but if you do_need/only_has
> > in-kernel access than using in-kernel CARP is the only solution.
> 
> Evgeniy, this is the most valuable arguement you have for in-kernel. I
> suggest drop all the other ones because they are red herrings and lets
> focus on this one.
> 
> > My main idea for in-kernel CARP was to implement invisible HA
> > mechanism suitable for in-kernel use. You do not need to create
> > netlink protocol parser, you do not need to create extra userspace
> > overhead, you do not need to create suitable for userspace control
> > hooks in kernel infrastructure. Just register callback.
> > But even with such simple approach you have opportunity to
> > collaborate with userspace. If you need.
> > 
> > Why creating all userspace cruft if/when you need only kernel one?
> 
> Because of all the reasons i have mentioned so far ;->
> Again, i am not against kernel helpers. I am against putting CARP in
> the kernel.

Okey.
I will summarize our views:
on one side we have in-kernel solution which may control any process
there, which may be used for in-kernel access.
On the other side we have userspace solution which requres kernel
helpers.

One do may use any, question is, does concrete situation requires
userspace control? If no, the using in-kernel solution if preferable.

You think that any in-kernel access must have userspace arbiter, but i
do think that in some situation we do not need it. For such situations
you do not need to create kernel helper and userspace controller, only
in-kernel carp.

> cheers,
> jamal
> 


	Evgeniy Polyakov ( s0mbre )

Only failure makes us experts. -- Theo de Raadt
