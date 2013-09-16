From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/1] net: race condition when removing virtual net_device
Date: Mon, 16 Sep 2013 03:45:06 -0700
Message-ID: <87six5kpu5.fsf@xmission.com>
References: <1379008796-2121-1-git-send-email-fruggeri@aristanetworks.com>
	<87txhp249u.fsf@xmission.com>
	<CA+HUmGgyCsc-er6iB_mqg9whMyaquGWinkHOQEuEHbFCYVrXBw@mail.gmail.com>
	<871u4t1d9t.fsf@xmission.com>
	<CA+HUmGjEC8eXT7BHm20uVOagJQbsqO9VZjmGSgmUvnrtEH-JYw@mail.gmail.com>
	<87d2ocrx9b.fsf@xmission.com>
	<CA+HUmGifVOs+d=hs2rTUmMyyK17xfBFFbO8sY=rjS2D=RxFLZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: Francesco Ruggeri <fruggeri@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:43830 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753380Ab3IPKpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 06:45:21 -0400
In-Reply-To: <CA+HUmGifVOs+d=hs2rTUmMyyK17xfBFFbO8sY=rjS2D=RxFLZg@mail.gmail.com>
	(Francesco Ruggeri's message of "Sun, 15 Sep 2013 19:54:43 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francesco Ruggeri <fruggeri@aristanetworks.com> writes:

> On Fri, Sep 13, 2013 at 6:46 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>> Francesco Ruggeri <fruggeri@aristanetworks.com> writes:
>>
>>> On Thu, Sep 12, 2013 at 10:50 PM, Eric W. Biederman
>>> <ebiederm@xmission.com> wrote:
>>>
>>> I do have some concerns about both correctness and feasibility of this approach.
>>>
>>> About 2), namespace dependent operations triggered by unregistering
>>> the virtual devices (eg rt_flush_dev, dst_dev_event/dst_ifdown and
>>> probably more) would not be done in the namespaces where they should.
>>
>> Yes they will.  That is what dev_change_net_namespace does.
>
> You are right, I don't know what I was thinking.

>> It was worth a second look.  I can not find anything wrong with your
>> patch but I can not convince myself that it is correct either.  The
>> moving around the loopback device in the net dev todo list to prevent
>> deadlock I can't imagine why you are doing that.
>>
>
> That is in order not to introduce a potential deadlock when multiple
> namespaces are destroyed in default_device_exit_batch.
> Take the same veth scenario as before:
> v0 in namespace ns0 (loopback_dev lo0) and similarly for v1, ns1 and lo1.
> Assume two processes destroy ns0 and ns1. cleanup_net is executed in a
> workqueue and the two namespaces can end up being processed in the
> same instance of cleanup_net/ops_exit_list/default_device_exit_batch.
> default_device_exit_batch traverses each namespace's dev_base list and
> unregister_netdevice_queue is executed in this order:
> v0 v1 lo0 v1 v0 lo1.
> unregister_netdevice_queue is executed twice on v0 and v1 but that is
> ok because it uses list_move_tail and only the last one sticks.
> The resulting list for unregister_netdevice_many is:
> lo0 v1 v0 lo1.
> If v0 holds a reference to lo0 there will be a deadlock in
> netdev_run_todo if v0 does not come before lo0 in net_todo_list. By
> pushing all loopback_devs to the end of net_todo_list this situation
> is avoided.


>
> This is the sequence with today's (actually 3.4) code:
>
> unregister_netdevice_queue: v0 (ns ffff880037aecd00)
> unregister_netdevice_queue: v1 (ns ffff880037aed800)
> unregister_netdevice_queue: lo (ns ffff880037aecd00)
> unregister_netdevice_queue: v1 (ns ffff880037aed800)
> unregister_netdevice_queue: v0 (ns ffff880037aecd00)
> unregister_netdevice_queue: lo (ns ffff880037aed800)
> unregister_netdevice_many: lo (ns ffff880037aecd00) v1 (ns
> ffff880037aed800) v0 (ns ffff880037aecd00) lo (ns ffff880037aed800)
> netdev_run_todo: lo (ns ffff880037aecd00) v1 (ns ffff880037aed800) v0
> (ns ffff880037aecd00) lo (ns ffff880037aed800)

Interesting.

So we have a very small chance of hillarity ensuing with dst_ifdown.
But we probably won't notice because even if lo has been freed
the memory likely hasn't been recycled.  So dst_hold likely does not
affect anyone.

So it seems real problems only happens when we send the rebroadcast.
Which explains why this has gone unnoticed for so long.

I really don't want to support concurrency during the network namespace
shutdown.  That quickly becomes too crazy to think about.

I believe the weird reordering of veth devices is solved or largely
solved by:

commit f45a5c267da35174e22cec955093a7513dc1623d
Author: Eric Dumazet <edumazet@google.com>
Date:   Fri Feb 8 20:10:49 2013 +0000

    veth: fix NULL dereference in veth_dellink()
    
    commit d0e2c55e7c940 (veth: avoid a NULL deref in veth_stats_one)
    added another NULL deref in veth_dellink().
    
    # ip link add name veth1 type veth peer name veth0
    # rmmod veth
    
    We crash because veth_dellink() is called twice, so we must
    take care of NULL peer.
    
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Which unfortunately means you really need to test 3.11 or 3.12-rc1
to make headway on this issue.  If there is further veth specific
madness we can solve it by tweaking the veth driver.

> and this is the sequence after pushing the loopback_devs to the tail
> of net_todo_list:
>
> unregister_netdevice_queue: v0 (ns ffff8800379f8000)
> unregister_netdevice_queue: v1 (ns ffff8800378c0b00)
> unregister_netdevice_queue: lo (ns ffff8800379f8000)
> unregister_netdevice_queue: v1 (ns ffff8800378c0b00)
> unregister_netdevice_queue: v0 (ns ffff8800379f8000)
> unregister_netdevice_queue: lo (ns ffff8800378c0b00)
> unregister_netdevice_many: lo (ns ffff8800379f8000) v1 (ns
> ffff8800378c0b00) v0 (ns ffff8800379f8000) lo (ns ffff8800378c0b00)
> netdev_run_todo: v1 (ns ffff8800378c0b00) v0 (ns ffff8800379f8000) lo
> (ns ffff8800379f8000) lo (ns ffff8800378c0b00)

I am scratching my head.  That isn't what I would expect from putting
loopback devices at the end of the list.

Even more I am not comfortable with any situation where preserving the
order in which the devices are unregistered is not sufficient to make
things work correctly.  That quickly gets into fragile layering
problems, and I don't know how anyone would be able to maintain that.

I still don't see a better solution than dev_change_net_namespace,
for the network devices that have this problem.  Network devices are not
supposed to be findable after the dance at the start of cleanup_net.

It might be possible to actually build asynchronous network device
unregistration and opportunistick batching.  Aka cleanup network devices
much like we clean up network namespaces now, and by funnelling them all
into a single threaded work queue that would probably stop the races, as
well as improve performance.  I don't have the energy to do that right
now unfortunately :(

> Should we take this discussion offline?
> I do appreciate your spending time on this.

If anyone complains we can drop them off of the CC but it is useful to
leave a record of the thought process that went into this, so we should
at the minimum keep netdev in the loop.
