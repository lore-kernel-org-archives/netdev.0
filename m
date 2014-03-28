From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [Xen-devel] [PATCH net v2 1/3] xen-netback: remove pointless clause from if statement
Date: Fri, 28 Mar 2014 12:35:55 +0100
Message-ID: <90991437.20140328123555@eikelenboom.it>
References: <1395924973-42904-1-git-send-email-paul.durrant@citrix.com> <1395924973-42904-2-git-send-email-paul.durrant@citrix.com> <289461862.20140327144546@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029C992@AMSPEX01CL01.citrite.net> <68689563.20140327150256@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029CAA6@AMSPEX01CL01.citrite.net> <874580615.20140327174607@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029D28D@AMSPEX01CL01.citrite.net> <636041055.20140327181524@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029D498@AMSPEX01CL01.citrite.net> <1279623918.20140327193454@eikelenboom.it> <602920213.20140327202235@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029DDEA@AMSPEX01CL01.citrite.net> <1144281350.20140328103919@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029DFE7@AMS
 PEX01CL01.citrite.net> <063D6719AE5E284EB5DD2968C1650D6D0F6EB615@AcuExch.aculab.com> <9AAE0902D5BC7E449B7C8E4E778ABCD029E138@AMSPEX01CL01.citrite.net> <063D6719AE5E284EB5DD2968C1650D6D0F6EB72D@AcuExch.aculab.com> <196961493.20140328114238@eikelenboom.it> <063D6719AE5E284EB5DD2968C1650D6D0F6EB7AC@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Paul Durrant' <Paul.Durrant@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:41176 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185AbaC1LgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 07:36:02 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6EB7AC@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Friday, March 28, 2014, 12:11:24 PM, you wrote:

> From: Sander Eikelenboom
>> Friday, March 28, 2014, 11:35:58 AM, you wrote:
>> 
>> > From: Paul Durrant
>> >> > A reasonable high estimate for the number of slots required for a specific
>> >> > message is 'frag_count + total_size/4096'.
>> >> > So if that are that many slots free it is definitely ok to add the message.
>> >> >
>> >>
>> >> Hmm, that may work. By total_size, I assume you mean skb->len, so that calculation is based on an
>> >> overhead of 1 non-optimally packed slot per frag. There'd still need to be a +1 for the GSO 'extra'
>> >> though.
>> 
>> > Except I meant '2 * frag_count + size/4096' :-(
>> 
>> > You have to assume that every fragment starts at n*4096-1 (so need
>> > at least two slots). A third slot is only needed for fragments
>> > longer that 1+4096+2 - but an extra one is needed for every
>> > 4096 bytes after that.
>> 
>> He did that in his followup patch series .. that works .. for small packets
>> But for larger ones it's an extremely wasteful estimate and it quickly get larger than the
>> MAX_SKB_FRAGS
>> we had before and even to large causing stalls. I tried doing this type of calculation with a CAP of
>> the old  MAX_SKB_FRAGS calculation and that works.

> I'm confused (easily done).
> If you are trying to guess at the number of packets to queue waiting for
> the thread that sets things up to run then you want an underestimate.
> Since any packets that can't actually be transferred will stay on the queue

We want to overestimate the max_slots_needed .. so that if we check and the ring
hasn't got that many slots free .. we don't dequeue the SKB and wait until there becomes
more space available on the ring.

This is done by a very very cheap minimum estimate .. and a slightly more costly maximum estimate,

The maximum estimate was changed (in said commit) and believed to be the worst case.
But this didn't take the offset into account so it could lead to an underestimation,
which then leads to trying to overrun the ring .. this then fails at the grant_copy code,
since the grant reference is bogus so the hypervisor refuses to do that.

But if you do take the offset into account worst case .. you end up with a gross overestimation
that could even be larger than the ring size, leading to a stall since the packet can never be processed
since the ring can't possibly free more slots that in has. But i think the old calculation is the
theoretical max (due to the limitation in total packetsize not *all* frags can have a offset and be that large
that it would cost more slots).

So you could use the old calc as a CAP so you don't overestimate to the extent that you would stall.
)
