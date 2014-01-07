From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net 1/2] macvlan: forbid L2 fowarding offload for macvtap
Date: Mon, 06 Jan 2014 23:26:34 -0800
Message-ID: <52CBAC2A.90005@intel.com>
References: <1388978467-2075-1-git-send-email-jasowang@redhat.com> <52CA5CDA.1020503@gmail.com> <52CA612D.2000902@redhat.com> <20140106122628.GA24280@hmsreliant.think-freely.org> <52CB7009.2030903@redhat.com> <52CB8D54.9090506@gmail.com> <52CB9D1A.1050101@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, Vlad Yasevich <vyasevic@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52CB9D1A.1050101@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[...]

>>> Unfortunately not. This commit has a side effect that it in fact
>>> disables the multiqueue macvtap transmission. Since all macvtap queues
>>> will contend on a single qdisc lock.
>>>
>>
>> They will only contend on a single qdisc lock if the lower device has
>> 1 queue.
>
> I think we are talking about 6acf54f1cf0a6747bac9fea26f34cfc5a9029523.

Yes.

>
> The qdisc or txq lock were macvlan device itself since dev_queue_xmit()
> was called for macvlan device itself. So even if lower device has
> multiple txqs, if you just create a one queue macvlan device, you will
> get lock contention on macvlan device. And even if you explicitly
> specifying the txq numbers ( though I don't believe most management
> software will do this) when creating the macvlan/macvtap device, you
> must also configure the XPS for macvlan to make sure it has the
> possibility of using multiple transmit queues.
>

OK I think I'm finally putting all the pieces together thanks.

Do you know why macvtap is setting dev->tx_queue_len by default? If you
zero this then the noqueue_qdisc is used and the q->enqueue check in
dev_queue_xmit will fail.

Also if XPS is not configured then skb_tx_hash is used so multiple
transmit queues will still be used.

>> Perhaps defaulting the L2 forwarding devices to 1queue was a
>> mistake. But the same issue arises when running macvtap over a
>> non-multiqueue nic. Or even if you have a multiqueue device and create
>> many more macvtap queues than the lower device has queues.
>>
>> Shouldn't the macvtap configuration take into account the lowest level
>> devices queues?
>
> See commit 8ffab51b3dfc54876f145f15b351c41f3f703195 ("macvlan: lockless
> tx path"). It allows the management to create a device without worrying
> the underlying device.

OK.

>> How does using the L2 forwarding device change the
>> contention issues? Without the L2 forwarding LLTX is enabled but the
>> qdisc lock, etc is still acquired on the device below the macvlan.
>>
>
> That's the point. We need make sure the txq selection and qdisc lock
> were done for the lower device not for the macvlan device itself. Then
> macvlan can automatically benefit from the multi-queue capable lower
> devices. But L2 forwarding needs to contend on the txq lock on macvlan
> device itself, which is unnecessary and can complex the management.

If I make the l2 forwarding defaults a bit better then using the L2
forwarding case should not be any more complex. And because the queues
are dedicated to the macvtap device any contention from qdisc lock, etc
comes from the upper device only. Also if I get the bandwidth controls
in we can set the max/min bandwidth per macvtap device this way. That
is future work though.

>> The ixgbe driver as it is currently written can be configured for up to
>> 4 queues by setting numtxqueues when the device is created. I assume
>> when creating macvtap queues the user needs to account for the number
>> of queues supported by the lower device.
>>
>
> We'd better not complicate the task of management, lockless tx path work
> very well so we can just keep it. Btw, there's no way for the user to
> know the maximum number of queues that L2 forwarding supports.

Good point I'll add an attribute to query it.

>>> For L2 forwarding offload itself, more issues need to be addressed for
>>> multiqueue macvtap:
>>>
>>> - ndo_dfwd_add_station() can only create queues per device at ndo_open,
>>> but multiqueue macvtap allows user to create and destroy queues at their
>>> will and at any time.
>>
>> same argument as above, isn't this the same when running macvtap without
>> the l2 offloads over a real device? I expect you hit the same contention
>> points when running over a real device.
>
> Not true and not only for contention.
>
> Macvtap allows user to create or destroy a queue by simply open or close
> to character device /dev/tapX. But currently, we do nothing when a new
> queue was created or destroyed for L2 forwarding offload.
>
> For contention, lockless tx path make the contention only happens for
> the txq or qdisc for the lower device, but L2 forwarding offload make
> contention also happen for the macvlan device itself.

Right, but there will be less contention there because those queues
are a dedicated resource for the upper device.

At this point I think I need to put together a real testbed and
benchmark some of this with netperf and perf running to get real
numbers. When I originally did the l2 forwarding I did not do any
testing with multiple macvtap queues and only very limited work with
macvtap.

>
>>
>>
>>> - it looks that ixgbe has a upper limit of 4 queues per station, but
>>> macvtap currently allows up to 16 queues per device.
>>>
>>
>> The 4 limit was to simplify the code because the queue mapping in the
>> driver gets complicated if it is greater than 4. We can probably
>> increase this latter. But sorry reiterating how is this different than
>> a macvtap on a real device that supports a max of 4 queues?
>
> Well, it maybe easy. I just point out possible issues we may meet currently.

Right.

>>
>>> So more works need to be done and unless those above 3 issues were
>>> addressed, this patch is really needed to make sure macvtap works.
>>>
>>
>> Agreed there is a lot more work here to improve things I'm just not
>> sure we need to disable this now. Also note its the l2 forwarding
>> should be disabled by default so a user would have to enable the
>> feature flag.
>
> Even if it was disabled by default. We should not surprise the user who
> want to enable it for macvtap.

So the question is what to do in net while we improve net-next. Either
we fix the crash from the null txq and note that with l2 forwarding
some non default configuration is needed for optimal performance OR
for now disable it as your patch does. I would prefer to fix the crash
and note the configuration but I see your point about surprising users
so could go either way.

Neil any thoughts?

To fix the null txq in the gso case adding a check for a non-null
txq before calling txq_trans_update() makes sense to me. We already
have the check in the non-gso case so making it symmetric fixes it.

>>
>> Thanks,
>> John
>>
>
> Thanks
>
