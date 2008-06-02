From: Brice Goglin <brice@myri.com>
Subject: Re: howto use ioremap_wc?
Date: Mon, 02 Jun 2008 18:27:31 +0200
Message-ID: <48441F73.5040005@myri.com>
References: <4841143E.5080003@myri.com> <20080531185424.1cd18220@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	"venkatesh.pallipadi@intel.com" <venkatesh.pallipadi@intel.com>
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757331AbYFBQ1p@vger.kernel.org>
In-Reply-To: <20080531185424.1cd18220@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> Brice Goglin <brice@myri.com> wrote
>> We're looking at using ioremap_wc() in myri10ge. No drivers seem to be
>> using it yet, so I'd like to get some clarification regarding
>> ioremap_wc failures, MTRR and so on.
>>
>> What we currently do is mtrr_add() and then ioremap. Depending on the
>> mtrr_add() success, we use the "wc_fifo" or regular PIO with fences to
>> submit requests to the NIC. 
>>     
>
> Ok this leads to a question: since write combining is effectively an
> extension (eg relaxation) to uncached, how much do you care if you
> actually get uncached? Eg can you just use the "WC" function even for
> the case where you get an uncached mapping ?
>   

WC is strictly required for our "wcfifo" path, but this path is actually
not so important nowadays. It is disabled by default and might even be
removed in the future. So, no, myri10ge itself does not really need to
know whether the mapping is actually WC.

The only case I see where it would be helpful is to avoid calling
mtrr_add when WC got enabled through PAT. See below.

> Actually it would make sense for the ioremap_wc() implementation to try
> to add an mtrr I suppose... it's better to be done there than trying to
> do it in some driver....
>   

Agreed, that would be nice!

>From what we discussed here after your reply, our plan is now to just
replace
    ioremap+mtrr_add
with
    ioremap_wc+mtrr_add

If mtrr_add() is moved into ioremap_wc(), we'll remove it from myri10ge.
For now, when PAT is enabled, we may have PAT + MTRR both doing WC, but
I don't think it can break anything, right?

thanks,
Brice
