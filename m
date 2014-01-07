From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net 1/2] macvlan: forbid L2 fowarding offload for macvtap
Date: Tue, 07 Jan 2014 14:22:18 +0800
Message-ID: <52CB9D1A.1050101@redhat.com>
References: <1388978467-2075-1-git-send-email-jasowang@redhat.com> <52CA5CDA.1020503@gmail.com> <52CA612D.2000902@redhat.com> <20140106122628.GA24280@hmsreliant.think-freely.org> <52CB7009.2030903@redhat.com> <52CB8D54.9090506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, John Fastabend <john.r.fastabend@intel.com>,
	Vlad Yasevich <vyasevic@redhat.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19138 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750849AbaAGGWg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 01:22:36 -0500
In-Reply-To: <52CB8D54.9090506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2014 01:15 PM, John Fastabend wrote:
> On 01/06/2014 07:10 PM, Jason Wang wrote:
>> On 01/06/2014 08:26 PM, Neil Horman wrote:
>>> On Mon, Jan 06, 2014 at 03:54:21PM +0800, Jason Wang wrote:
>>>> On 01/06/2014 03:35 PM, John Fastabend wrote:
>>>>> On 01/05/2014 07:21 PM, Jason Wang wrote:
>>>>>> L2 fowarding offload will bypass the rx handler of real device. This
>>>>>> will make
>>>>>> the packet could not be forwarded to macvtap device. Another problem
>>>>>> is the
>>>>>> dev_hard_start_xmit() called for macvtap does not have any
>>>>>> synchronization.
>>>>>>
>>>>>> Fix this by forbidding L2 forwarding for macvtap.
>>>>>>
>>>>>> Cc: John Fastabend <john.r.fastabend@intel.com>
>>>>>> Cc: Neil Horman <nhorman@tuxdriver.com>
>>>>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>>>>> ---
>>>>>>    drivers/net/macvlan.c |    5 ++++-
>>>>>>    1 files changed, 4 insertions(+), 1 deletions(-)
>>>>>>
>>>>> I must be missing something.
>>>>>
>>>>> The lower layer device should set skb->dev to the correct macvtap
>>>>> device on receive so that in netif_receive_skb_core() the macvtap
>>>>> handler is hit. Skipping the macvlan receive handler should be OK
>>>>> because the switching was done by the hardware. If I read macvtap.c
>>>>> correctly macvlan_common_newlink() is called with 'dev' where 'dev'
>>>>> is the macvtap device. Any idea what I'm missing? I guess I'll need
>>>>> to setup a macvtap test case.
>>>> Unlike macvlan, macvtap depends on rx handler on the lower device to
>>>> work. In this case macvlan_handle_frame() will call macvtap_receive().
>>>> So doing netif_receive_skb_core() for macvtap device directly won't
>>>> work
>>>> since we need to forward the packet to userspace instead of kernel.
>>>>
>>>> For net-next.git, it may work since commit
>>>> 6acf54f1cf0a6747bac9fea26f34cfc5a9029523 let macvtap device
>>>> register an
>>>> rx handler for itself.
>>> I agree, this seems like it should already be fixed with the above
>>> commit.  With
>>> this the macvlan rx handler should effectively be a no-op as far as the
>>> reception of frames is concerned.  As long as the driver sets the
>>> dev correctly
>>> to the macvtap device (and it appears to), macvtap will get frames
>>> to user
>>> space, regardless of weather the software or hardware did the
>>> switching.  If
>>> thats the case though, I think the solution is moving that fix to
>>> -stable
>>> (pending testing of course), rather than comming up with a new fix.
>>>
>>>>> And what synchronization are you worried about on
>>>>> dev_hard_start_xmit()?
>>>>> In the L2 forwarding offload case macvlan_open() clears the
>>>>> NETIF_F_LLTX
>>>>> flag so HARD_TX_LOCK protects the driver txq. We might hit this
>>>>> warning
>>>>> in dev_queue_xmit() though,
>>>>>
>>>>>    net_crit_ratelimited("Virtual device %s asks to queue packet!\n",
>>>>>
>>>>> Perhaps we can remove it.
>>>> The problem is macvtap does not call dev_queue_xmit() for macvlan
>>>> device. It calls macvlan_start_xmit() directly from
>>>> macvtap_get_user().
>>>> So HARD_TX_LOCK was not done for the txq.
>>> This seems to also be fixed by
>>> 6acf54f1cf0a6747bac9fea26f34cfc5a9029523.
>>> Macvtap does, as of that commit use dev_queue_xmit for the
>>> transmission of
>>> frames to the lowerdevice.
>>
>> Unfortunately not. This commit has a side effect that it in fact
>> disables the multiqueue macvtap transmission. Since all macvtap queues
>> will contend on a single qdisc lock.
>>
>
> They will only contend on a single qdisc lock if the lower device has
> 1 queue. 

I think we are talking about 6acf54f1cf0a6747bac9fea26f34cfc5a9029523.

The qdisc or txq lock were macvlan device itself since dev_queue_xmit()
was called for macvlan device itself. So even if lower device has
multiple txqs, if you just create a one queue macvlan device, you will
get lock contention on macvlan device. And even if you explicitly
specifying the txq numbers ( though I don't believe most management
software will do this) when creating the macvlan/macvtap device, you
must also configure the XPS for macvlan to make sure it has the
possibility of using multiple transmit queues.

> Perhaps defaulting the L2 forwarding devices to 1queue was a
> mistake. But the same issue arises when running macvtap over a
> non-multiqueue nic. Or even if you have a multiqueue device and create
> many more macvtap queues than the lower device has queues.
>
> Shouldn't the macvtap configuration take into account the lowest level
> devices queues? 

See commit 8ffab51b3dfc54876f145f15b351c41f3f703195 ("macvlan: lockless
tx path"). It allows the management to create a device without worrying
the underlying device.
> How does using the L2 forwarding device change the
> contention issues? Without the L2 forwarding LLTX is enabled but the
> qdisc lock, etc is still acquired on the device below the macvlan.
>

That's the point. We need make sure the txq selection and qdisc lock
were done for the lower device not for the macvlan device itself. Then
macvlan can automatically benefit from the multi-queue capable lower
devices. But L2 forwarding needs to contend on the txq lock on macvlan
device itself, which is unnecessary and can complex the management.
> The ixgbe driver as it is currently written can be configured for up to
> 4 queues by setting numtxqueues when the device is created. I assume
> when creating macvtap queues the user needs to account for the number
> of queues supported by the lower device.
>

We'd better not complicate the task of management, lockless tx path work
very well so we can just keep it. Btw, there's no way for the user to
know the maximum number of queues that L2 forwarding supports.
>> For L2 forwarding offload itself, more issues need to be addressed for
>> multiqueue macvtap:
>>
>> - ndo_dfwd_add_station() can only create queues per device at ndo_open,
>> but multiqueue macvtap allows user to create and destroy queues at their
>> will and at any time.
>
> same argument as above, isn't this the same when running macvtap without
> the l2 offloads over a real device? I expect you hit the same contention
> points when running over a real device.

Not true and not only for contention.

Macvtap allows user to create or destroy a queue by simply open or close
to character device /dev/tapX. But currently, we do nothing when a new
queue was created or destroyed for L2 forwarding offload.

For contention, lockless tx path make the contention only happens for
the txq or qdisc for the lower device, but L2 forwarding offload make
contention also happen for the macvlan device itself.

>
>
>> - it looks that ixgbe has a upper limit of 4 queues per station, but
>> macvtap currently allows up to 16 queues per device.
>>
>
> The 4 limit was to simplify the code because the queue mapping in the
> driver gets complicated if it is greater than 4. We can probably
> increase this latter. But sorry reiterating how is this different than
> a macvtap on a real device that supports a max of 4 queues?

Well, it maybe easy. I just point out possible issues we may meet currently.
>
>> So more works need to be done and unless those above 3 issues were
>> addressed, this patch is really needed to make sure macvtap works.
>>
>
> Agreed there is a lot more work here to improve things I'm just not
> sure we need to disable this now. Also note its the l2 forwarding
> should be disabled by default so a user would have to enable the
> feature flag.

Even if it was disabled by default. We should not surprise the user who
want to enable it for macvtap.
>
> Thanks,
> John
>

Thanks
