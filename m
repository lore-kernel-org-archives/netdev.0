From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/1] net: race condition when removing virtual net_device
Date: Mon, 16 Sep 2013 17:25:28 -0700
Message-ID: <87r4cocn0n.fsf@xmission.com>
References: <1379008796-2121-1-git-send-email-fruggeri@aristanetworks.com>
	<87txhp249u.fsf@xmission.com>
	<CA+HUmGgyCsc-er6iB_mqg9whMyaquGWinkHOQEuEHbFCYVrXBw@mail.gmail.com>
	<871u4t1d9t.fsf@xmission.com>
	<CA+HUmGjEC8eXT7BHm20uVOagJQbsqO9VZjmGSgmUvnrtEH-JYw@mail.gmail.com>
	<87d2ocrx9b.fsf@xmission.com>
	<CA+HUmGifVOs+d=hs2rTUmMyyK17xfBFFbO8sY=rjS2D=RxFLZg@mail.gmail.com>
	<87six5kpu5.fsf@xmission.com>
	<CA+HUmGih9akzhpRrb_0WEapi4jGcuSV8qO==QeRWHoqnxzFyng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: Francesco Ruggeri <fruggeri@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:42275 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166Ab3IQAZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 20:25:38 -0400
In-Reply-To: <CA+HUmGih9akzhpRrb_0WEapi4jGcuSV8qO==QeRWHoqnxzFyng@mail.gmail.com>
	(Francesco Ruggeri's message of "Mon, 16 Sep 2013 13:30:50 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Francesco Ruggeri <fruggeri@aristanetworks.com> writes:

> On Mon, Sep 16, 2013 at 3:45 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>
>> I believe the weird reordering of veth devices is solved or largely
>> solved by:
>>
>> commit f45a5c267da35174e22cec955093a7513dc1623d
>
> I looked at d0e2c55e and f45a5c26 in the past and I do not think they
> are related to the problem I see, which I think is more related to the
> infrastructure. See more below.

If everything is in the same batch they definitely relate, as it stops
refiling one of the devices past the point where it's loopback device
is destroyed.

It is not the fundamental problem but it is related and those fixes.

>>> and this is the sequence after pushing the loopback_devs to the tail
>>> of net_todo_list:
>>>
>>> unregister_netdevice_queue: v0 (ns ffff8800379f8000)
>>> unregister_netdevice_queue: v1 (ns ffff8800378c0b00)
>>> unregister_netdevice_queue: lo (ns ffff8800379f8000)
>>> unregister_netdevice_queue: v1 (ns ffff8800378c0b00)
>>> unregister_netdevice_queue: v0 (ns ffff8800379f8000)
>>> unregister_netdevice_queue: lo (ns ffff8800378c0b00)
>>> unregister_netdevice_many: lo (ns ffff8800379f8000) v1 (ns
>>> ffff8800378c0b00) v0 (ns ffff8800379f8000) lo (ns ffff8800378c0b00)
>>> netdev_run_todo: v1 (ns ffff8800378c0b00) v0 (ns ffff8800379f8000) lo
>>> (ns ffff8800379f8000) lo (ns ffff8800378c0b00)
>>
>> I am scratching my head.  That isn't what I would expect from putting
>> loopback devices at the end of the list.
>
> The way to read it is as follows:
> unregister_netdevice_many gets the sequence lo0 v1 v0 lo1 (lo0 is the
> occurrence of "lo" with the same namespace as v0, etc.).
> As the interfaces are unlisted the loopback_devs are queued at the end
> of net_todo_list, so when netdev_run_todo executes net_todo_list is v1
> v0 lo0 lo1.

My reading jumbled the unregister_netdevice_many line and the
netdev_run_todo line.  So I was seeing v0, lo, v1, v0, lo, lo.
But since both loop devices are now at the end your that part of your
patch looks ok.

>> Even more I am not comfortable with any situation where preserving the
>> order in which the devices are unregistered is not sufficient to make
>> things work correctly.  That quickly gets into fragile layering
>> problems, and I don't know how anyone would be able to maintain that.
>>
>
> I agree with your general statement, but unfortunately the order in
> which the interfaces are unregistered is not preserved even in the
> current code, since dev_close_many already rearranges them based on
> whether they are UP or not.

Ugh.  That is a bug.

I have sent a patch to solve this by simply not reordering the device
deletions as that is easier to think about.  And more robust if we
happen to care about anything besides the loopback device.  Reording
happens so seldom I can't imagine it being tested properly.

I have also sent a patch to set loopback_dev to NULL so that it is more
likely we will see your class of bugs.

I think I see bugs with the handling of rtmsg_ifinfo, and
netpoll_rx_enable/disable in dev_close_many as well. But those are
significantly less serious issues.

If you could verify that my patch to dev_close solves the ordering
issues you were seeing I would appreciate that.

>> I still don't see a better solution than dev_change_net_namespace,
>> for the network devices that have this problem.  Network devices are not
>> supposed to be findable after the dance at the start of cleanup_net.
>>
>
> I think the problem we are seeing is an infrastructure one. If I can restate it:
>
> 1) When destroying a namespace all net_devices in it should be
> disposed of before any non-device pernet subsystems exit. The existing
> code tries to do this but it does not take into consideration
> net_devices that may have been unlisted from the namespace by another
> process which is still in the process of destroying them (specifically
> in netdev_run_todo/netdev_wait_allrefs).

The existing code makes the assumption that is not possible to find
a network device and manipulate it outside the network namespace in
any way (outside of the network namespace cleanup methods) after the
network namespace reference count has dropped to 0 and the network
namespace is no longer in the network namespace list.

That assumption is clearly not true for veth pairs, vlans, macvlans and
the like, and it is an infrastructure problem.

The question is what is the most robust comprehensible and maintinable
fix?  (That doesn't penalize the fast path of course).

> There is also another issue, separate but related (my diffs did not
> try to address it):
>
> 2) dev_change_net_namespace does not have the equivalent of
> netdev_wait_allrefs. If rebroadcasts are in fact needed when
> destroying a net_device then the same should apply when the net_device
> is moved out of a namespace. With existing code a net_device can be
> moved to a different namespace before its refcount drops to 0. Any
> later broadcasts will not trigger any action in the original namespace
> where they should have occurred.

Not having the broadcast in dev_change_net_namespace is not a bug.  The
repeated broadcast is most definitely there for hysterical raisins, and
with a good audit of dev_hold/dev_put call sites can most definitely be
removed.  At a practical level the repeated broadcast is just acting as
a hammer and saying to subsystems you messed up now let this device go.
Let go! Let go! Let go! And there is a slight hope that something will
let go when told multiple times.

> I suspect that this is not catastrophic but its effects could be
> subtle. This is another reason why I would avoid using
> dev_change_net_namespace as a driver level solution for 1) above,
> besides the fact that we would have to apply it to all drivers
> affected by this (veth, vlan, macvlan, maybe more).

We don't avoid the rebroadcast and wait, with dev_change_net_namespace,
they are just performed in a different network namespace.  So if
something is wrong we will know.

>> It might be possible to actually build asynchronous network device
>> unregistration and opportunistick batching.  Aka cleanup network devices
>> much like we clean up network namespaces now, and by funnelling them all
>> into a single threaded work queue that would probably stop the races, as
>> well as improve performance.  I don't have the energy to do that right
>> now unfortunately :(
>>
>
> That would probably solve it, but as you suggest it will take a
> considerable amount of work and code re-structuring.

And it may be worth it for the speed up you get when destroying 384 mlag
ports.

Eric
