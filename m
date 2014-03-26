From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [Xen-devel] Xen-unstable Linux 3.14-rc3 and 3.13 Network
 troubles "bisected"
Date: Wed, 26 Mar 2014 16:25:21 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD029B106@AMSPEX01CL01.citrite.net>
References: <1744594108.20140318162127@eikelenboom.it>
 <20140318160412.GB16807@zion.uk.xensource.com>
 <1701035622.20140318211402@eikelenboom.it>
 <722971844.20140318221859@eikelenboom.it>
 <1688396550.20140319001104@eikelenboom.it>
 <20140319113532.GD16807@zion.uk.xensource.com>
 <246793256.20140319220752@eikelenboom.it>
 <20140321164958.GA31766@zion.uk.xensource.com>
 <1334202265.20140321182727@eikelenboom.it>
 <1056661597.20140322192834@eikelenboom.it>
 <20140325151539.GG31766@zion.uk.xensource.com>
 <79975567.20140325162942@eikelenboom.it>
 <1972209744.20140326121116@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029AD94@AMSPEX01CL01.citrite.net>
 <1715463578.20140326162245@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029AFC1@AMSPEX01CL01.citrite.net>
 <799579453.20140326170641@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Wei Liu <wei.liu2@citrix.com>, annie li <annie.li@oracle.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <799579453.20140326170641@eikelenboom.it>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
