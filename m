From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] macvtap: Fix macvtap_get_queue to use rxhash first
Date: Thu, 24 Nov 2011 18:14:31 +0200
Message-ID: <20111124161430.GC26770@redhat.com>
References: <20111124081714.26635.68141.sendpatchset@krkumar2.in.ibm.com>
	<20111124095902.GD14491@redhat.com> <4ECE18D5.3060605@redhat.com>
	<20111124103449.GA16031@redhat.com> <4ECE3F0D.3090908@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2@in.ibm.com>, arnd@arndb.de, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, davem@davemloft.net
To: jasowang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <4ECE3F0D.3090908@redhat.com>
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

On Thu, Nov 24, 2011 at 08:56:45PM +0800, jasowang wrote:
> On 11/24/2011 06:34 PM, Michael S. Tsirkin wrote:
> >On Thu, Nov 24, 2011 at 06:13:41PM +0800, jasowang wrote:
> >>On 11/24/2011 05:59 PM, Michael S. Tsirkin wrote:
> >>>On Thu, Nov 24, 2011 at 01:47:14PM +0530, Krishna Kumar wrote:
> >>>>It was reported that the macvtap device selects a
> >>>>different vhost (when used with multiqueue feature)
> >>>>for incoming packets of a single connection. Use
> >>>>packet hash first. Patch tested on MQ virtio_net.
> >>>So this is sure to address the problem, why exactly does this happen?
> >>Ixgbe has flow director and bind queue to host cpu, so it can make
> >>sure the packet of a flow to be handled by the same queue/cpu. So
> >>when vhost thread moves from one host cpu to another, ixgbe would
> >>therefore send the packet to the new cpu/queue.
> >Confused. How does ixgbe know about vhost thread moving?
> 
> As far as I can see, ixgbe binds queues to physical cpu, so let consider:
> 
> vhost thread transmits packets of flow A on processor M
> during packet transmission, ixgbe driver programs the card to
> deliver the packet of flow A to queue/cpu M through flow director
> (see ixgbe_atr())
> vhost thread then receives packet of flow A with from M
> ...
> vhost thread transmits packets of flow A on processor N
> ixgbe driver programs the flow director to change the delivery of
> flow A to queue N ( cpu N )
> vhost thread then receives packet of flow A with from N
> ...
> 
> So, for a single flow A, we may get different queue mappings. Using
> rxhash instead may solve this issue.

Or better, transmit a single flow from a single vhost thread.

If packets of a single flow get spread over different CPUs,
they will get reordered and things are not going to work well.

> >
> >>>Does your device spread a single flow across multiple RX queues? Would
> >>>not that cause trouble in the TCP layer?
> >>>It would seem that using the recorded queue should be faster with
> >>>less cache misses. Before we give up on that, I'd
> >>>like to understand why it's wrong. Do you know?
> >>>
> >>>>Signed-off-by: Krishna Kumar<krkumar2@in.ibm.com>
> >>>>---
> >>>>  drivers/net/macvtap.c |   16 ++++++++--------
> >>>>  1 file changed, 8 insertions(+), 8 deletions(-)
> >>>>
> >>>>diff -ruNp org/drivers/net/macvtap.c new/drivers/net/macvtap.c
> >>>>--- org/drivers/net/macvtap.c	2011-10-22 08:38:01.000000000 +0530
> >>>>+++ new/drivers/net/macvtap.c	2011-11-16 18:34:51.000000000 +0530
> >>>>@@ -175,6 +175,14 @@ static struct macvtap_queue *macvtap_get
> >>>>  	if (!numvtaps)
> >>>>  		goto out;
> >>>>
> >>>>+	/* Check if we can use flow to select a queue */
> >>>>+	rxq = skb_get_rxhash(skb);
> >>>>+	if (rxq) {
> >>>>+		tap = rcu_dereference(vlan->taps[rxq % numvtaps]);
> >>>>+		if (tap)
> >>>>+			goto out;
> >>>>+	}
> >>>>+
> >>>>  	if (likely(skb_rx_queue_recorded(skb))) {
> >>>>  		rxq = skb_get_rx_queue(skb);
> >>>>
> >>>>@@ -186,14 +194,6 @@ static struct macvtap_queue *macvtap_get
> >>>>  			goto out;
> >>>>  	}
> >>>>
> >>>>-	/* Check if we can use flow to select a queue */
> >>>>-	rxq = skb_get_rxhash(skb);
> >>>>-	if (rxq) {
> >>>>-		tap = rcu_dereference(vlan->taps[rxq % numvtaps]);
> >>>>-		if (tap)
> >>>>-			goto out;
> >>>>-	}
> >>>>-
> >>>>  	/* Everything failed - find first available queue */
> >>>>  	for (rxq = 0; rxq<   MAX_MACVTAP_QUEUES; rxq++) {
> >>>>  		tap = rcu_dereference(vlan->taps[rxq]);
> >>>--
> >>>To unsubscribe from this list: send the line "unsubscribe netdev" in
> >>>the body of a message to majordomo@vger.kernel.org
> >>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >--
> >To unsubscribe from this list: send the line "unsubscribe netdev" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
