From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 net 1/2] drivers/net: Disable UFO through virtio
Date: Sun, 23 Nov 2014 12:33:39 +0200
Message-ID: <20141123103339.GA25224@redhat.com>
References: <1414693592.16849.61.camel@decadent.org.uk>
	<1414693632.16849.62.camel@decadent.org.uk>
	<20141119091455.GA26036@redhat.com>
	<1416595612.7215.21.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Hannes Frederic Sowa <hannes@stressinduktion.org>,
	virtualization@lists.linux-foundation.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1416595612.7215.21.camel@decadent.org.uk>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 21, 2014 at 06:46:52PM +0000, Ben Hutchings wrote:
> On Wed, 2014-11-19 at 11:14 +0200, Michael S. Tsirkin wrote:
> > On Thu, Oct 30, 2014 at 06:27:12PM +0000, Ben Hutchings wrote:
> > > IPv6 does not allow fragmentation by routers, so there is no
> > > fragmentation ID in the fixed header.  UFO for IPv6 requires the ID to
> > > be passed separately, but there is no provision for this in the virtio
> > > net protocol.
> > > 
> > > Until recently our software implementation of UFO/IPv6 generated a new
> > > ID, but this was a bug.  Now we will use ID=0 for any UFO/IPv6 packet
> > > passed through a tap, which is even worse.
> > > 
> > > Unfortunately there is no distinction between UFO/IPv4 and v6
> > > features, so disable UFO on taps and virtio_net completely until we
> > > have a proper solution.
> > > 
> > > We cannot depend on VM managers respecting the tap feature flags, so
> > > keep accepting UFO packets but log a warning the first time we do
> > > this.
> > > 
> > > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> > > Fixes: 916e4cf46d02 ("ipv6: reuse ip6_frag_id from ip6_ufo_append_data")
> > 
> > 
> > There's something I don't understand here. I see:
> > 
> >         NETIF_F_UFO_BIT,                /* ... UDPv4 fragmentation */
> > 
> > this comment is wrong then?
> 
> Yes.
> 
> > The patches drastically regress performance for UDPv4 for VMs only, but
> > isn't it likely many other devices based their code on this comment?
> 
> There's only one hardware driver that implements UFO (s2io), and it does
> handle IPv6.
> 
> > How about we disable UFO for IPv6 globally, and put the
> > flag back in?
> > We can then gradually add NETIF_F_UFO6_BIT for devices that
> > actually support UFO for IPv6.
> 
> Since the corresponding virtio feature bit is understood to include
> UFO/IPv6, and existing VMs rely on that, I don't see what this solves.
> 
> Ben.


I'm confused. Patching virtio has 0 effect on existing VMs - they
are running old drivers anyway.

Here's the proposal for guest side:

- Add NETIF_F_UFO6_BIT, set in s2io.
- Teach IPv6 to check NETIF_F_UFO6_BIT and not NETIF_F_UFO_BIT.

What is accomplishes is good speed for virtio with UDP over IPv4,
and correct, slower transmission for IPv6.

Of course this does not help old guests but your patch
to which I'm replying doesn't affect old guests either.

Or did I miss something?

> -- 
> Ben Hutchings
> Beware of bugs in the above code;
> I have only proved it correct, not tried it. - Donald Knuth
