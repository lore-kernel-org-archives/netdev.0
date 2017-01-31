From: Anoob Soman <anoob.soman@citrix.com>
Subject: Re: [PATCH net] packet: call fanout_release, while UNREGISTERING a
 netdev
Date: Tue, 31 Jan 2017 17:03:53 +0000
Message-ID: <d2b23842-f6db-c2c9-d22c-d7e0945abc15@citrix.com>
References: <1475676774-18726-1-git-send-email-anoob.soman@citrix.com>
 <20161006.205052.1380596858044266995.davem@davemloft.net>
 <1485797189.6360.98.camel@edumazet-glaptop3.roam.corp.google.com>
 <10e9ac4b-585e-2878-0141-f00020a027f0@citrix.com>
 <1485805493.6360.113.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:32011 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750869AbdAaRK6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 12:10:58 -0500
In-Reply-To: <1485805493.6360.113.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 30/01/17 19:44, Eric Dumazet wrote:
> On Mon, 2017-01-30 at 19:08 +0000, Anoob Soman wrote:
>> On 30/01/17 17:26, Eric Dumazet wrote:
>>> On Thu, 2016-10-06 at 20:50 -0400, David Miller wrote:
>>>> From: Anoob Soman <anoob.soman@citrix.com>
>>>> Date: Wed, 5 Oct 2016 15:12:54 +0100
>>>>
>>>>> If a socket has FANOUT sockopt set, a new proto_hook is registered
>>>>> as part of fanout_add(). When processing a NETDEV_UNREGISTER event in
>>>>> af_packet, __fanout_unlink is called for all sockets, but prot_hook which was
>>>>> registered as part of fanout_add is not removed. Call fanout_release, on a
>>>>> NETDEV_UNREGISTER, which removes prot_hook and removes fanout from the
>>>>> fanout_list.
>>>>>
>>>>> This fixes BUG_ON(!list_empty(&dev->ptype_specific)) in netdev_run_todo()
>>>>>
>>>>> Signed-off-by: Anoob Soman <anoob.soman@citrix.com>
>>>> Applied and queued up for -stable, thanks.
>>> This commit (6664498280cf "packet: call fanout_release, while
>>> UNREGISTERING a netdev")
>>> looks buggy :
>>>
>>> We end up calling fanout_release() while holding a spinlock
>>> ( spin_lock(&po->bind_lock); )
>>>
>>> But fanout_release() grabs a mutex ( mutex_lock(&fanout_mutex) ), and
>>> this is absolutely not valid while holding a spinlock.
>> Yes, that is wrong.
>>
>>> Anoob, can you cook a fix, I guess you have a way to reproduce the thing
>>> that wanted a kernel patch ?
>>>
>>> (Please build your test kernel with CONFIG_LOCKDEP=y)
>> Sure, I am planning to move fanout_release(sk) after
>> spin_unlock(bind_lock). Something like this.
>>                                   }
>>                                   if (msg == NETDEV_UNREGISTER) {
>>                                           packet_cached_dev_reset(po);
>> -                                       fanout_release(sk);
>>                                           po->ifindex = -1;
>>                                           if (po->prot_hook.dev)
>> dev_put(po->prot_hook.dev);
>>                                           po->prot_hook.dev = NULL;
>>                                   }
>>                                   spin_unlock(&po->bind_lock);
>> +                               if (msg == NETDEV_UNREGISTER) {
>> +                                       fanout_release(sk);
>> +                               }
>>                           }
>>                           break;
>>
>> I will quickly test it out.
> It wont be enough.
>
> You need to also fix a race if two cpus call fanout_release(sk) at the
> same time.
>
> Thanks.
>
>
>
Hi Eric,

I have ran into some problem trying to enable CONFIG_LOCKDEP. I think 
this particular scenario, taking mutex_lock() while holding a spin_lock 
debugging, requires CONFIG_DEBUG_ATOMIC_SLEEP to be enabled. 
CONFIG_DEBUG_ATOMIC_SLEEP, selects CONFIG_PREEMPT_COUNT and my kernel 
doesn't behave well if PREEMPTION is enabled. I am trying to reproduce 
this issue in a way that I might be able to use debug_atomic_sleep.

Meanwhile, I have modified patch fix the race.

@@ -1722,18 +1722,20 @@ static void fanout_release(struct sock *sk)
      struct packet_sock *po = pkt_sk(sk);
      struct packet_fanout *f;

+    mutex_lock(&fanout_mutex);
+
      f = po->fanout;
-    if (!f)
+    if (!f) {
+        mutex_unlock(&fanout_mutex);
          return;
-
-    mutex_lock(&fanout_mutex);
-    po->fanout = NULL;
+    }

      if (atomic_dec_and_test(&f->sk_ref)) {
          list_del(&f->list);
          dev_remove_pack(&f->prot_hook);
          fanout_release_data(f);
          kfree(f);
+        po->fanout = NULL;
      }
      mutex_unlock(&fanout_mutex);

@@ -3855,13 +3857,14 @@ static int packet_notifier(struct notifier_block 
*this,
                  }
                  if (msg == NETDEV_UNREGISTER) {
                      packet_cached_dev_reset(po);
-                    fanout_release(sk);
                      po->ifindex = -1;
                      if (po->prot_hook.dev)
                          dev_put(po->prot_hook.dev);
                      po->prot_hook.dev = NULL;
                  }
                  spin_unlock(&po->bind_lock);
+                if (msg == NETDEV_UNREGISTER)
+                    fanout_release(sk);
              }
              break;
          case NETDEV_UP:

Thanks,
Anoob.
