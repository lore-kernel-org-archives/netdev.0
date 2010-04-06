From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC] [PATCH v2 3/3] Let host NIC driver to DMA to guest user
 space.
Date: Tue, 6 Apr 2010 14:26:29 +0800
Message-ID: <97F6D3BD476C464182C1B7BABF0B0AF5C17B5C2A@shzsmsx502.ccr.corp.intel.com>
References: <1270193410-6877-1-git-send-email-xiaohui.xin@intel.com>
 <20100402085556.75a8ff7c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>, "mst@redhat.com" <mst@redhat.com>,
	"jdike@c2.user-mode-linux.org" <jdike@c2.user-mode-linux.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100402085556.75a8ff7c@nehalam>
Content-Language: en-US
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>> From: Xin Xiaohui <xiaohui.xin@intel.com>
>> 
>> The patch let host NIC driver to receive user space skb,
>> then the driver has chance to directly DMA to guest user
>> space buffers thru single ethX interface.
>> We want it to be more generic as a zero copy framework.
>> 
>> Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
>> Signed-off-by: Zhao Yu <yzhao81@gmail.com>
>> Sigend-off-by: Jeff Dike <jdike@c2.user-mode-linux.org>
>> ---
>> 
>> We consider 2 way to utilize the user buffres, but not sure which one
>> is better. Please give any comments.
>> 
>> One:    Modify __alloc_skb() function a bit, it can only allocate a
>>         structure of sk_buff, and the data pointer is pointing to a
>>         user buffer which is coming from a page constructor API.
>>         Then the shinfo of the skb is also from guest.
>>         When packet is received from hardware, the skb->data is filled
>>         directly by h/w. What we have done is in this way.
>> 
>>         Pros:   We can avoid any copy here.
>>         Cons:   Guest virtio-net driver needs to allocate skb as almost
>>                 the same method with the host NIC drivers, say the size
>>                 of netdev_alloc_skb() and the same reserved space in the
>>                 head of skb. Many NIC drivers are the same with guest and
>>                 ok for this. But some lastest NIC drivers reserves special
>>                 room in skb head. To deal with it, we suggest to provide
>>                 a method in guest virtio-net driver to ask for parameter
>>                 we interest from the NIC driver when we know which device
>>                 we have bind to do zero-copy. Then we ask guest to do so.
>>                 Is that reasonable?
>> 
>> Two:    Modify driver to get user buffer allocated from a page constructor
>>         API(to substitute alloc_page()), the user buffer are used as payload
>>         buffers and filled by h/w directly when packet is received. Driver
>>         should associate the pages with skb (skb_shinfo(skb)->frags). For
>>         the head buffer side, let host allocates skb, and h/w fills it.
>>         After that, the data filled in host skb header will be copied into
>>         guest header buffer which is submitted together with the payload buffer.
>> 
>>         Pros:   We could less care the way how guest or host allocates their
>>                 buffers.
>>         Cons:   We still need a bit copy here for the skb header.
>> 
>> We are not sure which way is the better here. This is the first thing we want
>> to get comments from the community. We wish the modification to the network
>> part will be generic which not used by vhost-net backend only, but a user
>> application may use it as well when the zero-copy device may provides async
>> read/write operations later.
>> 
>> 
>> Thanks
>> Xiaohui

>How do you deal with the DoS problem of hostile user space app posting huge
>number of receives and never getting anything. 

That's a problem we are trying to deal with. It's critical for long term.
Currently, we tried to limit the pages it can pin, but not sure how much is reasonable.
For now, the buffers submitted is from guest virtio-net driver, so it's safe in some extent
just for now.

Thanks
Xiaohui
