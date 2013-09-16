From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: Re: [PATCH 1/1] net: race condition when removing virtual net_device
Date: Mon, 16 Sep 2013 13:30:50 -0700
Message-ID: <CA+HUmGih9akzhpRrb_0WEapi4jGcuSV8qO==QeRWHoqnxzFyng@mail.gmail.com>
References: <1379008796-2121-1-git-send-email-fruggeri@aristanetworks.com>
	<87txhp249u.fsf@xmission.com>
	<CA+HUmGgyCsc-er6iB_mqg9whMyaquGWinkHOQEuEHbFCYVrXBw@mail.gmail.com>
	<871u4t1d9t.fsf@xmission.com>
	<CA+HUmGjEC8eXT7BHm20uVOagJQbsqO9VZjmGSgmUvnrtEH-JYw@mail.gmail.com>
	<87d2ocrx9b.fsf@xmission.com>
	<CA+HUmGifVOs+d=hs2rTUmMyyK17xfBFFbO8sY=rjS2D=RxFLZg@mail.gmail.com>
	<87six5kpu5.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f182.google.com ([209.85.220.182]:41423 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065Ab3IPUav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 16:30:51 -0400
Received: by mail-vc0-f182.google.com with SMTP id hf12so3248170vcb.41
        for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 13:30:50 -0700 (PDT)
In-Reply-To: <87six5kpu5.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 16, 2013 at 3:45 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:

> I believe the weird reordering of veth devices is solved or largely
> solved by:
>
> commit f45a5c267da35174e22cec955093a7513dc1623d

I looked at d0e2c55e and f45a5c26 in the past and I do not think they
are related to the problem I see, which I think is more related to the
infrastructure. See more below.

>
>> and this is the sequence after pushing the loopback_devs to the tail
>> of net_todo_list:
>>
>> unregister_netdevice_queue: v0 (ns ffff8800379f8000)
>> unregister_netdevice_queue: v1 (ns ffff8800378c0b00)
>> unregister_netdevice_queue: lo (ns ffff8800379f8000)
>> unregister_netdevice_queue: v1 (ns ffff8800378c0b00)
>> unregister_netdevice_queue: v0 (ns ffff8800379f8000)
>> unregister_netdevice_queue: lo (ns ffff8800378c0b00)
>> unregister_netdevice_many: lo (ns ffff8800379f8000) v1 (ns
>> ffff8800378c0b00) v0 (ns ffff8800379f8000) lo (ns ffff8800378c0b00)
>> netdev_run_todo: v1 (ns ffff8800378c0b00) v0 (ns ffff8800379f8000) lo
>> (ns ffff8800379f8000) lo (ns ffff8800378c0b00)
>
> I am scratching my head.  That isn't what I would expect from putting
> loopback devices at the end of the list.

The way to read it is as follows:
unregister_netdevice_many gets the sequence lo0 v1 v0 lo1 (lo0 is the
occurrence of "lo" with the same namespace as v0, etc.).
As the interfaces are unlisted the loopback_devs are queued at the end
of net_todo_list, so when netdev_run_todo executes net_todo_list is v1
v0 lo0 lo1.

>
> Even more I am not comfortable with any situation where preserving the
> order in which the devices are unregistered is not sufficient to make
> things work correctly.  That quickly gets into fragile layering
> problems, and I don't know how anyone would be able to maintain that.
>

I agree with your general statement, but unfortunately the order in
which the interfaces are unregistered is not preserved even in the
current code, since dev_close_many already rearranges them based on
whether they are UP or not.

If I delete a namespace with only lo and v0 this is the order in which
they are released depending on their state. If lo is DOWN then it will
be processed before v0 in netdev_run_todo.

====== lo down, v0 down
unregister_netdevice_queue: v0 (ns ffff880037bb0b00)
unregister_netdevice_queue: lo (ns ffff880037bb0b00)
unregister_netdevice_many: v0 (ns ffff880037bb0b00) lo (ns ffff880037bb0b00)
netdev_run_todo: lo (ns ffff880037bb0b00) v0 (ns ffff880037bb0b00)

====== lo up, v0 down
unregister_netdevice_queue: v0 (ns ffff8800378a9600)
unregister_netdevice_queue: lo (ns ffff8800378a9600)
unregister_netdevice_many: v0 (ns ffff8800378a9600) lo (ns ffff8800378a9600)
netdev_run_todo: v0 (ns ffff8800378a9600) lo (ns ffff8800378a9600)

====== lo down, v0 up
unregister_netdevice_queue: v0 (ns ffff880037bb0b00)
unregister_netdevice_queue: lo (ns ffff880037bb0b00)
unregister_netdevice_many: v0 (ns ffff880037bb0b00) lo (ns ffff880037bb0b00)
netdev_run_todo: lo (ns ffff880037bb0b00) v0 (ns ffff880037bb0b00)

====== lo up, v0 up
unregister_netdevice_queue: v0 (ns ffff8800378a9600)
unregister_netdevice_queue: lo (ns ffff8800378a9600)
unregister_netdevice_many: v0 (ns ffff8800378a9600) lo (ns ffff8800378a9600)
netdev_run_todo: v0 (ns ffff8800378a9600) lo (ns ffff8800378a9600)


> I still don't see a better solution than dev_change_net_namespace,
> for the network devices that have this problem.  Network devices are not
> supposed to be findable after the dance at the start of cleanup_net.
>

I think the problem we are seeing is an infrastructure one. If I can restate it:

1) When destroying a namespace all net_devices in it should be
disposed of before any non-device pernet subsystems exit. The existing
code tries to do this but it does not take into consideration
net_devices that may have been unlisted from the namespace by another
process which is still in the process of destroying them (specifically
in netdev_run_todo/netdev_wait_allrefs).

There is also another issue, separate but related (my diffs did not
try to address it):

2) dev_change_net_namespace does not have the equivalent of
netdev_wait_allrefs. If rebroadcasts are in fact needed when
destroying a net_device then the same should apply when the net_device
is moved out of a namespace. With existing code a net_device can be
moved to a different namespace before its refcount drops to 0. Any
later broadcasts will not trigger any action in the original namespace
where they should have occurred.

I suspect that this is not catastrophic but its effects could be
subtle. This is another reason why I would avoid using
dev_change_net_namespace as a driver level solution for 1) above,
besides the fact that we would have to apply it to all drivers
affected by this (veth, vlan, macvlan, maybe more).

> It might be possible to actually build asynchronous network device
> unregistration and opportunistick batching.  Aka cleanup network devices
> much like we clean up network namespaces now, and by funnelling them all
> into a single threaded work queue that would probably stop the races, as
> well as improve performance.  I don't have the energy to do that right
> now unfortunately :(
>

That would probably solve it, but as you suggest it will take a
considerable amount of work and code re-structuring.

Francesco
