From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH 6/7] xen-netback: coalesce slots and fix
 regressions
Date: Tue, 9 Apr 2013 14:48:36 +0100
Message-ID: <20130409134836.GJ16998@zion.uk.xensource.com>
References: <1365505655-8021-1-git-send-email-wei.liu2@citrix.com>
 <1365505655-8021-7-git-send-email-wei.liu2@citrix.com>
 <5164221302000078000CBBF2@nat28.tlf.novell.com>
 <20130409124845.GG16998@zion.uk.xensource.com>
 <5164301902000078000CBC46@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"wdauchy@gmail.com" <wdauchy@gmail.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:23499 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756358Ab3DINsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 09:48:38 -0400
Content-Disposition: inline
In-Reply-To: <5164301902000078000CBC46@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 09, 2013 at 02:13:29PM +0100, Jan Beulich wrote:
> >>> On 09.04.13 at 14:48, Wei Liu <wei.liu2@citrix.com> wrote:
> > On Tue, Apr 09, 2013 at 01:13:39PM +0100, Jan Beulich wrote:
> >> >>> On 09.04.13 at 13:07, Wei Liu <wei.liu2@citrix.com> wrote:
> > [...]
> >> > +
> >> > +static struct kernel_param_ops max_skb_slots_param_ops = {
> >> 
> >> __moduleparam_const
> > 
> > TBH I don't see any driver makes use of this.
> 
> Sure, because generally you use the simple module_param() or
> module_param_named() macros.
> 

That means other modules using this need to be fixed too. :-)

> > Probably a simple "const" can do?
> 
> The purpose of __moduleparam_const is to abstract away the
> need to not have the const for a very limited set of architectures.
> Even if Xen currently doesn't support any of those, I would still
> not want to see architecture incompatibilities introduced if
> avoidable.
> 

Sure.

> >> > @@ -251,7 +291,7 @@ static int max_required_rx_slots(struct xenvif *vif)
> >> >  	int max = DIV_ROUND_UP(vif->dev->mtu, PAGE_SIZE);
> >> >  
> >> >  	if (vif->can_sg || vif->gso || vif->gso_prefix)
> >> > -		max += MAX_SKB_FRAGS + 1; /* extra_info + frags */
> >> > +		max += XEN_NETIF_NR_SLOTS_MIN + 1; /* extra_info + frags */
> >> >  
> >> >  	return max;
> >> >  }
> >> > @@ -657,7 +697,7 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
> >> >  		__skb_queue_tail(&rxq, skb);
> >> >  
> >> >  		/* Filled the batch queue? */
> >> > -		if (count + MAX_SKB_FRAGS >= XEN_NETIF_RX_RING_SIZE)
> >> > +		if (count + XEN_NETIF_NR_SLOTS_MIN >= XEN_NETIF_RX_RING_SIZE)
> >> >  			break;
> >> >  	}
> >> >  
> >> 
> >> Are the two changes above really correct? You're having an skb as
> >> input here, and hence you want to use all the frags, and nothing
> >> beyond. Another question is whether the frontend can handle
> >> those, but that aspect isn't affected by the code being modified
> >> here.
> >> 
> > 
> > This patch tries to remove dependency on MAX_SKB_FRAGS. Writing the
> > protocol-defined value here is OK IMHO.
> 
> I understand the intentions of the patch, but you shouldn't go
> further with this than you need to. Just think through carefully
> the cases of MAX_SKB_FRAGS being smaller/bigger than
> XEN_NETIF_NR_SLOTS_MIN: In the first instance, you needlessly
> return too big a value when the latter is the bigger one, and in
> the second instance you bail from the loop early in the same case.
> 
> What's worse, in the opposite case I'm having the impression that
> you would continue the loop when you shouldn't (because there's
> not enough room left), and I'd suspect problems for the caller of
> max_required_rx_slots() in that case too.
> 

The frontend and backend work at the moment is because MAX_SKB_FRAGS only
went down once. If it goes like 18 -> 17 -> 19 then we are screwed...

For the MAX_SKB_FRAGS < XEN_NETIF_NR_SLOTS_MIN case it is fine, we are
just reserving more room in the ring.

For the MAX_SKB_FRAGS > XEN_NETIF_NR_SLOTS_MIN case, my thought is that
is not likely to happen in the near future, we could possibly upstream
mechinasim to negotiate number of slots before MAX_SKB_FRAGS >
XEN_NETIF_NR_SLOTS_MIN ever happens.

But yes, let's leave RX path along at the moment, need to investigate
more on this.


Wei.
