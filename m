From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/4] deferred drop, __parent workaround, reshape_fail
Date: 25 Aug 2004 08:12:05 -0400
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <1093435925.1039.221.camel@jzny.localdomain>
References: <411C0FCE.9060906@crocetta.org>
	<1092401484.1043.30.camel@jzny.localdomain>
	<411CCB98.4080904@crocetta.org>
	<1092518370.2876.3.camel@jzny.localdomain>
	<20040816073530.GI15418@sunbeam2>
	<1092662998.2874.102.camel@jzny.localdomain>
	<20040824185703.GP26877@sunbeam.de.gnumonks.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: sandr8@crocetta.org, devik@cdi.cz, netfilter-devel@lists.netfilter.org,
	netdev@oss.sgi.com
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040824185703.GP26877@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Tue, 2004-08-24 at 14:57, Harald Welte wrote:
> On Mon, Aug 16, 2004 at 09:29:59AM -0400, jamal wrote:

> Yes, I am working on the next generation of ulogd (ulogd-2).  It will
> allow you to stack multiple plugins on top of each other, such as:
> 
> ctnetlink -> ipfix
> 
> or 
> 
> ulog -> packet parser -> flow_aggrgation -> ipfix 
> 
> or even exporting per-packet data in ipfix 
> 
> ulog -> packet parser -> ipfix
> 
> It's far from complete, but I'm almost finished with the core and can
> start to write the plugins:
> http://svn.gnumonks.org/branches/ulog/ulogd2/

cool. Looks nice.

> > Let me think about it.
> > Clearly the best place to account for things is on the wire once the
> > packet has left the box ;-> 
> 
> This is arguable.  Why not once the packet was receieved on the incoming
> wire?  If you are Ingress router of your network, your ISP bills you for
> the amout of traffic it sends to your ingress router.
> 
> OTOTH, for egress traffic I agree.

I think maybe the issue is to define what the end goal is.
For a passive box getting copies of the packets on the wire, ingress 
would be fine. Unfairness would still be there incase the forwarding
box (not the accounting box) actually immediately drops the packet
that has already been accounted for.
OTOH, in what you have introduced you are also accounting for
localy generated packets in a box that is not dedicatedfor just
accounting.
In such a case, we can (if the cost of making the change is acceptable)
make more intelligent decisions.

> > How open are you to move accounting further down? My thoughts
> > are along the lines of incrementing the contrack counters at the qdisc
> > level. Since you transport after the structure has been deleted, it
> > should work out fine and fair billing will be taken care of.
> 
> Sure, it can be done... but you need to grab ip_conntrack_lock in order
> to do so.

Suggestion is you just do the marking, let the qdisc do the accounting
on possibly independent accounting table with much more fine grained
locks.

> > Has someone done experimented and figured how expensive it would be to
> > do it at the qdisc level? Note, you can probably have a low level
> > grained lock just for stats.
> 
> It doesn't help.  Currently we still have one global rwlock for all
> conntrack's.  There are patches for per-bucket locking.  
> 
> But well, as long as the usage count of ip_conntrack doesn't drop to
> zero (which we're guaranteed since our skb still references it), and we
> don't need to walk the hash table, we don't actually need to grab
> ip_conntrack_lock.   A seperate accounting lock would be possible.
> 
> Somebody needs to implement this and run profiles...
> 

We should probably avoid this approach totaly if we are going to do all
that work.

> > INC_STATS is generic (goes in the generic stats code in attached patch)
> > and will have an ifdef for contrack billing (which includes unbilling
> > depending on reason code). Reason code could be results that are now
> > returned.
> > As an example NET_XMIT_DROP is definetely unbilling while
> > NET_XMIT_SUCCESS implies bill. 
> 
> sounds fine to me.  But this basically means that we would hide
> conntrack counters behind generic API - the counters themselves are
> stored in our own data structure.
> 

yes, that would also be a good starting compromise. 
I am begining to question the wisdom of "fixing" this. The clear
solution is to have the contracking code do nothing other
than mark the packets. This is the most valuable thing we can
get out of contracking. Let the tc bits do the accounting. You can still
transport this over ctnetlink. There will somehow need to be signaling
as well from contrack to indicate addition or deletion of marks (other
alternative is to have admin select marks).

Of course all this is a big bait so we can have the energetic Alessandro
do all the work ;-> <wink, wink>

cheers,
jamal

 
