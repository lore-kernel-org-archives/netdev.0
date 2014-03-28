From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [Xen-devel] [PATCH net v2 1/3] xen-netback: remove pointless
 clause from if statement
Date: Fri, 28 Mar 2014 09:36:42 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD029DE36@AMSPEX01CL01.citrite.net>
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
 <1054504065.20140328015521@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:58343 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbaC1Jgn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 05:36:43 -0400
In-Reply-To: <1054504065.20140328015521@eikelenboom.it>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
> Sent: 28 March 2014 00:55
> To: Paul Durrant
> Cc: netdev@vger.kernel.org; Wei Liu; Ian Campbell; xen-devel@lists.xen.org
> Subject: Re: [Xen-devel] [PATCH net v2 1/3] xen-netback: remove pointless
> clause from if statement
> 
> 
> Thursday, March 27, 2014, 7:34:54 PM, you wrote:
> 
> > <big snip>
> 
> >>> >>
> >>> >> > So, it may be that the worse-case estimate is now too bad. In the
> case
> >>> >> where it's failing for you it would be nice to know what the estimate
> was
> >>>
> >>>
> >>> > Ok, so we cannot be too pessimistic. In that case I don't see there's a
> lot
> >>> > of
> >>> > choice but to stick with the existing DIV_ROUND_UP (i.e. don't assume
> >>> > start_new_rx_buffer() returns true every time) and just add the extra
> 1.
> >>>
> >>> Hrmm i don't like a "magic" 1 bonus slot, there must be some theoretical
> >>> backing.
> 
> > I don't like it either, but theory suggested each frag should take no more
> > space than the original DIV_ROUND_UP and that proved to be wrong, but I
> cannot
> > figure out why.
> 
> >>> And since the original problem always seemed to occur on a packet with
> a
> >>> single large frag, i'm wondering
> >>> if this 1 would actually be correct in other cases.
> 
> > That's why I went for an extra 1 per frag... a pessimal slot packing i.e. 2
> > byte frag may span 2 slots, PAGE_SIZE + 2 bytes may span 3, etc. etc.
> 
> > In what situation my a 2 byte frag span 2 slots ?
> 
> > At least there must be a theoretical cap to the number of slots needed ..
> > - assuming and SKB can contain only 65535 bytes
> > - assuming a slot can take max PAGE_SIZE and frags are slit into PAGE_SIZE
> pieces ..
> 
> > - it could only max contain 15 PAGE_SIZE slots if nicely aligned ..
> > - double it ..  and at 30 we wouldn't still be near that 52 estimate and i don't
> know the ring size
> >   but wasn't that 32 ? So if the ring get's fully drained we shouldn't stall
> there.
> 
> 
> >>> Well this is what i said earlier on .. it's hard to estimate upfront if
> >>> "start_new_rx_buffer()" will return true,
> >>> and how many times that is possible per frag .. and if that is possible for
> >>> only
> >>> 1 frag or for all frags.
> >>>
> >>> The problem is now replaced from packets with 1 large frag (for which it
> >>> didn't account properly leading to a too small estimate) .. to packets
> >>> with a large number of (smaller) frags .. leading to a too large over
> >>> estimation.
> >>>
> >>> So would there be a theoretical maximum how often that path could hit
> >>> based on a combination of sizes (total size of all frags, nr_frags, size per
> >>> frag)
> >>> ?
> >>> - if you hit "start_new_rx_buffer()" == true  in the first frag .. could you
> >>> hit it
> >>> in a next frag ?
> >>> - could it be limited due to something like the packet_size / nr_frags /
> >>> page_size ?
> >>>
> >>> And what was wrong with the previous calculation ?
> >>>                  int max = DIV_ROUND_UP(vif->dev->mtu, PAGE_SIZE);
> >>>                  if (vif->can_sg || vif->gso_mask || vif->gso_prefix_mask)
> >>>                          max += MAX_SKB_FRAGS + 1; /* extra_info + frags */
> >>>
> 
> >> This is not safe if frag size can be > PAGE_SIZE.
> 
> > #define MAX_SKB_FRAGS (65536/PAGE_SIZE + 2)
> 
> > So if one of the frags is > PAGE_SIZE ..
> > wouldn't that imply that we have nr_frags < MAX_SKB_FRAGS because we
> are limited by the total packet size ?
> > (so we would spare a slot since we have a frag less .. but spend one more
> because we have a frag that needs 2 slots ?)
> 
> > (and that this should even be pessimistic since we didn't substract the
> header etc from the max total packet size ?)
> 
> 
> > So from what i said early, you could probably do the pessimistic estimate
> (that would help when packets have a small skb->data_len
> > (space occupied by frags)) so the estimate would be less then the old one
> based on MAX_SKB_FRAGS causing the packet to be processed earlier.
> > And CAP it using the old way since a packet should never be able to use
> more slots than that theoretical max_slots (which hopefully is less than
> > the ring size, so a packet can always be processed if the ring is finally
> emptied.
> 
> ok .. annotated "xenvif_gop_frag_copy()" to print what it did when we end
> up with (vif->rx.req_cons - req_cons_start) > estimatedcost for that frag
> where estimatedcost = DIV_ROUND_UP(size, PAGE_SIZE).
> 
> So the calculation indeed didn't take the offset used into account.
> 
> vif vif-7-0 vif7.0: ?!?!? xenvif_gop_frag_copy: frag costed more than est. 3>2
> | start i:0 size:7120 offset:1424 estimatedcost: 2
> begin i:0 size:7120 offset:1424 bytes:308159856 head:1282276652
>  d2 d4 d5
> begin i:1 size:4448 offset:0 bytes:2672 head:1282276652
>  d2 d4 d5
> begin i:2 size:352 offset:0 bytes:4096 head:1282276652
>  d1 d2 d5
> end i:3 size:0 offset:352
> 
> In the first round we only process 2672 bytes (instead of a full 4096 that could
> fit in a slot),
> which begs the question if it's actually needed to use the same offset from
> the frags in the slots ?
> 
> And this printk hits quite often for me ..

The reason for paying attention to the offset is that the grant copy hypercall cannot cross a 4k boundary. (Note that the requirement is that slots are limited to 4k, so the actual page size in the front or backend is irrelevant to the protocol). So, I think the start_new_rx_buffer() logic is there to try to limit the number of grant copy operations  - i.e. the code is supposed  to copy enough to align the source and dest buffers on a 4k boundary and then copy in 4k chunks. I seriously wonder whether it's worth limiting the number of copy ops in this way though as, if we did not do this, we'd have the benefit of knowing exactly how many slots each skb needs.

  Paul

> 
> >>> That perhaps also misses some theoretical backing, what if it would have
> >>> (MAX_SKB_FRAGS - 1) nr_frags, but larger ones that have to be split to
> >>> fit in a slot. Or is the total size of frags a skb can carry limited to
> >>> MAX_SKB_FRAGS / PAGE_SIZE ? .. than you would expect that
> >>> MAX_SKB_FRAGS is a upper limit.
> >>> (and you could do the new check maxed by MAX_SKB_FRAGS so it
> doesn't
> >>> get to a too large non reachable estimate).
> >>>
> >>> But as a side question .. the whole "get_next_rx_buffer()" path is
> needed
> >>> for when a frag could not fit in a slot
> >>> as a whole ?
> 
> 
> >> Perhaps it would be best to take the hit on copy_ops and just tightly pack,
> so
> >> we only start a new slot when the current one is completely full; then
> actual
> >> slots would simply be DIV_ROUND_UP(skb->len, PAGE_SIZE) (+ 1 for the
> extra if
> >> it's a GSO).
> 
> > Don't know if and how much a performance penalty that would be.
> 
> >>  Paul
> 
> 
> 
> 
> 
