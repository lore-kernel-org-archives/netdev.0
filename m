From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [GIT] Networking
Date: Mon, 09 Nov 2015 11:38:10 +0100
Message-ID: <87io5bh2zx.fsf@stressinduktion.org>
References: <CA+55aFwxDSYSB=bBfCxLadgCmFiOzAi0T0JHLFLK5nkR6cm8tg@mail.gmail.com> <CA+55aFy6nC9tQFE_kRrF-YS9N7Jp18CnSxsLNcnAykNLyXQUtg@mail.gmail.com> <CALCETrUxU_AVcQheeCXc0qTh=o2tmDbDct27QfTCb_+G6qc3gQ@mail.gmail.com> <1446512176.17404.30.camel@kernel.crashing.org> <CA+55aFxas=6fg2LtcLjDB3jM9cHBj=7PnDf-8J31jc3yXNpXNQ@mail.gmail.com> <CALCETrUijiLwtYRwc-UHPkuhh+PoMh0scwffewuJ+7wRBR=Jfg@mail.gmail.com> <CA+55aFxgr=VteHvxj7EY===QbchRdLY56r7cyFxSnuF_G0rqVA@mail.gmail.com> <1446555200.1870849.427743457.63139285@webmail.messagingengine.com> <CA+55aFw-pzoSNnO_eot1c2ZJOWKrFeRhXw4oQQS9dwt4NziHfQ@mail.gmail.com> <CA+55aFzSD=H8pAP7B48HCCdjiB3R-Zvx3Dn=x-BjyiL+3UBeiw@mail.gmail.com> <20151109081219.GA11321@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andy Lutomirski <luto@amacapital.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Andy Lutomirski <luto@kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Sasha Levin <sasha.levin@oracle.com>
To: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:38581 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750770AbbKIKiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 05:38:12 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id DE5612016B
	for <netdev@vger.kernel.org>; Mon,  9 Nov 2015 05:38:11 -0500 (EST)
In-Reply-To: <20151109081219.GA11321@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Ingo Molnar <mingo@kernel.org> writes:

> * Linus Torvalds <torvalds@linux-foundation.org> wrote:
>
>> Does anybody have any particular other "uhhuh, overflow in multiplication" 
>> issues in mind? Because the interface for a saturating multiplication (or 
>> addition, for that matter) would actually be much easier. And would be trivial 
>> to have as an inline asm for compatibility with older versions of gcc too.
>> 
>> Then you could just do that jiffies conversion - or allocation, for that matter 
>> - without any special overflow handling at all. Doing
>> 
>>     buf = kmalloc(sat_mul(sizeof(x), nr), GFP_KERNEL);
>> 
>> would just magically work.
>
> Exactly: saturation is the default behavior for many GPU vector/pixel attributes 
> as well, to simplify and speed up the code and the hardware. I always wanted our 
> ABIs to saturate instead of duplicating complexity with overflow failure logic.

I don't think saturation arithmetic is useful at all in the kernel as a
replacement for overflow/wrap-around checks. Linus' example has a
discrepancy between what the caller expects and the actual number of
bytes allocated. Imagine sat_mul does the operation in signed char and
kmalloc takes only signed chars as an argument, it could actually be a
huge discrepancy that could lead to security vulnerabilities. The call
should definitely error out here and not try to allocate memory of some
different size and return it to the caller.

> In the kernel the first point of failure is missing overflow checks. The second 
> point of failure are buggy overflow checks. We can eliminate both if we just use 
> safe operations that produce output that never exit the valid range. This also 
> happens to result in the simplest code. We should start thinking of overflow 
> checks as rootkit enablers.

Sorry, I don't understand that at all. sat_mul is a rootkit enabler, I
fear. If you allocate a smalelr portion of memory as the caller actually
asked for because of saturation logic, this definitely could lead to
memory corruption and hard to diagnose bugs.

> And note how much this simplifies review and static analysis: if this is the 
> dominant model used in new kernel code then the analysis (human or machine) would 
> only have to ensure that no untrusted input values get multiplied (or added) in an 
> unsafe way. It would not have to be able to understand and track any 'overflow 
> logic' through a maze of return paths, and validate whether the 'overflow logic' 
> is correct for all input parameter ranges...

Sorry, I don't really understand that proposal. :/

> The flip side is marginally less ABI robustness: random input parameters due to 
> memory corruption will just saturate and produce nonsensical results. I don't 
> think it's a big issue, and I also think the simplicity of input parameter 
> validation is _way_ more important than our behavior to random input - but I've 
> been overruled in the past when trying to introduce saturating ABIs, so saturation 
> is something people sometimes find inelegant.

If those nonsensical results are memory corruptions I also don't
agree. I think we need to be very much accurate when dealing with
overflows.

Bye,
Hannes
