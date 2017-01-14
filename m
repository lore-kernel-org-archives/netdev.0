From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net PATCH v3 5/5] virtio_net: XDP support for adjust_head
Date: Fri, 13 Jan 2017 16:45:46 -0800
Message-ID: <587974BA.9000204@gmail.com>
References: <20170113024908.4535.8835.stgit@john-Precision-Tower-5810>
 <20170113025206.4535.28363.stgit@john-Precision-Tower-5810>
 <7c41d9b0-aa77-1485-4890-177ca7b01e50@redhat.com>
 <587933C2.8090003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35595 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750820AbdANAqa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 19:46:30 -0500
Received: by mail-pf0-f194.google.com with SMTP id f144so10357719pfa.2
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 16:46:00 -0800 (PST)
In-Reply-To: <587933C2.8090003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-13 12:08 PM, John Fastabend wrote:
> On 17-01-12 11:41 PM, Jason Wang wrote:
>>
>>
>> On 2017年01月13日 10:52, John Fastabend wrote:
>>> Add support for XDP adjust head by allocating a 256B header region
>>> that XDP programs can grow into. This is only enabled when a XDP
>>> program is loaded.
>>>
>>> In order to ensure that we do not have to unwind queue headroom push
>>> queue setup below bpf_prog_add. It reads better to do a prog ref
>>> unwind vs another queue setup call.
>>>
>>> At the moment this code must do a full reset to ensure old buffers
>>> without headroom on program add or with headroom on program removal
>>> are not used incorrectly in the datapath. Ideally we would only
>>> have to disable/enable the RX queues being updated but there is no
>>> API to do this at the moment in virtio so use the big hammer. In
>>> practice it is likely not that big of a problem as this will only
>>> happen when XDP is enabled/disabled changing programs does not
>>> require the reset. There is some risk that the driver may either
>>> have an allocation failure or for some reason fail to correctly
>>> negotiate with the underlying backend in this case the driver will
>>> be left uninitialized. I have not seen this ever happen on my test
>>> systems and for what its worth this same failure case can occur
>>> from probe and other contexts in virtio framework.
>>>
>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>> ---
>>>   drivers/net/virtio_net.c |  155 ++++++++++++++++++++++++++++++++++++++++------
>>>   drivers/virtio/virtio.c  |    9 ++-
>>>   include/linux/virtio.h   |    3 +
>>>   3 files changed, 144 insertions(+), 23 deletions(-)
>>>
>>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>>> index 6041828..8b897e7 100644
>>> --- a/drivers/net/virtio_net.c
>>> +++ b/drivers/net/virtio_net.c
>>> @@ -28,6 +28,7 @@
>>>   #include <linux/slab.h>
>>>   #include <linux/cpu.h>
>>>   #include <linux/average.h>
>>> +#include <linux/pci.h>
>>>   #include <net/busy_poll.h>
>>>     static int napi_weight = NAPI_POLL_WEIGHT;
>>> @@ -159,6 +160,9 @@ struct virtnet_info {
>>>       /* Ethtool settings */
>>>       u8 duplex;
>>>       u32 speed;
>>> +
>>> +    /* Headroom allocated in RX Queue */
>>> +    unsigned int headroom;
>>
>> If this could not be changed in anyway, better use a macro instead of a filed
>> here. And there's even no need to add an extra parameter to
>> add_recvbuf_mergeable().
> 
> OK originally I thought this might be dynamic but I agree no need
> for it here.
> 

Well there is a bit of an order of operation issue that means we need at
least some bit here to tell us an enablement is pending.

The problem is when we do the reset we need to know that headroom for XDP
is needed. But we can't use the xdp_prog values because xdp_prog can not
be added on an device that is up without headroom otherwise the program
could fail. Plus reset via freeze/restore tears these structures down and
rebuilds them.

How about a boolean bit here instead of an unsigned int,

	'bool xdp_headroom_needed'

seems better than an int.

Thanks,
John
