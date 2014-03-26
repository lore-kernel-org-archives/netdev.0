From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [Xen-devel] Xen-unstable Linux 3.14-rc3 and 3.13 Network troubles "bisected"
Date: Wed, 26 Mar 2014 21:17:44 +0100
Message-ID: <103668635.20140326211744@eikelenboom.it>
References: <1744594108.20140318162127@eikelenboom.it> <20140318160412.GB16807@zion.uk.xensource.com> <1701035622.20140318211402@eikelenboom.it> <722971844.20140318221859@eikelenboom.it> <1688396550.20140319001104@eikelenboom.it> <20140319113532.GD16807@zion.uk.xensource.com> <246793256.20140319220752@eikelenboom.it> <20140321164958.GA31766@zion.uk.xensource.com> <1334202265.20140321182727@eikelenboom.it> <1056661597.20140322192834@eikelenboom.it> <20140325151539.GG31766@zion.uk.xensource.com> <79975567.20140325162942@eikelenboom.it> <1972209744.20140326121116@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029AD94@AMSPEX01CL01.citrite.net> <1715463578.20140326162245@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029AFC1@AMSPEX01CL01.citrite.net> <799579453.20140326170641@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029B106@AMSPEX01CL01.citrite.net> <789809468.20140326175352@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029B277@AMSPEX01CL01.citrite.net> <966386043.20140326183304@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029B350@AMSPEX01CL01.citrite.net> <1959698732.20140326190752@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029B49C@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, annie li <annie.li@oracle.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD029B49C@AMSPEX01CL01.citrite.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Wednesday, March 26, 2014, 7:15:30 PM, you wrote:

