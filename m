From: Anoob Soman <anoob.soman@citrix.com>
Subject: Re: [PATCH net] packet: call fanout_release, while UNREGISTERING a
 netdev
Date: Thu, 2 Feb 2017 14:42:11 +0000
Message-ID: <60cc2983-9985-055a-39cd-e9dbec4f7a57@citrix.com>
References: <1475676774-18726-1-git-send-email-anoob.soman@citrix.com>
 <20161006.205052.1380596858044266995.davem@davemloft.net>
 <1485797189.6360.98.camel@edumazet-glaptop3.roam.corp.google.com>
 <10e9ac4b-585e-2878-0141-f00020a027f0@citrix.com>
 <1485805493.6360.113.camel@edumazet-glaptop3.roam.corp.google.com>
 <d2b23842-f6db-c2c9-d22c-d7e0945abc15@citrix.com>
 <1485885650.6360.122.camel@edumazet-glaptop3.roam.corp.google.com>
 <61fb944f-776c-00ff-dd05-d33e263f205a@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:21692 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751495AbdBBOnv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 09:43:51 -0500
In-Reply-To: <61fb944f-776c-00ff-dd05-d33e263f205a@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/01/17 18:14, Anoob Soman wrote:
>
>
> On 31/01/17 18:00, Eric Dumazet wrote:
>> On Tue, 2017-01-31 at 17:03 +0000, Anoob Soman wrote:
>>> On 30/01/17 19:44, Eric Dumazet wrote:
>>>> On Mon, 2017-01-30 at 19:08 +0000, Anoob Soman wrote:
>>>>> On 30/01/17 17:26, Eric Dumazet wrote:
>>>>>> On Thu, 2016-10-06 at 20:50 -0400, David Miller wrote:
>>>>>>> From: Anoob Soman <anoob.soman@citrix.com>
>>>>>>> Date: Wed, 5 Oct 2016 15:12:54 +0100
>>>>>>>
>>>>>>>> If a socket has FANOUT sockopt set, a new proto_hook is registered
>>>>>>>> as part of fanout_add(). When processing a NETDEV_UNREGISTER 
>>>>>>>> event in
>>>>>>>> af_packet, __fanout_unlink is called for all sockets, but 
>>>>>>>> prot_hook which was
>>>>>>>> registered as part of fanout_add is not removed. Call 
>>>>>>>> fanout_release, on a
>>>>>>>> NETDEV_UNREGISTER, which removes prot_hook and removes fanout 
>>>>>>>> from the
>>>>>>>> fanout_list.
>>>>>>>>
>>>>>>>> This fixes BUG_ON(!list_empty(&dev->ptype_specific)) in 
>>>>>>>> netdev_run_todo()
>>>>>>>>
>>>>>>>> Signed-off-by: Anoob Soman <anoob.soman@citrix.com>
>>>>>>> Applied and queued up for -stable, thanks.
>>>>>> This commit (6664498280cf "packet: call fanout_release, while
>>>>>> UNREGISTERING a netdev")
>>>>>> looks buggy :
>>>>>>
>>>>>> We end up calling fanout_release() while holding a spinlock
>>>>>> ( spin_lock(&po->bind_lock); )
>>>>>>
>>>>>> But fanout_release() grabs a mutex ( mutex_lock(&fanout_mutex) ), 
>>>>>> and
>>>>>> this is absolutely not valid while holding a spinlock.
>>>>> Yes, that is wrong.
>>>>>
>>>>>> Anoob, can you cook a fix, I guess you have a way to reproduce 
>>>>>> the thing
>>>>>> that wanted a kernel patch ?
>>>>>>
>>>>>> (Please build your test kernel with CONFIG_LOCKDEP=y)
>>>>> Sure, I am planning to move fanout_release(sk) after
>>>>> spin_unlock(bind_lock). Something like this.
>>>>>                                    }
>>>>>                                    if (msg == NETDEV_UNREGISTER) {
>>>>> packet_cached_dev_reset(po);
>>>>> - fanout_release(sk);
>>>>>                                            po->ifindex = -1;
>>>>>                                            if (po->prot_hook.dev)
>>>>> dev_put(po->prot_hook.dev);
>>>>> po->prot_hook.dev = NULL;
>>>>>                                    }
>>>>> spin_unlock(&po->bind_lock);
>>>>> +                               if (msg == NETDEV_UNREGISTER) {
>>>>> + fanout_release(sk);
>>>>> +                               }
>>>>>                            }
>>>>>                            break;
>>>>>
>>>>> I will quickly test it out.
>>>> It wont be enough.
>>>>
>>>> You need to also fix a race if two cpus call fanout_release(sk) at the
>>>> same time.
>>>>
>>>> Thanks.
>>>>
>>>>
>>>>
>>> Hi Eric,
>>>
>>> I have ran into some problem trying to enable CONFIG_LOCKDEP. I think
>>> this particular scenario, taking mutex_lock() while holding a spin_lock
>>> debugging, requires CONFIG_DEBUG_ATOMIC_SLEEP to be enabled.
>>> CONFIG_DEBUG_ATOMIC_SLEEP, selects CONFIG_PREEMPT_COUNT and my kernel
>>> doesn't behave well if PREEMPTION is enabled. I am trying to reproduce
>>> this issue in a way that I might be able to use debug_atomic_sleep.
>>>
>>> Meanwhile, I have modified patch fix the race.
>>
>> So you can definitely have in a .config all these at the same time
>> (LOCKDEP,  non PREEMPT, and DEBUG_ATOMIC_SLEEP)
>>
>>
>>
>>
>> $ egrep "DEBUG_ATOMIC_SLEEP|PREEMPT|LOCKDEP" .config
>> CONFIG_LOCKDEP_SUPPORT=y
>> CONFIG_PREEMPT_NOTIFIERS=y
>> CONFIG_PREEMPT_NONE=y
>> # CONFIG_PREEMPT_VOLUNTARY is not set
>> # CONFIG_PREEMPT is not set
>> CONFIG_PREEMPT_COUNT=y
>> CONFIG_LOCKDEP=y
>> # CONFIG_DEBUG_LOCKDEP is not set
>> CONFIG_DEBUG_ATOMIC_SLEEP=y
>>
>
> yes, thats exactly what I have.
>
> $ egrep "DEBUG_ATOMIC_SLEEP|PREEMPT|LOCKDEP" .config
> CONFIG_LOCKDEP_SUPPORT=y
> # CONFIG_PREEMPT_NONE is not set
> CONFIG_PREEMPT_VOLUNTARY=y
> # CONFIG_PREEMPT is not set
> CONFIG_PREEMPT_COUNT=y
> CONFIG_LOCKDEP=y
> # CONFIG_DEBUG_LOCKDEP is not set
> CONFIG_DEBUG_ATOMIC_SLEEP=y
>
> I initially thought CONFIG_PREEMPT_COUNT enables CONFIG_PREEMPT, but 
> looks like all it does is to inc/dec preempt_count.
>
> Let me give the test a spin again, and see why everything seems to 
> fall apart.
>
>>
>>
>
Hi Eric,

