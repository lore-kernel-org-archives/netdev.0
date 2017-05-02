From: Guy Harris <guy@alum.mit.edu>
Subject: Re: TPACKET_V3 timeout bug?
Date: Tue, 2 May 2017 10:54:52 -0700
Message-ID: <C289F9B5-A8DE-45B1-9485-AE322850B462@alum.mit.edu>
References: <20170415194042.GA5936@lunn.ch>
 <20170415224530.GA21010@oracle.com> <20170416021050.GA16418@lunn.ch>
 <251BA382-D82C-4931-A98F-A23AD88F9811@alum.mit.edu>
 <CAAsGZS5ir2Ha1swhdGCg7ibgYRORZykZcu089=oJ51NT4GKDuA@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Andrew Lunn <andrew@lunn.ch>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        netdev <netdev@vger.kernel.org>,
        tcpdump-workers <tcpdump-workers@lists.tcpdump.org>
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c.mail.sonic.net ([64.142.111.80]:32908 "EHLO c.mail.sonic.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750896AbdEBRzE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 13:55:04 -0400
In-Reply-To: <CAAsGZS5ir2Ha1swhdGCg7ibgYRORZykZcu089=oJ51NT4GKDuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On May 2, 2017, at 8:04 AM, chetan loke <loke.chetan@gmail.com> wrote:

> On Sat, Apr 15, 2017 at 7:41 PM, Guy Harris <guy@alum.mit.edu> wrote:
>> On Apr 15, 2017, at 7:10 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>> 
>>> Do you think this is a kernel problem, libpcap problem, or an
>>> application problem?
>> 
> 
> Its clearly a kernel regression.
> 
> If you look at if_packet.h, I have explicitly called out all the cases
> for the return/status codes. When I first merged the functionality in
> 3.11(or 3.12 I think) I had the logic in place to retire the block
> with or without packets in it. I think there was one case where we
> wouldn't wake up userspace. Someone checked in a fix for that. Now I
> am not sure the regression happened as part of that bug fix or
> sometime later. If you diff 3.12 against the latest you will find the
> regression. Look for prb_retire_rx_blk_timer_expired().

Yes, there's a case where user space wasn't being woken up.

As I said in

	https://github.com/the-tcpdump-group/libpcap/issues/335#issuecomment-30280794

It appeared, at the time, that PF_PACKET sockets delivered a wakeup when a packet is put in a buffer block or dropped due to no buffer blocks being empty, but not when a buffer block is handed to userland.

This means that if the kernel's timer expires, and there are no packets in the current buffer block being filled by the kernel, that buffer block will be handed to userland, but userland won't be woken up to tell it to consume that block.

Thus, libpcap will consume that block only if either:

	* a packet is put in a buffer block, meaning it must pass the filter and there must be a current buffer block, belonging to the kernel, into which to put it;
	* a packet arrives and passes the filter, but there are no current buffer blocks belonging to the kernel, so it's dropped;
	* the poll() times out.

So, with a low packet acceptance rate (either because there isn't much network traffic or because there is but most of it is rejected by the packet filter), and with a poll() timeout of -1, meaning "block forever", 1) will happen infrequently, and 3) will never happen. With an in-kernel timeout rate significantly lower than the rate of packet acceptance, the timeout will often occur when there are no packets in the current buffer block, in which case the kernel will hand an empty buffer block to userland and not tell userland about it.

If that happens often enough in sequence to cause all buffer blocks to be handed to userland before any wakeups occur, the kernel now has no buffer blocks into which to put packets, and the next time a packet arrives, it will be dropped, and a wakeup will finally occur. libpcap will drain the ring, handing all buffer blocks to the kernel, but it won't have any packets to process!

So this is ultimately a problem with the TPACKET_V3 code in the kernel. I personally think that it should not deliver empty buffer blocks to userland, and that it also should not deliver a wakeup when a packet is accepted, and should deliver a wakeup whenever a buffer block is handed to userland. I'll report this to somebody and let them decide which of those changes should be done.

If you want to deliver empty buffer blocks to userland, that's fine, but make sure you wake up userland so that it can process those packets rather than leaving them there taking up space in the ring buffer.

And if you insist on delivering a wakeup when a packet is accepted - a wakeup that libpcap, at least, won't do anything with, as there's nothing useful for it to do with that wakeup - also make sure you deliver a wakeup when a buffer block is handed to userland, which is what libpcap cares about.

> I cannot speak on behalf of user-space wrappers developed around
> tpacket_v3 but the intention(from the kernel POV) of the block_timer
> *is* to unblock the capture/user process/thread so that it does NOT
> stay blocked for an indefinite period of time. The header explicitly
> specifies that contract.

That's not part of the contract for libpcap, as it's a question of what the underlying capture mechanism does, and we don't necessarily have any control over that; if a particular capture mechanism used by libpcap has that as part of its contract, that's OK, but libpcap-based applications shouldn't depend on it.
