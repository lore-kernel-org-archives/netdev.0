From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] xen-netback: count number required slots for an skb
 more carefully
Date: Wed, 4 Sep 2013 13:41:25 +0100
Message-ID: <1378298485.17510.109.camel@kazak.uk.xensource.com>
References: <1378229390-12919-1-git-send-email-david.vrabel@citrix.com>
	 <20130903215328.GA13465@zion.uk.xensource.com>
	 <52271DFF.3070008@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<netdev@vger.kernel.org>, <msw@amazon.com>, <annie.li@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:21914 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934439Ab3IDMl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 08:41:27 -0400
In-Reply-To: <52271DFF.3070008@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-04 at 12:48 +0100, David Vrabel wrote:
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

That's a good argument. I think we should take this patch, or something
very like it, now and then rebase the more complex thing on top.

>  Xi's approach of packing the ring differently is a change in frontend
> visible behaviour and seems more risky. e.g., possible performance
> impact so I would like to see some performance analysis of that approach.

Yes.
