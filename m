From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: ipv6: handle -EFAULT from skb_copy_bits
Date: Sat, 17 Dec 2016 11:43:23 -0500
Message-ID: <20161217164323.zf5w5juhcmhy3tqd@codemonkey.org.uk>
References: <20161214154729.g4yg4mxcgkvpe5w7@codemonkey.org.uk>
 <20161217.104120.945262627572958024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:53634 "EHLO
        arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754228AbcLQQn0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 11:43:26 -0500
Content-Disposition: inline
In-Reply-To: <20161217.104120.945262627572958024.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 17, 2016 at 10:41:20AM -0500, David Miller wrote:
 > From: Dave Jones <davej@codemonkey.org.uk>
 > Date: Wed, 14 Dec 2016 10:47:29 -0500
 > 
 > > It seems to be possible to craft a packet for sendmsg that triggers
 > > the -EFAULT path in skb_copy_bits resulting in a BUG_ON that looks like:
 > > 
 > > RIP: 0010:[<ffffffff817c6390>] [<ffffffff817c6390>] rawv6_sendmsg+0xc30/0xc40
 > > RSP: 0018:ffff881f6c4a7c18  EFLAGS: 00010282
 > > RAX: 00000000fffffff2 RBX: ffff881f6c681680 RCX: 0000000000000002
 > > RDX: ffff881f6c4a7cf8 RSI: 0000000000000030 RDI: ffff881fed0f6a00
 > > RBP: ffff881f6c4a7da8 R08: 0000000000000000 R09: 0000000000000009
 > > R10: ffff881fed0f6a00 R11: 0000000000000009 R12: 0000000000000030
 > > R13: ffff881fed0f6a00 R14: ffff881fee39ba00 R15: ffff881fefa93a80
 > > 
 > > Call Trace:
 > >  [<ffffffff8118ba23>] ? unmap_page_range+0x693/0x830
 > >  [<ffffffff81772697>] inet_sendmsg+0x67/0xa0
 > >  [<ffffffff816d93f8>] sock_sendmsg+0x38/0x50
 > >  [<ffffffff816d982f>] SYSC_sendto+0xef/0x170
 > >  [<ffffffff816da27e>] SyS_sendto+0xe/0x10
 > >  [<ffffffff81002910>] do_syscall_64+0x50/0xa0
 > >  [<ffffffff817f7cbc>] entry_SYSCALL64_slow_path+0x25/0x25
 > > 
 > > Handle this in rawv6_push_pending_frames and jump to the failure path.
 > > 
 > > Signed-off-by: Dave Jones <davej@codemonkey.org.uk>
 > 
 > Hmmm, that's interesting.  Becaue the code in __ip6_append_data(), which
 > sets up the ->cork.base.length value, seems to be defensively trying to
 > avoid this possibility.
 > 
 > For example, it checks things like:
 > 
 > 	if (cork->length + length > mtu - headersize && ipc6->dontfrag &&
 > 	    (sk->sk_protocol == IPPROTO_UDP ||
 > 	     sk->sk_protocol == IPPROTO_RAW)) {
 > 
 > This is why the transport offset plus the length should never exceed
 > the total length for that skb_copy_bits() call.
 > 
 > Perhaps this protocol check in the code above is incomplete?  Do you
 > know what the sk->sk_protocol value was when that BUG triggered?  That
 > might shine some light on what is really happening here.

I'll see if I can craft up a reproducer next week.
For some reason I've not hit this on my test setup at home, but it
reproduces daily in our test setup at facebook.  The only thing
I can think of is that those fb boxes are ipv6 only, so I might be
exercising v4 more at home.

	Dave
