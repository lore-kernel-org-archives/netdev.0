From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: SKB paged fragment lifecycle on receive
Date: Mon, 27 Jun 2011 10:41:35 +0100
Message-ID: <1309167695.32717.181.camel@zakaz.uk.xensource.com>
References: <1308930202.32717.144.camel@zakaz.uk.xensource.com>
	<20110626102543.GA4961@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mashirle@us.ibm.com" <mashirle@us.ibm.com>,
	Russell <rusty@rustcorp.com.au>, Rusty
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <20110626102543.GA4961@redhat.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Sun, 2011-06-26 at 11:25 +0100, Michael S. Tsirkin wrote:
> On Fri, Jun 24, 2011 at 04:43:22PM +0100, Ian Campbell wrote:
> > In this mode guest data pages ("foreign pages") were mapped into the
> > backend domain (using Xen grant-table functionality) and placed into the
> > skb's paged frag list (skb_shinfo(skb)->frags, I hope I am using the
> > right term). Once the page is finished with netback unmaps it in order
> > to return it to the guest (we really want to avoid returning such pages
> > to the general allocation pool!).
> 
> Are the pages writeable by the source guest while netback processes
> them?  If yes, firewalling becomes unreliable as the packet can be
> modified after it's checked, right?

We only map the paged frags, the linear area is always copied (enough to
cover maximally sized TCP/IP, including options), for this reason.

> Also, for guest to guest communication, do you wait for
> the destination to stop looking at the packet in order
> to return it to the source? If yes, can source guest
> networking be disrupted by a slow destination?

There is a timeout which ultimately does a copy into dom0 memory and
frees up the domain grant for return to the sending guest.

> > Jeremy Fitzhardinge and I subsequently
> > looked at the possibility of a no-clone skb flag (i.e. always forcing a
> > copy instead of a clone)
> 
> I think this is the approach that the patchset
> 'macvtap/vhost TX zero-copy support' takes.

That's TX from the guests PoV, the same as I am looking at here,
correct?

I should definitely check this work out, thanks for the pointer. Is V7
(http://marc.info/?l=linux-kernel&m=130661128431312&w=2) the most recent
posting?

I suppose one difference with this is that it deals with data from
"dom0" userspace buffers rather than (what looks like) kernel memory,
although I don't know if that matters yet. Also it hangs off of struct
sock which netback doesn't have. Anyway I'll check it out.

> > but IIRC honouring it universally turned into a
> > very twisty maze with a number of nasty corner cases etc.
> 
> Any examples? Are they covered by the patchset above?

It was quite a while ago so I don't remember many of the specifics.
Jeremy might remember better but for example any broadcast traffic
hitting a bridge (a very interesting case for Xen), seems like a likely
case? pcap was another one which I do remember, but that's obviously
less critical.

I presume with the TX zero-copy support the "copying due to attempted
clone" rate is low?

> > FWIW I proposed a session on the subject for LPC this year.
> We also plan to discuss this on kvm forum 2011
> (colocated with linuxcon 2011).
> http://www.linux-kvm.org/page/KVM_Forum_2011

I had already considered coming to LinuxCon for other reasons but
unfortunately I have family commitments around then :-(

Ian.