I managed to reproduce the problem consistently with LOCKDEP enabled. I have
to workaround few other problems in order to make the repro consistent.

There are 4 potential problem with the commit.

1. calling mutex_lock(&fanout_mutex) (fanout_release()) from inside 
rcu_read-side
critical section. rcu_read_lock disables preemption, most often (expect if
CONFIG_PREEMPT/CONFIG_PREEMPTE_RCU are set), which prohibits calling 
sleeping
functions.

[  180.940388] include/linux/rcupdate.h:560 Illegal context switch in 
RCU read-side critical section!
[  180.940401]
[  180.940401] other info that might help us debug this:
[  180.940401]
[  180.940417]
[  180.940417] rcu_scheduler_active = 1, debug_locks = 0
[  180.940430] 4 locks held by ovs-vswitchd/1969:
[  180.940438]  #0:  (cb_lock){++++++}, at: [<ffffffff8158a6c9>] 
genl_rcv+0x19/0x40
[  180.940498]  #1:  (ovs_mutex){+.+.+.}, at: [<ffffffffa04878ca>] 
ovs_vport_cmd_del+0x4a/0x100 [openvswitch]
[  180.940530]  #2:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81564157>] 
rtnl_lock+0x17/0x20
[  180.940557]  #3:  (rcu_read_lock){......}, at: [<ffffffff81614165>] 
packet_notifier+0x5/0x3f0
[  180.940587]
[  180.940697] Call Trace:
[  180.940710]  [<ffffffff813770c1>] dump_stack+0x85/0xc4
[  180.940727]  [<ffffffff810c9077>] lockdep_rcu_suspicious+0x107/0x110
[  180.940742]  [<ffffffff810a2da7>] ___might_sleep+0x57/0x210
[  180.940755]  [<ffffffff810a2fd0>] __might_sleep+0x70/0x90
[  180.940768]  [<ffffffff8162e80c>] mutex_lock_nested+0x3c/0x3a0
[  180.940785]  [<ffffffff810de93f>] ? vprintk_default+0x1f/0x30
[  180.940801]  [<ffffffff81186e88>] ? printk+0x4d/0x4f
[  180.940814]  [<ffffffff816106dd>] fanout_release+0x1d/0xe0
[  180.940828]  [<ffffffff81614459>] packet_notifier+0x2f9/0x3f0

