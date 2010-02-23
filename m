From: "Stephens, Allan" <allan.stephens@windriver.com>
Subject: Re: [PATCH]: tipc: Fix oops on send prior to
	entering networked mode
Date: Tue, 23 Feb 2010 07:02:16 -0800
Message-ID: <29C1DC0826876849BDD9F1C67ABA2943070F0D92@ala-mail09.corp.ad.wrs.com>
References: <20100219194033.GA28743@hmsreliant.think-freely.org>
	<29C1DC0826876849BDD9F1C67ABA29430705EF62@ala-mail09.corp.ad.wrs.com>
	<20100223011116.GA2021@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, davem@davemloft.net
To: "Neil Horman" <nhorman@tuxdriver.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
Content-class: urn:content-classes:message
In-Reply-To: <20100223011116.GA2021@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Neil wrote:

> > 2) The other change you made to defer setting tipc_mode to 
> > TIPC_NET_MODE will cause problems if TIPC has to bail out during 
> > tipc_net_start() because of problems.  Specifically, the 
> ensuing call 
> > to tipc_net_stop() won't get a chance to clean up any partial 
> > initialization that got done prior to the initialization 
> problem, which could result in memory leaks.
> > 
> > Fortunately, I think there's a relatively easy solution.  
> Since TIPC 
> > always needs to call tipc_node_select() in order to send an 
> off-node 
> > message, you should be able to add the necessary error 
> checking there.
> > I'm thinking of something along the lines of:
> > 
> That seems like it might be a problem in and of itself.  If 
> the startup/shutdown code relies on the state of the 
> implementation, perhaps that worth cleaning up so as to avoid 
> a race condition.

I'm afraid I don't understand what you mean here.  It sounds like you're
saying that TIPC's code shouldn't rely on the state of its own
implementation.

 
> > static inline struct tipc_node *tipc_node_select(u32 addr, u32 
> > selector) {
> > 	if (likely(in_own_cluster(addr)))
> > 		return tipc_local_nodes ?
> > tipc_local_nodes[tipc_node(addr)] : NULL;
> > 	return tipc_net->zones ? tipc_node_select_next_hop(addr,
> > selector) : NULL;
> > }
> > 
> > Please give this a try and let us know how things go.
> > 
> I'm happy to give this a try, but I'm a bit concerned by this 
> approach.  It certainly seems like it will solve the problem 
> at hand, but it doesn't seem to address the underlying cause, 
> which is that you can execute code paths which the state of 
> the implementation doesn't/shouldn't allow.  In other words, 
> this solve the immediate problem, but it still allows someone 
> to try send data via tipc before tipc is ready to send data.  
> It would be nice if we could deal with the larger problem.

I don't think you've stated the issue correctly.  The problem you
encountered isn't that TIPC is allowing users to send data before TIPC
is ready, it's that TIPC is allowing users to send data *off-node*
before TIPC is ready.  TIPC was deliberately designed so that messages
could be sent within the node itself as soon as possible, without having
to wait for full connectivity to the rest of the network, and this it
does quite well.  Later, once connectivity to the network is
established, TIPC allows applications to send data to other nodes, and
this also appears to work properly providing the applications use TIPC's
location transparent service naming form of addressing.

What we don't appear to have anticipated is that someone would attempt
to send messages to another node without first receiving an indication
from TIPC that the node could be reached.  As far as I can tell, the
only way that the crash you encountered could be generated would be if
your application blindly tries to send to a named service on a specified
node without first waiting for notification that the node exists.
(Please correct me if I'm wrong about this.)  While this operation is
certainly legal, including a specific node address in a send operation
kind of defeats the whole location transparent addressing premise on
which TIPC is based and I'm wondering if it's really necessary to do
things this way.  Regardless, the fix I've suggested seems to me to be a
reasonable way of blocking premature sends off-node while still
permitting on-node sends to work, and should make everyone happy.

 
> I'll let you know how the above patch goes.

Thanks,
Al 

------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