> Sent: 26 March 2014 16:07
> To: Paul Durrant
> Cc: Wei Liu; annie li; Zoltan Kiss; xen-devel@lists.xen.org; Ian Campbell; linux-
> kernel; netdev@vger.kernel.org
> Subject: Re: [Xen-devel] Xen-unstable Linux 3.14-rc3 and 3.13 Network
> troubles "bisected"
> 
> 
> Wednesday, March 26, 2014, 4:50:30 PM, you wrote:
> 
> >> -----Original Message-----
> >> From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
> >> Sent: 26 March 2014 15:23
> >> To: Paul Durrant
> >> Cc: Wei Liu; annie li; Zoltan Kiss; xen-devel@lists.xen.org; Ian Campbell;
> linux-
> >> kernel; netdev@vger.kernel.org
> >> Subject: Re: [Xen-devel] Xen-unstable Linux 3.14-rc3 and 3.13 Network
> >> troubles "bisected"
> >>
> >>
> >> Wednesday, March 26, 2014, 3:44:42 PM, you wrote:
> >>
> >> >> -----Original Message-----
> >> >> From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
> >> >> Sent: 26 March 2014 11:11
> >> >> To: Paul Durrant
> >> >> Cc: Wei Liu; annie li; Zoltan Kiss; xen-devel@lists.xen.org; Ian Campbell;
> >> linux-
> >> >> kernel; netdev@vger.kernel.org
> >> >> Subject: Re: [Xen-devel] Xen-unstable Linux 3.14-rc3 and 3.13 Network
> >> >> troubles "bisected"
> >> >>
> >> >> Paul,
> >> >>
> >> >> You have been awfully silent for this whole thread while this is a
> >> regression
> >> >> caused by a patch of you
> >> >> (ca2f09f2b2c6c25047cfc545d057c4edfcfe561c as clearly stated much
> earlier
> >> in
> >> >> this thread).
> >> >>
> >>
> >> > Sorry, I've been distracted...
> >>
> >> >> The commit messages states:
> >> >>     "net_rx_action() is the place where we could do with an accurate
> >> >> predicition but,
> >> >>     since that has proven tricky to calculate, a cheap worse-case (but not
> >> too
> >> >> bad)
> >> >>     estimate is all we really need since the only thing we *must* prevent
> is
> >> >> xenvif_gop_skb()
> >> >>     consuming more slots than are available."
> >> >>
> >> >> Your "worst-case" calculation stated in the commit message is clearly
> not
> >> the
> >> >> worst case,
> >> >> since it doesn't take calls to "get_next_rx_buffer" into account.
> >> >>
> >>
> >> > It should be taking into account the behaviour of
> start_new_rx_buffer(),
> >> which should be true if a slot is full or a frag will overflow the current slot
> and
> >> doesn't require splitting.
> >> > The code in net_rx_action() makes the assumption that each frag will
> >> require as many slots as its size requires, i.e. it assumes no packing of
> >> multiple frags into a single slot, so it should be a worst case.
> >> > Did I miss something in that logic?
> >>
> >> Yes.
> >> In "xenvif_gop_skb()" this loop:
> >>
> >>         for (i = 0; i < nr_frags; i++) {
> >>                 xenvif_gop_frag_copy(vif, skb, npo,
> >>                                      skb_frag_page(&skb_shinfo(skb)->frags[i]),
> >>                                      skb_frag_size(&skb_shinfo(skb)->frags[i]),
> >>                                      skb_shinfo(skb)->frags[i].page_offset,
> >>                                      &head);
> >>         }
> >>
> >> Is capable of using up (at least) 1 slot more than is anticipated for in
> >> "net_rx_action()"  by this code:
> >>
> >>                 for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
> >>                         unsigned int size;
> >>                         size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
> >>                         max_slots_needed += DIV_ROUND_UP(size, PAGE_SIZE);
> >>                 }
> >>
> >> And this happens when it calls "get_next_rx_buffer()" from
> >> "xenvif_gop_frag_copy()" where it's breaking down the frag.
> >>
> 
> > The function that determines whether to consume another slot is
> start_new_rx_buffer() and for each frag I don't see why this would return
> true more than DIV_ROUND_UP(size, PAGE_SIZE) times.
> > It may be called more times than that since the code in
> xenvif_gop_frag_copy() must also allow for the offset of the frag but should
> not return true in all cases.
> > So, I still cannot see why a frag would ever consume more than
> DIV_ROUND_UP(size, PAGE_SIZE) slots.
> 
> Well here a case were a frag is broken down in 2 pieces:
> 
> [ 1156.870372] vif vif-7-0 vif7.0: ?!? xenvif_gop_frag_copy Me here 1  npo-
> >meta_prod:39 vif->rx.sring->req_prod:2105867 vif->rx.req_cons:2105867
> npo->copy_gref:760  npo->copy_off:4096  MAX_BUFFER_OFFSET:4096
> bytes:560 size:560  offset:0 head:1273462060 i:2 vif->rx.sring-
> >req_event:2104275 estimated_slots_needed:4 reserved_slots_left:0
> [ 1156.871971] vif vif-7-0 vif7.0: ?!? xenvif_start_xmit stopping queue !
> min_slots_needed:1 min_slots_needed_2:0 min_slots_needed_3:0 vif-
> >rx.sring->req_prod:2105867 vif->rx.req_cons:2105867 vif->rx.sring-
> >req_event:2105868 skb->len:66 skb->data_len:0
> [ 1156.964316] vif vif-7-0 vif7.0: ?!? get_next_rx_buffer before req npo-
> >meta_prod:39 vif->rx.sring->req_prod:2105867 vif->rx.req_cons:2105867
> vif->rx.sring->req_event:2105868, reserved_slots_left:0
> [ 1157.001635] vif vif-7-0 vif7.0: ?!? get_next_rx_buffer after req npo-
> >meta_prod:39 vif->rx.sring->req_prod:2105867 vif->rx.req_cons:2105868
> req->gref:4325379 req->id:11 vif->rx.sring->req_event:2105868
> reserved_slots_left:-1
> [ 1157.039095] vif vif-7-0 vif7.0: ?!? xenvif_gop_frag_copy Me here 2  npo-
> >meta_prod:40 vif->rx.sring->req_prod:2105867 vif->rx.req_cons:2105868
> npo->copy_gref:4325379  npo->copy_off:0  MAX_BUFFER_OFFSET:4096
> bytes:560 size:560  offset:0 head:1273462060 i:2 vif->rx.sring-
> >req_event:2105868 estimated_slots_needed:4 reserved_slots_left:-1
> [ 1157.095216] vif vif-7-0 vif7.0: ?!? xenvif_gop_frag_copy Me here end npo-
> >meta_prod:40 vif->rx.sring->req_prod:2105867 vif->rx.req_cons:2105868
> npo->copy_gref:4325379 npo->copy_off:560  MAX_BUFFER_OFFSET:4096
> bytes:560 size:0  offset:560 head:1273462060 i:3 vif->rx.sring-
> >req_event:2105868 gso_gaps:0 estimated_slots_needed:4
> reserved_slots_left:-1
> [ 1157.151338] vif vif-7-0 vif7.0: ?!? xenvif_gop_skb Me here 4 after npo-
> >meta_prod:40 old_meta_prod:36 vif->rx.sring->req_prod:2105867 vif-
> >rx.req_cons:2105868 meta->gso_type:1 meta->gso_size:1448 nr_frags:1
> req->gref:657 req->id:7 estimated_slots_needed:4 i(frag):0 j(data):1
> reserved_slots_left:-1
> [ 1157.188908] vif vif-7-0 vif7.0: ?!? xenvif_gop_skb Me here 5 npo-
> >meta_prod:40 old_meta_prod:36 vif->rx.sring->req_prod:2105867 vif-
> >rx.req_cons:2105868 meta->gso_type:1 meta->gso_size:1448 nr_frags:1
> req->gref:657 req->id:7 estimated_slots_needed:4 j(data):1
> reserved_slots_left:-1    used in funcstart: 0 + 1 .. used_dataloop:1 ..
> used_fragloop:3
> [ 1157.244975] vif vif-7-0 vif7.0: ?!? xenvif_rx_action me here 2 ..  vif-
> >rx.sring->req_prod:2105867 vif->rx.req_cons:2105868 sco-
> >meta_slots_used:4 max_upped_gso:1 skb_is_gso(skb):1
> max_slots_needed:4 j:6 is_gso:1 nr_frags:1 firstpart:1 secondpart:2
> reserved_slots_left:-1
> 
> - When processing an SKB we end up in "xenvif_gop_frag_copy" while prod
> == cons ... but we still have bytes and size left ..
> - start_new_rx_buffer() has returned true ..
> - so we end up in get_next_rx_buffer
> - this does a RING_GET_REQUEST and ups cons ..
> - and we end up with a bad grant reference.
> 
> Sometimes we are saved by the bell .. since additional slots have become
> free (you see cons become > prod in "get_next_rx_buffer" but shortly after
> that prod is increased ..
> just in time to not cause a overrun).
> 

