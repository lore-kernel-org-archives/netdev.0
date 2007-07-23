From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 02/10] Networking include file changes.
Date: Mon, 23 Jul 2007 11:57:07 +0530
Message-ID: <OF9DDA4E7D.6ED7F3A1-ON65257321.0022D06C-65257321.0023714C@in.ibm.com>
References: <46A443CB.6060200@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	kaber@trash.net, jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, netdev@vger.kernel.org,
	davem@davemloft.net, rdreier@cisco.com
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46A443CB.6060200@us.ibm.com>
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

Hi Sridhar,

Sridhar Samudrala <sri@us.ibm.com> wrote on 07/23/2007 11:29:39 AM:

> Krishna Kumar2 wrote:
> > Hi Sridhar,
> >
> > Sridhar Samudrala <sri@us.ibm.com> wrote on 07/20/2007 10:55:05 PM:
> >>> diff -ruNp org/include/net/pkt_sched.h new/include/net/pkt_sched.h
> >>> --- org/include/net/pkt_sched.h   2007-07-20 07:49:28.000000000 +0530
> >>> +++ new/include/net/pkt_sched.h   2007-07-20 08:30:22.000000000 +0530
> >>> @@ -80,13 +80,13 @@ extern struct qdisc_rate_table *qdisc_ge
> >>>        struct rtattr *tab);
> >>>  extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
> >>>
> >>> -extern void __qdisc_run(struct net_device *dev);
> >>> +extern void __qdisc_run(struct net_device *dev, struct sk_buff_head
> > *blist);
> >> Why do we need this additional 'blist' argument?
> >> Is this different from dev->skb_blist?
> >
> > It is the same, but I want to call it mostly with NULL and rarely with
the
> > batch list pointer (so it is related to your other question). My
original
> > code didn't have this and was trying batching in all cases. But in most
> > xmit's (probably almost all), there will be only one packet in the
queue to
> > send and batching will never happen. When there is a lock contention or
if
> > the queue is stopped, then the next iteration will find >1 packets. But
I
> > still will try no batching for the lock failure case as there be
probably
> > 2 packets (one from previous time and 1 from this time, or 3 if two
> > failures,
> > etc), and try batching only when queue was stopped from net_tx_action
(this
> > was based on Dave Miller's idea).
>
> Is this right to say that the above change is to get this behavior?
>    If qdisc_run() is called from dev_queue_xmit() don't use batching.
>    If qdisc_run() is called from net_tx_action(), do batching.

Correct.

> Isn't it possible to have multiple skb's in the qdisc queue in the
> first case?

It is possible but rarer (so unnecessary checking most of the time). From
net_tx_action you are guaranteed to have multiple skbs, but from xmit you
will almost always get one skb (since most send of 1 skb will go out OK).
And also in the xmit path, it is more likely to have few skbs compared to
possibly hundreds in the net_tx_action path.

> If this additional argument is used to indicate if we should do batching
> or not, then passing a flag may be much more cleaner than passing the
blist.

OK, I will add this as another action item to check (along with Patrick's
suggestion to use single API) and will get back.

- KK