>> -----Original Message-----
>> From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
>> Sent: 26 March 2014 18:08
>> To: Paul Durrant
>> Cc: Wei Liu; annie li; Zoltan Kiss; xen-devel@lists.xen.org; Ian Campbell; linux-
>> kernel; netdev@vger.kernel.org
>> Subject: Re: [Xen-devel] Xen-unstable Linux 3.14-rc3 and 3.13 Network
>> troubles "bisected"
>> 
>> 
>> Wednesday, March 26, 2014, 6:46:06 PM, you wrote:
>> 
>> > Re-send shortened version...
>> 
>> >> -----Original Message-----
>> >> From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
>> >> Sent: 26 March 2014 16:54
>> >> To: Paul Durrant
>> >> Cc: Wei Liu; annie li; Zoltan Kiss; xen-devel@lists.xen.org; Ian Campbell;
>> linux-
>> >> kernel; netdev@vger.kernel.org
>> >> Subject: Re: [Xen-devel] Xen-unstable Linux 3.14-rc3 and 3.13 Network
>> >> troubles "bisected"
>> >>
>> > [snip]
>> >> >>
>> >> >> - When processing an SKB we end up in "xenvif_gop_frag_copy" while
>> >> prod
>> >> >> == cons ... but we still have bytes and size left ..
>> >> >> - start_new_rx_buffer() has returned true ..
>> >> >> - so we end up in get_next_rx_buffer
>> >> >> - this does a RING_GET_REQUEST and ups cons ..
>> >> >> - and we end up with a bad grant reference.
>> >> >>
>> >> >> Sometimes we are saved by the bell .. since additional slots have
>> become
>> >> >> free (you see cons become > prod in "get_next_rx_buffer" but shortly
>> >> after
>> >> >> that prod is increased ..
>> >> >> just in time to not cause a overrun).
>> >> >>
>> >>
>> >> > Ah, but hang on... There's a BUG_ON meta_slots_used >
>> >> max_slots_needed, so if we are overflowing the worst-case calculation
>> then
>> >> why is that BUG_ON not firing?
>> >>
>> >> You mean:
>> >>                 sco = (struct skb_cb_overlay *)skb->cb;
>> >>                 sco->meta_slots_used = xenvif_gop_skb(skb, &npo);
>> >>                 BUG_ON(sco->meta_slots_used > max_slots_needed);
>> >>
>> >> in "get_next_rx_buffer" ?
>> >>
>> 
>> > That code excerpt is from net_rx_action(),isn't it?
>> 
>> Yes
>> 
>> >> I don't know .. at least now it doesn't crash dom0 and therefore not my
>> >> complete machine and since tcp is recovering from a failed packet  :-)
>> >>
>> 
>> > Well, if the code calculating max_slots_needed were underestimating then
>> the BUG_ON() should fire. If it is not firing in your case then this suggests
>> your problem lies elsewhere, or that meta_slots_used is not equal to the
>> number of ring slots consumed.
>> 
>> It's seem to be the last ..
>> 
>> [ 1157.188908] vif vif-7-0 vif7.0: ?!? xenvif_gop_skb Me here 5 npo-
>> >meta_prod:40 old_meta_prod:36 vif->rx.sring->req_prod:2105867 vif-
>> >rx.req_cons:2105868 meta->gso_type:1 meta->gso_size:1448 nr_frags:1
>> req->gref:657 req->id:7 estimated_slots_needed:4 j(data):1
>> reserved_slots_left:-1    used in funcstart: 0 + 1 .. used_dataloop:1 ..
>> used_fragloop:3
>> [ 1157.244975] vif vif-7-0 vif7.0: ?!? xenvif_rx_action me here 2 ..  vif-
>> >rx.sring->req_prod:2105867 vif->rx.req_cons:2105868 sco-
>> >meta_slots_used:4 max_upped_gso:1 skb_is_gso(skb):1
>> max_slots_needed:4 j:6 is_gso:1 nr_frags:1 firstpart:1 secondpart:2
>> reserved_slots_left:-1
>> 
>> net_rx_action() calculated we would need 4 slots .. and sco-
>> >meta_slots_used == 4 when we return so it doesn't trigger you BUG_ON ..
>> 
>> The 4 slots we calculated are:
>>   1 slot for the data part: DIV_ROUND_UP(offset_in_page(skb->data) +
>> skb_headlen(skb), PAGE_SIZE)
>>   2 slots for the single frag in this SKB from: DIV_ROUND_UP(size, PAGE_SIZE)
>>   1 slot since GSO
>> 
>> In the debug code i annotated all cons++, and the code uses 1 slot to process
>> the data from the SKB as expected but uses 3 slots in the frag chopping loop.
>> And when it reaches the state  were cons > prod it is always in
>> "get_next_rx_buffer".
>> 
>> >> But probably because "npo->copy_prod++" seems to be used for the
>> frags ..
>> >> and it isn't added to  npo->meta_prod ?
>> >>
>> 
>> > meta_slots_used is calculated as the value of meta_prod at return (from
>> xenvif_gop_skb()) minus the value on entry ,
>> > and if you look back up the code then you can see that meta_prod is
>> incremented every time RING_GET_REQUEST() is evaluated.
>> > So, we must be consuming a slot without evaluating RING_GET_REQUEST()
>> and I think that's exactly what's happening...
>> > Right at the bottom of xenvif_gop_frag_copy() req_cons is simply
>> incremented in the case of a GSO. So the BUG_ON() is indeed off by one.
>> 
>> That is probably only done on first iteration / frag ?

> Yes, the extra slot is accounted for right after the head frag is processed

Ok so we are talking about:

if (*head && ((1 << gso_type) & vif->gso_mask)){
                        vif->rx.req_cons++;

Well it had some debug code in place to detect if that path is taken as well:

[ 1157.095216] vif vif-7-0 vif7.0: ?!? xenvif_gop_frag_copy Me here end npo->meta_prod:40 vif->rx.sring->req_prod:2105867 vif->rx.req_cons:2105868 npo->copy_gref:4325379 npo->copy_off:560  MAX_BUFFER_OFFSET:4096 bytes:560 size:0  offset:560 head:1273462060 i:3 vif->rx.sring->req_event:2105868 gso_gaps:0 estimated_slots_needed:4 reserved_slots_left:-1

Well "gso_gaps:0" indicates that in this case that path in "xenvif_gop_frag_copy()" has not been taken in any iteration of that frag.

However i=3 .. so we have done 3 iterations of the loop while we expected to do only 2 ...

So that would mean that somehow the code in "xenvif_gop_frag_copy()" needs more slots
to brake this frag down than the loop with DIV_ROUND_UP(size, PAGE_SIZE) in net_rx_action() has accounted for.
