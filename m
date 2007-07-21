From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 05/10] sch_generic.c changes.
Date: Sat, 21 Jul 2007 12:26:23 +0530
Message-ID: <OF206CB1B7.31D1C39B-ON6525731F.00254E4C-6525731F.00261F1A@in.ibm.com>
References: <46A0FC04.1000006@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, davem@davemloft.net, sri@us.ibm.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46A0FC04.1000006@trash.net>
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

Patrick McHardy <kaber@trash.net> wrote on 07/20/2007 11:46:36 PM:

> Krishna Kumar wrote:
> > +static inline int get_skb(struct net_device *dev, struct Qdisc *q,
> > +           struct sk_buff_head *blist,
> > +           struct sk_buff **skbp)
> > +{
> > +   if (likely(!blist) || (!skb_queue_len(blist) && qdisc_qlen(q) <=
1)) {
> > +      return likely((*skbp = dev_dequeue_skb(dev, q)) != NULL);
> > +   } else {
> > +      int max = dev->tx_queue_len - skb_queue_len(blist);
>
>
> I'm assuming the driver will simply leave excess packets in the
> blist for the next run.

Yes, and the next run will be scheduled even if no more xmits are called
either
due to qdisc_restart()'s call to driver returning :
      BUSY : driver failed to send all, net_tx_action will handle this
later (the
             case you mentioned)
      OK : and qlen is > 0, return 1 and __qdisc_run() will re-retry (where
            blist len will become zero as driver processed EVERYTHING on
blist)

> The check for tx_queue_len is wrong though,
> its only a default which can be overriden and some qdiscs don't
> care for it at all.

I think it should not matter whether qdiscs use this or not, or even if it
is modified (unless it is made zero in which case this breaks). The
intention behind this check is to make sure that not more than tx_queue_len
skbs are in all queues put together (q->qdisc + dev->skb_blist), otherwise
the blist can become too large and breaks the idea of tx_queue_len. Is that
a good justification ?

> > -void __qdisc_run(struct net_device *dev)
> > +void __qdisc_run(struct net_device *dev, struct sk_buff_head *blist)
>
>
> And the patches should really be restructured so this change is
> in the same patch changing the header and the caller, for example.

Ah, OK.

Thanks,

- KK
