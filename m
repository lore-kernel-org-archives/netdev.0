From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: SKB paged fragment lifecycle on receive
Date: Mon, 27 Jun 2011 14:19:43 +0300
Message-ID: <20110627111942.GD12978@redhat.com>
References: <1308930202.32717.144.camel@zakaz.uk.xensource.com>
	<20110626102543.GA4961@redhat.com>
	<1309167695.32717.181.camel@zakaz.uk.xensource.com>
	<20110627102129.GB12978@redhat.com>
	<1309172042.32717.199.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	"mashirle@us.ibm.com" <mashirle@us.ibm.com>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
Content-Disposition: inline
In-Reply-To: <1309172042.32717.199.camel@zakaz.uk.xensource.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 27, 2011 at 11:54:02AM +0100, Ian Campbell wrote:
> On Mon, 2011-06-27 at 11:21 +0100, Michael S. Tsirkin wrote:
> > On Mon, Jun 27, 2011 at 10:41:35AM +0100, Ian Campbell wrote:
> > > On Sun, 2011-06-26 at 11:25 +0100, Michael S. Tsirkin wrote:
> > > > On Fri, Jun 24, 2011 at 04:43:22PM +0100, Ian Campbell wrote:
> > > > > In this mode guest data pages ("foreign pages") were mapped into the
> > > > > backend domain (using Xen grant-table functionality) and placed into the
> > > > > skb's paged frag list (skb_shinfo(skb)->frags, I hope I am using the
> > > > > right term). Once the page is finished with netback unmaps it in order
> > > > > to return it to the guest (we really want to avoid returning such pages
> > > > > to the general allocation pool!).
> > > > 
> > > > Are the pages writeable by the source guest while netback processes
> > > > them?  If yes, firewalling becomes unreliable as the packet can be
> > > > modified after it's checked, right?
> > > 
> > > We only map the paged frags, the linear area is always copied (enough to
> > > cover maximally sized TCP/IP, including options), for this reason.
> > 
> > Hmm. That'll cover the most common scenarios
> > (such as port filtering) but not deep inspection.
> 
> Right.
> 
> > Not sure how important that is.
> > 
> > > > Also, for guest to guest communication, do you wait for
> > > > the destination to stop looking at the packet in order
> > > > to return it to the source? If yes, can source guest
> > > > networking be disrupted by a slow destination?
> > > 
> > > There is a timeout which ultimately does a copy into dom0 memory and
> > > frees up the domain grant for return to the sending guest.
> > 
> > Interesting. How long's the timeout?
> 
> 1 second IIRC.

I think that's unlikely to prevent networking disruption, only
complete loss of networking.

> > > I suppose one difference with this is that it deals with data from
> > > "dom0" userspace buffers rather than (what looks like) kernel memory,
> > > although I don't know if that matters yet. Also it hangs off of struct
> > > sock which netback doesn't have. Anyway I'll check it out.
> > 
> > I think the most important detail is the copy on clone approach.
> > We can make it controlled by an skb flag if necessary.
> > 
> > > > > but IIRC honouring it universally turned into a
> > > > > very twisty maze with a number of nasty corner cases etc.
> > > > 
> > > > Any examples? Are they covered by the patchset above?
> > > 
> > > It was quite a while ago so I don't remember many of the specifics.
> > > Jeremy might remember better but for example any broadcast traffic
> > > hitting a bridge (a very interesting case for Xen), seems like a likely
> > > case? pcap was another one which I do remember, but that's obviously
> > > less critical.
> > 
> > Last I looked I thought these clone the skb, so if a copy happens on
> > clone things will work correctly?
> 
> Things should be correct, but won't necessarily perform well.
> 
> In particular if the clones (which become copies with this flag) are
> frequent enough then there is no advantage to doing mapping instead of
> just copying upfront, in fact it probably hurts overall.

True. Further, the CPU used up by the copy isn't accounted for in the
appropriate cgroup.

> Taking a quick look at the callers of skb_clone I also see skb_segment
> in there. Since Xen tries to pass around large skbs (using LRO/GSO over
> the PV interface) in order to amortise costs it is quite common for
> things to undergo GSO as they hit the physical device. I'm not sure if
> these commonly hit the specific code path which causes a clone though.

Probably not, I think this patchset was tested with GSO as well.

> > > I presume with the TX zero-copy support the "copying due to attempted
> > > clone" rate is low?
> > 
> > Yes. My understanding is that this version targets a non-bridged setup
> > (guest connected to a macvlan on a physical dev) as the first step.
> 
> OK.
> 
> > > > > FWIW I proposed a session on the subject for LPC this year.
> > > > We also plan to discuss this on kvm forum 2011
> > > > (colocated with linuxcon 2011).
> > > > http://www.linux-kvm.org/page/KVM_Forum_2011
> > > 
> > > I had already considered coming to LinuxCon for other reasons but
> > > unfortunately I have family commitments around then :-(
> 
> > And I'm not coming to LPC this year :(
> 
> That's a shame.
> 
> Ian.
> 
