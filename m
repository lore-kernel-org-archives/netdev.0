From: David Miller <davem@davemloft.net>
Subject: Re: ipv6: handle -EFAULT from skb_copy_bits
Date: Mon, 19 Dec 2016 14:48:48 -0500 (EST)
Message-ID: <20161219.144848.736886978545428136.davem@davemloft.net>
References: <20161214154729.g4yg4mxcgkvpe5w7@codemonkey.org.uk>
        <20161217.104120.945262627572958024.davem@davemloft.net>
        <20161219170320.nnezhql2vj5mrrrp@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@codemonkey.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49838 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752461AbcLSTsz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 14:48:55 -0500
In-Reply-To: <20161219170320.nnezhql2vj5mrrrp@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@codemonkey.org.uk>
Date: Mon, 19 Dec 2016 12:03:20 -0500

> On Sat, Dec 17, 2016 at 10:41:20AM -0500, David Miller wrote:
> 
>  > > It seems to be possible to craft a packet for sendmsg that triggers
>  > > the -EFAULT path in skb_copy_bits resulting in a BUG_ON that looks like:
>  > > 
>  > > RIP: 0010:[<ffffffff817c6390>] [<ffffffff817c6390>] rawv6_sendmsg+0xc30/0xc40
>  > > RSP: 0018:ffff881f6c4a7c18  EFLAGS: 00010282
>  > > RAX: 00000000fffffff2 RBX: ffff881f6c681680 RCX: 0000000000000002
>  > > RDX: ffff881f6c4a7cf8 RSI: 0000000000000030 RDI: ffff881fed0f6a00
>  > > RBP: ffff881f6c4a7da8 R08: 0000000000000000 R09: 0000000000000009
>  > > R10: ffff881fed0f6a00 R11: 0000000000000009 R12: 0000000000000030
>  > > R13: ffff881fed0f6a00 R14: ffff881fee39ba00 R15: ffff881fefa93a80
>  > > 
>  > > Call Trace:
>  > >  [<ffffffff8118ba23>] ? unmap_page_range+0x693/0x830
>  > >  [<ffffffff81772697>] inet_sendmsg+0x67/0xa0
>  > >  [<ffffffff816d93f8>] sock_sendmsg+0x38/0x50
>  > >  [<ffffffff816d982f>] SYSC_sendto+0xef/0x170
>  > >  [<ffffffff816da27e>] SyS_sendto+0xe/0x10
>  > >  [<ffffffff81002910>] do_syscall_64+0x50/0xa0
>  > >  [<ffffffff817f7cbc>] entry_SYSCALL64_slow_path+0x25/0x25
>  > > 
>  > > Handle this in rawv6_push_pending_frames and jump to the failure path.
>  > > 
>  > > Signed-off-by: Dave Jones <davej@codemonkey.org.uk>
>  > 
>  > Hmmm, that's interesting.  Becaue the code in __ip6_append_data(), which
>  > sets up the ->cork.base.length value, seems to be defensively trying to
>  > avoid this possibility.
>  > 
>  > For example, it checks things like:
>  > 
>  > 	if (cork->length + length > mtu - headersize && ipc6->dontfrag &&
>  > 	    (sk->sk_protocol == IPPROTO_UDP ||
>  > 	     sk->sk_protocol == IPPROTO_RAW)) {
>  > 
>  > This is why the transport offset plus the length should never exceed
>  > the total length for that skb_copy_bits() call.
>  > 
>  > Perhaps this protocol check in the code above is incomplete?  Do you
>  > know what the sk->sk_protocol value was when that BUG triggered?  That
>  > might shine some light on what is really happening here.
> 
> Hm.
>   sk_protocol = 7, 

So, some arbitrary value.

Obviously, the test above intends to handle RAW sockets and that is exactly
what we have here.

A raw socket gets whatever the user specified as 'protocol' at create
time as the sk->sk_protocol value.

One thing that's interesting is that if the user picks "IPPROTO_RAW"
as the value of 'protocol' we set inet->hdrincl to 1.

The user can also set inet->hdrincl to 1 or 0 via setsockopt().

I think this is part of the problem.  The test above means to check
for "RAW socket with hdrincl set" and is trying to do this more simply.
But because setsockopt() can set this arbitrarily, testing sk_protocol
alone isn't enough.

So changing:

	sk->sk_protocol == IPPROTO_RAW

into something like:

	(sk->sk_socket->type == SOCK_RAW && inet_sk(sk)->hdrincl)

should correct the test.

That is because this hdrincl thing is what controls which code path we
take in rawv6_sendmsg():

	if (inet->hdrincl)
		err = rawv6_send_hdrinc(sk, msg, len, &fl6, &dst, msg->msg_flags);
	else {
		ipc6.opt = opt;
		lock_sock(sk);
		err = ip6_append_data(sk, raw6_getfrag, &rfv,
			len, 0, &ipc6, &fl6, (struct rt6_info *)dst,
			msg->msg_flags, &sockc);

		if (err)
			ip6_flush_pending_frames(sk);
		else if (!(msg->msg_flags & MSG_MORE))
			err = rawv6_push_pending_frames(sk, &fl6, rp);
		release_sock(sk);
	}

You can test if the change I suggest above works.
