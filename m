From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 6/6] net: Free skbs from irqs when possible.
Date: Tue, 18 Mar 2014 08:23:58 -0700
Message-ID: <20140318082358.60fc414c@nehalam.linuxnetplumber.net>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com>
	<877g7wqg8e.fsf_-_@xmission.com>
	<20140317.154916.2276987764507311378.davem@davemloft.net>
	<87iorcgh5d.fsf_-_@xmission.com>
	<87fvmgf2c7.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:42321 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756487AbaCRP1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 11:27:30 -0400
Received: by mail-pa0-f51.google.com with SMTP id kq14so7430930pab.24
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 08:27:30 -0700 (PDT)
In-Reply-To: <87fvmgf2c7.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Mar 2014 23:27:52 -0700
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Add a test skb_irq_freeable to report when it is safe to free a skb
> from irq context.
> 
> It is not safe to free an skb from irq context when:
> - The skb has a destructor as some skb destructors call local_bh_disable
>   or spin_lock_bh.
> - There is xfrm state as __xfrm_state_destroy calls spin_lock_bh.
> - There is netfilter conntrack state as destroy_conntrack calls
>   spin_lock_bh.
> - If there is a refcounted dst entry on the skb, as __dst_free
>   calls spin_lock_bh.
> - If there is a frag_list, which could be a list of any skbs.
> Otherwise it appears safe to free a skb from interrupt context.
> 
> - Update the warning in skb_releae_head_state to warn about freeing
>   skb's in the wrong context.
> 
> - Update __dev_kfree_skb_irq to free all skbs that it can immediately
> 
> - Kill zap_completion_queue because there is no point going through
>   a queue of packets that are not safe to free and looking for packets
>   that are safe to free.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Why introduce the additional complexity for so little gain?
It looks like you are only optimizing for the corner case where netpoll
is cleaning up on Tx.

-1
