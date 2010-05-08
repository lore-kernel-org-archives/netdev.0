From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC][PATCH v4 00/18] Provide a zero-copy method on KVM
	virtio-net.
Date: Sat, 8 May 2010 15:55:48 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D790AB4A3F137@shsmsx502.ccr.corp.intel.com>
References: <1272187206-18534-10-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-11-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-12-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-13-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-14-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-15-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-16-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-17-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-18-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-19-git-send-email-xiaohui.xin@intel.com>
 <20100425121420.GB10238@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:18394 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751282Ab0EHHzx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 May 2010 03:55:53 -0400
In-Reply-To: <20100425121420.GB10238@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael,
Sorry, somehow I missed this mail. :-(

>> Here, we have ever considered 2 ways to utilize the page constructor
>> API to dispense the user buffers.
>> 
>> One:	Modify __alloc_skb() function a bit, it can only allocate a 
>> 	structure of sk_buff, and the data pointer is pointing to a 
>> 	user buffer which is coming from a page constructor API.
>> 	Then the shinfo of the skb is also from guest.
>> 	When packet is received from hardware, the skb->data is filled
>> 	directly by h/w. What we have done is in this way.
>> 
>> 	Pros:	We can avoid any copy here.
>> 	Cons:	Guest virtio-net driver needs to allocate skb as almost
>> 		the same method with the host NIC drivers, say the size
>> 		of netdev_alloc_skb() and the same reserved space in the
>> 		head of skb. Many NIC drivers are the same with guest and
>> 		ok for this. But some lastest NIC drivers reserves special
>> 		room in skb head. To deal with it, we suggest to provide
>> 		a method in guest virtio-net driver to ask for parameter
>> 		we interest from the NIC driver when we know which device 
>> 		we have bind to do zero-copy. Then we ask guest to do so.
>> 		Is that reasonable?

>Do you still do this?

Currently, we still use the first way. But we now ignore the room which 
host skb_reserve() required when device is doing zero-copy. Now we don't 
taint guest virtio-net driver with a new method by this way.

>> Two:	Modify driver to get user buffer allocated from a page constructor
>> 	API(to substitute alloc_page()), the user buffer are used as payload
>> 	buffers and filled by h/w directly when packet is received. Driver
>> 	should associate the pages with skb (skb_shinfo(skb)->frags). For 
>> 	the head buffer side, let host allocates skb, and h/w fills it. 
>> 	After that, the data filled in host skb header will be copied into
>> 	guest header buffer which is submitted together with the payload buffer.
>> 
>> 	Pros:	We could less care the way how guest or host allocates their
>> 		buffers.
>> 	Cons:	We still need a bit copy here for the skb header.
>> 
>> We are not sure which way is the better here. This is the first thing we want
>> to get comments from the community. We wish the modification to the network
>> part will be generic which not used by vhost-net backend only, but a user
>> application may use it as well when the zero-copy device may provides async
>> read/write operations later.

>I commented on this in the past. Do you still want comments?

Now we continue with the first way and try to push it. But any comments about the two methods are still welcome.

>That's nice. The thing to do is probably to enable GSO/TSO
>and see what we get this way. Also, mergeable buffer support
>was recently posted and I hope to merge it for 2.6.35.
>You might want to take a look.

I'm looking at the mergeable buffer. I think GSO/GRO support with zero-copy also needs it.
Currently, GSO/TSO is still not supported by vhost-net?
-- 
MST
