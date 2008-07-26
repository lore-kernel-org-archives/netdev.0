From: Patrick McHardy <kaber@trash.net>
Subject: Re: [regression] nf_iterate(), BUG: unable to handle kernel NULL
 pointer dereference
Date: Sat, 26 Jul 2008 15:47:17 +0200
Message-ID: <488B2AE5.9070106@trash.net>
References: <20080724060448.GA10203@elte.hu>  <E1KLwlD-0001Ub-00@gondolin.me.apana.org.au>  <20080724.022259.113079007.davem@davemloft.net>  <20080724093411.GA12001@elte.hu> <20080724115625.GA23994@elte.hu>  <20080724115957.GA25701@elte.hu> <48886FA6.6050908@trash.net> <84144f020807240544q507e1b7cv220d1afbae0ee0f0@mail.gmail.com> <48887A71.5010209@trash.net> <alpine.LFD.1.10.0807241407410.8109@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, w@1wt.eu, davidn@davidnewall.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stefanr@s5r6.in-berlin.de,
	rjw@sisk.pl, ilpo.jarvinen@helsinki.fi,
	Dave Jones <davej@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64131 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776AbYGZNrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2008 09:47:21 -0400
In-Reply-To: <alpine.LFD.1.10.0807241407410.8109@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus Torvalds wrote:
> 
> On Thu, 24 Jul 2008, Patrick McHardy wrote:
>> To fix this I think we need a __krealloc() that doesn't
>> free the old memory, especially since it must not be
>> freed immediately because it may still be used in a RCU
>> read side (see the last part in the patch attached to
>> this mail (based on a kernel without your patch)).
> 
> Hmm. Don't you need to fix some of the ordering of the initialization too?
> 
> If there are possible readers that happen in parallel with changing this 
> thing, don't you need to protect the update of "ext->len" against the 
> actual changes? And the readers should probably have a read barrier 
> between checking "len" and actually looking at the values?

Extensions can only be added while the conntrack is "unconfirmed",
meaning its not in the hash tables yet and the reference is exclusive.
The reason why we need RCU at all is that the extension areas
might already visible and contained in RCU protected lists.

> Finally, why do 
> the "ct->ext" dereference thing, when we know it has to be equal to "new"?

Thats a relict of the old code, which allocated "new" conditionally.
I've taken that part from your patch without the smb_wmb(), which
shouldn't be necessary.
