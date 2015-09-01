From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 3/3] ipv6: Fix dst_entry refcnt bugs in ip6_tunnel
Date: Tue, 01 Sep 2015 13:14:20 -0700
Message-ID: <1441138460.8932.182.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1441133703-1570969-1-git-send-email-kafai@fb.com>
	 <1441133703-1570969-4-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33906 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbbIAUOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 16:14:23 -0400
Received: by padhy1 with SMTP id hy1so6322552pad.1
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 13:14:23 -0700 (PDT)
In-Reply-To: <1441133703-1570969-4-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-09-01 at 11:55 -0700, Martin KaFai Lau wrote:
> Problems in the current dst_entry cache in the ip6_tunnel:
> 
> 1. ip6_tnl_dst_set is racy.  There is no lock to protect it:
>    - One major problem is that the dst refcnt gets messed up. F.e.
>      the same dst_cache can be released multiple times and then
>      triggering the infamous dst refcnt < 0 warning message.
>    - Another issue is the inconsistency between dst_cache and
>      dst_cookie.
> 
>    It can be reproduced by adding and removing the ip6gre tunnel
>    while running a super_netperf TCP_CRR test.
> 
> 2. In ip6_tnl_xmit2() and ip6gre_xmit2(), the outgoing skb does
>    not hold a dst_entry's refcnt.

It should not be a problem. refcnt is taken when/if necessary (skb
queued on a qdisc for example)

We have other uses of skb_dst_set_noref()

Please describe the problem ?

> 
> This patch:
> 1. Create a percpu dst_entry cache in ip6_tnl
OK
> 2. Use a spinlock to protect the dst_cache operations

Well, a seqlock would be better : No need for an atomic operation in
fast path.

> 3. The outgoing skb always holds the dst_entry's refcnt
> 

Not clear why it is needed. Inexpensive thanks to per cpu dst, but
still...
