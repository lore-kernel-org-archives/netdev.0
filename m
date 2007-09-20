From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Thu, 20 Sep 2007 12:33:49 +0200
Message-ID: <46F24C8D.2020804@trash.net>
References: <20070917100321.18347.0@janus.isnogud.escape.de>	<20070917100438.18347.2@janus.isnogud.escape.de>	<46EFD33D.8030905@trash.net> <ygffy1bzn4c.fsf@janus.isnogud.escape.de>	<46F0DD8E.8070808@trash.net> <ygfy7f1g1l0.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34538 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbXITKlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 06:41:12 -0400
In-Reply-To: <ygfy7f1g1l0.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
>>>When the module is unloaded it calls can_proto_unregister() which
>>>clears the pointer.  Do you see a race condition here?
>>
>>Yes, you do request_module, load the module, get the cp pointer
>>from proto_tab, the module is unloaded again. cp points to
>>stable memory. Using module references would fix this.
> 
> 
> How would I use the module reference counter?  Somehow with
> try_module_get()?  I have thought something like
> 
>         cp = proto_tab[protocol];
>         if (!cp ...)
>                 return ...;
> 
>         if (!try_module_get(cp->prot->owner))
>                 return ...;
> 
>         sk = sk_alloc(...)
> 
>         module_put(...);
>         return ret;
> 
> But here I see two problems:
> 
> 1. Between the check !cp...  and referencing cp->prot->owner the
>    module could get unloaded and the reference be invalid.  Is there
>    some lock I can hold that prevents module unloading?  I haven't
>    found something like this in include/linux/module.h


No, you need to add your own locking to prevent this, something
list this:

registration/unregistration:

take lock
change proto_tab[]
release lock

lookup:

take lock
cp = proto_tab[]
if (cp && !try_module_get(cp->owner))
	cp = NULL
release lock

> 2. If the module gets unloaded after the first check and
>    request_module() but before the call to try_module_get() the
>    socket() syscall will return with error, although module auto
>    loading would normally be successful.  How can I prevent that?


Why do you want to prevent it? The admin unloaded the module,
so he apparently doesn't want the operation to succeed.

>>>find_dev_rcv_lists() is called in one place from can_rcv() with RCU
>>>lock held, as you write.  The other two calls to find_dev_rcv_lists()
>>>are from can_rx_register/unregister() functions which change the
>>>receive lists.  Therefore, we can't only use RCU but need protection
>>>against simultanous writes.  We do this with the spin_lock_bh().  The
>>>_bh variant, because can_rcv() runs in interrupt and we need to block
>>>that.  I thought this is pretty standard.
>>>
>>>I'll check this again tomorrow, but I have put much time in these
>>>locking issues already, changed it quite a few times and hoped to have
>>>got it right finally.
>>
>>
>>I'm not saying you should use *only* RCU, you need the lock
>>for additions/removal of course, but since the receive path
>>doesn't take that lock and relies on RCU, you need to use
>>the _rcu list walking variant to avoid races with concurrent
>>list changes.
> 
> 
> I have no objections to add the _rcu suffix for the code changing the
> receive lists, but I don't see why it's necessary.  When I do a
> spin_lock_bh() before writing, can't I be sure that there is no
> interrupt routine running in parallel while I hold this spinlock?  If
> so, there is no reader in parallel because the can_rcv() function runs
> in a softirq.  I'd really like to understand why you think the writers
> should also use the _rcu variant. 


I'm saying you need _rcu for the *read side*. All operations changing
the list already use the _rcu variants.

> I'm sorry if I miss something
> obvious here, but could you try to explain it to me?


spin_lock_bh only disables BHs locally, other CPUs can still process
softirqs. And since rcv_lists_lock is only used in process context,
the BH disabling is actually not even necessary.

