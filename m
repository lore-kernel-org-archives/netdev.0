From: Zoltan Kiss <zoltan.kiss@linaro.org>
Subject: Re: [Xen-devel] BUG in xennet_make_frags with paged skb data
Date: Fri, 07 Nov 2014 14:51:00 +0000
Message-ID: <545CDC54.9050305@linaro.org>
References: <20141106214940.GD44162@ubuntu-hedt> <545CA27F.4070400@citrix.com> <545CA823.2080307@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Stefan Bader <stefan.bader@canonical.com>,
	David Vrabel <david.vrabel@citrix.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Jay Vosburgh <jay.vosburgh@canonical.com>,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:33811 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753088AbaKGOvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 09:51:04 -0500
Received: by mail-wi0-f170.google.com with SMTP id r20so4588837wiv.5
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2014 06:51:01 -0800 (PST)
In-Reply-To: <545CA823.2080307@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 07/11/14 11:08, Stefan Bader wrote:
> On 07.11.2014 11:44, David Vrabel wrote:
>> On 06/11/14 21:49, Seth Forshee wrote:
>>> We've had several reports of hitting the following BUG_ON in
>>> xennet_make_frags with 3.2 and 3.13 kernels (I'm currently awaiting
>>> results of testing with 3.17):
>>>
>>>          /* Grant backend access to each skb fragment page. */
>>>          for (i = 0; i < frags; i++) {
>>>                  skb_frag_t *frag = skb_shinfo(skb)->frags + i;
>>>                  struct page *page = skb_frag_page(frag);
>>>
>>>                  len = skb_frag_size(frag);
>>>                  offset = frag->page_offset;
>>>
>>>                  /* Data must not cross a page boundary. */
>>>                  BUG_ON(len + offset > PAGE_SIZE<<compound_order(page));
>>>
>>> When this happens the page in question is a "middle" page in a compound
>>> page (i.e. it's a tail page but not the last tail page), and the data is
>>> fully contained within the compound page. The data does however cross
>>> the hardware page boundary, and since compound_order evaluates to 0 for
>>> tail pages the check fails.
>>>
>>> In going over this I've been unable to determine whether the BUG_ON in
>>> xennet_make_frags is incorrect or the paged skb data is wrong. I can't
>>> find that it's documented anywhere, and the networking code itself is a
>>> bit ambiguous when it comes to compound pages. On the one hand
>>> __skb_fill_page_desc specifically handles adding tail pages as paged
>>> data, but on the other hand skb_copy_bits kmaps frag->page.p which could
>>> fail with data that extends into another page.
>>
>> netfront will safely handle this case so you can remove this BUG_ON()
>> (and the one later on).  But it would be better to find out were these
>> funny-looking skbs are coming from and (if necessary) fixing the bug there.
>
> Right, in fact it does ignore pages from the start of a compound page in case
> the offset is big enough. So there is no difference between that case and the
> one where the page pointer from the frag is adjusted the way it was observed.
>
> It really boils down to the question what the real rules for the frags are. If
> it is "only" that data may not cross the boundary of a hw or compound page this
> leaves room for interpretation. The odd skb does not violate that but a check
> for conformance would become a lot more complex. And netfront is not the only
> place that expects the frag page to be pointing to the compound head (there is
> igb for example, though it does only a warn_on upon failing).
>
> On the other hand the __skb_fill_page_desc is written in a way that seems to
> assume the frag page pointer may be pointing to a tail page. So before "blaming"
> one piece of code or the other we need an authoritative answer to what we are
> supposed to expect.

Looking at skb_copy_bits and kmap_atomic it looks confusing indeed. It 
seems kmap_atomic maps only the actual page, not the whole compound, and 
it doesn't matter whether you gave a head or a tail page to it. 
Therefore if skb_copy_bits comes over a frag where the buffer exceeds 
the page the pointer points to, it shouldn't work.
This raises a few question in me:

- I assume frags are allowed to have compound pages, where page.p points 
to the head, and the buffer can be anywhere in the compound, e.g. offset 
= 9000 and len = 4000 is allowed (if the compound is more than four 4k 
pages, of course). Is this assumption correct?
- Is it then allowed to have page.p pointed to a tail page of the 
compound? To use the above example: page.p points to the third page, and 
offset is 808. Or pointer points to the second page, and offset is 4904. 
(the answer to the above two question should be documented somewhere, or 
codified)
- how does it works with skb_copy_bits? kmap_atomic seems to map only 
the actual page, not the whole compound.

Zoli
