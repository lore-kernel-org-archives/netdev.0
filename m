From: Vladislav Bolkhovitin <vst@vlnb.net>
Subject: Re: After memory pressure: can't read from tape anymore
Date: Tue, 14 Dec 2010 23:35:37 +0300
Message-ID: <4D07D519.70800@vlnb.net>
References: <1290971729.2814.13.camel@larosa>	 <alpine.LNX.2.00.1011291857420.7923@kai.makisara.local>	 <20101203212453W.fujita.tomonori@lab.ntt.co.jp>	 <4CF905D1.6050903@kolumbus.fi>  <1291388776.2881.4.camel@mulgrave.site>	 <1291395815.2814.376.camel@larosa> <1291399814.2881.66.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Lukas Kolbe <lkolbe@techfak.uni-bielefeld.de>,
	=?ISO-8859-1?Q?Kai_M?= =?ISO-8859-1?Q?=E4kisara?=
	<kai.makisara@kolumbus.fi>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	linux-scsi@vger.kernel.org, Kashyap Desai <Kashyap.Desai@lsi.com>,
	netdev@vger.kernel.org
To: James Bottomley <James.Bottomley@suse.de>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1291399814.2881.66.camel@mulgrave.site>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Bottomley, on 12/03/2010 09:10 PM wrote:
>>>> Thanks for noticing this bug. I hope this helps the users. The question 
>>>> about number of s/g segments is still valid for the direct i/o case but 
>>>> that is optimization and not whether one can read/write.
>>>
>>> Realistically, though, this will only increase the probability of making
>>> an allocation work, we can't get this to a certainty.
>>>
>>> Since we fixed up the infrastructure to allow arbitrary length sg lists,
>>> perhaps we should document what cards can actually take advantage of
>>> this (and how to do so, since it's not set automatically on boot).  That
>>> way users wanting tapes at least know what the problems are likely to be
>>> and how to avoid them in their hardware purchasing decisions. The
>>> corollary is that we should likely have a list of not recommended cards:
>>> if they can't go over 128 SG elements, then they're pretty much
>>> unsuitable for modern tapes.
>>
>> Are you implying here that the LSI SAS1068E is unsuitable to drive two
>> LTO-4 tape drives? Or is it 'just' a problem with the driver?
> 
> The information seems to be the former.  There's no way the kernel can
> guarantee physical contiguity of memory as it operates.  We try to
> defrag, but it's probabalistic, not certain, so if we have to try to
> find a physically contiguous buffer to copy into for an operation like
> this, at some point that allocation is going to fail.

What is interesting to me in this regard is how networking with 9K jumbo
frames manages to work acceptably reliable? Jumbo frames used
sufficiently often, including under high memory pressure.

I'm not a deep networking guru, but network drivers need to allocate
physically continual memory for skbs, which means 16K per 9K packet,
which means order 2 allocations per skb.

I guess, it works reliably, because for networking it is OK to drop an
incoming packet and retry allocation for the next one later.

If so, maybe similarly in this case it is worth to not return allocation
error immediately, but retry it several times after few seconds intervals?

Usually tape read/write operations have pretty big timeouts, like 60
seconds. In this time it is possible to retry 10 times in 5 seconds
between retries.

Vlad

> The only way to be certain you can get a 2MB block down to a tape device
> is to be able to transmit the whole thing as a SG list of fully
> discontiguous pages.  On a system with 4k pages, that requires 512 SG
> entries.  From what I've heard Kashyap say, that can't currently be done
> on the 1068 because of firmware limitations (I'm not entirely clear on
> this, but that's how it sounds to me ... if there is a way of making
> firmware accept more than 128 SG elements per SCSI command, then it is a
> fairly simple driver change).  This isn't something we can work around
> in the driver because the transaction can't be split ... it has to go
> down as a single WRITE command with a single output data buffer.
> 
> The LSI 1068 is an upgradeable firmware system, so it's always possible
> LSI can come up with a firmware update that increases the size (this
> would also require a corresponding driver change), but it doesn't sound
> to be something that can be done in the driver alone.
> 
> James
