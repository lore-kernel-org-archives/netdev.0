From: Vladislav Bolkhovitin <vst@vlnb.net>
Subject: Re: [PATCH][RFC 23/23]: Support for zero-copy TCP transmit of user
 space data
Date: Tue, 30 Dec 2008 20:37:00 +0300
Message-ID: <495A5C3C.8090006@vlnb.net>
References: <494C8D57.7040808@goop.org> <20081220065105.GA16936@gondor.apana.org.au> <494CA226.9000200@goop.org> <20081220081045.GA17439@gondor.apana.org.au> <20081220103209.GA23632@ioremap.net> <49513909.1050100@vlnb.net> <20081223213817.GB16883@ioremap.net> <4952493F.10508@vlnb.net> <20081224144422.GA25089@ioremap.net> <49527590.7090909@vlnb.net> <20081224180841.GA615@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	linux-scsi@vger.kernel.org,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Jeff Garzik <jeff@garzik.org>,
	Boaz Harrosh <bharrosh@panasas.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net,
	Bart Van Assche <bart.vanassche@gmail.com>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout-xforward.kundenserver.de ([212.227.17.4]:54398 "EHLO
	mout-xforward.kundenserver.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751739AbYL3Riy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 12:38:54 -0500
In-Reply-To: <20081224180841.GA615@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov, on 12/24/2008 09:08 PM wrote:
> On Wed, Dec 24, 2008 at 08:46:56PM +0300, Vladislav Bolkhovitin (vst@vlnb.net) wrote:
>> I think in most cases there would be possibility to embed 
>> sk_transaction_token to some higher level structure. E.g. Xen apparently 
>> should have something to track packets passed through host/guest 
>> boundary. From other side, kmem cache is too well polished to have much 
>> overhead. I doubt, you would even notice it in this application. In most 
>> cases allocation of such small object in it using SLUB is just about the 
>> same as a list_del() under disabled IRQs.
> 
> I definitely would not rely on that, especially at cache reclaim time.
> But it of course depends on the workload and maybe appropriate for the
> cases in question. The best solution I think is to combine tag and
> separate destructur, so that those who do not want to allocate a token
> could still get notification via destructor callback.

Although I agree that any additional allocation is something, which 
should be avoided, *if possible*. But you shouldn't overestimate the 
overhead of the sk_transaction_token allocation in cases, when it would 
be needed. At first, sk_transaction_token is quite small, so a single 
page in the kmem cache would keep about 100 of them, hence the slow 
allocation path would be called only once per 100 objects. Second, in 
many cases ->sendpages() needs to allocate a new skb, so already there 
is at least one such allocations on the fast path.

Actually, it doesn't look like the skb shared info destructor alone 
can't solve the task we are solving, because we need to know not when an 
skb transmittion finished, but when transmittion of our *set of pages* 
finished. Hence, with skb shared info destructor we would need also to 
invent some way to track set of pages <-> set of skbs translation (you 
refer it as combining tag and separate destructor), which would bring 
this solution on the entire new complexity level for no gain over the 
sk_transaction_token solution.

Thanks,
Vlad



