From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [Xen-devel] [PATCH net v2 1/3] xen-netback: remove pointless
 clause from if statement
Date: Fri, 28 Mar 2014 10:20:25 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD029E138@AMSPEX01CL01.citrite.net>
References: <1395924973-42904-1-git-send-email-paul.durrant@citrix.com>
 <1395924973-42904-2-git-send-email-paul.durrant@citrix.com>
 <289461862.20140327144546@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029C992@AMSPEX01CL01.citrite.net>
 <68689563.20140327150256@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029CAA6@AMSPEX01CL01.citrite.net>
 <874580615.20140327174607@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029D28D@AMSPEX01CL01.citrite.net>
 <636041055.20140327181524@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029D498@AMSPEX01CL01.citrite.net>
 <1279623918.20140327193454@eikelenboom.it>
 <602920213.20140327202235@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029DDEA@AMSPEX01CL01.citrite.net>
 <1144281350.20140328103919@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029DFE7@AMSPEX01CL01.citrite.net>
 <063D6719AE5E284EB5DD2968C1650D6D0F6EB615@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: David Laight <David.Laight@ACULAB.COM>,
	Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:38291 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbaC1KU2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 06:20:28 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6EB615@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of David Laight
> Sent: 28 March 2014 10:01
> To: Paul Durrant; Sander Eikelenboom
> Cc: netdev@vger.kernel.org; Wei Liu; Ian Campbell; xen-devel@lists.xen.org
> Subject: RE: [Xen-devel] [PATCH net v2 1/3] xen-netback: remove pointless
> clause from if statement
> 
> From: Paul Durrant
> ...
> > > The behaviour of the Windows frontend is different to netfront; it tries to
> > > keep the shared ring as full as possible so the estimate could be as
> > > pessimistic as you like (as long as it doesn't exceed ring size ;-)) and you'd
> > > never see the lock-up. For some reason (best known to the originator of
> the
> > > code I suspect) the Linux netfront driver limits the number of requests it
> > > posts into the shared ring leading to the possibility of lock-up in the case
> > > where the backend needs more slots than the fontend 'thinks' it should.
> > > But from what i read the ring size is determined by the frontend .. so that
> PV
> > > driver should be able to guarantee that itself ..
> > >
> >
> > The ring size is 256 - that's baked in. The number of pending requests
> available to backend *is*
> > determined by the frontend.
> >
> > > Which begs for the question .. was that change of max_slots_needed
> > > calculation *needed* to prevent the problem you saw on "Windows
> Server
> > > 2008R2",
> > > or was that just changed for correctness ?
> > >
> >
> > It was changed for correctness. As I understand it, use of MAX_SKB_FRAGS
> is incorrect if compound
> > pages are in use as the page size is no longer the slot size. It's also wasteful
> to always wait for
> > space for a maximal packet if the packet you have is smaller so the
> intention of the max estimate was
> > that it should be at least the number of slots required but not excessive. I
> think you've proved that
> > making such an estimate is just too hard and since we don't want to fall
> back to the old dry-run style
> > of slot counting (which meant you had two codepaths that *must* arrive at
> the same number - and they
> > didn't, which is why I was getting the lock-up with Windows guests) I think
> we should just go with
> > full-packing so that we don't need to estimate.
> 
> A reasonable high estimate for the number of slots required for a specific
> message is 'frag_count + total_size/4096'.
> So if that are that many slots free it is definitely ok to add the message.
> 

Hmm, that may work. By total_size, I assume you mean skb->len, so that calculation is based on an overhead of 1 non-optimally packed slot per frag. There'd still need to be a +1 for the GSO 'extra' though.

> I can see a more general problem for transmits.
> I believe a NAPI driver is supposed to indicate that it can't accept
> a tx packet in advance of being given a specific packet to transmit.
> This means it has to keep enough tx ring space for a worst case packet
> (which in some cases can be larger than 1+MAX_SKB_FRAGS) even though
> such a packet is unlikely.
> I would be tempted to save the skb that 'doesn't fit' within the driver
> rather than try to second guess the number of fragments the next packet
> will need.
> 

Well, we avoid that by having an internal queue and then only stopping the tx queue if the skb we were just handed will definitely not fit. TBH though, I think this internal queue is problematic though as we require a context switch to get the skbs into the shared ring and I think the extra latency caused by this is hitting performance. If we do get rid of it then we do need to worry about the size of a maximal skb again.

  Paul

> FWIW the USB3 'bulk' driver has the same problem, fragments can't cross
> 64k boundaries.
> 
> 	David
> 
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
