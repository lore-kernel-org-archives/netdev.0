From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next RFC] pktgen: don't wait for the device who doesn't
	free skb immediately after sent
Date: Mon, 3 Dec 2012 08:01:11 -0800
Message-ID: <20121203080111.74acf7d7@nehalam.linuxnetplumber.net>
References: <1353916612-6357-1-git-send-email-jasowang@redhat.com>
	<50B46179.4040809@redhat.com>
	<20121127084919.1587c647@nehalam.linuxnetplumber.net>
	<2663254.1vRFru9xhh@jason-thinkpad-t430s>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <2663254.1vRFru9xhh@jason-thinkpad-t430s>
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

On Mon, 03 Dec 2012 14:45:46 +0800
Jason Wang <jasowang@redhat.com> wrote:

> On Tuesday, November 27, 2012 08:49:19 AM Stephen Hemminger wrote:
> > On Tue, 27 Nov 2012 14:45:13 +0800
> > 
> > Jason Wang <jasowang@redhat.com> wrote:
> > > On 11/27/2012 01:37 AM, Stephen Hemminger wrote:
> > > > On Mon, 26 Nov 2012 15:56:52 +0800
> > > > 
> > > > Jason Wang <jasowang@redhat.com> wrote:
> > > >> Some deivces do not free the old tx skbs immediately after it has been
> > > >> sent
> > > >> (usually in tx interrupt). One such example is virtio-net which
> > > >> optimizes for virt and only free the possible old tx skbs during the
> > > >> next packet sending. This would lead the pktgen to wait forever in the
> > > >> refcount of the skb if no other pakcet will be sent afterwards.
> > > >> 
> > > >> Solving this issue by introducing a new flag IFF_TX_SKB_FREE_DELAY
> > > >> which could notify the pktgen that the device does not free skb
> > > >> immediately after it has been sent and let it not to wait for the
> > > >> refcount to be one.
> > > >> 
> > > >> Signed-off-by: Jason Wang <jasowang@redhat.com>
> > > > 
> > > > Another alternative would be using skb_orphan() and skb->destructor.
> > > > There are other cases where skb's are not freed right away.
> > > > --
> > > > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > > > the body of a message to majordomo@vger.kernel.org
> > > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > 
> > > Hi Stephen:
> > > 
> > > Do you mean registering a skb->destructor for pktgen then set and check
> > > bits in skb->tx_flag?
> > 
> > Yes. Register a destructor that does something like update a counter (number
> > of packets pending), then just spin while number of packets pending is over
> > threshold.
> 
> Have some experiments on this, looks like it does not work weel when clone_skb 
> is used. For driver that call skb_orphan() in ndo_start_xmit, the destructor 
> is only called when the first packet were sent, but what we need to know is 
> when the last were sent. Any thoughts on this or we can just introduce another 
> flag (anyway we have something like IFF_TX_SKB_SHARING) ?
> 

The SKB_SHARING flag looks like the best solution then.
Surprisingly, transmit buffer completion is a major bottleneck for 10G
devices, and I suspect more changes will come.
