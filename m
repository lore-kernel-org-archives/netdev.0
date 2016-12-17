From: David Miller <davem@davemloft.net>
Subject: Re: ipv6: handle -EFAULT from skb_copy_bits
Date: Sat, 17 Dec 2016 10:41:20 -0500 (EST)
Message-ID: <20161217.104120.945262627572958024.davem@davemloft.net>
References: <20161214154729.g4yg4mxcgkvpe5w7@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@codemonkey.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40644 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752602AbcLQPlW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 10:41:22 -0500
In-Reply-To: <20161214154729.g4yg4mxcgkvpe5w7@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@codemonkey.org.uk>
Date: Wed, 14 Dec 2016 10:47:29 -0500

> It seems to be possible to craft a packet for sendmsg that triggers
> the -EFAULT path in skb_copy_bits resulting in a BUG_ON that looks like:
> 
> RIP: 0010:[<ffffffff817c6390>] [<ffffffff817c6390>] rawv6_sendmsg+0xc30/0xc40
> RSP: 0018:ffff881f6c4a7c18  EFLAGS: 00010282
> RAX: 00000000fffffff2 RBX: ffff881f6c681680 RCX: 0000000000000002
> RDX: ffff881f6c4a7cf8 RSI: 0000000000000030 RDI: ffff881fed0f6a00
> RBP: ffff881f6c4a7da8 R08: 0000000000000000 R09: 0000000000000009
> R10: ffff881fed0f6a00 R11: 0000000000000009 R12: 0000000000000030
> R13: ffff881fed0f6a00 R14: ffff881fee39ba00 R15: ffff881fefa93a80
> 
> Call Trace:
>  [<ffffffff8118ba23>] ? unmap_page_range+0x693/0x830
>  [<ffffffff81772697>] inet_sendmsg+0x67/0xa0
>  [<ffffffff816d93f8>] sock_sendmsg+0x38/0x50
>  [<ffffffff816d982f>] SYSC_sendto+0xef/0x170
>  [<ffffffff816da27e>] SyS_sendto+0xe/0x10
>  [<ffffffff81002910>] do_syscall_64+0x50/0xa0
>  [<ffffffff817f7cbc>] entry_SYSCALL64_slow_path+0x25/0x25
> 
> Handle this in rawv6_push_pending_frames and jump to the failure path.
> 
> Signed-off-by: Dave Jones <davej@codemonkey.org.uk>

Hmmm, that's interesting.  Becaue the code in __ip6_append_data(), which
sets up the ->cork.base.length value, seems to be defensively trying to
avoid this possibility.

For example, it checks things like:

	if (cork->length + length > mtu - headersize && ipc6->dontfrag &&
	    (sk->sk_protocol == IPPROTO_UDP ||
	     sk->sk_protocol == IPPROTO_RAW)) {

This is why the transport offset plus the length should never exceed
the total length for that skb_copy_bits() call.

Perhaps this protocol check in the code above is incomplete?  Do you
know what the sk->sk_protocol value was when that BUG triggered?  That
might shine some light on what is really happening here.

Thanks.
