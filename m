From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: Re: [PATCH 1/1] net: race condition when removing virtual net_device
Date: Sun, 15 Sep 2013 19:54:43 -0700
Message-ID: <CA+HUmGifVOs+d=hs2rTUmMyyK17xfBFFbO8sY=rjS2D=RxFLZg@mail.gmail.com>
References: <1379008796-2121-1-git-send-email-fruggeri@aristanetworks.com>
	<87txhp249u.fsf@xmission.com>
	<CA+HUmGgyCsc-er6iB_mqg9whMyaquGWinkHOQEuEHbFCYVrXBw@mail.gmail.com>
	<871u4t1d9t.fsf@xmission.com>
	<CA+HUmGjEC8eXT7BHm20uVOagJQbsqO9VZjmGSgmUvnrtEH-JYw@mail.gmail.com>
	<87d2ocrx9b.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f175.google.com ([209.85.128.175]:55910 "EHLO
	mail-ve0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538Ab3IPCyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Sep 2013 22:54:44 -0400
Received: by mail-ve0-f175.google.com with SMTP id jy13so2492346veb.20
        for <netdev@vger.kernel.org>; Sun, 15 Sep 2013 19:54:43 -0700 (PDT)
In-Reply-To: <87d2ocrx9b.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 13, 2013 at 6:46 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Francesco Ruggeri <fruggeri@aristanetworks.com> writes:
>
>> On Thu, Sep 12, 2013 at 10:50 PM, Eric W. Biederman
>> <ebiederm@xmission.com> wrote:
>>
>> I do have some concerns about both correctness and feasibility of this approach.
>>
>> About 2), namespace dependent operations triggered by unregistering
>> the virtual devices (eg rt_flush_dev, dst_dev_event/dst_ifdown and
>> probably more) would not be done in the namespaces where they should.
>
> Yes they will.  That is what dev_change_net_namespace does.

You are right, I don't know what I was thinking.

>
> It was worth a second look.  I can not find anything wrong with your
> patch but I can not convince myself that it is correct either.  The
> moving around the loopback device in the net dev todo list to prevent
> deadlock I can't imagine why you are doing that.
>

That is in order not to introduce a potential deadlock when multiple
namespaces are destroyed in default_device_exit_batch.
Take the same veth scenario as before:
v0 in namespace ns0 (loopback_dev lo0) and similarly for v1, ns1 and lo1.
Assume two processes destroy ns0 and ns1. cleanup_net is executed in a
workqueue and the two namespaces can end up being processed in the
same instance of cleanup_net/ops_exit_list/default_device_exit_batch.
default_device_exit_batch traverses each namespace's dev_base list and
unregister_netdevice_queue is executed in this order:
v0 v1 lo0 v1 v0 lo1.
unregister_netdevice_queue is executed twice on v0 and v1 but that is
ok because it uses list_move_tail and only the last one sticks.
The resulting list for unregister_netdevice_many is:
lo0 v1 v0 lo1.
If v0 holds a reference to lo0 there will be a deadlock in
netdev_run_todo if v0 does not come before lo0 in net_todo_list. By
pushing all loopback_devs to the end of net_todo_list this situation
is avoided.

This is the sequence with today's (actually 3.4) code:

unregister_netdevice_queue: v0 (ns ffff880037aecd00)
unregister_netdevice_queue: v1 (ns ffff880037aed800)
unregister_netdevice_queue: lo (ns ffff880037aecd00)
unregister_netdevice_queue: v1 (ns ffff880037aed800)
unregister_netdevice_queue: v0 (ns ffff880037aecd00)
unregister_netdevice_queue: lo (ns ffff880037aed800)
unregister_netdevice_many: lo (ns ffff880037aecd00) v1 (ns
ffff880037aed800) v0 (ns ffff880037aecd00) lo (ns ffff880037aed800)
netdev_run_todo: lo (ns ffff880037aecd00) v1 (ns ffff880037aed800) v0
(ns ffff880037aecd00) lo (ns ffff880037aed800)

and this is the sequence after pushing the loopback_devs to the tail
of net_todo_list:

unregister_netdevice_queue: v0 (ns ffff8800379f8000)
unregister_netdevice_queue: v1 (ns ffff8800378c0b00)
unregister_netdevice_queue: lo (ns ffff8800379f8000)
unregister_netdevice_queue: v1 (ns ffff8800378c0b00)
unregister_netdevice_queue: v0 (ns ffff8800379f8000)
unregister_netdevice_queue: lo (ns ffff8800378c0b00)
unregister_netdevice_many: lo (ns ffff8800379f8000) v1 (ns
ffff8800378c0b00) v0 (ns ffff8800379f8000) lo (ns ffff8800378c0b00)
netdev_run_todo: v1 (ns ffff8800378c0b00) v0 (ns ffff8800379f8000) lo
(ns ffff8800379f8000) lo (ns ffff8800378c0b00)

Should we take this discussion offline?
I do appreciate your spending time on this.

Thanks,
Francesco

>
> Eric
>
