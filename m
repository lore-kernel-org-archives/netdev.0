From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next RFC] pktgen: don't wait for the device who doesn't
	free skb immediately after sent
Date: Thu, 29 Nov 2012 09:21:10 -0800
Message-ID: <20121129092110.465c068d@nehalam.linuxnetplumber.net>
References: <1353916612-6357-1-git-send-email-jasowang@redhat.com>
	<50B5B3D4.1070106@redhat.com>
	<20121128085305.2b0503ce@nehalam.linuxnetplumber.net>
	<1570859.IePPxHAEX1@jason-thinkpad-t430s>
	<20121129113012.GA7866@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20121129113012.GA7866@redhat.com>
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

On Thu, 29 Nov 2012 13:30:13 +0200
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Thu, Nov 29, 2012 at 06:13:13PM +0800, Jason Wang wrote:
> > On Wednesday, November 28, 2012 08:53:05 AM Stephen Hemminger wrote:
> > > On Wed, 28 Nov 2012 14:48:52 +0800
> > > 
> > > Jason Wang <jasowang@redhat.com> wrote:
> > > > On 11/28/2012 12:49 AM, Stephen Hemminger wrote:
> > > > > On Tue, 27 Nov 2012 14:45:13 +0800
> > > > > 
> > > > > Jason Wang <jasowang@redhat.com> wrote:
> > > > >> On 11/27/2012 01:37 AM, Stephen Hemminger wrote:
> > > > >>> On Mon, 26 Nov 2012 15:56:52 +0800
> > > > >>> 
> > > > >>> Jason Wang <jasowang@redhat.com> wrote:
> > > > >>>> Some deivces do not free the old tx skbs immediately after it has
> > > > >>>> been sent
> > > > >>>> (usually in tx interrupt). One such example is virtio-net which
> > > > >>>> optimizes for virt and only free the possible old tx skbs during the
> > > > >>>> next packet sending. This would lead the pktgen to wait forever in
> > > > >>>> the refcount of the skb if no other pakcet will be sent afterwards.
> > > > >>>> 
> > > > >>>> Solving this issue by introducing a new flag IFF_TX_SKB_FREE_DELAY
> > > > >>>> which could notify the pktgen that the device does not free skb
> > > > >>>> immediately after it has been sent and let it not to wait for the
> > > > >>>> refcount to be one.
> > > > >>>> 
> > > > >>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> > > > >>> 
> > > > >>> Another alternative would be using skb_orphan() and skb->destructor.
> > > > >>> There are other cases where skb's are not freed right away.
> > > > >>> --
> > > > >>> To unsubscribe from this list: send the line "unsubscribe netdev" in
> > > > >>> the body of a message to majordomo@vger.kernel.org
> > > > >>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > > >> 
> > > > >> Hi Stephen:
> > > > >> 
> > > > >> Do you mean registering a skb->destructor for pktgen then set and check
> > > > >> bits in skb->tx_flag?
> > > > > 
> > > > > Yes. Register a destructor that does something like update a counter
> > > > > (number of packets pending), then just spin while number of packets
> > > > > pending is over threshold.
> > > > > --
> > > > 
> > > > Not sure this is the best method, since pktgen was used to test the tx
> > > > process of the device driver and NIC. If we use skb_orhpan(), we would
> > > > miss the test of tx completion part.
> > > 
> > > There are other places that delay freeing and your solution would mean
> > > finding and fixing all those. Code that does that already has to use
> > > skb_orphan() to work, and I was looking for a way that could use that.
> > > Introducing another flag value seems like a long term burden.
> > > 
> > 
> > Get the point, will draft another version.
> >
> > > Alternatively, virtio could do cleanup more aggressively. Maybe in response
> > > to ring getting half full, or add a cleanup timer or something to avoid the
> > > problem.
> 
> Timer would prevent complete deadlock but it is very expensive
> in the virt scenario.
> pulling at ring half full would only help if ring gets half full :)
> which it does not have to.

A timer that fires once (when idle) to mop up the last packet in a stream
would be not very expensive. Most of the time, it would just be continually
rescheduled.
