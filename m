From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [CFT][PATCH] net: Delay default_device_exit_batch until no devices are unregistering
Date: Tue, 17 Sep 2013 02:38:56 -0700
Message-ID: <87mwnb949b.fsf@xmission.com>
References: <1379008796-2121-1-git-send-email-fruggeri@aristanetworks.com>
	<87txhp249u.fsf@xmission.com>
	<CA+HUmGgyCsc-er6iB_mqg9whMyaquGWinkHOQEuEHbFCYVrXBw@mail.gmail.com>
	<871u4t1d9t.fsf@xmission.com>
	<CA+HUmGjEC8eXT7BHm20uVOagJQbsqO9VZjmGSgmUvnrtEH-JYw@mail.gmail.com>
	<87d2ocrx9b.fsf@xmission.com>
	<CA+HUmGifVOs+d=hs2rTUmMyyK17xfBFFbO8sY=rjS2D=RxFLZg@mail.gmail.com>
	<87six5kpu5.fsf@xmission.com>
	<CA+HUmGih9akzhpRrb_0WEapi4jGcuSV8qO==QeRWHoqnxzFyng@mail.gmail.com>
	<87mwncaz04.fsf_-_@xmission.com>
	<CA+HUmGjg9jE1fjSMgkfVtiWVRD3d2DuwfbPU3Owrk_cTCe0FQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: Francesco Ruggeri <fruggeri@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:57134 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853Ab3IQJjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 05:39:07 -0400
In-Reply-To: <CA+HUmGjg9jE1fjSMgkfVtiWVRD3d2DuwfbPU3Owrk_cTCe0FQA@mail.gmail.com>
	(Francesco Ruggeri's message of "Mon, 16 Sep 2013 23:54:41 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francesco Ruggeri <fruggeri@aristanetworks.com> writes:

> On Mon, Sep 16, 2013 at 8:49 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:

>> Francesco could you take a look at this.  I am about 99% certain this is
>> right but I am starting to fade.  So it is entirely possible I missed
>> something.
>
> Same here ...
> The logic looks right to me and I think it should address the original
> issue I ran into.
> Would it make sense to have netdev_unregistering and
> netdev_unregistering_wait be per-namespace, and have
> default_device_exit_batch only wait for the namespaces in net_list? It
> would require some extra loops and locking, but it may help avoid
> unnecessary waits.

It might be worth it, and it certainly would give a good progress
guarantee, as activity in an exiting network namespace is guaranteed to
wind down.  Progress guarantees are always good to have.

The downside of a per netns unregistering count is that we will have
extra wake ups which will could result in extra contention on the
rtnl_lock.

The wait queue definitely makes sense to be global as there only ever
can be a single waiter, because the netns_wq is single threaded and
everything we are doing is happening with the net_mutex held.

The count doesn't necessarily need to be atomic as it can be protected
by the rtnl_lock.

Like I said the logic is a little rough as I was tired. 

I am heading off to New Orleans for Linux Plumbers Conference in a
couple hours so I don't expect I will be particularly responsive
again until next week.

If you could test this patch perhaps refine it I think we are almost at
a final point of fixing this.

Just to be clear my reason for prefering this approach is that because
it adds no extra wait points (we already wait for the rtnl_lock), the
logic is unconditional and explicit and not hidden in the loopback
device's reference count.  Which should allow anyone reading the code
to discover and understand this guarantee.  Although a big fat comment
in default_device_exit_batch that we are guaranteeing we don't allow
the network namespace to exit while there are still network devices in
it (or something to that effect) is probably appropriate.

Eric

> Francesco
>
>>
>>  net/core/dev.c |   12 ++++++++++++
>>  1 files changed, 12 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 5d702fe..c25e6f3 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -5002,10 +5002,13 @@ static int dev_new_index(struct net *net)
>>
>>  /* Delayed registration/unregisteration */
>>  static LIST_HEAD(net_todo_list);
>> +static atomic_t netdev_unregistering = ATOMIC_INIT(0);
>> +static DECLARE_WAIT_QUEUE_HEAD(netdev_unregistering_wait);
>>
>>  static void net_set_todo(struct net_device *dev)
>>  {
>>         list_add_tail(&dev->todo_list, &net_todo_list);
>> +       atomic_inc(&netdev_unregistering);
>>  }
>>
>>  static void rollback_registered_many(struct list_head *head)
>> @@ -5673,6 +5676,9 @@ void netdev_run_todo(void)
>>                 if (dev->destructor)
>>                         dev->destructor(dev);
>>
>> +               if (atomic_dec_and_test(&netdev_unregistering))
>> +                       wake_up(&netdev_unregistering_wait);
>> +
>>                 /* Free network device */
>>                 kobject_put(&dev->dev.kobj);
>>         }
>> @@ -6369,7 +6375,13 @@ static void __net_exit default_device_exit_batch(struct list_head *net_list)
>>         struct net *net;
>>         LIST_HEAD(dev_kill_list);
>>
>> +retry:
>> +       wait_event(netdev_unregistering_wait, (atomic_read(&netdev_unregistering) == 0));
>>         rtnl_lock();
>> +       if (atomic_read(&netdev_unregistering) != 0) {
>> +               __rtnl_unlock();
>> +               goto retry;
>> +       }
>>         list_for_each_entry(net, net_list, exit_list) {
>>                 for_each_netdev_reverse(net, dev) {
>>                         if (dev->rtnl_link_ops)
>> --
>> 1.7.5.4
>>
