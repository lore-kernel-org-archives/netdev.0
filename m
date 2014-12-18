From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 01/10] core: Split out UFO6 support
Date: Thu, 18 Dec 2014 19:50:02 +0200
Message-ID: <20141218175002.GA5539@redhat.com>
References: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
	<1418840455-22598-2-git-send-email-vyasevic@redhat.com>
	<20141217224553.GE30969@redhat.com> <54921266.30300@redhat.com>
	<20141218075409.GA31702@redhat.com> <5492EC4F.5080303@redhat.com>
	<20141218173546.GB5425@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vladislav Yasevich <vyasevich@gmail.com>,
	virtualization@lists.linux-foundation.org, stefanha@redhat.com,
	ben@decadent.org.uk, David Miller <davem@davemloft.net>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20141218173546.GB5425@redhat.com>
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

On Thu, Dec 18, 2014 at 07:35:46PM +0200, Michael S. Tsirkin wrote:
> > > We should either generate our own ID,
> > > like we always did, or make sure we don't accept
> > > these packets.
> > > Second option is almost sure to break userspace,
> > > so it seems we must do the first one.
> > > 
> > 
> > Right.  This was missing from packet sockets.  I can fix it.
> > 
> > -vlad
> 
> Also, this can't be a patch on top, since we don't
> want bisect to give us configurations which
> can BUG().

So how doing this in stages:

1. add helper that checks skb GSO type.
If it is SKB_GSO_UDP, check for IPv6, and
generate the fragment ID.

Call this helper in
	- virtio net rx path
	- tun rx path (get user)
	- macvtap tx patch (get user)
	- packet socket tx patch (get user)

2. Put back UFO flag everywhere: virtio,tun,macvtap,packet,
since we can handle IPv6 now even if it's suboptimal.

Above two seem like smalling patches, appropriate for stable.

Next, work on a new feature to pass
fragment ID in virtio header:

3. split UFO/UFO6 as you did here, but add code
in above 4 places to convert UDP to UDP6,
additionally, add code in
	- virtio net tx path
	- tun tx path (get user)
	- macvtap rx patch (put user)
	- packet socket rx patch (put user)
to convert UDP6 to UDP.

	step 3 needs to be bisect-clean, somehow.

4. add new field in header, new feature bit for virtio net to gate it,
new ioctls to tun,macvtap,packet socket.

These two are more like optimizations, so not stable material.


-- 
MST
