From: Vladislav Bolkhovitin <vst@vlnb.net>
Subject: Re: [PATCH][RFC 23/23]: Support for zero-copy TCP transmit of user
 space data
Date: Tue, 23 Dec 2008 22:14:05 +0300
Message-ID: <4951387D.2030003@vlnb.net>
References: <494C0255.8010208@goop.org> <20081220103209.GA23632@ioremap.net> <494D49E6.9000703@goop.org> <200812221113.24044.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-scsi@vger.kernel.org,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Jeff Garzik <jeff@garzik.org>,
	Boaz Harrosh <bharrosh@panasas.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net,
	Bart Van Assche <bart.vanassche@gmail.com>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:55730 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbYLWTOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 14:14:55 -0500
In-Reply-To: <200812221113.24044.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell, on 12/22/2008 03:43 AM wrote:
> On Sunday 21 December 2008 06:09:18 Jeremy Fitzhardinge wrote:
>> Evgeniy Polyakov wrote:
>>> Things should work fine, since pskb_expand_head() copies whole shared
>>> info structure (and thus will copy destructor), get all pages and then
>>> copy all pointers into the new skb, and then release old skb's data.
>>>
>>> So destructor for the pages should not rely on which skb it is called on
>>> and check if pages are about to be really freed (i.e. check theirs
>>> reference counter).
>>>   
>> OK.
>>
>>> __pskb_pull_tail() is tricky, it just puts some pages it does not want
>>> to be present in the skb, but it could be possible to add there
>>> destructor callback from the original skb with partial flag (or just
>>> having destructor with two parameters: skb and page, and if page is not
>>> NULL, then actually only given page is freed, otherwise the whole skb).
>>>   
>> Yes, that doesn't sound too bad.
> 
> That would be one approach.  Actually, my patch solved this by keeping a
> parent ref in various cases if the parent had a destructor: we only destroy
> the parent when all the clones are gone.
> 
> Here's the patch for reference:
> 
> net: add destructor for skb data.
> 
> If we want to notify something when an skb is truly finished (such as
> for tun vringfd support), we need a destructor on the data.
> 
> This turns out to be slightly non-trivial as fragments from one skb
> get copied to another skb: if the first skb has a destructor (or its
> parent does) we need to keep a reference to it and destroy it only
> when (all the) children are destroyed.  We add an 'orig' pointer to
> the skb_shared_info to do this.
> 
> But there's currently no way to get from the shinfo to the head (to
> kfree it), so we add a 'len' field.  A better alternative to this
> might be to move the skb_shared_info to before the head of the skb data.
> 
> Note that the destructor is responsible for calling kfree: for the tun
> device, this is critical since the destructor can be called from any
> context and it has to do a copy_to_user, so it queues the skb.

Rusty,

Can you describe how one should use your patch, please? Maybe, there is 
some code you use to test it?

Thanks,
Vlad
