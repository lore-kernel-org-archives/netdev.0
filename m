From: Guy Harris <guy@alum.mit.edu>
Subject: Re: TPACKET_V3 timeout bug?
Date: Tue, 2 May 2017 20:15:38 -0700
Message-ID: <52D4A836-1F12-4DD8-84AB-A6655C577391@alum.mit.edu>
References: <20170415194042.GA5936@lunn.ch>
 <20170415224530.GA21010@oracle.com> <20170416021050.GA16418@lunn.ch>
 <251BA382-D82C-4931-A98F-A23AD88F9811@alum.mit.edu>
 <CAAsGZS5ir2Ha1swhdGCg7ibgYRORZykZcu089=oJ51NT4GKDuA@mail.gmail.com>
 <CAAsGZS4e6XuDxprJUo+ZBY5x0AiWWL4z9Gw7nwe-vcFcrADfzQ@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Andrew Lunn <andrew@lunn.ch>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        netdev <netdev@vger.kernel.org>,
        tcpdump-workers <tcpdump-workers@lists.tcpdump.org>
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from d.mail.sonic.net ([64.142.111.50]:60260 "EHLO d.mail.sonic.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751144AbdECDPw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 23:15:52 -0400
In-Reply-To: <CAAsGZS4e6XuDxprJUo+ZBY5x0AiWWL4z9Gw7nwe-vcFcrADfzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On May 2, 2017, at 10:16 AM, chetan loke <loke.chetan@gmail.com> wrote:

> Commit that caused it:
> 
> https://github.com/torvalds/linux/commit/41a50d621a321b4c15273cc1b5ed41437f4acdfb
> 
> Reverting that change is what we need.

As long as you do *not* revert

	https://github.com/torvalds/linux/commit/da413eec729dae5dcb150e2eb34c5e7e5e4e1b49

"packet: Fixed TPACKET V3 to signal poll when block is closed rather than every packet

Make TPACKET_V3 signal poll when block is closed rather than for every
packet. Side effect is that poll will be signaled when block retire
timer expires which didn't previously happen. Issue was visible when
sending packets at a very low frequency such that all blocks are retired
before packets are received by TPACKET_V3. This caused avoidable packet
loss. The fix ensures that the signal is sent when blocks are closed
which covers the normal path where the block is filled as well as the
path where the timer expires. The case where a block is filled without
moving to the next block (ie. all blocks are full) will still cause poll
to be signaled."

The behavior in the commit message exactly what libpcap (and probably at least some other users of TPACKET_V3) need.  libpcap doesn't care whether empty blocks are passed up (as indicated, "you get woken up when the packet buffer timeout expires" is *not* part of libpcap's contract, and code shouldn't depend on that), so, as long as you preserve the "signal poll when a block is closed, even if it's an empty block" behavior, libpcap will work fine.
