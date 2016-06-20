From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: rcu locking issue in mpls output code?
Date: Mon, 20 Jun 2016 19:33:17 +0300
Message-ID: <20160620163317.GS20238@wantstofly.org>
References: <20160620004546.GP20238@wantstofly.org>
 <8d325ab7-bc46-dd69-288a-571d56efc545@cumulusnetworks.com>
 <20160620063055.GR20238@wantstofly.org>
 <7d7097bc-ce10-d8e1-4a90-36045c7d2041@cumulusnetworks.com>
 <CAJieiUi8WX1=Yri_b8aZpP2sEkQ6CqARcX29M94Qdf4gczFDjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsa@cumulusnetworks.com>,
	Robert Shearman <rshearma@brocade.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hmm.wantstofly.org ([138.201.34.84]:53412 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752380AbcFTQdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 12:33:19 -0400
Content-Disposition: inline
In-Reply-To: <CAJieiUi8WX1=Yri_b8aZpP2sEkQ6CqARcX29M94Qdf4gczFDjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 20, 2016 at 09:13:36AM -0700, Roopa Prabhu wrote:

> >>>> diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
> >>>> index fb31aa8..802956b 100644
> >>>> --- a/net/mpls/mpls_iptunnel.c
> >>>> +++ b/net/mpls/mpls_iptunnel.c
> >>>> @@ -105,12 +105,15 @@ static int mpls_output(struct net *net, struct
> >>>> sock *sk, struct sk_buff *skb)
> >>>>                 bos = false;
> >>>>         }
> >>>>
> >>>> +       rcu_read_lock_bh();
> >>>>         if (rt)
> >>>>                 err = neigh_xmit(NEIGH_ARP_TABLE, out_dev,
> >>>> &rt->rt_gateway,
> >>>>                                  skb);
> >>>>         else if (rt6)
> >>>>                 err = neigh_xmit(NEIGH_ND_TABLE, out_dev,
> >>>> &rt6->rt6i_gateway,
> >>>>                                  skb);
> >>>> +       rcu_read_unlock_bh();
> >>>> +
> >>>>         if (err)
> >>>>                 net_dbg_ratelimited("%s: packet transmission failed:
> >>>> %d\n",
> >>>>                                     __func__, err);
> >>>>
> >>>
> >>> I think those need to be added to neigh_xmit in the
> >>>
> >>>         if (likely(index < NEIGH_NR_TABLES)) {
> >>>
> >>>         }
> >>
> >>
> >> That'll force callers that don't need the extra protection (i.e.
> >> mpls_forward(), since that always runs from softirq and it's enough
> >> to protect the neigh state with rcu_read_lock() from softirq and we're
> >> already running under rcu_read_lock() when we get to neigh_xmit()) to
> >> eat the useless overhead of an extra rcu_read_{,un}lock_bh() pair, but
> >> sure, functionally that's correct, I think, and in my workload I don't
> >> care about MPLS forwarding performance anyway. ;-)
> >
> >
> > __neigh_lookup_noref expects bh level protection. Since the if block in
> > neigh_xmit requires the locking seems like this the appropriate place for
> > it.
> >
> >>
> >> Want me to send a patch moving it to neigh_xmit() ?
> >
> >
> > Roopa/Robert: agree?
> 
> yes, seems like an appropriate place for it.  provided it does not add
> unnecessary overhead for others.
> But then neigh_xmit seems to be only called from mpls_output and mpls_forward.

OK, patch coming up.  Thanks!
