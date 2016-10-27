From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Thu, 27 Oct 2016 14:09:08 -0700
Message-ID: <58126CF4.5090500@gmail.com>
References: <20161026185743-mutt-send-email-mst@kernel.org>
 <20161026.125245.1630138589657247338.davem@davemloft.net>
 <20161026200153-mutt-send-email-mst@kernel.org>
 <20161026.131122.318218609871320141.davem@davemloft.net>
 <20161027105514.4c0374dd@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, shrijeet@gmail.com, tom@herbertland.com,
        netdev@vger.kernel.org, shm@cumulusnetworks.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34027 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934631AbcJ0VJZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 17:09:25 -0400
Received: by mail-pf0-f196.google.com with SMTP id u84so3577615pfj.1
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 14:09:25 -0700 (PDT)
In-Reply-To: <20161027105514.4c0374dd@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-27 01:55 AM, Jesper Dangaard Brouer wrote:
> On Wed, 26 Oct 2016 13:11:22 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: "Michael S. Tsirkin" <mst@redhat.com>
>> Date: Wed, 26 Oct 2016 20:07:19 +0300
>>
>>> On Wed, Oct 26, 2016 at 12:52:45PM -0400, David Miller wrote:  
>>>> From: "Michael S. Tsirkin" <mst@redhat.com>
>>>> Date: Wed, 26 Oct 2016 19:36:45 +0300
>>>>   
>>>>> On Wed, Oct 26, 2016 at 03:52:02PM +0200, Jesper Dangaard Brouer wrote:  
>>>>>> On Sat, 22 Oct 2016 04:07:23 +0000
>>>>>> Shrijeet Mukherjee <shrijeet@gmail.com> wrote:
>>>>>>   
>>>>>>> This patch adds support for xdp ndo and also inserts the xdp program
>>>>>>> call into the merged RX buffers and big buffers paths  
>>>>>>
>>>>>> I really appreciate you are doing this for virtio_net.
>>>>>>
>>>>>> My first question is: Is the (packet) page data writable?
>>>>>> (MST might be able to answer?)
>>>>>>
>>>>>> As this is currently an XDP requirement[1].    
>>>>>
>>>>> I'm not sure I understand what does writable mean.
>>>>> Could you explain a bit more pls?
>>>>> We do copy data into skb ATM but I plan to change that.  
>>>>
>>>> The packet data area must be writable,  
>>>
>>> This is the part I don't fully understand.
>>> It's in RAM so of course it's writeable.  
>>
>> Pages in SKB frag lists are not usually writable, because they share
>> space with data from other packets the way drivers usually carve up
>> pages to receive packets into.
>>
>> It is therefore illegal for the networking code to write into SKB frag
>> pages.
>>
>> Pages used for XDP processed packets must not have this restriction.
>>
>>> We share pages between arbitrary multiple packets. I think that's
>>> OK  
>>
>> That's exactly what is not allowed with XDP.
>>
>> Each packet must be the sole user of a page, otherwise the semantics
>> required by XDP are not met.
> 
> Looking at the virtio_net.c code, the function call receive_big() might
> actually be okay for XDP, unless the incoming packet is larger than
> PAGE_SIZE and thus uses several pages (via a linked list in page->private).
> 
> The receive_mergeable() does not look compatible with XDP.
> 

Looks to me the correct conditions can be met by getting the correct
feature negotiation to happen, specifically no VIRTIO_NET_F_MRG_RXBUF
and one of the TSO/ECN/GSO feature bits set the big_packets flag as
Jesper notes.

Srijeet, are you going to give this a try? I'm trying to get the device
side working by the way on the vhost interface.

Thanks,
John