Ah, but hang on... There's a BUG_ON meta_slots_used > max_slots_needed, so if we are overflowing the worst-case calculation then why is that BUG_ON not firing?

  Paul

> If you need additional / other info, please cook up a debug patch with what
> you need.
> 
> --
> Sander
> 
> 
> 
> 
> 
> 
> >   Paul
> 
> >> Ultimately this results in bad grant reference warnings (and packets
> marked
> >> as "errors" in the interface statistics).
> >>
> >> In my case it always seems to be a skb with 1 frag which is broken down in
> 5
> >> or 6 pieces ..
> >>
> >> So "get_next_rx_buffer()" is called once .. and i'm overrunning the ring
> with
> >> 1 slot, but i'm not sure if that's not coincedence
> >> since in the code there seem to be no explicit limitation on how often this
> >> code path is taken. So perhaps it's implicitly limited
> >> since packets and frags can't be arbitrarily large in comparison with the
> >> page_size but that's not something i'm capable of figuring out :-)
> >>
> >>
> >>
> >> >   Paul
> >>
> >> >> Problem is that a worst case calculation would probably be reverting to
> >> the
> >> >> old calculation,
> >> >> and the problems this patch was trying to solve would reappear, but
> >> >> introducing new regressions
> >> >> isn't very useful either. And since it seems such a tricky and fragile
> thing to
> >> >> determine, it would
> >> >> probably be best to be split into a distinct function with a comment to
> >> explain
> >> >> the rationale used.
> >> >>
> >> >> Since this doesn't seem to progress very fast .. CC'ed some more folks
> ..
> >> you
> >> >> never know ..
> >> >>
> >> >> --
> >> >> Sander
> >> >>
> >> >>
> >> >> Tuesday, March 25, 2014, 4:29:42 PM, you wrote:
> >> >>
> >> >>
> >> >> > Tuesday, March 25, 2014, 4:15:39 PM, you wrote:
> >> >>
> >> >> >> On Sat, Mar 22, 2014 at 07:28:34PM +0100, Sander Eikelenboom
> wrote:
> >> >> >> [...]
> >> >> >>> > Yes there is only one frag .. but it seems to be much larger than
> >> >> PAGE_SIZE .. and xenvif_gop_frag_copy brakes that frag down into
> >> smaller
> >> >> bits .. hence the calculation in xenvif_rx_action determining the slots
> >> needed
> >> >> by doing:
> >> >> >>>
> >> >> >>> >                 for (i = 0; i < nr_frags; i++) {
> >> >> >>> >                         unsigned int size;
> >> >> >>> >                         size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
> >> >> >>> >                         max_slots_needed += DIV_ROUND_UP(size,
> >> PAGE_SIZE);
> >> >> >>> >                 }
> >> >> >>>
> >> >> >>> > But the code in xenvif_gop_frag_copy .. seems to be needing
> one
> >> >> more slot (from the emperical test) .. and calling "get_next_rx_buffer"
> >> >> seems involved in that ..
> >> >> >>>
> >> >> >>> Hmm looked again .. and it seems this is it .. when your frags are
> large
> >> >> enough you have the chance of running into this.
> >> >> >>>
> >> >>
> >> >> >> get_next_rx_buffer is guarded by start_new_rx_buffer. Do you
> see
> >> any
> >> >> >> problem with that implementation?
> >> >> > In general no, but "get_next_rx_buffer" up's cons .. and the
> calculations
> >> >> done in "xenvif_rx_action" for max_slots_needed to prevent the
> overrun
> >> >> > don't count in this possibility. So it's not the guarding of
> >> >> "start_new_rx_buffer" that is at fault. It's the ones early in
> >> >> "xenvif_rx_action".
> >> >> > The ones that were changed by Paul's patch from MAX_SKB_FRAGS
> to a
> >> >> calculated value that should be a "slim fit".
> >> >>
> >> >> > The problem is in determining upfront in "xenvif_rx_action" when
> and
> >> how
> >> >> often the "get_next_rx_buffer" path will be taken.
> >> >> > Unless there are other non direct restrictions (from a size point of
> view)
> >> it
> >> >> can be called multiple times per frag per skb.
> >> >>
> >> >> >>> Problem is .. i don't see an easy fix, the "one more slot" of the
> >> empirical
> >> >> test doesn't seem to be the worst case either (i think):
> >> >> >>>
> >> >> >>> - In my case the packets that hit this only have 1 frag, but i could
> have
> >> >> had more frags.
> >> >> >>>   I also think you can't rule out the possibility of doing the
> >> >> "get_next_rx_buffer" for multiple subsequent frags from one packet,
> >> >> >>>   so in the worst (and perhaps even from a single frag since it's
> looped
> >> >> over a split of it in what seems PAGE_SIZE pieces.)
> >> >> >>>   - So an exact calculation of how much slots we are going to need
> for
> >> >> hitting this "get_next_rx_buffer"  upfront in "xenvif_rx_action" seems
> >> >> unfeasible.
> >> >> >>>   - A worst case gamble seems impossible either .. if you take
> multiple
> >> >> frags * multiple times the "get_next_rx_buffer" ... you would probably
> be
> >> >> back at just
> >> >> >>>     setting the needed_slots to MAX_SKB_FRAGS.
> >> >> >>>
> >> >> >>> - Other thing would be checking for the available slots before
> doing
> >> the
> >> >> "get_next_rx_buffer" .. how ever .. we don't account for how many
> slots
> >> we
> >> >> still need to
> >> >> >>>   just process the remaining frags.
> >> >> >>>
> >> >>
> >> >> >> We've done a worst case estimation for whole SKB (linear area + all
> >> >> >> frags) already, at the very first beginning. That's what
> >> >> >> max_slots_needed is for.
> >> >>
> >> >> >>> - Just remove the whole "get_next_rx_buffer".. just tested it but
> it
> >> >> seems the "get_next_rx_buffer" is necessary ..  when i make
> >> >> start_new_rx_buffer always return false
> >> >> >>>   i hit the bug below :S
> >> >> >>>
> >> >> >>> So the questions are ... is the "get_next_rx_buffer" part really
> >> necessary
> >> >> ?
> >> >> >>>    - if not, what is the benefit of the "get_next_rx_buffer" and
> does
> >> that
> >> >> outweigh the additional cost of accounting
> >> >> >>>      of needed_slots for the frags that have yet to be processed ?
> >> >> >>>    - if yes, erhmmm what would be the best acceptable solution ..
> >> >> returning to using MAX_SKB_FRAGS ?
> >> >> >>>
> >> >>
> >> >> >> I think you need to answer several questions first:
> >> >> >> 1. is max_slots_needed actually large enough to cover whole SKB?
> >> >> >         No it's not if, you end up calling "get_next_rx_buffer" one or
> >> multiple
> >> >> times when processing the SKB
> >> >> >         you have the chance of overrunning (or be saved because prod
> gets
> >> >> upped before you overrun).
> >> >>
> >> >> >> 2. is the test of ring slot availability acurate?
> >> >> >         Seems to be.
> >> >>
> >> >> >> 3. is the number of ring slots consumed larger than
> >> max_slots_needed? (I
> >> >> >>    guess the answer is yes)
> >> >> >         Yes that was the whole point.
> >> >>
> >> >> >> 4. which step in the break-down procedure causes backend to
> overrun
> >> >> the
> >> >> >>    ring?
> >> >> >         The "get_next_rx_buffer" call .. that is not accounted for (which
> can
> >> be
> >> >> called
> >> >> >         multiple times per frag (unless some other none obvious size
> >> >> restriction limits this
> >> >> >         to one time per frag or one time per SKB).
> >> >> >         In my errorneous case it is called one time, but it would be nice if
> >> there
> >> >> would be some theoretical proof
> >> >> >         instead of just some emperical test.
> >> >>
> >> >>
> >> >> >> It doesn't matter how many frags your SKB has and how big a frag
> is. If
> >> >> >> every step is correct then you're fine. The code you're looking at
> >> >> >> (start_new_rx_buffer / get_next_rx_buffer and friend) needs to
> be
> >> >> >> carefully examined.
> >> >>
> >> >> > Well it seems it only calls "get_next_rx_buffer" in some special cases
> ..
> >> >> (and that also what i'm seeing because it doesn't happen
> >> >> > continously.
> >> >>
> >> >> > Question is shouldn't this max_needed_slots calc be reverted to
> what it
> >> >> was before 3.14 and take the time in 3.15 to figure out a
> >> >> > the theoretical max (if it can be calculated upfront) .. or another way
> to
> >> >> guarantee the code is able to process the whole SKB  ?
> >> >>
> >> >> >> Wei.
> >> >>
> >> >>
> >> >>
> >> >>
> >>
> >>
> 
> 
