From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] udp: don't rereference dst_entry dev pointer on rcv
Date: Thu, 14 Mar 2013 02:18:04 +0100
Message-ID: <1363223884.29475.0.camel@edumazet-glaptop>
References: <1362695800-8633-1-git-send-email-tparkin@katalix.com>
	 <1362695800-8633-2-git-send-email-tparkin@katalix.com>
	 <1362696444.15793.220.camel@edumazet-glaptop>
	 <20130307.181527.390191009324148471.davem@davemloft.net>
	 <20130313232743.GA3686@raven>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Parkin <tparkin@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:48072 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755678Ab3CNBSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 21:18:09 -0400
Received: by mail-ea0-f169.google.com with SMTP id z7so712316eaf.14
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 18:18:08 -0700 (PDT)
In-Reply-To: <20130313232743.GA3686@raven>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-13 at 23:27 +0000, Tom Parkin wrote:

> I've been working to this end, and while I don't have a root cause as
> yet, I do have some more information.
> 
> I think what's happening is that the dst_entry refcounting is getting
> screwed up either by the ip defrag code, or by something before that
> in the rcv path.  What I see from ftrace debugging is that an skb
> fragment ends up queued on the reassembly queue while pointing to a
> dst_entry with a refcount of 0.  If the dst_entry should be deleted before
> the final fragment in the frame arrives, then we end up accessing
> free'd memory.
> 
> So far as I can make out, the l2tp code isn't doing anything untoward
> which is causing this bug.  My stress test simply makes it easier to
> reproduce because I'm setting up and tearing down routes and devices
> a lot while passing data.  I'm lucky in that my dev branch seems to
> reproduce this more easily than net-next master does, although the
> same oops occurs on master if you're prepared to wait around for long
> enough.
> 
> This ftrace debug log snippet shows the sort of behaviour I'm seeing.
> The numbers in brackets after some dst pointer values represent the
> refcount for that dst:
> 
> # The dst_entry is created with a refcount of 1
>   <idle>-0     [000] ..s2   112.770192: dst_alloc: dst ffff880012bbb0c0, refcnt 1
> # First fragment is queued
>   <idle>-0     [000] ..s2   112.770193: ip_local_deliver: skb ffff880012864600, dst ffff880012bbb0c0(1) : is fragment
>   <idle>-0     [000] ..s2   112.770206: ip_local_deliver: skb ffff880012864600, dst ffff880012bbb0c0 : fragment queued
> # Second and final fragment arrives, reassemble
>       ip-10970 [000] ..s1   112.770678: ip_local_deliver: skb ffff880010937e00, dst ffff880012bbb0c0(1) : is fragment
> # skb_morph bumps refcount to 2, skb_consume drops it back down to 1
>       ip-10970 [000] ..s2   112.770682: ip_defrag: >>> clone skb ffff880010937e00 with dst ffff880012bbb0c0
>       ip-10970 [000] ..s2   112.770691: __copy_skb_header: don't dst_clone ffff880012bbb0c0
>       ip-10970 [000] ..s2   112.770691: ip_defrag: >>> morph skb ffff880010937e00 from ffff880012864600
>       ip-10970 [000] ..s2   112.770692: skb_release_head_state: drop skb ffff880010937e00 dst ref
>       ip-10970 [000] ..s2   112.770692: __copy_skb_header: cloning dst ffff880012bbb0c0 (skb ffff880012864600 -> skb ffff880010937e00)
>       ip-10970 [000] ..s2   112.770692: ip_defrag: >>> consume skb ffff880012864600
>       ip-10970 [000] ..s2   112.770693: skb_release_head_state: drop skb ffff880012864600 dst ref
>       ip-10970 [000] ..s2   112.770693: dst_release: dst ffff880012bbb0c0 newrefcnt 1
>       ip-10970 [000] ..s2   112.770698: ip_defrag: >>> coalesce loop
>       ip-10970 [000] ..s2   112.770698: ip_defrag: kfree_skb_partial(ffff880010937500, false)
>       ip-10970 [000] ..s2   112.770699: skb_release_head_state: drop skb ffff880010937500 dst ref
> # skb is reassembled and delivered, dst has refcount of 1 now
>       ip-10970 [000] ..s1   112.770705: ip_local_deliver: skb ffff880010937e00, dst ffff880012bbb0c0(1) : queue defragmented
> # l2tp_eth uses dev_forward_skb, which calls skb_dst_drop
>       ip-10970 [000] ..s1   112.770707: skb_release_head_state: drop skb ffff880010937e00 dst ref
>       ip-10970 [000] ..s1   112.770708: dst_release: dst ffff880012bbb0c0 newrefcnt 0
> # Another skb arrives; dst refcount remains at 0
>   <idle>-0     [000] ..s2   112.771481: ip_local_deliver: skb ffff880012864500, dst ffff880012bbb0c0(0) : is fragment
>   <idle>-0     [000] ..s2   112.771494: ip_local_deliver: skb ffff880012864500, dst ffff880012bbb0c0 : fragment queued
> 
> The strange thing is that once the dst refcount reaches zero, another
> skb hitting ip_input doesn't bump the refcount back up.  This is
> partially why I'm not sure whether the error is caused by the defrag
> code, or by something prior to that in the rcv path.

Ah thanks for this, as this definitely makes more sense ;)

Could you try the following fix ?

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index b6d30ac..87f4ecb 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -529,6 +529,7 @@ found:
 	    qp->q.meat == qp->q.len)
 		return ip_frag_reasm(qp, prev, dev);
 
+	skb_dst_force(skb);
 	inet_frag_lru_move(&qp->q);
 	return -EINPROGRESS;
 
