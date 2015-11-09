From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [GIT] Networking
Date: Mon, 9 Nov 2015 09:12:19 +0100
Message-ID: <20151109081219.GA11321@gmail.com>
References: <CA+55aFwxDSYSB=bBfCxLadgCmFiOzAi0T0JHLFLK5nkR6cm8tg@mail.gmail.com>
 <CA+55aFy6nC9tQFE_kRrF-YS9N7Jp18CnSxsLNcnAykNLyXQUtg@mail.gmail.com>
 <CALCETrUxU_AVcQheeCXc0qTh=o2tmDbDct27QfTCb_+G6qc3gQ@mail.gmail.com>
 <1446512176.17404.30.camel@kernel.crashing.org>
 <CA+55aFxas=6fg2LtcLjDB3jM9cHBj=7PnDf-8J31jc3yXNpXNQ@mail.gmail.com>
 <CALCETrUijiLwtYRwc-UHPkuhh+PoMh0scwffewuJ+7wRBR=Jfg@mail.gmail.com>
 <CA+55aFxgr=VteHvxj7EY===QbchRdLY56r7cyFxSnuF_G0rqVA@mail.gmail.com>
 <1446555200.1870849.427743457.63139285@webmail.messagingengine.com>
 <CA+55aFw-pzoSNnO_eot1c2ZJOWKrFeRhXw4oQQS9dwt4NziHfQ@mail.gmail.com>
 <CA+55aFzSD=H8pAP7B48HCCdjiB3R-Zvx3Dn=x-BjyiL+3UBeiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Andy Lutomirski <luto@kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Sasha Levin <sasha.levin@oracle.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFzSD=H8pAP7B48HCCdjiB3R-Zvx3Dn=x-BjyiL+3UBeiw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> Does anybody have any particular other "uhhuh, overflow in multiplication" 
> issues in mind? Because the interface for a saturating multiplication (or 
> addition, for that matter) would actually be much easier. And would be trivial 
> to have as an inline asm for compatibility with older versions of gcc too.
> 
> Then you could just do that jiffies conversion - or allocation, for that matter 
> - without any special overflow handling at all. Doing
> 
>     buf = kmalloc(sat_mul(sizeof(x), nr), GFP_KERNEL);
> 
> would just magically work.

Exactly: saturation is the default behavior for many GPU vector/pixel attributes 
as well, to simplify and speed up the code and the hardware. I always wanted our 
ABIs to saturate instead of duplicating complexity with overflow failure logic.

In the kernel the first point of failure is missing overflow checks. The second 
point of failure are buggy overflow checks. We can eliminate both if we just use 
safe operations that produce output that never exit the valid range. This also 
happens to result in the simplest code. We should start thinking of overflow 
checks as rootkit enablers.

And note how much this simplifies review and static analysis: if this is the 
dominant model used in new kernel code then the analysis (human or machine) would 
only have to ensure that no untrusted input values get multiplied (or added) in an 
unsafe way. It would not have to be able to understand and track any 'overflow 
logic' through a maze of return paths, and validate whether the 'overflow logic' 
is correct for all input parameter ranges...

The flip side is marginally less ABI robustness: random input parameters due to 
memory corruption will just saturate and produce nonsensical results. I don't 
think it's a big issue, and I also think the simplicity of input parameter 
validation is _way_ more important than our behavior to random input - but I've 
been overruled in the past when trying to introduce saturating ABIs, so saturation 
is something people sometimes find inelegant.

Thanks,

	Ingo
