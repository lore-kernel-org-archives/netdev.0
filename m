From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next RFC V3 PATCH 4/6] tuntap: multiqueue support
Date: Thu, 28 Jun 2012 13:31:24 +0800
Message-ID: <4FEBEC2C.8020700@redhat.com>
References: <20120625060830.6765.27584.stgit@amd-6168-8-1.englab.nay.redhat.com> <20120625061018.6765.76633.stgit@amd-6168-8-1.englab.nay.redhat.com> <20120625082553.GC18229@redhat.com> <4FE92F99.6020402@redhat.com> <20120626104250.GC13108@redhat.com> <4FEA972E.9010104@redhat.com> <20120627084431.GC15406@redhat.com> <4FEBC936.3080001@redhat.com> <4FEBE2FF.3010105@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, habanero@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	krkumar2@in.ibm.com, tahm@linux.vnet.ibm.com, akong@redhat.com,
	davem@davemloft.net, shemminger@vyatta.com, mashirle@us.ibm.com
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FEBE2FF.3010105@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/28/2012 12:52 PM, Sridhar Samudrala wrote:
> On 6/27/2012 8:02 PM, Jason Wang wrote:
>> On 06/27/2012 04:44 PM, Michael S. Tsirkin wrote:
>>> On Wed, Jun 27, 2012 at 01:16:30PM +0800, Jason Wang wrote:
>>>> On 06/26/2012 06:42 PM, Michael S. Tsirkin wrote:
>>>>> On Tue, Jun 26, 2012 at 11:42:17AM +0800, Jason Wang wrote:
>>>>>> On 06/25/2012 04:25 PM, Michael S. Tsirkin wrote:
>>>>>>> On Mon, Jun 25, 2012 at 02:10:18PM +0800, Jason Wang wrote:
>>>>>>>> This patch adds multiqueue support for tap device. This is done 
>>>>>>>> by abstracting
>>>>>>>> each queue as a file/socket and allowing multiple sockets to be 
>>>>>>>> attached to the
>>>>>>>> tuntap device (an array of tun_file were stored in the 
>>>>>>>> tun_struct). Userspace
>>>>>>>> could write and read from those files to do the parallel packet
>>>>>>>> sending/receiving.
>>>>>>>>
>>>>>>>> Unlike the previous single queue implementation, the socket and 
>>>>>>>> device were
>>>>>>>> loosely coupled, each of them were allowed to go away first. In 
>>>>>>>> order to let the
>>>>>>>> tx path lockless, netif_tx_loch_bh() is replaced by 
>>>>>>>> RCU/NETIF_F_LLTX to
>>>>>>>> synchronize between data path and system call.
>>>>>>> Don't use LLTX/RCU. It's not worth it.
>>>>>>> Use something like netif_set_real_num_tx_queues.
>>>>>>>
>>>>>>>> The tx queue selecting is first based on the recorded rxq index 
>>>>>>>> of an skb, it
>>>>>>>> there's no such one, then choosing based on rx hashing 
>>>>>>>> (skb_get_rxhash()).
>>>>>>>>
>>>>>>>> Signed-off-by: Jason Wang<jasowang@redhat.com>
>>>>>>> Interestingly macvtap switched to hashing first:
>>>>>>> ef0002b577b52941fb147128f30bd1ecfdd3ff6d
>>>>>>> (the commit log is corrupted but see what it
>>>>>>> does in the patch).
>>>>>>> Any idea why?
>>>>>> Yes, so tap should be changed to behave same as macvtap. I remember
>>>>>> the reason we do that is to make sure the packet of a single flow to
>>>>>> be queued to a fixed socket/virtqueues. As 10g cards like ixgbe
>>>>>> choose the rx queue for a flow based on the last tx queue where the
>>>>>> packets of that flow comes. So if we are using recored rx queue in
>>>>>> macvtap, the queue index of a flow would change as vhost thread
>>>>>> moves amongs processors.
>>>>> Hmm. OTOH if you override this, if TX is sent from VCPU0, RX might 
>>>>> land
>>>>> on VCPU1 in the guest, which is not good, right?
>>>> Yes, but better than making the rx moves between vcpus when we use
>>>> recorded rx queue.
>>> Why isn't this a problem with native TCP?
>>> I think what happens is one of the following:
>>> - moving between CPUs is more expensive with tun
>>>    because it can queue so much data on xmit
>>> - scheduler makes very bad decisions about VCPUs
>>>    bouncing them around all the time
>>
>> For usual native TCP/host process, as it reads and writes tcp 
>> sockets, so it make make sense to move rx to the porcessor where the 
>> process moves. But vhost does not do tcp stuffs and ixgbe would still 
>> move rx when vhost process moves, and we can't even make sure the 
>> vhost process that handling rx is running on processor that handle rx 
>> interrupt.
>
> We also saw this behavior with the default ixgbe configuration. If 
> vhost is pinned to a CPU all
> packets for that VM are received on a single RX queue.
> So even if the VM is doing multiple TCP_RR sessions, packets for all 
> the flows are received
> on a single RX queue. Without pinning, vhost moves around and so does 
> the packets across
> the RX queues.
>
> I think
>         ethtool -K ethX ntuple on
> will disable this behavior and it should be possible to program the 
> flow director using ethtool -U.
> This way we can split the packets across the host NIC RX queues based 
> on the flows, but it is not
> clear if this would help with the current model of single vhost per 
> device.
> With per-cpu vhost,  each RX queue can be handled by the matching 
> vhost, but if we have only
> 1 queue in the VMs virtio-net device, that could become the bottleneck.

Yes, I've been thinking about this. And instead of using ethtool -U 
(maybe possible for macvtap but hard for tuntap), we can 'teach' the 
ixgbe of the rxq it would used for a flow because ixgbe_select_queue() 
would first select the txq based on the recorded rxq. So if we want the 
flow using a dedicated rxq say N, we can record N to the rxq in tuntap 
before we passing the skb to bridge.

> Multi-queue virtio-net should help here, but we need the same number 
> of queues in VM's virtio-net
> device as the host's NIC so that each vhost can handle the 
> corresponding virtio queue.
> But if the VM has only 2 vcpus, i think it is not efficient to have 8 
> virtio-net queues.(to match a host
> with 8 physical cpus and 8 RX queues in the NIC).

Ideally, if we can 2 queues in guest, it's better to only use 2 queues 
in host to avoid extra contention.
>
> Thanks
> Sridhar
>
>>
>>> Could we isolate which it is? Does the problem
>>> still happen if you pin VCPUs to host cpus?
>>> If not it's the queue depth.
>>
>> It may not help as tun does not record the vcpu/queue that send the 
>> stream, so it can't transmit the packets back the same vcpu/queue.
>>>> Flow steering is needed to make sure the tx and
>>>> rx on the same vcpu.
>>> That involves IPI between processes, so it might be
>>> very expensive for kvm.
>>>
>>>>>> But during test tun/tap, one interesting thing I find is that even
>>>>>> ixgbe has recorded the queue index during rx, it seems be lost when
>>>>>> tap tries to transmit skbs to userspace.
>>>>> dev_pick_tx does this I think but ndo_select_queue
>>>>> should be able to get it without trouble.
>>>>>
>>>>>
>
