From: Jason Wang <jasowang@redhat.com>
Subject: Re: Fwd: [RFC PATCH net-next 0/3] virtio_net: add aRFS support
Date: Fri, 17 Jan 2014 14:45:20 +0800
Message-ID: <52D8D180.9020906@redhat.com>
References: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com> <52D75EA5.1050000@redhat.com> <CAEH94Lg7ygXgHqE8ubE+nuunicDqgmnCfO2AuDSS2nXgv5GikQ@mail.gmail.com> <20140116085253.GA32073@stefanha-thinkpad.redhat.com> <CA+mtBx9PBtYurdnhCKL0MLL8i+_+3yPNWFVj5h6SPJH+YDBCjw@mail.gmail.com> <20140117052229.GE16061@stefanha-thinkpad.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Zhi Yong Wu <zwu.kernel@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Stefan Hajnoczi <stefanha@redhat.com>,
	Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21104 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751064AbaAQGpq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 01:45:46 -0500
In-Reply-To: <20140117052229.GE16061@stefanha-thinkpad.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/2014 01:22 PM, Stefan Hajnoczi wrote:
> On Thu, Jan 16, 2014 at 09:12:29AM -0800, Tom Herbert wrote:
>> On Thu, Jan 16, 2014 at 12:52 AM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
>>> On Thu, Jan 16, 2014 at 04:34:10PM +0800, Zhi Yong Wu wrote:
>>>> CC: stefanha, MST, Rusty Russel
>>>>
>>>> ---------- Forwarded message ----------
>>>> From: Jason Wang <jasowang@redhat.com>
>>>> Date: Thu, Jan 16, 2014 at 12:23 PM
>>>> Subject: Re: [RFC PATCH net-next 0/3] virtio_net: add aRFS support
>>>> To: Zhi Yong Wu <zwu.kernel@gmail.com>
>>>> Cc: netdev@vger.kernel.org, therbert@google.com, edumazet@google.com,
>>>> davem@davemloft.net, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>>>>
>>>>
>>>> On 01/15/2014 10:20 PM, Zhi Yong Wu wrote:
>>>>> From: Zhi Yong Wu<wuzhy@linux.vnet.ibm.com>
>>>>>
>>>>> HI, folks
>>>>>
>>>>> The patchset is trying to integrate aRFS support to virtio_net. In this case,
>>>>> aRFS will be used to select the RX queue. To make sure that it's going ahead
>>>>> in the correct direction, although it is still one RFC and isn't tested, it's
>>>>> post out ASAP. Any comment are appreciated, thanks.
>>>>>
>>>>> If anyone is interested in playing with it, you can get this patchset from my
>>>>> dev git on github:
>>>>>    git://github.com/wuzhy/kernel.git virtnet_rfs
>>>>>
>>>>> Zhi Yong Wu (3):
>>>>>    virtio_pci: Introduce one new config api vp_get_vq_irq()
>>>>>    virtio_net: Introduce one dummy function virtnet_filter_rfs()
>>>>>    virtio-net: Add accelerated RFS support
>>>>>
>>>>>   drivers/net/virtio_net.c      |   67 ++++++++++++++++++++++++++++++++++++++++-
>>>>>   drivers/virtio/virtio_pci.c   |   11 +++++++
>>>>>   include/linux/virtio_config.h |   12 +++++++
>>>>>   3 files changed, 89 insertions(+), 1 deletions(-)
>>>>>
>>>> Please run get_maintainter.pl before sending the patch. You'd better
>>>> at least cc virtio maintainer/list for this.
>>>>
>>>> The core aRFS method is a noop in this RFC which make this series no
>>>> much sense to discuss. You should at least mention the big picture
>>>> here in the cover letter. I suggest you should post a RFC which can
>>>> run and has expected result or you can just raise a thread for the
>>>> design discussion.
>>>>
>>>> And this method has been discussed before, you can search "[net-next
>>>> RFC PATCH 5/5] virtio-net: flow director support" in netdev archive
>>>> for a very old prototype implemented by me. It can work and looks like
>>>> most of this RFC have already done there.
>>>>
>>>> A basic question is whether or not we need this, not all the mq cards
>>>> use aRFS (see ixgbe ATR). And whether or not it can bring extra
>>>> overheads? For virtio, we want to reduce the vmexits as much as
>>>> possible but this aRFS seems introduce a lot of more of this. Making a
>>>> complex interfaces just for an virtual device may not be good, simple
>>>> method may works for most of the cases.
>>>>
>>>> We really should consider to offload this to real nic. VMDq and L2
>>>> forwarding offload may help in this case.
>> Adding flow director support would be a good step, Zhi's patches for
>> support in tun have been merged, so support in virtio-net would be a
>> good follow on. But, flow-director does have some limitations and
>> performance issues of it's own (forced pairing between TX and RX
>> queues, lookup on every TX packet). In the case of virtualization,
>> aRFS, RSS, ntuple filtering, LRO, etc. can be implemented as software
>> emulations and so far seems to be wins in most cases. Extending these
>> down into the stack so that they can leverage HW mechanisms is a good
>> goal for best performance. It's probably generally true that most of
>> the offloads commonly available for NICs we'll want in virtualization
>> path. Of course, we need to deomonstrate that they provide real
>> performance benefit in this use case.
>>
>> I believe tying in aRFS (or flow director) into a real aRFS is just a
>> matter of programming the RFS table properly. This is not the complex
>> side of the interface, I believe this already works with the tun
>> patches.
>>
>>> Zhi Yong and I had an IRC chat.  I wanted to post my questions on the
>>> list - it's still the same concern I had in the old email thread that
>>> Jason mentioned.
>>>
>>> In order for virtio-net aRFS to make sense there needs to be an overall
>>> plan for pushing flow mapping information down to the physical NIC.
>>> That's the only way to actually achieve the benefit of steering:
>>> processing the packet on the CPU where the application is running.
>>>
>> I don't think this is necessarily true. Per flow steering amongst
>> virtual queues should be beneficial in itself. virtio-net can leverage
>> RFS or aRFS where it's available.
> I guess we need to see benchmark results :)
>
>>> If it's not possible or too hard to implement aRFS down the entire
>>> stack, we won't be able to process the packet on the right CPU.
>>> Then we might as well not bother with aRFS and just distribute uniformly
>>> across the rx virtqueues.
>>>
>>> Please post an outline of how rx packets will be steered up the stack so
>>> we can discuss whether aRFS can bring any benefit.
>>>
>> 1. The aRFS interface for the guest to specify which virtual queue to
>> receive a packet on is fairly straight forward.
>> 2. To hook into RFS, we need to match the virtual queue to the real
>> CPU it will processed on, and then program the RFS table for that flow
>> and CPU.
>> 3. NIC aRFS keys off the RFS tables so it can program the HW with the
>> correct queue for the CPU.
> There are a lot of details that are not yet worked out:
>
> If you want to implement aRFS down the vhost_net + macvtap path
> (probably easiest?) how will Step 2 work?  Do the necessary kernel
> interfaces exist to take the flow information in vhost_net, give them to
> macvtap, and finally push them down to the physical NIC?
>
> Not sure if aRFS will work down the full stack with vhost_net + tap +
> bridge.  Any ideas?

It actually works, tun will record the flow to cpu mapping through RFS
when it receive a packet from vhost_net. And host card driver will use
this info to program the hardware flow director to let it send the
interrupt directly to the cpu where vhost_net is running.
>
> At the QEMU level it is currently pointless to implement virtio-net aRFS
> emulation since the QEMU global mutex is taken and virtio-net emulation
> is not multi-threaded.

I don't think qemu is the proper layer to do this. It should be the work
of tun/macvtap which allows us to cooperate more with kernel.
>
> I think aRFS is a good thing, we just need to see performance results
> and know that this won't be a dead end after merging changes to
> virtio-net and the virtio specification.
>
> Stefan
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
