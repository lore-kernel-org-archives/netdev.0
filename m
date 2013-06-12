From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 0/2] fix kernel crash with macvtap on top of LRO
Date: Wed, 12 Jun 2013 22:00:33 +0300
Message-ID: <20130612190033.GB3462@redhat.com>
References: <1360193660.32217.39.camel@deadeye.wl.decadent.org.uk>
	<1360207111.28557.47.camel@edumazet-glaptop>
	<1360254046.3605.8.camel@bwh-desktop.uk.solarflarecom.com>
	<20130207.131420.1211188723341167971.davem@davemloft.net>
	<20130610070710.GA673@redhat.com>
	<1371048996.1894.15.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1371048996.1894.15.camel@bwh-desktop.uk.level5networks.com>
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

On Wed, Jun 12, 2013 at 03:56:36PM +0100, Ben Hutchings wrote:
> On Mon, 2013-06-10 at 10:07 +0300, Michael S. Tsirkin wrote:
> > On Thu, Feb 07, 2013 at 01:14:20PM -0500, David Miller wrote:
> > > From: Ben Hutchings <bhutchings@solarflare.com>
> > > Date: Thu, 7 Feb 2013 16:20:46 +0000
> > > 
> > > > If the consensus is still that we must preserve packets exactly (aside
> > > > from the usual modifications by IP routers) then LRO should be disabled
> > > > on all devices for which forwarding is enabled.
> > > 
> > > I believe this is still undoubtedly the consensus.
> > 
> > With virtio we are getting packets from a linux host,
> > so we could thinkably preserve packets exactly
> > even with LRO. I am guessing other hardware could be
> > doing this as well.
> > 
> > I am not sure what information would need to be preserved -
> > could someone help clarify please?
> 
> Some LRO implementations may not preserve:
> 
> - Packet boundaries
>   - TSO/GSO produces packets all the same size, except possibly for the
>     last one.  GRO therefore flushes a flow after merging a packet with
>     a different segment size.
> - IPv4 TTL, IPv6 hop-limit, TCP timestamp
>   - TSO/GSO will put the same values in all packets.  GRO flushes a flow
>     if they change.
> - IPv4 fragment ID
>   - TSO/GSO produces consecutive fragment IDs.  GRO flushes a flow
>     if it sees a non-consecutive fragment ID.
> - MAC header, IPv4 TOS, IPv6 traffic class
>   - Should be the same for all packets in a flow.  GRO actually checks
>     and flushes a flow if they change.
> 
> Ben.

Thanks!

Okay so since LRO in virtio is actually running on top
of GRO/TSO in linux, looks like the only things worth preserving
that we don't preserve at the moment are the packet
boundaries, for which it's enough to report
the first segment size to guest - we have the total length,
from that we can calculate the last segment size.

> -- 
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
