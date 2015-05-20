From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: Kernel crash while using tc script
Date: Wed, 20 May 2015 13:53:26 +0200
Message-ID: <555C75B6.7040407@iogearbox.net>
References: <CAGK4HS_cCQPJwXVoCuZAa2zHtPnXO+ar5Wpg_azyxc5Efv4Mwg@mail.gmail.com> <555BAE72.40609@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, tgraf <tgraf@suug.ch>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51764 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182AbbETLx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 07:53:28 -0400
In-Reply-To: <555BAE72.40609@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2015 11:43 PM, Daniel Borkmann wrote:
> On 05/19/2015 10:11 PM, Vijay Subramanian wrote:
>> Hi,
>>
>> It seems latest net-next kernel crashes while unloading modules.
>> Please see simple script below to reproduce the crash.
>>
>> ===============================
>>
>> #!/bin/bash
>>
>> while true; do
>>
>> # modules will be loaded automatically
>>
>> tc qdisc add dev eth1 root handle 1: prio
>>
>> tc filter add dev eth1 parent 1: u32 match u32 0 0  flowid 1
>>
>>
>> tc qdisc del dev eth1 root
>>
>> rmmod cls_u32
>>
>> rmmod sch_prio
>>
>>
>> done
>>
>> =========================
>>
>> It seems there is some refcounting or locking issue issue. I am unable
>> to easily post the dump but sometimes it points to crashes in various
>> functions in prio_class_ops  (sch_prio.c), such as prio_walk(),
>> prio_dump_class etc. Probably, sch_prio call back functions are
>> invoked when they should not be.
>>
>> I bisected this down to following commit:
>>
>> commit 78fd1d0ab072d4d9b5f0b7c14a1516665170b565
>> Author: Thomas Graf <tgraf@suug.ch>
>> Date:   Tue Oct 21 22:05:38 2014 +0200
>> netlink: Re-add locking to netlink_lookup() and seq walker
>>
>> If there are suggestions for me to try or you need more info, let me know.
>
> Hmm, seems rather like the synchronize_net() removal in netlink_release()
> must have uncovered a bug elsewhere.

What seems to be happening is a race here between RCU and
classifier module refcounting, i.e. between the two commands
(under the requirement at least one u32 classifier is attached
to the qdisc):

   tc qdisc del dev foo root
   rmmod cls_u32

On qdisc deletion, prio_destroy() is called which invokes
tcf_destroy_chain() that walks all classifiers and calls
tcf_destroy() on them.

You can take any of them, it's not u32 specific, for example,
cls_bpf_destroy(): They register an RCU callback, e.g.
call_rcu(&prog->rcu, __cls_bpf_delete_prog) for later
invocation.

The problem however is that this callback very likely is
executed *after* the module_put() from tcf_destroy()!

That means, kernel thinks that no-one is holding reference
on that module anymore and thus rmmod cls_u32 can succeed.

Problem is that when RCU callback is invoked by the kernel,
that address of the function is not valid anymore, as the
module already disappeared from under us.

The synchronize_net() that was called when the netlink
socket (for removing the qdisc) got destroyed, was hiding
that from us. ;)

Out of curiosity, I did a test by only moving __cls_bpf_delete_prog()
callback into a built-in section that won't disappear on module
unload and the panic is not triggered anymore.

Will be cooking a patch.
