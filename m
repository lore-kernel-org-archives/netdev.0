From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net PATCH v5 1/6] virtio_net: use dev_kfree_skb for small buffer
 XDP receive
Date: Tue, 24 Jan 2017 20:02:29 -0800
Message-ID: <58882355.70307@gmail.com>
References: <20170117221443.20280.62546.stgit@john-Precision-Tower-5810>
 <20170117221950.20280.39496.stgit@john-Precision-Tower-5810>
 <20170123230809-mutt-send-email-mst@kernel.org>
 <20170124.144328.2195698124358175034.davem@davemloft.net>
 <20170124215412-mutt-send-email-mst@kernel.org>
 <a129524e-c4af-5c67-5397-dec992c70fa1@redhat.com>
 <20170125051810-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34225 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751137AbdAYECq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 23:02:46 -0500
Received: by mail-pg0-f68.google.com with SMTP id 3so635344pgj.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 20:02:46 -0800 (PST)
In-Reply-To: <20170125051810-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-24 07:23 PM, Michael S. Tsirkin wrote:
> On Wed, Jan 25, 2017 at 10:57:12AM +0800, Jason Wang wrote:
>>
>>
>> On 2017年01月25日 04:08, Michael S. Tsirkin wrote:
>>> On Tue, Jan 24, 2017 at 02:43:28PM -0500, David Miller wrote:
>>>> From: "Michael S. Tsirkin" <mst@redhat.com>
>>>> Date: Mon, 23 Jan 2017 23:08:35 +0200
>>>>
>>>>> On Tue, Jan 17, 2017 at 02:19:50PM -0800, John Fastabend wrote:
>>>>>> In the small buffer case during driver unload we currently use
>>>>>> put_page instead of dev_kfree_skb. Resolve this by adding a check
>>>>>> for virtnet mode when checking XDP queue type. Also name the
>>>>>> function so that the code reads correctly to match the additional
>>>>>> check.
>>>>>>
>>>>>> Fixes: bb91accf2733 ("virtio-net: XDP support for small buffers")
>>>>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>>>>> Acked-by: Jason Wang <jasowang@redhat.com>
>>>>> Acked-by: Michael S. Tsirkin <mst@redhat.com>
>>>>>
>>>>> I think we definitely want this one in -net as it's
>>>>> a bugfix.
>>>> This whole series is a bug fix, we must have adjust_header XDP
>>>> support in the virtio_net driver before v4.10 goes out, it is
>>>> a requires base feature for XDP.
>>> I have to say device resets outside probe have a huge potential
>>> to uncover hypervisor bugs.
>>
>> Maybe not if it reuses most of current codes? Since we've already used them
>> in sleep or hibernation?
>>
>> Thanks
> 
> Except almost no one uses sleep or hybernate with VMs.  I'm not saying
> it's a bad idea, just that it needs a lot of testing before release and
> we won't get enough if we merge at this point.
> 

Then it would seem like a good thing to have another user of these paths and
find the bugs versus letting them sit there for some poor folks who do use
sleep/hybernate.

>>>   I am rather uncomfortable
>>> doing that after -rc1.
>>>
>>> How about a module option to disable it by default?
>>> We can then ship a partial implementation in 4.10
>>> and work on completing it in 4.11.
>>>

Ugh I would prefer to avoid module options. This will only happen if users
push XDP program into driver anyways.

> 
> To clarify, I'm thinking an option similar to enable_xdp,
> and have all packets have a 256 byte headroom for 4.10.

An option where? In QEMU side, in driver? Is the reset really that bad, coming
from a hardware driver side lots of configuration changes can cause resets. I
agree its not overly elegant but could follow on patches be used to make it
prettier if possible.

I know folks prefer to avoid tuning knobs but I think exposing the headroom
configuration to users might not be a bad idea. After all these same users are
already programming maps and ebpf codes. A simple tuning knob should not be a
big deal and reasonable defaults would of course be used. That is a net-next
debate though.

> 
> Consider our options for 4.11.
> 

Finally just to point out here are the drivers with XDP support on latest
net tree,

	mlx/mlx5
	mlx/mlx4
	qlogic/qede
	netronome/nfp
	virtio_net

And here is the list of adjust header support,

	mlx/mlx4

So we currently have the same feature gap on all the other drivers except one.
Although I do not think that is a very good excuse. Lets figure out what we
should do about virtio.

Thanks,
John

	
	
