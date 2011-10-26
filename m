From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC v2 PATCH 5/4 PATCH] virtio-net: send
 gratuitous packet when needed
Date: Wed, 26 Oct 2011 12:49:28 +0800
Message-ID: <4EA79158.7050607@redhat.com>
References: <20111022054311.21798.3340.stgit@dhcp-8-146.nay.redhat.com>
	<87ty6z10f8.fsf@rustcorp.com.au> <20111024052526.GA2362@redhat.com>
	<4EA62401.5000602@redhat.com> <20111025154106.GA22553@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: aliguori@us.ibm.com, kvm@vger.kernel.org, quintela@redhat.com,
	jan.kiszka@siemens.com, Rusty Russell <rusty@rustcorp.com.au>,
	qemu-devel@nongnu.org, blauwirbel@gmail.com,
	netdev@vger.kernel.org, pbonzini@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <20111025154106.GA22553@redhat.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

On 10/25/2011 11:41 PM, Michael S. Tsirkin wrote:
> On Tue, Oct 25, 2011 at 10:50:41AM +0800, Jason Wang wrote:
>> On 10/24/2011 01:25 PM, Michael S. Tsirkin wrote:
>>> On Mon, Oct 24, 2011 at 02:54:59PM +1030, Rusty Russell wrote:
>>>> On Sat, 22 Oct 2011 13:43:11 +0800, Jason Wang <jasowang@redhat.com> wrote:
>>>>> This make let virtio-net driver can send gratituous packet by a new
>>>>> config bit - VIRTIO_NET_S_ANNOUNCE in each config update
>>>>> interrupt. When this bit is set by backend, the driver would schedule
>>>>> a workqueue to send gratituous packet through NETDEV_NOTIFY_PEERS.
>>>>>
>>>>> This feature is negotiated through bit VIRTIO_NET_F_GUEST_ANNOUNCE.
>>>>>
>>>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>>>
>>>> This seems like a huge layering violation.  Imagine this in real
>>>> hardware, for example.
>>>
>>> commits 06c4648d46d1b757d6b9591a86810be79818b60c
>>> and 99606477a5888b0ead0284fecb13417b1da8e3af
>>> document the need for this:
>>>
>>> NETDEV_NOTIFY_PEERS notifier indicates that a device moved to a 
>>> different physical link.
>>> 	and
>>> In real hardware such notifications are only
>>> generated when the device comes up or the address changes.
>>>
>>> So hypervisor could get the same behaviour by sending link up/down
>>> events, this is just an optimization so guest won't do
>>> unecessary stuff like try to reconfigure an IP address.
>>>
>>>
>>> Maybe LOCATION_CHANGE would be a better name?
>>>
>>
>> ANNOUNCE_SELF?
> 
> It would be nice to formulate what kind of event
> are we notifying the guest about.
> The announce part of it is really up to the guest, isn't it?
> 

Right.

>>>
>>>> There may be a good reason why virtual devices might want this kind of
>>>> reconfiguration cheat, which is unnecessary for normal machines,
>>>
>>> I think yes, the difference with real hardware is guest can change
>>> location without link getting dropped.
>>> FWIW, Xen seems to use this capability too.
>>
>> So does ms netvsc.
>>
>>>
>>>> but
>>>> it'd have to be spelled out clearly in the spec to justify it...
>>>>
>>>> Cheers,
>>>> Rusty.
>>>
>>> Agree, and I'd like to see the spec too. The interface seems
>>> to involve the guest clearing the status bit when it detects
>>> an event?
>>
>> I would describe this in spec. The interface need guest to clear the
>> status bit, this would let the back-end know it has finished the work as
>> we may need to send the gratuitous packets many times.
>>
>>>
>>> Also - how does it interact with the link up event?
>>> We probably don't want to schedule this when we detect
>>> a link status change or during initialization, as
>>> this patch seems to do? What if link goes down
>>> while the work is running? Is that OK?
>>>
>>
>> Looks like there's are duplications if guest enable arp_notify vm is
>> started,
> 
> How hard would it be to avoid these duplicates?

Not hard, it could be done in backend by distinguishing the reason :
fresh start or cont after migration or stop.

> 
>> but we need to handle the situation that resuming a stopped
>> virtual machine.
>>
>> For the link down race, I don't see any real issue, either dropping or
>> queued.
> 
> For example, you do
>         unregister_netdev(vi->dev);
>         cancel_work_sync(&vi->announce);
> 
> which looks scary as announce seems to use the netdev.
> 

oops, it's a bug, I would fix it. Thanks
