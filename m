From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] net: squash ->rx_handler and ->rx_handler_data
 into single rcu pointer
Date: Sat, 30 Mar 2013 18:13:25 +0100
Message-ID: <20130330171325.GC1544@minipsycho.orion>
References: <1364659034-7049-1-git-send-email-jiri@resnulli.us>
 <1364660588.5113.110.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	fubar@us.ibm.com, andy@greyhouse.net, kaber@trash.net,
	stephen@networkplumber.org, jesse@nicira.com,
	alexander.h.duyck@intel.com, xiyou.wangcong@gmail.com,
	dev@openvswitch.org, rostedt@goodmis.org,
	nicolas.2p.debian@gmail.com, tglx@linutronix.de,
	streeter@redhat.com, paulmck@us.ibm.com, ivecera@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:52945 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756877Ab3C3RN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 13:13:29 -0400
Received: by mail-ea0-f172.google.com with SMTP id z7so562699eaf.17
        for <netdev@vger.kernel.org>; Sat, 30 Mar 2013 10:13:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1364660588.5113.110.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Mar 30, 2013 at 05:23:08PM CET, eric.dumazet@gmail.com wrote:
>On Sat, 2013-03-30 at 16:57 +0100, Jiri Pirko wrote:
>> No need to have two pointers in struct netdevice for rx_handler func and
>> priv data. Just embed rx_handler structure into driver port_priv and
>> have ->func pointer there. This introduces no performance penalty,
>> reduces struct netdevice by one pointer and reduces number of needed
>> rcu_dereference calls from 2 to 1.
>> 
>
>Thats not true.
>
>> Note this also fixes the race bug pointed out by Steven Rostedt and
>> fixed by patch "[PATCH] net: add a synchronize_net() in
>> netdev_rx_handler_unregister()" by Eric Dumazet. This is based on
>> current net-next tree where the patch is not applied yet.
>> I can rebase it on whatever tree/state, just say so.
>> 
>> Smoke tested with all drivers who use rx_handler.
>> 
>> Reported-by: Steven Rostedt <rostedt@goodmis.org>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>
>I see no value for this patch.
>
>It obfuscates things for no good reason.

Well, I like this what you call obfuscation. It looks similar to
list_head and rcu_head. I do not think that this makes the readibility
more difficult.

>
>Once again rcu_dereference(dev->field) has no cost, its a memory read,
>like dev->field.

Well, not entirely true, depends on arch.

>
>I fear you don't understand enough RCU to make so invasive changes.
>
>Your patch adds a double dereference on fast path, and its more
>expensive than two single deref.
>
>dev->rx_handler actually gets the function pointer, and after your patch
>we would have to do dev->rx_handler->func instead, which is bad on many
>cpus.

dev->rx_handler == port_priv and it is treated as such and accessed in
handle_frame driver functions. Is it really that bad to access deref
port_priv->pointer (rx_handler->func) couple of instructions earlier?
I wonder what the difference is in compare with the original code.


Thanks, Jiri

>
>I'll send a patch reordering some fields of net_device, because as time
>passed, it seems a lot of junk broke work done in commit
>cd13539b8bc9ae884 (net: shrinks struct net_device)
>
>offsetof(struct net_device,dev_addr)=0x258
>offsetof(struct net_device,rx_handler)=0x2b8
>offsetof(struct net_device,ingress_queue)=0x2c8
>offsetof(struct net_device,broadcast)=0x278
>
>
