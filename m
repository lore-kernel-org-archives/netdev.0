From: Rafal Ozieblo <rafalo@cadence.com>
Subject: RE: [PATCH v2 4/4] net: macb: Add hardware PTP support
Date: Wed, 7 Jun 2017 11:13:36 +0000
Message-ID: <BN3PR07MB2516A47C2CFEB58BCFFB2C46C9C80@BN3PR07MB2516.namprd07.prod.outlook.com>
References: <1496413439-12900-1-git-send-email-rafalo@cadence.com>
 <1496413690-22826-1-git-send-email-rafalo@cadence.com>
 <20170606183358.GA25220@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "andrei.pistirica@microchip.com" <andrei.pistirica@microchip.com>,
 "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>,
 David Miller <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170606183358.GA25220@localhost.localdomain>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: 6 czerwca 2017 20:34
> To: Rafal Ozieblo <rafalo@cadence.com>
> Cc: David Miller <davem@davemloft.net>; nicolas.ferre@atmel.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devicetree@vger.kernel.org; linux-arm-kernel@lists.infradead.org;
> harini.katakam@xilinx.com; andrei.pistirica@microchip.com
> Subject: Re: [PATCH v2 4/4] net: macb: Add hardware PTP support
> 
> On Fri, Jun 02, 2017 at 03:28:10PM +0100, Rafal Ozieblo wrote:
> > +static void gem_ptp_clear_timer(struct macb *bp)
> > +{
> > +	bp->tsu_incr.ns = 0;
> > +	bp->tsu_incr.sub_ns = 0;
> 
> What is the point of this function?
Cleaning all bellow registers will stop hardware PTP clock.

> 
> > +	gem_writel(bp, TISUBN, GEM_BF(SUBNSINCR, 0));
> > +	gem_writel(bp, TI, GEM_BF(NSINCR, 0));
> > +	gem_writel(bp, TA, 0);
> > +}
(...)
> > +int gem_ptp_txstamp(struct macb_queue *queue, struct sk_buff *skb,
> > +		    struct macb_dma_desc *desc)
> > +{
> > +	struct gem_tx_ts *tx_timestamp;
> > +	struct macb_dma_desc_ptp *desc_ptp;
> > +	unsigned long head = queue->tx_ts_head;
> > +	unsigned long tail = READ_ONCE(queue->tx_ts_tail);
> > +
> > +	if (!GEM_BFEXT(DMA_TXVALID, desc->ctrl))
> > +		return -EINVAL;
> > +
> > +	if (CIRC_SPACE(head, tail, PTP_TS_BUFFER_SIZE) == 0)
> > +		return -ENOMEM;
> > +
> > +	skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
> > +	desc_ptp = macb_ptp_desc(queue->bp, desc);
> > +	tx_timestamp = &queue->tx_timestamps[head];
> > +	tx_timestamp->skb = skb;
> > +	tx_timestamp->desc_ptp.ts_1 = desc_ptp->ts_1;
> > +	tx_timestamp->desc_ptp.ts_2 = desc_ptp->ts_2;
> > +	/* move head */
> > +	smp_store_release(&queue->tx_ts_head,
> > +			  (head + 1) & (PTP_TS_BUFFER_SIZE - 1));
> > +
> > +	schedule_work(&queue->tx_ts_task);
> 
> Since the time stamp is in the buffer descriptor, why delay the
> delivery via the work item?

I put comment about that a few months ago:
https://patchwork.ozlabs.org/patch/705629/
Let me quote part about not doing it via worker:

" I think, you can not do it in that way. 
It will hold two locks. If you enable appropriate option in kernel (as far as I 
remember CONFIG_DEBUG_SPINLOCK) you will get a warning here.

Please look at following call-stack:

1. macb_interrupt()   // spin_lock(&bp->lock) is taken
2. macb_tx_interrupt()
3. macb_handle_txtstamp()
4. skb_tstamp_tx()
5. __skb_tstamp_tx()
6. skb_may_tx_timestamp()
7. read_lock_bh() // second lock is taken

I know that those are different locks and different types. But this could lead 
to deadlocks. This is the reason of warning I could see.
And this is the reason why I get timestamp in interrupt routine but pass it to 
skb outside interrupt (using circular buffer).

Please, refer to this:
https://lkml.org/lkml/2016/11/18/168

1. macb_tx_interrupt()
2. macb_tx_timestamp_add() and schedule_work(&queue->tx_timestamp_task)

Then, outside interrupt (without holding a lock) :
1. macb_tx_timestamp_flush()
2. macb_tstamp_tx()
3. skb_tstamp_tx()"
> 
> > +	return 0;
> > +}
(...)
> > +void gem_ptp_remove(struct net_device *ndev)
> > +{
> > +	struct macb *bp = netdev_priv(ndev);
> > +
> > +	if (bp->ptp_clock)
> > +		ptp_clock_unregister(bp->ptp_clock);
> > +
> > +	gem_ptp_clear_timer(bp);
> 
> Why is this 'clear' needed?
To stop hardware PTP clock.
> 
> > +	dev_info(&bp->pdev->dev, "%s ptp clock unregistered.\n",
> > +		 GEM_PTP_TIMER_NAME);
> > +}
> 
> Thanks,
> Richard

I'll correct all other issues.

Regards,
Rafal
