From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH]: sctp: Fix skb_over_panic resulting from multiple
 invalid parameter errors (CVE-2010-1173)
Date: Wed, 28 Apr 2010 14:52:26 -0400
Message-ID: <20100428185226.GE4818@hmsreliant.think-freely.org>
References: <20100428134748.GA4818@hmsreliant.think-freely.org>
 <4BD83F85.8090308@hp.com>
 <20100428142147.GB4818@hmsreliant.think-freely.org>
 <4BD8481E.3010509@hp.com>
 <4BD875C5.9000907@hp.com>
 <20100428181645.GD4818@hmsreliant.think-freely.org>
 <4BD87DFF.6080502@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sri@us.ibm.com, linux-sctp@vger.kernel.org, eteo@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net, security@kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38430 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756395Ab0D1Swe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 14:52:34 -0400
Content-Disposition: inline
In-Reply-To: <4BD87DFF.6080502@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 28, 2010 at 02:27:11PM -0400, Vlad Yasevich wrote:
> 
> 
> Neil Horman wrote:
> > On Wed, Apr 28, 2010 at 01:52:05PM -0400, Vlad Yasevich wrote:
> >>
> >> Vlad Yasevich wrote:
> >>> Neil Horman wrote:
> >>>> On Wed, Apr 28, 2010 at 10:00:37AM -0400, Vlad Yasevich wrote:
> >>>>> I have this patch and a few others already queued.
> >>>>>
> >>>>> I was planning on sending these today for stable.
> >>>>>
> >>>>> Here is the full list of stable patches I have:
> >>>>>
> >>>>> sctp: Fix oops when sending queued ASCONF chunks
> >>>>> sctp: fix to calc the INIT/INIT-ACK chunk length correctly is set
> >>>>> sctp: per_cpu variables should be in bh_disabled section
> >>>>> sctp: fix potential reference of a freed pointer
> >>>>> sctp: avoid irq lock inversion while call sk->sk_data_ready()
> >>>>>
> >>>>> -vlad
> >>>>>
> >>>> Are you sure?  this oops looks _very_ simmilar to the INIT/INIT-ACK length
> >>>> calculation oops described above, but is in fact different, and requires this
> >>>> patch, from what I can see.  The right fix might be in the ASCONF chunk patch
> >>>> you list above, but I don't see that in your tree at the moment, so I can't be
> >>>> sure.
> >>> As I said, I totally goofed when reading the description and I apologize.
> >>> However, I do one comment regarding the patch.
> >>>
> >>> If the bad packet is REALLY long (I mean close to 65K IP limit), then
> >>> we'll end up allocating a supper huge skb in this case and potentially exceed
> >>> the IP length limitation.  Section 11.4 of rfc 4960 allows us to omit some
> >>> errors and limit the size of the packet.
> >>>
> >>> I would recommend limiting this to MTU worth of potentiall errors.  This is
> >>> on top of what the INIT-ACK is going to carry, so at most we'll sent 2 MTUs
> >>> worth.  That's still a potential by amplification attack, but it's somewhat
> >>> mitigated.
> >>>
> >>> Of course now we have to handle the case of checking for space before adding
> >>> an error cause. :)
> >>>
> >> Hi Neil
> >>
> >> I am also not crazy about the pre-allocation scheme.  In the case where you have
> >> say 100 parameters that are all 'skip' parameters, you'd end up pre-allocating a
> >> huge buffer for absolutely nothing.
> >>
> > Would have been nice if you'd made your opinion known 4 hours ago when I was
> > testing version 2 of this. :)
> > 
> 
> sorry, fighting a head cold and need drugs to think clearly... ;)
> 
Its ok, I'm apparently just feeling a bit short tempered today. Apologies, hope
your feeling better soon :)

> 
> >> This is another point toward a fixed error chunk size and let parameter
> >> processing allocate it when it reaches a parameter that needs an error.
> >>
> > Hmm, ok, what would you say to a pathmtu sized chunk allocation in parameter
> > processing that drops errors beyond its capacity
> > Neil
> 
> Here is my quick take on this.  Haven't tested it at all.
> 
I think somthing like this will work, I've got a variant that uses some helper
functions to create and manipulate fixed length op error chunks going right now.
It does basically the same thing that your doing, but consolidates the checking
of remaining space to a central place.  I think that might be better, as during
my looking at this version, I found two other points that might be vulnerable to
this error (haven't tested to confirm yet though).  I'll post shortly.

Thanks!
Neil

