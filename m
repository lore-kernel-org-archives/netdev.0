From: jamal <hadi@cyberus.ca>
Subject: Re: [1/2] CARP implementation. HA master's failover.
Date: 17 Jul 2004 11:47:43 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1090079263.1063.1303.camel@jzny.localdomain>
References: <1089898303.6114.859.camel@uganda>
	 <1089898595.6114.866.camel@uganda>
	 <1089902654.1029.23.camel@jzny.localdomain>
	 <1089905244.6114.887.camel@uganda> <1089906936.6114.904.camel@uganda>
	 <1089908900.1027.77.camel@jzny.localdomain>
	 <1089910757.6114.965.camel@uganda>
	 <1089912658.1029.101.camel@jzny.localdomain>
	 <20040715232035.37e016ef@zanzibar.2ka.mipt.ru>
	 <1089981282.1060.1293.camel@jzny.localdomain>
	 <1089990384.6114.2842.camel@uganda>
	 <1090065129.1066.1196.camel@jzny.localdomain>
	 <20040717165942.1e7f847f@zanzibar.2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <20040717165942.1e7f847f@zanzibar.2ka.mipt.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-07-17 at 08:59, Evgeniy Polyakov wrote:
> On 17 Jul 2004 07:52:09 -0400
> jamal <hadi@cyberus.ca> wrote:

> > BTW, theres a very nice paper being presented at OLS by someone from
> > .au who is trying infact to move drivers to user space ;-> 
> 
> I saw it...
> May I not comment it? I do not want to look like rude freak... :)

rude freaks are not frowned upon here;-> They are loved (ok, maybe some
uptight people may have a problem with it;->). 
But maybe we should keep that thread separate from this.

> > Big difference though with CARP. CARP shouldnt need to process
> > 100Kpps; but even if it did, CARP packet contain control information
> > that is valuable in policy settings. Control protocols tend to be
> > "rich" and evolve over much shorter periods of time.  
> > A better comparison what you are saying is to move OSPF to the kernel.
> 
> Only for now, since we can imagine only some examples now.
> When number of agents controlled/connected to CARP will became
> significant broadcasting and userspace arbiter's overhead may not
> satisfy HA needs.

So let me put your fears to rest and share my experiences:
I have some experience in using VRRP in a variety of very large,
critical and at times very weird senseless setups. This is with some of
the most anal telco types you can come across. They protect the network
uptime just as if it was a part of their body. I hate to use dirty
cliches like "carrier grade" - but it would probably be the closest
qualifier; Telcos dont let you mess around their setups and create any
holes which will bring down anything for a few seconds. Note, this is
with VRRP running in user space. In _every_ case i have been in, i have
always been challenged as to why its not in the kernel or running as
realtime process. and in all cases, running in user space didnt prove to
be the problem. The biggest challenge was fixing broadcast storms
because someone created a bcast loop in which case the machine is under
DoS attack. The otehr valuable thing to do is to make sure that
VRRP packets (as any other control packets) get higher priority in the
network. 

BTW, If you are thinking of instantiating carpd for every agent, then
you got to rethink that plan. Hint: You need to handle all carp protocol
within one daemon. Maybe thats what you are saying but only to do it in
the kernel.

Broadcasts: I wasnt sure what you meant.

> Control, but it must have possibility to control any dataflow element.
> If using all_flows_one_arbiter, then we must have near standing
> controller like in-kernel CARP.
> If using one_flow_one_arbiter(like tc) then we may use far outstanding
> control mechanism and near standing arbiter. 
> Like qdisk + tc + ucarp.
> 
> The question is: "Do we need to create near standing ariters and far
> standing controller for scenatio A, while we may have near standing
> controller?".
> I do believe that for some situations we just need in-kernel controller
> without any overhead and simple in-kernel interface.

I think the example of ARP contradicts your view and may apply well
here. For small setups, you can use in-kernel ARP.
To scale it you move things to arpd in user space. Unfortunately, ARP
has always been in the kernel for Linux; so that maybe the reason Alexey
never ripped it out totaly.

> > We just have better architecture thats all ;-> 
> 
> If we want to put as many as possible outside the kernel while it works
> better in kernel then we slowly go to meet microkernel and userspace
> thread for fs, for network, which will be controlled by broadcast
> messages for simplifying control protocol.
> 
> But it is too far planes, so it is just "blah-blah" lyrics now... :)

hehe. Tell the guy who wrote openbsd song to make sure he doesnt quit
his day job;->
There are a lot of people talking about moving pieces of the net stack
to user space. I am not of that religion yet because i havent really
seen the value. 

> BTW, I just reread OpenBSD's load balancing code...
> IT is different from that one which may be created with tc and it's
> extensions.
> 
> They look into each packet and if it's "signature" is controlled by node
> and this node is master than process this packet.
> They have one arbiter for any dataflow, while Linux has many arbiters
> each of which may be controlled from userspace, that is the difference.

I think thats the wrong way to go about it.
What you need is enter a simple rule like:

filter: If you see ARP asking for our IPs
action: Accept
filter(installed by carpd): if you see ARP for IP X
action: accept
.... repeat a few similar ARP rules by carpd for different IPs ..
default action: drop all ARPs.

This is installed in the datapath before ARP code gets hit.
The additional accepts are entered by carpd when it receives CARP
packets which describe how to load balance.

> So their schema may not be implemented in userspace CARP, while in
> Linux it may be implemented using tc extensions with userspace CARP.

You could do the above in the kernel. It means everytime i want to make
changes i now have to change the kernel.

> I will rewrite my resume:
> With your approach any data flow MUST go through userspace arbiters with
> all overhead and complexity. With my approach any data flow _MAY_ go
> through userspace arbiters, but if you do_need/only_has in-kernel access
> than using in-kernel CARP is the only solution.

Evgeniy, this is the most valuable arguement you have for in-kernel. I
suggest drop all the other ones because they are red herrings and lets
focus on this one.

> My main idea for in-kernel CARP was to implement invisible HA mechanism
> suitable for in-kernel use. You do not need to create netlink protocol
> parser, you do not need to create extra userspace overhead, you do not
> need to create suitable for userspace control hooks in kernel
> infrastructure. Just register callback.
> But even with such simple approach you have opportunity to collaborate
> with userspace. If you need.
> 
> Why creating all userspace cruft if/when you need only kernel one?

Because of all the reasons i have mentioned so far ;->
Again, i am not against kernel helpers. I am against putting CARP in the
kernel.

cheers,
jamal
