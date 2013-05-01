From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next 2/2] xen-netback: avoid allocating variable size
 array on stack
Date: Wed, 1 May 2013 14:01:07 +0100
Message-ID: <20130501130107.GH9780@zion.uk.xensource.com>
References: <1367340644-19690-1-git-send-email-wei.liu2@citrix.com>
 <1367340644-19690-3-git-send-email-wei.liu2@citrix.com>
 <1367404361.3142.686.camel@zakaz.uk.xensource.com>
 <20130501105316.GE9780@zion.uk.xensource.com>
 <1367407303.3142.694.camel@zakaz.uk.xensource.com>
 <20130501114009.GG9780@zion.uk.xensource.com>
 <1367408826.3142.714.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jbeulich@suse.com" <jbeulich@suse.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:47480 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752947Ab3EANBI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 May 2013 09:01:08 -0400
Content-Disposition: inline
In-Reply-To: <1367408826.3142.714.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 01, 2013 at 12:47:06PM +0100, Ian Campbell wrote:
> On Wed, 2013-05-01 at 12:40 +0100, Wei Liu wrote:
> > On Wed, May 01, 2013 at 12:21:43PM +0100, Ian Campbell wrote:
> > > On Wed, 2013-05-01 at 11:53 +0100, Wei Liu wrote:
> > > > On Wed, May 01, 2013 at 11:32:41AM +0100, Ian Campbell wrote:
> > > > > On Tue, 2013-04-30 at 17:50 +0100, Wei Liu wrote:
> > > > > > Tune xen_netbk_count_requests to not touch working array beyond limit, so that
> > > > > > we can make working array size constant.
> > > > > 
> > > > > Is this really correct when max_skb_slots > XEN_NETIF_NR_SLOTS_MIN?
> > > > > Seems like we would either overrun the array or drop frames which
> > > > > max_skb_slots suggests we should accept?
> > > > > 
> > > > 
> > > > So the max_skb_slots for now is the standard to determine whether a
> > > > guest is malicious, not the maximum slots we can process.
> > > 
> > > Perhaps I've have misunderstood this patch then but it looks to me like
> > > it will cause us to drop skbs which use slots > XEN_NETIF_NR_SLOTS_MIN
> > > and < max_skb_slots, i.e. ones which are considered non-malicious by the
> > > above definition. Or it will cause us to access indexes into
> > > xen_netbk_tx_build_gops.txfrags which are > XEN_NETIF_NR_SLOTS_MIN.
> > > 
> > 
> > Any packet using more than XEN_NETIF_NR_SLOTS_MIN are considered
> > malformed at this point. The behavior is documented in previous commit
> > log. 2810e5b9a "xen-netback: coalesce slots in TX path and fix
> > regressions".
> > 
> > """
> > The behavior of netback for packet is thus:
> > 
> >         1-18            slots: valid
> >        19-max_skb_slots slots: drop and respond with an error
> >        max_skb_slots+   slots: fatal error
> > """
> 
> OK, so my understanding was wrong and this patch is doing the right
> thing.
> 
> However it does seem rather like NR_SLOTS_MIN and max_skb_slots are a
> bit misnamed. They are actually NR_SLOTS_MAX and fatal_skb_slots? The
> NR_SLOTS{MIN/MAX} disparity is particularly confusing in the context of
> this code (I understand its the minimum that a backend must support, but
> its still confusing in the context of these functions).
> 

Yes probably the naming is weird.

Probably we can do

  #define XEN_NETBK_SLOTS_MAX XEN_NETIF_NR_SLOTS_MIN
  max_skb_slots -> fatal_skb_slots

if it makes things clearer.


Wei.
