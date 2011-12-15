From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next RFC PATCH 0/5] Series short description
Date: Thu, 15 Dec 2011 01:36:44 +0000
Message-ID: <1323913005.2753.47.camel@bwh-desktop>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
	<87ty5cj0sw.fsf@rustcorp.com.au>  <4EDF4E82.7050201@redhat.com>
	<1323277324.2728.34.camel@bwh-desktop> <87r50efgza.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <87r50efgza.fsf@rustcorp.com.au>
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

On Fri, 2011-12-09 at 16:01 +1030, Rusty Russell wrote:
> On Wed, 7 Dec 2011 17:02:04 +0000, Ben Hutchings <bhutchings@solarflare.com> wrote:
> > Solarflare controllers (sfc driver) have 8192 perfect filters for
> > TCP/IPv4 and UDP/IPv4 which can be used for flow steering.  (The filters
> > are organised as a hash table, but matched based on 5-tuples.)  I
> > implemented the 'accelerated RFS' interface in this driver.
> > 
> > I believe the Intel 82599 controllers (ixgbe driver) have both
> > hash-based and perfect filter modes and the driver can be configured to
> > use one or the other.  The driver has its own independent mechanism for
> > steering RX and TX flows which predates RFS; I don't know whether it
> > uses hash-based or perfect filters.
> 
> Thanks for this summary (and Jason, too).  I've fallen a long way behind
> NIC state-of-the-art.
>  
> > Most multi-queue controllers could support a kind of hash-based
> > filtering for TCP/IP by adjusting the RSS indirection table.  However,
> > this table is usually quite small (64-256 entries).  This means that
> > hash collisions will be quite common and this can result in reordering.
> > The same applies to the small table Jason has proposed for virtio-net.
> 
> But this happens on real hardware today.  Better that real hardware is
> nice, but is it overkill?

What do you mean, it happens on real hardware today?  So far as I know,
the only cases where we have dynamic adjustment of flow steering are in
ixgbe (big table of hash filters, I think) and sfc (perfect filters).
I don't think that anyone's currently doing flow steering with the RSS
indirection table.  (At least, not on Linux.  I think that Microsoft was
intending to do so on Windows, but I don't know whether they ever did.)

> And can't you reorder even with perfect matching, since prior packets
> will be on the old queue and more recent ones on the new queue?  Does it
> discard or requeue old ones?  Or am I missing a trick?

Yes, that is possible.  RFS is careful to avoid such reordering by only
changing the steering of a flow when none of its packets can be in a
software receive queue.  It is not generally possible to do the same for
hardware receive queues.  However, when the first condition is met it is
likely that there won't be a whole lot of packets for that flow in the
hardware receive queue either.  (But if there are, then I think as a
side-effect of commit 09994d1 RFS will repeatedly ask the driver to
steer the flow.  Which isn't ideal.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
