From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen-netback: count number required slots for an skb more
 carefully
Date: Wed, 4 Sep 2013 14:14:59 +0100
Message-ID: <20130904131459.GO14104@zion.uk.xensource.com>
References: <1378229390-12919-1-git-send-email-david.vrabel@citrix.com>
 <20130903215328.GA13465@zion.uk.xensource.com>
 <52271DFF.3070008@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>, <msw@amazon.com>, <annie.li@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:23218 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755760Ab3IDNPA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 09:15:00 -0400
Content-Disposition: inline
In-Reply-To: <52271DFF.3070008@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 04, 2013 at 12:48:15PM +0100, David Vrabel wrote:
> On 03/09/13 22:53, Wei Liu wrote:
> > On Tue, Sep 03, 2013 at 06:29:50PM +0100, David Vrabel wrote:
> >> From: David Vrabel <david.vrabel@citrix.com>
> >>
> >> When a VM is providing an iSCSI target and the LUN is used by the
> >> backend domain, the generated skbs for direct I/O writes to the disk
> >> have large, multi-page skb->data but no frags.
> >>
> >> With some lengths and starting offsets, xen_netbk_count_skb_slots()
> >> would be one short because the simple calculation of
> >> DIV_ROUND_UP(skb_headlen(), PAGE_SIZE) was not accounting for the
> >> decisions made by start_new_rx_buffer() which does not guarantee
> >> responses are fully packed.
> >>
> >> For example, a skb with length < 2 pages but which spans 3 pages would
> >> be counted as requiring 2 slots but would actually use 3 slots.
> >>
> >> skb->data:
> >>
> >>     |        1111|222222222222|3333        |
> >>
> >> Fully packed, this would need 2 slots:
> >>
> >>     |111122222222|22223333    |
> >>
> >> But because the 2nd page wholy fits into a slot it is not split across
> >> slots and goes into a slot of its own:
> >>
> >>     |1111        |222222222222|3333        |
> >>
> >> Miscounting the number of slots means netback may push more responses
> >> than the number of available requests.  This will cause the frontend
> >> to get very confused and report "Too many frags/slots".  The frontend
> >> never recovers and will eventually BUG.
> >>
> >> Fix this by counting the number of required slots more carefully.  In
> >> xen_netbk_count_skb_slots(), more closely follow the algorithm used by
> >> xen_netbk_gop_skb() by introducing xen_netbk_count_frag_slots() which
> >> is the dry-run equivalent of netbk_gop_frag_copy().
> >>
> > 
> > Phew! So this is backend miscounting bug. I thought it was a frontend
> > bug so it didn't ring a bell when we had our face-to-face discussion,
> > sorry. :-(
> > 
> > This bug was discussed back in July among Annie, Matt, Ian and I. We
> > finally agreed to take Matt's solution. Matt agreed to post final
> > version within a week but obviously he's too busy to do so. I was away
> > so I didn't follow closely. Eventually it fell through the crack. :-(
> 
> I think I prefer fixing the counting for backporting to stable kernels.

The original patch has coding style change. Sans that contextual change
it's not a very long patch.

>  Xi's approach of packing the ring differently is a change in frontend
> visible behaviour and seems more risky. e.g., possible performance
> impact so I would like to see some performance analysis of that approach.
> 

With Xi's approach it is more efficient for backend to process. As we
now use one less grant copy operation which means we copy the same
amount of data with less grant ops.

>From frontend's PoV I think the impact is minimal. Frontend is involved
in assembling the packets. It only takes what's in the ring and chain
them together. The operation involves copying so far is the
__pskb_pull_tail which happens a) in rare case when there's more frags
than frontend's MAX_SKB_FRAGS, b) when pull_to > skb_headlen which
happens. With Xi's change the rare case a) will even be rarer than
before as we use less slots. b) happens the same as it happens before
Xi's change, because the pull is guarded by "if (pull_to >
skb_headlen(skb))" and Xi's change doesn't affect skb_headlen.

So overall I don't see obvious downside.

Wei.

> David
