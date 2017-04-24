From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH RFC (resend) net-next 0/6] virtio-net: Add support for
 virtio-net header extensions
Date: Mon, 24 Apr 2017 11:22:35 +0800
Message-ID: <951e021c-fa8e-f7d4-f058-92d28681379c@redhat.com>
References: <1492274298-17362-1-git-send-email-vyasevic@redhat.com>
 <0d9216af-e3db-e06b-f70d-d77f519c3fd4@redhat.com>
 <f52fa31e-5ca2-34dc-d48b-417a34061359@redhat.com>
 <2b70ab98-c5cc-25c7-dd42-4bb570b6aec6@redhat.com>
 <022c8af3-e7e7-5d35-5152-cb12e90359ef@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: virtio-dev@lists.oasis-open.org, mst@redhat.com,
        maxime.coquelin@redhat.com,
        virtualization@lists.linux-foundation.org
To: vyasevic@redhat.com, Vladislav Yasevich <vyasevich@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44418 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1164424AbdDXDW5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 23 Apr 2017 23:22:57 -0400
In-Reply-To: <022c8af3-e7e7-5d35-5152-cb12e90359ef@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年04月21日 21:08, Vlad Yasevich wrote:
> On 04/21/2017 12:05 AM, Jason Wang wrote:
>> On 2017年04月20日 23:34, Vlad Yasevich wrote:
>>> On 04/17/2017 11:01 PM, Jason Wang wrote:
>>>> On 2017年04月16日 00:38, Vladislav Yasevich wrote:
>>>>> Curreclty virtion net header is fixed size and adding things to it is rather
>>>>> difficult to do.  This series attempt to add the infrastructure as well as some
>>>>> extensions that try to resolve some deficiencies we currently have.
>>>>>
>>>>> First, vnet header only has space for 16 flags.  This may not be enough
>>>>> in the future.  The extensions will provide space for 32 possbile extension
>>>>> flags and 32 possible extensions.   These flags will be carried in the
>>>>> first pseudo extension header, the presense of which will be determined by
>>>>> the flag in the virtio net header.
>>>>>
>>>>> The extensions themselves will immidiately follow the extension header itself.
>>>>> They will be added to the packet in the same order as they appear in the
>>>>> extension flags.  No padding is placed between the extensions and any
>>>>> extensions negotiated, but not used need by a given packet will convert to
>>>>> trailing padding.
>>>> Do we need a explicit padding (e.g an extension) which could be controlled by each side?
>>> I don't think so.  The size of the vnet header is set based on the extensions negotiated.
>>> The one part I am not crazy about is that in the case of packet not using any extensions,
>>> the data is still placed after the entire vnet header, which essentially adds a lot
>>> of padding.  However, that's really no different then if we simply grew the vnet header.
>>>
>>> The other thing I've tried before is putting extensions into their own sg buffer, but that
>>> made it slower.h
>> Yes.
>>
>>>>> For example:
>>>>>     | vnet mrg hdr | ext hdr | ext 1 | ext 2 | ext 5 | .. pad .. | packet data |
>>>> Just some rough thoughts:
>>>>
>>>> - Is this better to use TLV instead of bitmap here? One advantage of TLV is that the
>>>> length is not limited by the length of bitmap.
>>> but the disadvantage is that we add at least 4 bytes per extension of just TL data.  That
>>> makes this thing even longer.
>> Yes, and it looks like the length is still limited by e.g the length of T.
> Not only that, but it is also limited by the skb->cb as a whole.  So adding putting
> extensions into a TLV style means we have less extensions for now, until we get rid of
> skb->cb usage.
>
>>>> - For 1.1, do we really want something like vnet header? AFAIK, it was not used by modern
>>>> NICs, is this better to pack all meta-data into descriptor itself? This may need a some
>>>> changes in tun/macvtap, but looks more PCIE friendly.
>>> That would really be ideal and I've looked at this.  There are small issues of exposing
>>> the 'net metadata' of the descriptor to taps so they can be filled in.  The alternative
>>> is to use a different control structure for tap->qemu|vhost channel (that can be
>>> implementation specific) and have qemu|vhost populate the 'net metadata' of the descriptor.
>> Yes, this needs some thought. For vhost, things looks a little bit easier, we can probably
>> use msg_control.
>>
> We can use msg_control in qemu as well, can't we?

AFAIK, it needs some changes since we don't export socket to userspace.

>   It really is a question of who is doing
> the work and the number of copies.
>
> I can take a closer look of how it would look if we extend the descriptor with type
> specific data.  I don't know if other users of virtio would benefit from it?

Not sure, but we can have a common descriptor header followed by device 
specific meta data. This probably need some prototype benchmarking to 
see the benefits first.

Thanks
