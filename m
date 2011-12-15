From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [net-next RFC PATCH 0/5] Series short description
Date: Fri, 16 Dec 2011 09:42:19 +1030
Message-ID: <87mxatqvjg.fsf@rustcorp.com.au>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
	<87ty5cj0sw.fsf@rustcorp.com.au> <4EDF4E82.7050201@redhat.com>
	<1323277324.2728.34.camel@bwh-desktop>
	<87r50efgza.fsf@rustcorp.com.au>
	<1323913005.2753.47.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, davem@redhat.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1323913005.2753.47.camel@bwh-desktop>
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

On Thu, 15 Dec 2011 01:36:44 +0000, Ben Hutchings <bhutchings@solarflare.com> wrote:
> On Fri, 2011-12-09 at 16:01 +1030, Rusty Russell wrote:
> > On Wed, 7 Dec 2011 17:02:04 +0000, Ben Hutchings <bhutchings@solarflare.com> wrote:
> > > Most multi-queue controllers could support a kind of hash-based
> > > filtering for TCP/IP by adjusting the RSS indirection table.  However,
> > > this table is usually quite small (64-256 entries).  This means that
> > > hash collisions will be quite common and this can result in reordering.
> > > The same applies to the small table Jason has proposed for virtio-net.
> > 
> > But this happens on real hardware today.  Better that real hardware is
> > nice, but is it overkill?
> 
> What do you mean, it happens on real hardware today?  So far as I know,
> the only cases where we have dynamic adjustment of flow steering are in
> ixgbe (big table of hash filters, I think) and sfc (perfect filters).
> I don't think that anyone's currently doing flow steering with the RSS
> indirection table.  (At least, not on Linux.  I think that Microsoft was
> intending to do so on Windows, but I don't know whether they ever did.)

Thanks, I missed the word "could".

> > And can't you reorder even with perfect matching, since prior packets
> > will be on the old queue and more recent ones on the new queue?  Does it
> > discard or requeue old ones?  Or am I missing a trick?
> 
> Yes, that is possible.  RFS is careful to avoid such reordering by only
> changing the steering of a flow when none of its packets can be in a
> software receive queue.  It is not generally possible to do the same for
> hardware receive queues.  However, when the first condition is met it is
> likely that there won't be a whole lot of packets for that flow in the
> hardware receive queue either.  (But if there are, then I think as a
> side-effect of commit 09994d1 RFS will repeatedly ask the driver to
> steer the flow.  Which isn't ideal.)

Should be easy to test, but the question is, how hard should we fight to
maintain ordering?  Dave?

It comes down to this.  We can say in the spec that a virtio nic which
offers VIRTIO_F_NET_RFS:

1) Must do a perfect matching, with perfect ordering.  This means you need
   perfect filters, and handle inter-queue ordering if you change a
   filter (requeue packets?)
2) Must do a perfect matching, but don't worry about ordering across changes.
3) Best effort matching, with perfect ordering.
3) Best effort matching, best effort ordering.

For a perfect filtering setup, the virtio nic needs to either say how
many filter slots it has, or have a way to fail an RFS request.  For
best effort, you can simply ignore RFS requests or accept hash
collisions, without bothering the guest driver at all.

Thanks,
Rusty.
