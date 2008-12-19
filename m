From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [PATCH][RFC 23/23]: Support for zero-copy TCP transmit of user
 space data
Date: Fri, 19 Dec 2008 12:21:41 -0800
Message-ID: <494C0255.8010208@goop.org>
References: <494009D7.4020602@vlnb.net> <494012C4.7090304@vlnb.net>
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
To: Vladislav Bolkhovitin <vst@vlnb.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:55521 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751320AbYLSUVs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2008 15:21:48 -0500
In-Reply-To: <494012C4.7090304@vlnb.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vladislav Bolkhovitin wrote:
> This patch implements support for zero-copy TCP transmit of user space 
> data. It is necessary in iSCSI-SCST target driver for transmitting data 
> from user space buffers, supplied by user space backend handlers. In 
> this case SCST core needs to know when TCP finished transmitting the 
> data, so the corresponding buffers can be reused or freed. Without this 
> patch it isn't possible, so iSCSI-SCST has to use data copying to TCP 
> send buffers function sock_sendpage(). ISCSI-SCST also works without 
> this patch, but that this patch gives a nice performance improvement.
>   

In Xen networking it looks like we're going to need to solve a very 
similar problem.

When a guest (non-privileged, with no direct hardware access) wants to 
send a network packet, it passes it over to the privileged (host) 
domain, who then puts it into the network stack for transmission.

The packet gets passed over in a page granted (read "borrowed") from the 
guest domain.   We can't return it to the guest while its tangled up in 
the host's network stack, so we need notification of when the stack has 
finished with the page.

The out of tree Xen patches do this by marking a page as having been 
allocated by a foreign allocator, and overloads the private memory of 
struct page with a destructor function pointer, which put_page calls as 
appropriate.  We can do this because the page is definitely "owned" by 
the Xen subsystem, so most of the fields are available for recycling; 
the main problem is that we need to grab another page flag.  Your case 
sounds more complex because the source page can be mapped by userspace 
and/or be in the pagecache, so everything is already claimed.

As with your case, we can simply copy the page data if this mechanism 
isn't available.  But it would be nice if it were.

> 1. Add net_priv analog in struct sk_buff, not in struct page. But then 
> it would be required that all the pages in each skb must be from the 
> same originator, i.e. with the same net_priv. It is unpractical to 
> change all the operations with skb's to forbid merging them, if they 
> have different net_priv. I tried, but quickly gave up. There are too 
> many such places in very not obvious code pieces.
>   

I think Rusty has a patch to put some kind of put notifier in struct 
skb_shared_info, but I'm not sure of the details.

> 2. Have in iSCSI-SCST a hashed list to translate page to iSCSI cmd by a 
> simple search function. This approach was rejected, because to copy a 
> page a modern CPU needs using MMX about 1500 ticks.

Is that the cold cache timing?

>  It was observed, 
> that each page can be referenced by TCP during transmit about 20 times 
> or even more. So, if each search needs, say, 20 ticks, the overall 
> search time will be 20*20*2 (to get() and put()) = 800 ticks. So, this 
> approach would considerably worse performance-wise to the chosen 
> approach and provide not too much benefit.
>   

Wouldn't you only need to do the lookup on the last put?

An external lookup table might well for for us, if the net_put_page() 
change is acceptable to the network folk.

    J