2. calling mutex_lock(&fanout_mutex) inside spin_lock(&po->bind_lock).
     "sleeping function called from invalid context"

[  181.941336] BUG: sleeping function called from invalid context at 
kernel/locking/mutex.c:620
[  181.941352] in_atomic(): 1, irqs_disabled(): 0, pid: 1969, name: 
ovs-vswitchd
[  181.941365] INFO: lockdep is turned off.
[  181.941462] Call Trace:
[  181.941469]  [<ffffffff813770c1>] dump_stack+0x85/0xc4
[  181.941480]  [<ffffffff810a2f52>] ___might_sleep+0x202/0x210
[  181.941492]  [<ffffffff810a2fd0>] __might_sleep+0x70/0x90
[  181.941503]  [<ffffffff8162e80c>] mutex_lock_nested+0x3c/0x3a0
[  181.941515]  [<ffffffff810de93f>] ? vprintk_default+0x1f/0x30
[  181.941526]  [<ffffffff81186e88>] ? printk+0x4d/0x4f
[  181.941537]  [<ffffffff816106dd>] fanout_release+0x1d/0xe0
[  181.941548]  [<ffffffff81614459>] packet_notifier+0x2f9/0x3f0

3. calling dev_remove_pack(&fanout->prot_hook), from inside 
spin_lock(&po->bind_lock)
or rcu_read-side critcial.section. dev_remove_pack() -> synchronize_net(),
which might sleep.

[  181.942401] BUG: scheduling while atomic: ovs-vswitchd/1969/0x00000002
[  181.942411] INFO: lockdep is turned off.
[  181.942751] Call Trace:
[  181.942760]  [<ffffffff813770c1>] dump_stack+0x85/0xc4
[  181.942771]  [<ffffffff81186274>] __schedule_bug+0x64/0x73
[  181.942782]  [<ffffffff8162b8cb>] __schedule+0x6b/0xd10
[  181.942794]  [<ffffffff8162c5db>] schedule+0x6b/0x80
[  181.942805]  [<ffffffff81630b1d>] schedule_timeout+0x38d/0x410
[  181.942820]  [<ffffffff810efac0>] ? internal_add_timer+0x80/0x80
[  181.942835]  [<ffffffff810ea3fd>] synchronize_sched_expedited+0x53d/0x810
[  181.942850]  [<ffffffff810bf650>] ? prepare_to_wait_event+0x110/0x110
[  181.942862]  [<ffffffff810ea6de>] synchronize_rcu_expedited+0xe/0x10
[  181.942873]  [<ffffffff8154eab5>] synchronize_net+0x35/0x50
[  181.942884]  [<ffffffff8154eae3>] dev_remove_pack+0x13/0x20
[  181.942896]  [<ffffffff8161077e>] fanout_release+0xbe/0xe0
[  181.942909]  [<ffffffff81614459>] packet_notifier+0x2f9/0x3f0

