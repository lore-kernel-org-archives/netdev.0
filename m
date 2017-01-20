From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net PATCH v5 6/6] virtio_net: XDP support for adjust_head
Date: Thu, 19 Jan 2017 19:39:40 -0800
Message-ID: <5881867C.2090400@gmail.com>
References: <20170117221443.20280.62546.stgit@john-Precision-Tower-5810>
 <20170117222259.20280.24625.stgit@john-Precision-Tower-5810>
 <20170118171259-mutt-send-email-mst@kernel.org>
 <40e9a46a-1115-c21a-49f3-fdedb0a34101@redhat.com>
 <20170119231027-mutt-send-email-mst@kernel.org>
 <d1c43849-0da9-5f03-1eae-09a27c2e9985@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: Jason Wang <jasowang@redhat.com>,
        "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35929 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751145AbdATDj7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 22:39:59 -0500
Received: by mail-pf0-f193.google.com with SMTP id 19so4520561pfo.3
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 19:39:59 -0800 (PST)
In-Reply-To: <d1c43849-0da9-5f03-1eae-09a27c2e9985@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-19 07:26 PM, Jason Wang wrote:
> 
> 
> On 2017年01月20日 05:11, Michael S. Tsirkin wrote:
>> On Thu, Jan 19, 2017 at 11:05:40AM +0800, Jason Wang wrote:
>>>
>>> On 2017年01月18日 23:15, Michael S. Tsirkin wrote:
>>>> On Tue, Jan 17, 2017 at 02:22:59PM -0800, John Fastabend wrote:
>>>>> Add support for XDP adjust head by allocating a 256B header region
>>>>> that XDP programs can grow into. This is only enabled when a XDP
>>>>> program is loaded.
>>>>>
>>>>> In order to ensure that we do not have to unwind queue headroom push
>>>>> queue setup below bpf_prog_add. It reads better to do a prog ref
>>>>> unwind vs another queue setup call.
>>>>>
>>>>> At the moment this code must do a full reset to ensure old buffers
>>>>> without headroom on program add or with headroom on program removal
>>>>> are not used incorrectly in the datapath. Ideally we would only
>>>>> have to disable/enable the RX queues being updated but there is no
>>>>> API to do this at the moment in virtio so use the big hammer. In
>>>>> practice it is likely not that big of a problem as this will only
>>>>> happen when XDP is enabled/disabled changing programs does not
>>>>> require the reset. There is some risk that the driver may either
>>>>> have an allocation failure or for some reason fail to correctly
>>>>> negotiate with the underlying backend in this case the driver will
>>>>> be left uninitialized. I have not seen this ever happen on my test
>>>>> systems and for what its worth this same failure case can occur
>>>>> from probe and other contexts in virtio framework.
>>>>>
>>>>> Signed-off-by: John Fastabend<john.r.fastabend@intel.com>
>>>> I've been thinking about it - can't we drop
>>>> old buffers without the head room which were posted before
>>>> xdp attached?
>>>>
>>>> Avoiding the reset would be much nicer.
>>>>
>>>> Thoughts?
>>>>
>>> As been discussed before, device may use them in the same time so it's not
>>> safe. Or do you mean detect them after xdp were set and drop the buffer
>>> without head room, this looks sub-optimal.
>>>
>>> Thanks
>> Yes, this is what I mean.  Why is this suboptimal? It's a single branch
>> in code. Yes we might lose some packets but the big hammer of device
>> reset will likely lose more.
>>
> 
> Maybe I was wrong but I think driver should try their best to avoid dropping
> packets. (And look at mlx4, it did something similar to this patch).
> 
> Thanks

+1 sorry didn't see your reply as I was typing mine. Bottom line when XDP
returns I believe the driver must be ready to accept packets or managing
XDP will be problematic.

.John
