From: Vladislav Bolkhovitin <vst@vlnb.net>
Subject: Re: [PATCH][RFC 23/23]: Support for zero-copy TCP transmit of user
 space data
Date: Tue, 23 Dec 2008 22:13:40 +0300
Message-ID: <49513864.7030306@vlnb.net>
References: <494009D7.4020602@vlnb.net> <494012C4.7090304@vlnb.net> <494C0255.8010208@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-scsi@vger.kernel.org,
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
	Herbert Xu <herbert@gondor.apana.org.au>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:53063 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022AbYLWTNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 14:13:40 -0500
In-Reply-To: <494C0255.8010208@goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeremy Fitzhardinge, on 12/19/2008 11:21 PM wrote:

[...]

> As with your case, we can simply copy the page data if this mechanism 
> isn't available.  But it would be nice if it were.
> 
>> 1. Add net_priv analog in struct sk_buff, not in struct page. But then 
>> it would be required that all the pages in each skb must be from the 
>> same originator, i.e. with the same net_priv. It is unpractical to 
>> change all the operations with skb's to forbid merging them, if they 
>> have different net_priv. I tried, but quickly gave up. There are too 
>> many such places in very not obvious code pieces.
>>   
> 
> I think Rusty has a patch to put some kind of put notifier in struct 
> skb_shared_info, but I'm not sure of the details.
> 
>> 2. Have in iSCSI-SCST a hashed list to translate page to iSCSI cmd by a 
>> simple search function. This approach was rejected, because to copy a 
>> page a modern CPU needs using MMX about 1500 ticks.
> 
> Is that the cold cache timing?

Should be L2 cache hot, which is almost always the case if FILEIO is 
used, because data are just copied from the page cache. Although, 
frankly, at the moment I can't find from where I got that number..

>>  It was observed, 
>> that each page can be referenced by TCP during transmit about 20 times 
>> or even more. So, if each search needs, say, 20 ticks, the overall 
>> search time will be 20*20*2 (to get() and put()) = 800 ticks. So, this 
>> approach would considerably worse performance-wise to the chosen 
>> approach and provide not too much benefit.
> 
> Wouldn't you only need to do the lookup on the last put?

No, because you can't say which one is the last. E.g., a page can be 
mmaped to another process, while it's being transmitted. So, the only 
possible way is to track all gets and puts done by networking using some 
external reference counting (net_ref_cnt in case if iscsi-scst).

Vlad