4. fanout_release() races with calls from different CPU.



Moving mutex_lock(&fanout_mutex) out of spin_lock(&po->bind_lock),
                                 if (msg == NETDEV_UNREGISTER) {
                                         packet_cached_dev_reset(po);
-                                       fanout_release(sk);
                                         po->ifindex = -1;
                                         if (po->prot_hook.dev)
dev_put(po->prot_hook.dev);
                                         po->prot_hook.dev = NULL;
                                 }
                                 spin_unlock(&po->bind_lock);
+                               if (msg == NETDEV_UNREGISTER)
+                                       fanout_release(sk);
                         }
                         break;
                 case NETDEV_UP:
will solve 2 and part (spin_lock) of 3, but definetly will not solve 1 and
(rcu_read-side cs) other part of 3 (if CONFIG_PREEMPT is enabled).

Inside packet_notifier packet.sklist is traversed under rcu_read_lock,
which meant any calls which might sleep (dev_remove_pack(), 
mutex_lock()) cannot
be done. Instead of traversing sklist under rcu_read_lock, we can traverse
sklist using mutex_lock(packet.sklist_lock). This would fix 1 and 3, but 
adds
additional overhead of blocking modifications, while traversing sklist.

Another way to fix, all the above problem, would be not to call 
fanout_release()
under rcu_read_lock(), instead call 
__dev_remove_pack(&fanout->prot_hook) and
netdev_run_todo is happy that &dev->ptype_specific list in empty. In order
to make this work, I had to move dev_{add,remove}_pack() out of
fanout_{add,release} to __fanout_{link,unlink}. So, call to
{,__}unregister_prot_hook() will make sure fanout->prot_hook is removed 
as well.

@@ -1498,6 +1498,8 @@ static void __fanout_link(struct sock *sk, struct 
packet_sock *po)
         f->arr[f->num_members] = sk;
         smp_wmb();
         f->num_members++;
+       if (f->num_members == 1)
+               dev_add_pack(&f->prot_hook);
         spin_unlock(&f->lock);
  }

@@ -1514,6 +1516,8 @@ static void __fanout_unlink(struct sock *sk, 
struct packet_sock *po)
         BUG_ON(i >= f->num_members);
         f->arr[i] = f->arr[f->num_members - 1];
         f->num_members--;
+       if (f->num_members == 0)
+               __dev_remove_pack(&f->prot_hook);
         spin_unlock(&f->lock);
  }

@@ -1692,7 +1696,6 @@ static int fanout_add(struct sock *sk, u16 id, u16 
type_flags)
                 match->prot_hook.func = packet_rcv_fanout;
                 match->prot_hook.af_packet_priv = match;
                 match->prot_hook.id_match = match_fanout_group;
-               dev_add_pack(&match->prot_hook);
                 list_add(&match->list, &fanout_list);
         }
         err = -EINVAL;
@@ -1731,7 +1734,6 @@ static void fanout_release(struct sock *sk)

         if (atomic_dec_and_test(&f->sk_ref)) {
                 list_del(&f->list);
-               dev_remove_pack(&f->prot_hook);
                 fanout_release_data(f);
                 kfree(f);
         }
@@ -3855,7 +3857,6 @@ static int packet_notifier(struct notifier_block 
*this,
                                 }
                                 if (msg == NETDEV_UNREGISTER) {
                                         packet_cached_dev_reset(po);
-                                       fanout_release(sk);
                                         po->ifindex = -1;
                                         if (po->prot_hook.dev)
dev_put(po->prot_hook.dev);


I have tested both the approaches and LOCKDEP doesn't seem to catch any
problem with the test I was doing.

Thanks,
Anoob.
