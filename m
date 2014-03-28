From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [Xen-devel] [PATCH net v2 1/3] xen-netback: remove pointless clause from if statement
Date: Fri, 28 Mar 2014 10:59:42 +0100
Message-ID: <1112313727.20140328105942@eikelenboom.it>
References: <1395924973-42904-1-git-send-email-paul.durrant@citrix.com> <1395924973-42904-2-git-send-email-paul.durrant@citrix.com> <289461862.20140327144546@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029C992@AMSPEX01CL01.citrite.net> <68689563.20140327150256@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029CAA6@AMSPEX01CL01.citrite.net> <874580615.20140327174607@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029D28D@AMSPEX01CL01.citrite.net> <636041055.20140327181524@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029D498@AMSPEX01CL01.citrite.net> <1279623918.20140327193454@eikelenboom.it> <602920213.20140327202235@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029DDEA@AMSPEX01CL01.citrite.net> <1144281350.20140328103919@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029DFE7@AMS
 PEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:40474 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908AbaC1J7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 05:59:47 -0400
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD029DFE7@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Friday, March 28, 2014, 10:47:20 AM, you wrote:

>> -----Original Message-----
>> From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
>> Sent: 28 March 2014 09:39
>> To: Paul Durrant
>> Cc: netdev@vger.kernel.org; Wei Liu; Ian Campbell; xen-devel@lists.xen.org
>> Subject: Re: [Xen-devel] [PATCH net v2 1/3] xen-netback: remove pointless
>> clause from if statement
>> 
>> 
>> Friday, March 28, 2014, 10:30:27 AM, you wrote:
>> 
>> >> -----Original Message-----
>> >> From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
>> >> Sent: 27 March 2014 19:23
>> >> To: Paul Durrant
>> >> Cc: netdev@vger.kernel.org; Wei Liu; Ian Campbell; xen-
>> devel@lists.xen.org
>> >> Subject: Re: [Xen-devel] [PATCH net v2 1/3] xen-netback: remove
>> pointless
>> >> clause from if statement
>> >>
>> >>
>> >> Thursday, March 27, 2014, 7:34:54 PM, you wrote:
>> >>
>> >> > <big snip>
>> >>
>> >> >>> >>
>> >> >>> >> > So, it may be that the worse-case estimate is now too bad. In
>> the
>> >> case
>> >> >>> >> where it's failing for you it would be nice to know what the
>> estimate
>> >> was
>> >> >>>
>> >> >>>
>> >> >>> > Ok, so we cannot be too pessimistic. In that case I don't see there's
>> a
> > The behaviour of the Windows frontend is different to netfront; it tries to
> keep the shared ring as full as possible so the estimate could be as
> pessimistic as you like (as long as it doesn't exceed ring size ;-)) and you'd
> never see the lock-up. For some reason (best known to the originator of the
> code I suspect) the Linux netfront driver limits the number of requests it
> posts into the shared ring leading to the possibility of lock-up in the case
> where the backend needs more slots than the fontend 'thinks' it should.
> But from what i read the ring size is determined by the frontend .. so that PV
> driver should be able to guarantee that itself ..
> 

> The ring size is 256 - that's baked in. The number of pending requests
> available to backend *is* determined by the frontend.

Ah ok, does it also reverse that space ?
(if so .. why not use it to allow multiple complete packets to be shoveled in)

> Which begs for the question .. was that change of max_slots_needed
> calculation *needed* to prevent the problem you saw on "Windows Server
> 2008R2",
> or was that just changed for correctness ?
> 

> It was changed for correctness. As I understand it, use of MAX_SKB_FRAGS is
> incorrect if compound pages are in use as the page size is no longer the slot
> size. It's also wasteful to always wait for space for a maximal packet if the
> packet you have is smaller so the intention of the max estimate was that it
> should be at least the number of slots required but not excessive. I think
> you've proved that making such an estimate is just too hard and since we don't
> want to fall back to the old dry-run style of slot counting (which meant you
> had two codepaths that *must* arrive at the same number - and they didn't,
> which is why I was getting the lock-up with Windows guests) I think we should
> just go with full-packing so that we don't need to estimate.

Ok i asked this question since the about to be released 3.14 does now underestimate and
it causes a regression.
So if that part of your patches is not involved in fixing the stated problem / regression i think
just that calculation change should be reverted to the MAX_SKB_FRAGS variant again.
It's more wasteful (as it always has been) but that is better than incorrect and inducing buffer overrun IMHO.

That would give time to think, revise and test this for 3.15.

BTW: if a slot is always 4k, should it check with PAGE_SIZE then on a lot of occasions or just with the
hardcoded 4k slot size ? (at the moment you only have x86 dom0 so probably the page_size==4k is guaranteed that way,
but nevertheless.)

> Paul
