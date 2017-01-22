From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net PATCH v5 6/6] virtio_net: XDP support for adjust_head
Date: Sun, 22 Jan 2017 10:51:42 +0800
Message-ID: <bcf017d4-96b9-9ccf-cc7b-06ec9301251d@redhat.com>
References: <20170117221443.20280.62546.stgit@john-Precision-Tower-5810>
 <20170117222259.20280.24625.stgit@john-Precision-Tower-5810>
 <20170118171259-mutt-send-email-mst@kernel.org>
 <40e9a46a-1115-c21a-49f3-fdedb0a34101@redhat.com>
 <20170119231027-mutt-send-email-mst@kernel.org>
 <063D6719AE5E284EB5DD2968C1650D6DB026921C@AcuExch.aculab.com>
 <20170120194824-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        "john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>
To: "Michael S. Tsirkin" <mst@redhat.com>,
        David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50428 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750770AbdAVCw5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 21 Jan 2017 21:52:57 -0500
In-Reply-To: <20170120194824-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年01月21日 01:48, Michael S. Tsirkin wrote:
> On Fri, Jan 20, 2017 at 04:59:11PM +0000, David Laight wrote:
>> From: Michael S. Tsirkin
>>> Sent: 19 January 2017 21:12
>>>> On 2017?01?18? 23:15, Michael S. Tsirkin wrote:
>>>>> On Tue, Jan 17, 2017 at 02:22:59PM -0800, John Fastabend wrote:
>>>>>> Add support for XDP adjust head by allocating a 256B header region
>>>>>> that XDP programs can grow into. This is only enabled when a XDP
>>>>>> program is loaded.
>>>>>>
>>>>>> In order to ensure that we do not have to unwind queue headroom push
>>>>>> queue setup below bpf_prog_add. It reads better to do a prog ref
>>>>>> unwind vs another queue setup call.
>>>>>>
>>>>>> At the moment this code must do a full reset to ensure old buffers
>>>>>> without headroom on program add or with headroom on program removal
>>>>>> are not used incorrectly in the datapath. Ideally we would only
>>>>>> have to disable/enable the RX queues being updated but there is no
>>>>>> API to do this at the moment in virtio so use the big hammer. In
>>>>>> practice it is likely not that big of a problem as this will only
>>>>>> happen when XDP is enabled/disabled changing programs does not
>>>>>> require the reset. There is some risk that the driver may either
>>>>>> have an allocation failure or for some reason fail to correctly
>>>>>> negotiate with the underlying backend in this case the driver will
>>>>>> be left uninitialized. I have not seen this ever happen on my test
>>>>>> systems and for what its worth this same failure case can occur
>>>>>> from probe and other contexts in virtio framework.
>>>>>>
>>>>>> Signed-off-by: John Fastabend<john.r.fastabend@intel.com>
>>>>> I've been thinking about it - can't we drop
>>>>> old buffers without the head room which were posted before
>>>>> xdp attached?
>>>>>
>>>>> Avoiding the reset would be much nicer.
>>>>>
>>>>> Thoughts?
>>>>>
>>>> As been discussed before, device may use them in the same time so it's not
>>>> safe. Or do you mean detect them after xdp were set and drop the buffer
>>>> without head room, this looks sub-optimal.
>>>>
>>>> Thanks
>>> Yes, this is what I mean.  Why is this suboptimal? It's a single branch
>>> in code. Yes we might lose some packets but the big hammer of device
>>> reset will likely lose more.
>> Why not leave let the hardware receive into the 'small' buffer (without
>> headroom) and do a copy when a frame is received.
>> Replace the buffers with 'big' ones for the next receive.
>> A data copy on a ring full of buffers won't really be noticed.
>>
>> 	David
>>
> I like that. John?
>

This works, I prefer this only if it uses simpler code (but I suspect) 
than reset.

Thanks
