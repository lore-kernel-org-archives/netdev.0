From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH V4 6/7] xen-netback: coalesce slots in TX path and fix
 regressions
Date: Sun, 14 Apr 2013 17:15:10 +0100
Message-ID: <20130414161510.GD17602@zion.uk.xensource.com>
References: <1365776646-10796-1-git-send-email-wei.liu2@citrix.com>
 <1365776646-10796-7-git-send-email-wei.liu2@citrix.com>
 <1365780944.15783.97.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"jbeulich@suse.com" <jbeulich@suse.com>,
	"wdauchy@gmail.com" <wdauchy@gmail.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:41015 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751894Ab3DNQPM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Apr 2013 12:15:12 -0400
Content-Disposition: inline
In-Reply-To: <1365780944.15783.97.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 12, 2013 at 04:35:44PM +0100, Ian Campbell wrote:
[...]
> > +module_param_cb(max_skb_slots, &max_skb_slots_param_ops,
> > +               &max_skb_slots, 0444);
> 
> Is all this infrastructure instead of module_param_int just so we can
> check XEN_NETIF_NR_SLOTS_MIN? I'm inclined to suggest that if an admin
> wants to set a smaller slot limit then they get to keep the pieces.
> 
> Or if you really want to check it then you could check+log/reject in the
> module init function.
> 

I will go for the latter one. :-)

> > 
[...]
> >         struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
> > -       struct gnttab_copy tx_copy_ops[MAX_PENDING_REQS];
> > +       /* Coalescing tx requests before copying makes number of grant
> > +        * copy ops greater of equal to number of slots required. In
>                               ^or
> 
> > +        * worst case a tx request consumes 2 gnttab_copy.
> 
> I'm happy with this as an upper bound but can it be made smaller?
> 
> For example there are at most MAX_PENDING_REQS on the ring, but we are
> filling MAX_SKB_FRAGS with that data, therefore only MAX_SKB_FRAGS (-1?)
> or those requests can cross a frag boundary and therefore the actual max
> is MAX_PENDING_REQS+MAX_SKB_FRAGS.
> 
> Is that logic right? Perhaps need to account for data going into the
> head too with another +N?
> 

I'm afraid this is not the case. Vif has a ring of size
MAX_PENDING_REQS, but that ring might contain multiple skbs, so the
statement "we are filling MAX_SKB_FRAGS with that data" doesn't stand.

> > +        */
> > +       struct gnttab_copy tx_copy_ops[2*MAX_PENDING_REQS];
> > 
> >         u16 pending_ring[MAX_PENDING_REQS];
> > 
> [...]
> 
> > 
> > -               memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + frags),
> > +               /* Xen network protocol had implicit dependency on
> > +                * MAX_SKB_FRAGS. XEN_NETIF_NR_SLOTS_MIN is set to the
> > +                * historical MAX_SKB_FRAGS value 18 to honor the same
> > +                * behavior as before. Any packet using more than 18
> > +                * slots but less than max_skb_slots slots is dropped
> > +                */
> 
> It seems a bit odd not to accept such a thing if the local network stack
> can cope with it but I suppose the intention here is to maintain the
> historical status quo to reduce the problem space when we imminently
> implement proper negotiation between front- and backend about the number
> of slots they can handle?
> 

Yes, this behavior will be altered once we have mechanism to negotiate.


Wei.
