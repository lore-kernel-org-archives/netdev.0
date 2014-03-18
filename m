From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 6/6] net: Free skbs from irqs when possible.
Date: Tue, 18 Mar 2014 10:47:36 -0700
Message-ID: <8738if8klj.fsf@xmission.com>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
	<20140317.154916.2276987764507311378.davem@davemloft.net>
	<87iorcgh5d.fsf_-_@xmission.com> <87fvmgf2c7.fsf_-_@xmission.com>
	<20140318082358.60fc414c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:51175 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbaCRRro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 13:47:44 -0400
In-Reply-To: <20140318082358.60fc414c@nehalam.linuxnetplumber.net> (Stephen
	Hemminger's message of "Tue, 18 Mar 2014 08:23:58 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> writes:

> On Mon, 17 Mar 2014 23:27:52 -0700
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
>> Add a test skb_irq_freeable to report when it is safe to free a skb
>> from irq context.
>> 
>> It is not safe to free an skb from irq context when:
>> - The skb has a destructor as some skb destructors call local_bh_disable
>>   or spin_lock_bh.
>> - There is xfrm state as __xfrm_state_destroy calls spin_lock_bh.
>> - There is netfilter conntrack state as destroy_conntrack calls
>>   spin_lock_bh.
>> - If there is a refcounted dst entry on the skb, as __dst_free
>>   calls spin_lock_bh.
>> - If there is a frag_list, which could be a list of any skbs.
>> Otherwise it appears safe to free a skb from interrupt context.
>> 
>> - Update the warning in skb_releae_head_state to warn about freeing
>>   skb's in the wrong context.
>> 
>> - Update __dev_kfree_skb_irq to free all skbs that it can immediately
>> 
>> - Kill zap_completion_queue because there is no point going through
>>   a queue of packets that are not safe to free and looking for packets
>>   that are safe to free.
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>
> Why introduce the additional complexity for so little gain?
> It looks like you are only optimizing for the corner case where netpoll
> is cleaning up on Tx.
>
> -1

The netpoll cleanup is interesting.  And certainly something needs to be
done to fix/cleanup zap_completion_queue in netpoll.

However the deep reason for introducing skb_irq_freeable() is to fix the
warnings in skb_release_head_state aka __kfree_skb.  Only warning when
we have a destructor in irq context strongly suggests that it is only
when we have destructors that we have problems.

Most of the destructors today are fine (which doubly makes the warning
confusing).  Assuming we don't have a dst reference when a packet is
transmitted it is the presence of iptables in the system that makes tx
packets not freeable from hard irq context.

Received packets seem to be always freeable and freeing packets on the
error path of packet reception could actually be helped by this.
Especially in the drivers like the e1000 that have misplaced calls to
dev_kfree_skb_irq.

With respect to netpoll the only skbs that are likely to be freeable in
the netpoll transmit path are packets netpoll has transmitted itself.
So if this does not fit in the generic dev_kfree_skb_irq it definitely
makes sense to perform this test in netpoll's zap_completion_queue.

At a practical level seeing a skb->destructor typically will be what
pushes the code into the delayed freeing scenario.  So I don't see this
slowing things down noticably.

In addition freeing skbs in hard irq context (outside of netpoll) is
something only older mostly pre NAPI drivers do.  So frankly it seems
reasonable to me to optimize for the common case of freeing skbs in
hard irq context (i.e. netpoll).

Eric
