From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next 2/2] xen-netback: avoid allocating variable
 size array on stack
Date: Wed, 1 May 2013 12:21:43 +0100
Message-ID: <1367407303.3142.694.camel@zakaz.uk.xensource.com>
References: <1367340644-19690-1-git-send-email-wei.liu2@citrix.com>
	 <1367340644-19690-3-git-send-email-wei.liu2@citrix.com>
	 <1367404361.3142.686.camel@zakaz.uk.xensource.com>
	 <20130501105316.GE9780@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jbeulich@suse.com" <jbeulich@suse.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:26691 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753053Ab3EALVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 07:21:48 -0400
In-Reply-To: <20130501105316.GE9780@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-01 at 11:53 +0100, Wei Liu wrote:
> On Wed, May 01, 2013 at 11:32:41AM +0100, Ian Campbell wrote:
> > On Tue, 2013-04-30 at 17:50 +0100, Wei Liu wrote:
> > > Tune xen_netbk_count_requests to not touch working array beyond limit, so that
> > > we can make working array size constant.
> > 
> > Is this really correct when max_skb_slots > XEN_NETIF_NR_SLOTS_MIN?
> > Seems like we would either overrun the array or drop frames which
> > max_skb_slots suggests we should accept?
> > 
> 
> So the max_skb_slots for now is the standard to determine whether a
> guest is malicious, not the maximum slots we can process.

Perhaps I've have misunderstood this patch then but it looks to me like
it will cause us to drop skbs which use slots > XEN_NETIF_NR_SLOTS_MIN
and < max_skb_slots, i.e. ones which are considered non-malicious by the
above definition. Or it will cause us to access indexes into
xen_netbk_tx_build_gops.txfrags which are > XEN_NETIF_NR_SLOTS_MIN.

If XEN_NETIF_NR_SLOTS_MIN==18 and max_skb_slots == 22 what will this
patch cause to happen to an SKB which uses 20 slots? Will it be dropped
or will it access index 20 into an array with size 18?

> > Other options:
> > 
> > Handle batches of work in <max_skb_slots sized bundles, but that gets
> > complex when you consider the case of an skb which crosses multiple such
> > bundles.
> > 
> > xen_netbk_get_requests() copes the tx req again into the pending_tx_info
> > -- any way we can arrange for this to just happen right in the first
> > place?
> > 
> 
> Isn't the point of having xen_netbk_count_requests to drop malformed
> packets before wasting any effort processing them?

Yes, but it seems to me like you are dropping non-malformed packets.

Also remember that the tx requests accumulated by
xen_netbk_count_requests into the txfrags array are subsequently used by
xen_netbk_get_requests to do the actual processing.

Ian.
