From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: netfilter: nf_conntrack: add support for "conntrack zones"
Date: Thu, 14 Jan 2010 12:33:23 -0500
Message-ID: <1263490403.23480.109.camel@bigi>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>
	 <4B4F3A50.1050400@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Ben Greear <greearb@candelatech.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B4F3A50.1050400@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-01-14 at 16:37 +0100, Patrick McHardy wrote:
> jamal wrote:

> > Agreed that this would be a main driver of such a feature.
> > Which means that you need zones (or whatever noun other people use) to
> > work on not just netfilter, but also routing, ipsec etc.
> 
> Routing already works fine. I believe IPsec should also work already,
> but I haven't tried it.

maybe further discussion  would clarify this point..

> The zone is set based on some other criteria (in this case the
> incoming device).

If you are using a netdev as a reference point, then I take it 
if you add vlans should be possible to do multiple zones on a single
physical netdev? Or is there some other way to satisfy that?

>  The packets make one pass through the stack
> to a veth device and are SNATed in POSTROUTING to non-clashing
> addresses. 

Ok - makes sense. 
i.e NAT would work; and policy routing as well as arp would be fine.
Also it looks to be sufficiently useful to fit a specific use case you
are interested in.
But back to my question on routing, ipsec etc (and you may not be
interested in solving this problem, but it is what i was getting to
earlier). Lets take for example: 
a) network tables like SAD/SPD tables: how you would separate those on a
per-zone basis? i.e 10.0.0.1/zone1 could use different
policy/association than 10.0.0.1/zone2
b) dynamic protocols (routing, IKE etc): how do you do that without 
making both sides understand what is going on?

> > This is a valid concern against the namespace approach. Existing tools
> > of course could be taught to know about namespaces - and one could
> > argue that if you can resolve the overlap IP address issue, then you
> > _have to_ modify user space anyways.
> 
> I don't think thats true. 

Refer to my statements above for an example.

> In any case its completely impractical
> to modify every userspace tool that does something with networking
> and potentially make complex configuration changes to have all
> those namespaces interact nicely. 

Agreed. But the major ones like iproute2 etc could be taught. We have
namespaces in the kernel already, over a period of time I think changing
the user space tools would a sensible evolution.

> Currently they are simply not
> very well suited for virtualizing selected parts of networking.

My contention is that it is a lot less headache to just virtualize 
all the network stack and then use what you want than it is to go and
selectively changing the network objects.
Note: if i wanted today i could run racoon on every namespace 
unchanged and it would work or i could modify racoon to understand
namespaces...

> I'm not sure whether there is a typical user for overlapping
> networks :) I know of setups with ~150 overlapping networks.
> 
> The number of conntracks per zone doesn't matter since the
> table is shared between all zones. network namespaces would
> allocate 150 tables, each of the same size, which might be
> quite large.

Thats what i was looking for ..
So the difference, to pick the 150 zones example so as to put a number
around it, is namespaces will consume 150.X bytes (where X is the
overhead of a conntrack table) and you approach will be (X + 152) bytes,
correct?
What is the typical sizeof X?

> > You may also wanna look as a metric at code complexity/maintainability
> > of this scheme vs namespace (which adds zero changes to the kernel).
> 
> There's not a lot of complexity, its basically passing a numeric
> identifier around in a few spots and comparing it. Something like
> TOS handling in the routing code.

I think the challenge is whether zones will have to encroach on other
net stack objects or not. You are already touching structure netdev...
A digression: TOS is different really - it has network level semantic. This 
would be more like mark or in some cases ifindex (i.e local semantics)
 
> > BTW, why not use skb->mark instead of creating a new semantic construct?
> 
> Because people are already using it for different purposes.

tru dat - it only gives you one semantical axis and you need an
additional dimension in your case (namespace have that resolved via
struct net).

cheers,
jamal

