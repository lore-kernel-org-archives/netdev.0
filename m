From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH]: tipc: Fix oops on send prior to entering networked mode
Date: Tue, 23 Feb 2010 11:09:36 -0500
Message-ID: <20100223160936.GA16435@hmsreliant.think-freely.org>
References: <20100219194033.GA28743@hmsreliant.think-freely.org>
 <29C1DC0826876849BDD9F1C67ABA29430705EF62@ala-mail09.corp.ad.wrs.com>
 <20100223011116.GA2021@localhost.localdomain>
 <29C1DC0826876849BDD9F1C67ABA2943070F0D92@ala-mail09.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	tipc-discussion@lists.sourceforge.net, davem@davemloft.net
To: "Stephens, Allan" <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44135 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325Ab0BWQJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 11:09:48 -0500
Content-Disposition: inline
In-Reply-To: <29C1DC0826876849BDD9F1C67ABA2943070F0D92@ala-mail09.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2010 at 07:02:16AM -0800, Stephens, Allan wrote:
> Neil wrote:
> 
> > > 2) The other change you made to defer setting tipc_mode to 
> > > TIPC_NET_MODE will cause problems if TIPC has to bail out during 
> > > tipc_net_start() because of problems.  Specifically, the 
> > ensuing call 
> > > to tipc_net_stop() won't get a chance to clean up any partial 
> > > initialization that got done prior to the initialization 
> > problem, which could result in memory leaks.
> > > 
> > > Fortunately, I think there's a relatively easy solution.  
> > Since TIPC 
> > > always needs to call tipc_node_select() in order to send an 
> > off-node 
> > > message, you should be able to add the necessary error 
> > checking there.
> > > I'm thinking of something along the lines of:
> > > 
> > That seems like it might be a problem in and of itself.  If 
> > the startup/shutdown code relies on the state of the 
> > implementation, perhaps that worth cleaning up so as to avoid 
> > a race condition.
> 
> I'm afraid I don't understand what you mean here.  It sounds like you're
> saying that TIPC's code shouldn't rely on the state of its own
> implementation.
> 
Not at all, I'm saying quite the opposite, that TIPC should rely on its own
state, but in its current implementation:

1) It doesn't (i.e. theres no check in the send path for messages that the
internal mode is TIPC_NET_MODE if the destination address is not for the local z.c.n
tuple).

2) It couldn't rely on the internal state if it did check (i.e tipc_net_start
sets tipc_mode to TIPC_NET_MODE prior to initalizing the data structures
required to support sending messages off node).  So een if we did do a check for
being in NET mode prior to sending a message, it would be useless because theres
a window of time where the implementation says its ok to send, but its really
not (thats what caused the above oops).

>  
> > > static inline struct tipc_node *tipc_node_select(u32 addr, u32 
> > > selector) {
> > > 	if (likely(in_own_cluster(addr)))
> > > 		return tipc_local_nodes ?
> > > tipc_local_nodes[tipc_node(addr)] : NULL;
> > > 	return tipc_net->zones ? tipc_node_select_next_hop(addr,
> > > selector) : NULL;
> > > }
> > > 
> > > Please give this a try and let us know how things go.
> > > 
> > I'm happy to give this a try, but I'm a bit concerned by this 
> > approach.  It certainly seems like it will solve the problem 
> > at hand, but it doesn't seem to address the underlying cause, 
> > which is that you can execute code paths which the state of 
> > the implementation doesn't/shouldn't allow.  In other words, 
> > this solve the immediate problem, but it still allows someone 
> > to try send data via tipc before tipc is ready to send data.  
> > It would be nice if we could deal with the larger problem.
> 
> I don't think you've stated the issue correctly.  The problem you
> encountered isn't that TIPC is allowing users to send data before TIPC
> is ready, it's that TIPC is allowing users to send data *off-node*
> before TIPC is ready.  TIPC was deliberately designed so that messages
Well, yes.  Sorry for not being clear.  We only need to check that we're in net
mode if we're not sending to the local node.

> could be sent within the node itself as soon as possible, without having
> to wait for full connectivity to the rest of the network, and this it
My initial patch checked for this:
+       if ((tipc_mode != TIPC_NET_MODE) &&
+           (dest->addr.name.domain != tipc_own_addr))
+               return -EHOSTUNREACH;
+

If we're not in NET mode but the destination is not tipc_own_addr (initialized
to <0.0.0>) we can still send.

> does quite well.  Later, once connectivity to the network is
> established, TIPC allows applications to send data to other nodes, and
> this also appears to work properly providing the applications use TIPC's
> location transparent service naming form of addressing.
> 
Yes, it works fine, as long as user space applications all do the right things,


> What we don't appear to have anticipated is that someone would attempt
> to send messages to another node without first receiving an indication
> from TIPC that the node could be reached.  As far as I can tell, the
> only way that the crash you encountered could be generated would be if
> your application blindly tries to send to a named service on a specified
> node without first waiting for notification that the node exists.
> (Please correct me if I'm wrong about this.)  While this operation is
No, you got that exactly right :).

> certainly legal, including a specific node address in a send operation
> kind of defeats the whole location transparent addressing premise on
> which TIPC is based and I'm wondering if it's really necessary to do
> things this way.  Regardless, the fix I've suggested seems to me to be a

As you said, its perfectly legal, and one of the mandates of the kernel is to
prevent unprivlidged user space applications from taking down the entire system
when they do something stupid.  I completely agree with you that user space is
doing bad things here, but bad things need to result in errors and broken
applications, not crashed systems.

> reasonable way of blocking premature sends off-node while still
> permitting on-node sends to work, and should make everyone happy.
> 
I agree that you patch fixes the exact problem that I reported here, but theres
more to it than that.  A quick grep of the tipc stack reveals the following
symbols:
tipc_bearers
media_list
tipc_local_nodes
bcbearer
bclink
tipc_net.zones

All of these symbols:

1) Are allocated dynamically in tipc_net_start, _after_ tipc_mode is set to
TIPC_NET_MODE

2) dereferenced without NULL pointer checks in either the send path or in the
netlink configuration path, both of which are reachable from user space.

So your patch fixes the last item on your list, but what about the others?  In
fact, I'll bet I can very quickly change the application to trip over a null
tipc_local_nodes dereference by changing the destination address to be something
within zone 0, cluster 0.

I really think the proper solution needs to be modifying the send and control
paths to gate on the internal state, and modify the init/shutdown code to
change state properly.

I'll let you know what I come up with
Neil


