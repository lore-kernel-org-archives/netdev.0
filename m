From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/2] CARP implementation. HA master's failover.
Date: Sat, 17 Jul 2004 16:59:42 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040717165942.1e7f847f@zanzibar.2ka.mipt.ru>
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
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1090065129.1066.1196.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 17 Jul 2004 07:52:09 -0400
jamal <hadi@cyberus.ca> wrote:

<arguments and contrarguments are skipped>

> > Actually last example can't be used as argument in our discussion,
> > but it illustrates that sometimes we need to touch kernel-_only_
> > parts, and this decision is dictated from the outside of the
> > touchable part.
> > 
> 
> I can tell you one thing: I am totaly against this thing being part
> of the kernel; not just because it adds noise but because it makes it
> harder to keep adding more and more functionality or integrating its
> capability into other apps.
> BTW, theres a very nice paper being presented at OLS by someone from
> .au who is trying infact to move drivers to user space ;-> 

I saw it...
May I not comment it? I do not want to look like rude freak... :)

> I dont mind adding some needed datapath mechanism in the kernel to
> enable it to do interesting things; control of such mechanism and
> policy decisions should be very clearly separated and sit in
> userspace.
> 
> > > BTW, I like that ARP balancing feature that CARP has. Pretty neat.
> > > Note that it could be easily done via a tc action with user space
> > > control.
> > 
> > Anything may be done in userspace.
> > For example routing decision.
> > Yes, it _may_ be done in userspace. But it is slow.
> 
> Big difference though with CARP. CARP shouldnt need to process
> 100Kpps; but even if it did, CARP packet contain control information
> that is valuable in policy settings. Control protocols tend to be
> "rich" and evolve over much shorter periods of time.  
> A better comparison what you are saying is to move OSPF to the kernel.

Only for now, since we can imagine only some examples now.
When number of agents controlled/connected to CARP will became
significant broadcasting and userspace arbiter's overhead may not
satisfy HA needs.

> > SCSI over IP may be done as network block device.
> > Or even copying packet to userspace through raw device and then send
> > it using socket.
> 
> Again all that is datapath. CARP is control.

Control, but it must have possibility to control any dataflow element.
If using all_flows_one_arbiter, then we must have near standing
controller like in-kernel CARP.
If using one_flow_one_arbiter(like tc) then we may use far outstanding
control mechanism and near standing arbiter. 
Like qdisk + tc + ucarp.

The question is: "Do we need to create near standing ariters and far
standing controller for scenatio A, while we may have near standing
controller?".
I do believe that for some situations we just need in-kernel controller
without any overhead and simple in-kernel interface.

> > QNX and Mach are even designed in this way.
> 
> We just have better architecture thats all ;-> 

If we want to put as many as possible outside the kernel while it works
better in kernel then we slowly go to meet microkernel and userspace
thread for fs, for network, which will be controlled by broadcast
messages for simplifying control protocol.

But it is too far planes, so it is just "blah-blah" lyrics now... :)

> [BTW, A lot of people with experience in things like vxworks (one big
> flat memory space) always want to move things into the kernel.
> Typically after some fight they move certain things to user space with
> "you will hear from me" threats. I never hear back from them because
> it works fine. This after they wanted to shoot me because linux "wasnt
> realtime"]

BTW, I just reread OpenBSD's load balancing code...
IT is different from that one which may be created with tc and it's
extensions.

They look into each packet and if it's "signature" is controlled by node
and this node is master than process this packet.
They have one arbiter for any dataflow, while Linux has many arbiters
each of which may be controlled from userspace, that is the difference.

So their schema may not be implemented in userspace CARP, while in
Linux it may be implemented using tc extensions with userspace CARP.

I will rewrite my resume:
With your approach any data flow MUST go through userspace arbiters with
all overhead and complexity. With my approach any data flow _MAY_ go
through userspace arbiters, but if you do_need/only_has in-kernel access
than using in-kernel CARP is the only solution.

My main idea for in-kernel CARP was to implement invisible HA mechanism
suitable for in-kernel use. You do not need to create netlink protocol
parser, you do not need to create extra userspace overhead, you do not
need to create suitable for userspace control hooks in kernel
infrastructure. Just register callback.
But even with such simple approach you have opportunity to collaborate
with userspace. If you need.

Why creating all userspace cruft if/when you need only kernel one?

> > It is not talk about current possibilities, it is kind of design :)
> > Yes, probably our _current_ needs may be satisfied using existing
> > userspace tools.
> > But I absolutely sure that we will need in-kernel support.
> > I'm reading you second e-mail with pretty diagrams and already see
> > where in-kernel CARP will live there :)
> 
> Ok;-> I am looking forward to see your view on it.
> 
> cheers,
> jamal


	Evgeniy Polyakov ( s0mbre )

Only failure makes us experts. -- Theo de Raadt
