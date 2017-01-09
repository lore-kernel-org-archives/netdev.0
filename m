From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net PATCH] net: virtio: cap mtu when XDP programs are running
Date: Mon, 9 Jan 2017 15:13:15 -0800
Message-ID: <5874190B.9050505@gmail.com>
References: <20170102223031.11541.28717.stgit@john-Precision-Tower-5810>
 <402027b4-58c7-aa1b-5079-74e31448f544@redhat.com>
 <586BD5D5.6020100@gmail.com>
 <1caf1ffc-0f46-067e-0f0d-a93b408b4ffd@redhat.com>
 <586D458F.5050705@gmail.com>
 <068f0116-b37e-eb44-8c60-1781a9d5255e@redhat.com>
 <20170110010531-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33621 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937435AbdAIXNh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 18:13:37 -0500
Received: by mail-pf0-f193.google.com with SMTP id 127so25673750pfg.0
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 15:13:37 -0800 (PST)
In-Reply-To: <20170110010531-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-09 03:05 PM, Michael S. Tsirkin wrote:
> On Thu, Jan 05, 2017 at 11:09:14AM +0800, Jason Wang wrote:
>>
>>
>> On 2017年01月05日 02:57, John Fastabend wrote:
>>> [...]
>>>
>>>> On 2017年01月04日 00:48, John Fastabend wrote:
>>>>> On 17-01-02 10:14 PM, Jason Wang wrote:
>>>>>> On 2017年01月03日 06:30, John Fastabend wrote:
>>>>>>> XDP programs can not consume multiple pages so we cap the MTU to
>>>>>>> avoid this case. Virtio-net however only checks the MTU at XDP
>>>>>>> program load and does not block MTU changes after the program
>>>>>>> has loaded.
>>>>>>>
>>>>>>> This patch sets/clears the max_mtu value at XDP load/unload time.
>>>>>>>
>>>>>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>>>>>> ---
>>> [...]
>>>
>>>>> OK so this logic is a bit too simply. When it resets the max_mtu I guess it
>>>>> needs to read the mtu via
>>>>>
>>>>>      virtio_cread16(vdev, ...)
>>>>>
>>>>> or we may break the negotiated mtu.
>>>> Yes, this is a problem (even use ETH_MAX_MTU). We may need a method to notify
>>>> the device about the mtu in this case which is not supported by virtio now.
>>> Note this is not really a XDP specific problem. The guest can change the MTU
>>> after init time even without XDP which I assume should ideally result in a
>>> notification if the MTU is negotiated.
>>
>> Yes, Michael, do you think we need add some mechanism to notify host about
>> MTU change in this case?
>>
>> Thanks
> 
> Why does host care?
> 

Well the guest will drop packets after mtu has been reduced. Although the guest
by reducing its MTU in some sense must expect this. Likewise if the host were
to change MTU after virtio_net probe time the guest would not learn about it.

I think at best negotiating the mtu is just a hint? If system _really_ cares
we could use lldp or some other out of band mechanism to learn/set/adjust MTU
on both systems and it would be more robust. I'm not actually convinced this
is a problem in bare metal systems we have the same issue with physical
switches and solve it out of band via configuration, protocols, etc.

.John
