From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 3/9 Rev3] [sched] Modify qdisc_run to
	support batching
Date: Thu, 9 Aug 2007 09:36:28 +0530
Message-ID: <OF903DEA40.5CC1444C-ON65257332.001253B6-65257332.001690ED@in.ibm.com>
References: <46B9CD9D.4020506@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net, sri@us.ibm.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46B9CD9D.4020506@trash.net>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Hi Patrick,

Patrick McHardy <kaber@trash.net> wrote on 08/08/2007 07:35:17 PM:

> Krishna Kumar wrote:
<snip>
> > +static inline int get_skb(struct net_device *dev, struct Qdisc *q,
> > +           struct sk_buff_head *blist, struct sk_buff **skbp)
> > +{
> > +   if (likely(!blist || (!skb_queue_len(blist) && qdisc_qlen(q) <=
1))) {
> > +      return likely((*skbp = dev_dequeue_skb(dev, q)) != NULL);
> > +   } else {
> > +      int max = dev->tx_queue_len - skb_queue_len(blist);
> > +      struct sk_buff *skb;
> > +
> > +      while (max > 0 && (skb = dev_dequeue_skb(dev, q)) != NULL)
> > +         max -= dev_add_skb_to_blist(skb, dev);
> > +
> > +      *skbp = NULL;
> > +      return 1;   /* we have atleast one skb in blist */
> > +   }
> > +}
>
> I think you missed my previous reply to this in the flood of
> responses (or I missed your reply), so I'm copying it below:

Sorry, but I didn't get your post on this point earlier (thanks for
posting again).

> The entire idea of a single queue after qdiscs that is refilled
> independantly of transmissions times etc. make be worry a bit.
> By changing the timing you're effectively changing the qdiscs
> behaviour, at least in some cases. SFQ is a good example, but I
> believe it affects most work-conserving qdiscs. Think of this
> situation:
>
> 100 packets of flow 1 arrive
> 50 packets of flow 1 are sent
> 100 packets for flow 2 arrive
> remaining packets are sent
>
> On the wire you'll first see 50 packets of flow 1, than 100 packets
> alternate of flow 1 and 2, then 50 packets flow 2.
>
> With your additional queue all packets of flow 1 are pulled out of
> the qdisc immediately and put in the fifo. When the 100 packets of
> the second flow arrive they will also get pulled out immediately
> and are put in the fifo behind the remaining 50 packets of flow 1.
> So what you get on the wire is:
>
> 100 packets of flow 1
> 100 packets of flow 1

In normal case (qdisc run from xmit and not from tx_action), the code
executing is the same as regular code without any difference in wire
behavior due to the check:
      if (likely(!blist || (!skb_queue_len(blist) && qdisc_qlen(q) <= 1)))
{
            return likely((*skbp = dev_dequeue_skb(dev, q)) != NULL);
(I always pass blist as NULL).

With SFQ for the above scenario, my code will first send out 50 F1 skbs
iteratively (blist==NULL), get blocked so that 50 skbs accumulate on F1
and 100 on F2, then when it is woken up, it will batch but it will pick
up 50 F1 and 50 F2 skbs in alternate order and put in the queue, and
finally pick up the remaining 50 F2 skbs and put those too in the queue.
Since I am calling dev_dequeue_skb, I am assured of RR when using SFQ.
The only time I would have 100 skbs from F1 in my queue (and hence sent
out first) is if there are NO F2 skbs.

> So SFQ is without any effect. This is not completely avoidable of
> course, but you can and should limit the damage by only pulling
> out as much packets as the driver can take and have the driver
> stop the queue afterwards.

I feel this cannot happen. Please correct me if I am wrong.

Thanks,

- KK
