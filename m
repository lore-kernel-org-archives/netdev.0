From: Anoob Soman <anoob.soman@citrix.com>
Subject: Re: [PATCH net] packet: call fanout_release, while UNREGISTERING a
 netdev
Date: Mon, 30 Jan 2017 18:19:32 +0000
Message-ID: <4414de9f-962a-97f8-22cd-627588ce3d51@citrix.com>
References: <1475676774-18726-1-git-send-email-anoob.soman@citrix.com>
 <20161006.205052.1380596858044266995.davem@davemloft.net>
 <1485797189.6360.98.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([185.25.65.24]:18641 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753605AbdA3STj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 13:19:39 -0500
In-Reply-To: <1485797189.6360.98.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 30/01/17 17:26, Eric Dumazet wrote:
> On Thu, 2016-10-06 at 20:50 -0400, David Miller wrote:
>> From: Anoob Soman <anoob.soman@citrix.com>
>> Date: Wed, 5 Oct 2016 15:12:54 +0100
>>
>>> If a socket has FANOUT sockopt set, a new proto_hook is registered
>>> as part of fanout_add(). When processing a NETDEV_UNREGISTER event in
>>> af_packet, __fanout_unlink is called for all sockets, but prot_hook which was
>>> registered as part of fanout_add is not removed. Call fanout_release, on a
>>> NETDEV_UNREGISTER, which removes prot_hook and removes fanout from the
>>> fanout_list.
>>>
>>> This fixes BUG_ON(!list_empty(&dev->ptype_specific)) in netdev_run_todo()
>>>
>>> Signed-off-by: Anoob Soman <anoob.soman@citrix.com>
>> Applied and queued up for -stable, thanks.
> This commit (6664498280cf "packet: call fanout_release, while
> UNREGISTERING a netdev")
> looks buggy :
>
> We end up calling fanout_release() while holding a spinlock
> ( spin_lock(&po->bind_lock); )
>
> But fanout_release() grabs a mutex ( mutex_lock(&fanout_mutex) ), and
> this is absolutely not valid while holding a spinlock.
Yes correct, that is wrong.

>
> Anoob, can you cook a fix, I guess you have a way to reproduce the thing
> that wanted a kernel patch ?
>
> (Please build your test kernel with CONFIG_LOCKDEP=y)
Sure, I am planning to move fanout_release(sk) after 
spin_unlock(bond_lock). Something like this.
                                 }
                                 if (msg == NETDEV_UNREGISTER) {
                                         packet_cached_dev_reset(po);
-                                       fanout_release(sk);
                                         po->ifindex = -1;
                                         if (po->prot_hook.dev)
dev_put(po->prot_hook.dev);
                                         po->prot_hook.dev = NULL;
                                 }
                                 spin_unlock(&po->bind_lock);
+                               if (msg == NETDEV_UNREGISTER) {
+                                       fanout_release(sk);
+                               }
                         }
                         break;

I will quickly test it out.

> Thanks.
>
>
