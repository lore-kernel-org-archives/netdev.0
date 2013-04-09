From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH 6/7] xen-netback: coalesce slots and
 fix regressions
Date: Tue, 09 Apr 2013 14:13:29 +0100
Message-ID: <5164301902000078000CBC46@nat28.tlf.novell.com>
References: <1365505655-8021-1-git-send-email-wei.liu2@citrix.com>
 <1365505655-8021-7-git-send-email-wei.liu2@citrix.com>
 <5164221302000078000CBBF2@nat28.tlf.novell.com>
 <20130409124845.GG16998@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "David Vrabel" <david.vrabel@citrix.com>,
	"IanCampbell" <Ian.Campbell@citrix.com>,
	"wdauchy@gmail.com" <wdauchy@gmail.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:37866 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759517Ab3DINNc convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:5:1>);
	Tue, 9 Apr 2013 09:13:32 -0400
In-Reply-To: <20130409124845.GG16998@zion.uk.xensource.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 09.04.13 at 14:48, Wei Liu <wei.liu2@citrix.com> wrote:
> On Tue, Apr 09, 2013 at 01:13:39PM +0100, Jan Beulich wrote:
>> >>> On 09.04.13 at 13:07, Wei Liu <wei.liu2@citrix.com> wrote:
> [...]
>> > +
>> > +static struct kernel_param_ops max_skb_slots_param_ops = {
>> 
>> __moduleparam_const
> 
> TBH I don't see any driver makes use of this.

Sure, because generally you use the simple module_param() or
module_param_named() macros.

> Probably a simple "const" can do?

The purpose of __moduleparam_const is to abstract away the
need to not have the const for a very limited set of architectures.
Even if Xen currently doesn't support any of those, I would still
not want to see architecture incompatibilities introduced if
avoidable.

>> > @@ -251,7 +291,7 @@ static int max_required_rx_slots(struct xenvif *vif)
>> >  	int max = DIV_ROUND_UP(vif->dev->mtu, PAGE_SIZE);
>> >  
>> >  	if (vif->can_sg || vif->gso || vif->gso_prefix)
>> > -		max += MAX_SKB_FRAGS + 1; /* extra_info + frags */
>> > +		max += XEN_NETIF_NR_SLOTS_MIN + 1; /* extra_info + frags */
>> >  
>> >  	return max;
>> >  }
>> > @@ -657,7 +697,7 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
>> >  		__skb_queue_tail(&rxq, skb);
>> >  
>> >  		/* Filled the batch queue? */
>> > -		if (count + MAX_SKB_FRAGS >= XEN_NETIF_RX_RING_SIZE)
>> > +		if (count + XEN_NETIF_NR_SLOTS_MIN >= XEN_NETIF_RX_RING_SIZE)
>> >  			break;
>> >  	}
>> >  
>> 
>> Are the two changes above really correct? You're having an skb as
>> input here, and hence you want to use all the frags, and nothing
>> beyond. Another question is whether the frontend can handle
>> those, but that aspect isn't affected by the code being modified
>> here.
>> 
> 
> This patch tries to remove dependency on MAX_SKB_FRAGS. Writing the
> protocol-defined value here is OK IMHO.

I understand the intentions of the patch, but you shouldn't go
further with this than you need to. Just think through carefully
the cases of MAX_SKB_FRAGS being smaller/bigger than
XEN_NETIF_NR_SLOTS_MIN: In the first instance, you needlessly
return too big a value when the latter is the bigger one, and in
the second instance you bail from the loop early in the same case.

What's worse, in the opposite case I'm having the impression that
you would continue the loop when you shouldn't (because there's
not enough room left), and I'd suspect problems for the caller of
max_required_rx_slots() in that case too.

>> >  			return -E2BIG;
>> >  		}
>> >  
>> > -		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + frags),
>> > +		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + slots),
>> >  		       sizeof(*txp));
>> >  		if (txp->size > first->size) {
>> > -			netdev_err(vif->dev, "Frag is bigger than frame.\n");
>> > +			netdev_err(vif->dev, "Packet is bigger than frame.\n");
>> 
>> I don't think "packet" is the right term here.
>> 
> 
> Maybe just "Invalid tx request" and dump all information?

Possibly. But this may become a little too verbose then...

Jan
