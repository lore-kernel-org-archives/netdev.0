From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net PATCH v5 6/6] virtio_net: XDP support for adjust_head
Date: Thu, 19 Jan 2017 11:05:40 +0800
Message-ID: <40e9a46a-1115-c21a-49f3-fdedb0a34101@redhat.com>
References: <20170117221443.20280.62546.stgit@john-Precision-Tower-5810>
 <20170117222259.20280.24625.stgit@john-Precision-Tower-5810>
 <20170118171259-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: "Michael S. Tsirkin" <mst@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50486 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751960AbdASDWi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 22:22:38 -0500
In-Reply-To: <20170118171259-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年01月18日 23:15, Michael S. Tsirkin wrote:
> On Tue, Jan 17, 2017 at 02:22:59PM -0800, John Fastabend wrote:
>> Add support for XDP adjust head by allocating a 256B header region
>> that XDP programs can grow into. This is only enabled when a XDP
>> program is loaded.
>>
>> In order to ensure that we do not have to unwind queue headroom push
>> queue setup below bpf_prog_add. It reads better to do a prog ref
>> unwind vs another queue setup call.
>>
>> At the moment this code must do a full reset to ensure old buffers
>> without headroom on program add or with headroom on program removal
>> are not used incorrectly in the datapath. Ideally we would only
>> have to disable/enable the RX queues being updated but there is no
>> API to do this at the moment in virtio so use the big hammer. In
>> practice it is likely not that big of a problem as this will only
>> happen when XDP is enabled/disabled changing programs does not
>> require the reset. There is some risk that the driver may either
>> have an allocation failure or for some reason fail to correctly
>> negotiate with the underlying backend in this case the driver will
>> be left uninitialized. I have not seen this ever happen on my test
>> systems and for what its worth this same failure case can occur
>> from probe and other contexts in virtio framework.
>>
>> Signed-off-by: John Fastabend<john.r.fastabend@intel.com>
> I've been thinking about it - can't we drop
> old buffers without the head room which were posted before
> xdp attached?
>
> Avoiding the reset would be much nicer.
>
> Thoughts?
>

As been discussed before, device may use them in the same time so it's 
not safe. Or do you mean detect them after xdp were set and drop the 
buffer without head room, this looks sub-optimal.

Thanks
